---
title: "MCP 服务器开发"
weight: 8
date: 2026-06-18
tags: ["MCP", "Model Context Protocol", "FastMCP", "工具开发"]
---

MCP（Model Context Protocol，模型上下文协议）是 Anthropic 在 2024 年底发布、2025 年底捐献给 Linux 基金会的开放标准。它定义了 AI 应用与外部数据源/工具之间通信的统一接口——相当于 AI 世界的「USB-C」。这篇讲清楚 MCP 的架构原理，并用 FastMCP 从零实现一个可用的 MCP 服务器。

## 为什么需要 MCP

在 MCP 之前，让 LLM 应用接入外部工具要为每个应用单独写集成代码：Claude Desktop 一套、VS Code 一套、自己的应用又一套。MCP 用统一的协议解决这个重复问题：

```text
之前：
  Claude Desktop ──自定义代码──► 你的数据库
  VS Code        ──自定义代码──► 你的数据库
  自研应用       ──自定义代码──► 你的数据库

MCP 之后：
  Claude Desktop ┐
  VS Code        ├──── MCP ──► 你的 MCP 服务器 ──► 你的数据库
  自研应用       ┘
```

写一个 MCP 服务器，所有支持 MCP 的客户端（Claude Desktop、Cursor、Cline 等 200+ 工具）都能直接用。

## 核心概念

MCP 服务器对外暴露三种原语：

| 原语 | 类比 | 用途 |
| --- | --- | --- |
| **Tools（工具）** | POST 请求 | LLM 可调用的函数，有副作用（写数据、发消息） |
| **Resources（资源）** | GET 请求 | 只读数据，LLM 可读取（文件、数据库记录） |
| **Prompts（提示模板）** | 代码片段 | 预定义的交互模板，引导用户完成特定任务 |

传输层：
- **Stdio**：本地进程通信，适合命令行工具
- **Streamable HTTP**（推荐远程）：HTTP + SSE，2025-03 版规范的推荐远程方式

## 快速开始：用 FastMCP 构建

FastMCP 是目前最流行的 Python MCP 服务器框架（FastMCP 3.0 于 2026 年 1 月发布），一个装饰器即可暴露工具。

**安装**：

```bash
pip install fastmcp
```

### 基础示例：天气查询服务器

```python
# weather_server.py
import httpx
from fastmcp import FastMCP

mcp = FastMCP("天气查询服务")


@mcp.tool()
def get_weather(city: str, unit: str = "celsius") -> dict:
    """
    获取指定城市的当前天气。

    Args:
        city: 城市名称，如"北京"、"上海"
        unit: 温度单位，celsius（摄氏）或 fahrenheit（华氏）
    """
    # 实际项目中换成真实天气 API
    mock_data = {
        "北京": {"temp": 28, "condition": "晴", "humidity": 45},
        "上海": {"temp": 32, "condition": "多云", "humidity": 72},
    }
    data = mock_data.get(city, {"temp": 25, "condition": "未知", "humidity": 60})

    temp = data["temp"]
    if unit == "fahrenheit":
        temp = temp * 9 / 5 + 32

    return {
        "city": city,
        "temperature": f"{temp}{'°F' if unit == 'fahrenheit' else '°C'}",
        "condition": data["condition"],
        "humidity": f"{data['humidity']}%",
    }


@mcp.tool()
def get_forecast(city: str, days: int = 3) -> list[dict]:
    """
    获取城市未来 N 天的天气预报（最多 7 天）。

    Args:
        city: 城市名称
        days: 预报天数，1-7
    """
    days = min(days, 7)
    return [
        {"date": f"第{i+1}天", "city": city, "condition": "晴转多云", "high": 30, "low": 22}
        for i in range(days)
    ]


if __name__ == "__main__":
    mcp.run()  # 默认使用 stdio 传输
```

### 添加 Resources（资源）

```python
@mcp.resource("weather://cities/supported")
def get_supported_cities() -> str:
    """返回支持查询的城市列表"""
    cities = ["北京", "上海", "广州", "深圳", "成都", "杭州"]
    return "\n".join(cities)


@mcp.resource("weather://history/{city}")
def get_weather_history(city: str) -> str:
    """获取城市的历史天气数据"""
    return f"{city} 近 30 天平均气温：26°C，降水量：45mm"
```

### 添加 Prompts（提示模板）

```python
from fastmcp import Context

@mcp.prompt()
def weather_report_prompt(city: str, include_forecast: bool = True) -> str:
    """生成天气播报提示模板"""
    base = f"请为 {city} 生成一份简洁的天气播报，包含当前温度、天气状况和湿度。"
    if include_forecast:
        base += "同时附上未来 3 天的天气预报摘要。"
    base += "语气自然，适合口播，不超过 100 字。"
    return base
```

## 完整示例：数据库查询 MCP 服务器

一个更实用的例子——让 LLM 查询 SQLite 数据库：

```python
# db_server.py
import sqlite3
from pathlib import Path
from fastmcp import FastMCP

mcp = FastMCP("数据库助手", instructions="提供 SQLite 数据库的查询能力，只允许 SELECT 操作")
DB_PATH = Path("data.db")


@mcp.resource("db://schema")
def get_schema() -> str:
    """获取数据库所有表的结构"""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
    tables = [row[0] for row in cursor.fetchall()]

    schema_parts = []
    for table in tables:
        cursor.execute(f"PRAGMA table_info({table})")
        columns = cursor.fetchall()
        cols_desc = ", ".join(f"{col[1]} {col[2]}" for col in columns)
        schema_parts.append(f"表 {table}：{cols_desc}")

    conn.close()
    return "\n".join(schema_parts)


@mcp.tool()
def query_database(sql: str) -> list[dict]:
    """
    执行 SELECT 查询并返回结果。

    Args:
        sql: 标准 SQL SELECT 语句
    """
    # 安全检查：只允许 SELECT
    sql_stripped = sql.strip().upper()
    if not sql_stripped.startswith("SELECT"):
        raise ValueError("只允许 SELECT 查询，禁止数据修改操作")

    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute(sql)
    rows = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return rows


@mcp.tool()
def list_tables() -> list[str]:
    """列出数据库中的所有表名"""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
    tables = [row[0] for row in cursor.fetchall()]
    conn.close()
    return tables
```

## 部署为远程服务器（HTTP）

本地工具用 stdio，需要多用户共享或部署到云端时用 HTTP：

```python
# 启动为 HTTP 服务（Streamable HTTP 传输）
if __name__ == "__main__":
    mcp.run(transport="streamable-http", host="0.0.0.0", port=8080)
```

启动后 MCP 端点地址为 `http://localhost:8080/mcp`。

## 在 Claude Desktop 中配置

```json
// ~/Library/Application Support/Claude/claude_desktop_config.json（macOS）
// %APPDATA%\Claude\claude_desktop_config.json（Windows）
{
  "mcpServers": {
    "weather": {
      "command": "python",
      "args": ["/path/to/weather_server.py"]
    },
    "database": {
      "command": "python",
      "args": ["/path/to/db_server.py"],
      "env": {
        "DB_PATH": "/path/to/data.db"
      }
    }
  }
}
```

## 在 Python 代码中直接使用 MCP 服务器

不只是 Claude Desktop，自己的代码也可以连接 MCP 服务器：

```python
from fastmcp import Client
import asyncio

async def main():
    async with Client("weather_server.py") as client:
        # 列出可用工具
        tools = await client.list_tools()
        print("可用工具：", [t.name for t in tools])

        # 调用工具
        result = await client.call_tool("get_weather", {"city": "北京"})
        print("天气：", result)

        # 读取资源
        cities = await client.read_resource("weather://cities/supported")
        print("支持城市：", cities)

asyncio.run(main())
```

## 调试技巧

**MCP Inspector**（官方调试工具）：

```bash
npx @modelcontextprotocol/inspector python weather_server.py
```

浏览器打开 `http://localhost:6274`，可以可视化地测试所有工具、资源和提示模板。

{{< callout type="tip" >}}
开发阶段优先用 MCP Inspector 测试，能快速发现工具描述不清晰、参数类型错误等问题，不用每次都通过 Claude Desktop 验证。
{{< /callout >}}

## 安全注意事项

{{< callout type="warning" >}}
MCP 服务器拥有你授予它的所有权限。以下几点必须遵守：
- **工具描述中不得包含用户可控内容**（防提示注入）
- **写操作工具要做权限校验**，不要默认允许所有操作
- **不要在工具里暴露数据库连接字符串、API Key**（通过环境变量注入）
- **对 SQL 等动态语句做严格校验**，防止注入攻击
{{< /callout >}}

## 生态现状

截至 2026 年中，MCP 生态已包含 200+ 开源服务器实现，涵盖：

- 开发工具：GitHub、GitLab、Jira、Linear
- 数据库：PostgreSQL、MySQL、MongoDB、Redis
- 文件系统：本地文件、Google Drive、Notion
- 通信：Slack、Email、Discord
- 监控：Grafana、DataDog、Prometheus

可在 [mcp.so](https://mcp.so) 和 GitHub 上的 `awesome-mcp-servers` 仓库找到完整列表。
