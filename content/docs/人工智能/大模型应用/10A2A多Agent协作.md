---
title: "A2A 多 Agent 协作通信"
weight: 10
date: 2026-06-18
tags: ["A2A", "Agent-to-Agent", "多Agent", "协作", "分布式AI"]
---

当一个 Agent 无法独自完成所有任务时，需要把工作委托给其他专业 Agent——这就是 A2A（Agent-to-Agent）协议解决的核心问题。A2A 是 Google 于 2025 年 4 月开源、同年 6 月捐献给 Linux 基金会的多 Agent 通信标准，目前已有 150+ 家组织采用。这篇讲清楚 A2A 的架构原理，并实现一个可运行的多 Agent 协作系统。

## A2A vs MCP：两者的关系

这两个协议经常被混淆，实际上它们解决不同层面的问题：

```text
MCP（Model Context Protocol）
  方向：Agent ──► 工具/数据源
  用途：让 Agent 调用文件系统、数据库、API 等外部工具
  类比：Agent 的「手」

A2A（Agent-to-Agent Protocol）
  方向：Agent ──► 另一个 Agent
  用途：Agent 之间发现能力、委托任务、传递上下文
  类比：Agent 之间的「语言」
```

实际生产系统中两者配合使用：Client Agent 通过 A2A 委托任务给 Remote Agent，Remote Agent 用 MCP 工具执行具体操作。

## 核心概念

### Agent Card

每个 A2A 兼容的 Agent 在 `/.well-known/agent.json` 路径下托管一个 Agent Card，用于能力发现：

```json
{
  "name": "财务数据分析师",
  "description": "专注于财务报表分析、趋势预测和异常检测的 AI Agent",
  "version": "1.2.0",
  "url": "https://finance-agent.example.com",
  "capabilities": {
    "streaming": true,
    "pushNotifications": false,
    "stateTransitionHistory": true
  },
  "skills": [
    {
      "id": "analyze-financial-report",
      "name": "财务报表分析",
      "description": "分析损益表、资产负债表和现金流量表，生成结构化分析报告",
      "inputModes": ["text", "file"],
      "outputModes": ["text", "data"]
    },
    {
      "id": "detect-anomalies",
      "name": "财务异常检测",
      "description": "识别财务数据中的异常模式和潜在风险",
      "inputModes": ["data"],
      "outputModes": ["text", "data"]
    }
  ],
  "defaultInputModes": ["text"],
  "defaultOutputModes": ["text"]
}
```

### 任务状态机

A2A 任务有明确的生命周期：

```text
submitted → working → [input-required] → working → completed
                                                  ↘ failed
                                                  ↘ canceled
```

- `submitted`：任务已提交，等待处理
- `working`：Agent 正在处理（可配合 SSE 流式更新）
- `input-required`：Agent 需要用户或调用方补充信息
- `completed`：任务完成，包含 Artifacts（输出产物）

## 用 Python 实现 A2A 服务器

### 基础 A2A 服务端

```python
# a2a_server.py
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse, StreamingResponse
import anthropic
import json
import asyncio

app = FastAPI()
client = anthropic.Anthropic()

# Agent Card（能力声明）
AGENT_CARD = {
    "name": "代码审查 Agent",
    "description": "专业的代码审查 Agent，支持 Python、Go、JavaScript",
    "version": "1.0.0",
    "url": "http://localhost:9000",
    "capabilities": {
        "streaming": True,
        "pushNotifications": False,
    },
    "skills": [
        {
            "id": "review-code",
            "name": "代码审查",
            "description": "审查代码的逻辑、安全性和性能问题",
            "inputModes": ["text"],
            "outputModes": ["text"],
        }
    ],
    "defaultInputModes": ["text"],
    "defaultOutputModes": ["text"],
}

# 内存任务存储（生产环境用 Redis 或数据库）
tasks: dict[str, dict] = {}


@app.get("/.well-known/agent.json")
async def get_agent_card():
    return JSONResponse(AGENT_CARD)


@app.post("/")
async def handle_jsonrpc(request: Request):
    body = await request.json()
    method = body.get("method")
    req_id = body.get("id")
    params = body.get("params", {})

    if method == "message/send":
        return await handle_message_send(req_id, params)
    elif method == "tasks/get":
        return await handle_tasks_get(req_id, params)
    elif method == "tasks/cancel":
        return await handle_tasks_cancel(req_id, params)
    else:
        return JSONResponse({
            "jsonrpc": "2.0",
            "id": req_id,
            "error": {"code": -32601, "message": f"Method not found: {method}"}
        })


async def handle_message_send(req_id: str, params: dict):
    message = params.get("message", {})
    task_id = message.get("taskId") or f"task-{req_id}"

    # 提取用户文本
    user_text = ""
    for part in message.get("parts", []):
        if part.get("type") == "text":
            user_text += part["text"]

    # 创建任务记录
    tasks[task_id] = {
        "id": task_id,
        "status": {"state": "working"},
        "artifacts": [],
    }

    # 调用 LLM 执行审查
    asyncio.create_task(process_code_review(task_id, user_text))

    return JSONResponse({
        "jsonrpc": "2.0",
        "id": req_id,
        "result": tasks[task_id],
    })


async def process_code_review(task_id: str, code: str):
    """异步执行代码审查"""
    resp = client.messages.create(
        model="claude-opus-4-8",
        max_tokens=2048,
        system=(
            "你是专业代码审查专家。审查代码时只指出真正的问题：逻辑错误、安全漏洞、性能陷阱。"
            "输出格式：每条问题一行，格式为 '严重度[高/中/低] 行号: 问题 → 建议'"
        ),
        messages=[{"role": "user", "content": f"请审查以下代码：\n\n{code}"}],
    )

    result_text = resp.content[0].text
    tasks[task_id]["status"] = {"state": "completed"}
    tasks[task_id]["artifacts"] = [{
        "type": "text",
        "mimeType": "text/plain",
        "data": result_text,
    }]


async def handle_tasks_get(req_id: str, params: dict):
    task_id = params.get("id")
    task = tasks.get(task_id)
    if not task:
        return JSONResponse({
            "jsonrpc": "2.0", "id": req_id,
            "error": {"code": -32001, "message": "Task not found"}
        })
    return JSONResponse({"jsonrpc": "2.0", "id": req_id, "result": task})


async def handle_tasks_cancel(req_id: str, params: dict):
    task_id = params.get("id")
    if task_id in tasks:
        tasks[task_id]["status"] = {"state": "canceled"}
    return JSONResponse({"jsonrpc": "2.0", "id": req_id, "result": {"id": task_id}})
```

启动服务器：

```bash
uvicorn a2a_server:app --host 0.0.0.0 --port 9000
```

### A2A 客户端（调用方 Agent）

```python
# a2a_client.py
import httpx
import asyncio
import json


class A2AClient:
    def __init__(self, agent_url: str):
        self.base_url = agent_url.rstrip("/")

    async def get_agent_card(self) -> dict:
        async with httpx.AsyncClient() as client:
            resp = await client.get(f"{self.base_url}/.well-known/agent.json")
            return resp.json()

    async def send_message(self, text: str, task_id: str = None) -> dict:
        payload = {
            "jsonrpc": "2.0",
            "id": "req-001",
            "method": "message/send",
            "params": {
                "message": {
                    "taskId": task_id,
                    "parts": [{"type": "text", "text": text}],
                }
            }
        }
        async with httpx.AsyncClient() as client:
            resp = await client.post(self.base_url, json=payload)
            return resp.json()

    async def wait_for_completion(self, task_id: str, poll_interval: float = 0.5) -> dict:
        """轮询任务状态直到完成"""
        while True:
            payload = {
                "jsonrpc": "2.0",
                "id": "req-poll",
                "method": "tasks/get",
                "params": {"id": task_id}
            }
            async with httpx.AsyncClient() as client:
                resp = await client.post(self.base_url, json=payload)
                result = resp.json().get("result", {})

            state = result.get("status", {}).get("state")
            if state in ("completed", "failed", "canceled"):
                return result

            await asyncio.sleep(poll_interval)


async def main():
    client = A2AClient("http://localhost:9000")

    # 1. 发现 Agent 能力
    card = await client.get_agent_card()
    print(f"Agent: {card['name']}")
    print(f"技能: {[s['name'] for s in card['skills']]}\n")

    # 2. 提交代码审查任务
    code = """
def process_user_input(user_id, query):
    sql = f"SELECT * FROM users WHERE id = {user_id} AND search = '{query}'"
    return db.execute(sql)
    """
    result = await client.send_message(f"请审查以下代码：\n{code}")
    task_id = result["result"]["id"]
    print(f"任务已提交，ID: {task_id}")

    # 3. 等待结果
    final = await client.wait_for_completion(task_id)
    print("\n审查结果：")
    for artifact in final.get("artifacts", []):
        print(artifact.get("data", ""))


asyncio.run(main())
```

## 多 Agent 编排模式

### 模式一：主从委托

一个 Orchestrator Agent 分解任务，委托给多个专业 Agent：

```python
async def orchestrate_research(topic: str) -> str:
    """研究助手：协调多个专业 Agent 完成综合研究"""

    # 1. 并发委托给不同专业 Agent
    search_agent = A2AClient("http://search-agent:9001")
    analysis_agent = A2AClient("http://analysis-agent:9002")
    writing_agent = A2AClient("http://writing-agent:9003")

    # 并发提交任务
    search_task, analysis_task = await asyncio.gather(
        search_agent.send_message(f"搜索关于 {topic} 的最新信息"),
        analysis_agent.send_message(f"分析 {topic} 的市场趋势"),
    )

    # 等待两个任务完成
    search_result, analysis_result = await asyncio.gather(
        search_agent.wait_for_completion(search_task["result"]["id"]),
        analysis_agent.wait_for_completion(analysis_task["result"]["id"]),
    )

    # 2. 汇总结果，委托写作 Agent 生成报告
    combined = (
        f"搜索结果：\n{search_result['artifacts'][0]['data']}\n\n"
        f"分析结论：\n{analysis_result['artifacts'][0]['data']}"
    )
    writing_task = await writing_agent.send_message(
        f"基于以下信息，撰写关于 {topic} 的 500 字研究报告：\n{combined}"
    )
    final = await writing_agent.wait_for_completion(writing_task["result"]["id"])
    return final["artifacts"][0]["data"]
```

### 模式二：流水线（Pipeline）

任务按顺序通过多个 Agent 处理，前一个的输出是后一个的输入：

```python
async def data_pipeline(raw_data: str) -> str:
    """数据处理流水线：清洗 → 分析 → 可视化描述"""

    agents = [
        ("数据清洗 Agent", A2AClient("http://cleaner:9001")),
        ("数据分析 Agent", A2AClient("http://analyst:9002")),
        ("报告生成 Agent", A2AClient("http://reporter:9003")),
    ]

    current_data = raw_data
    for name, agent in agents:
        print(f"[{name}] 处理中...")
        task = await agent.send_message(current_data)
        result = await agent.wait_for_completion(task["result"]["id"])

        if result["status"]["state"] != "completed":
            raise RuntimeError(f"{name} 处理失败")

        current_data = result["artifacts"][0]["data"]

    return current_data
```

### 模式三：动态发现

Agent 不硬编码下游 URL，而是从注册中心动态发现能力匹配的 Agent：

```python
class AgentRegistry:
    """Agent 能力注册中心"""
    def __init__(self):
        self._agents: list[dict] = []

    async def register(self, agent_url: str):
        client = A2AClient(agent_url)
        card = await client.get_agent_card()
        self._agents.append({"url": agent_url, "card": card})

    def find_by_skill(self, skill_description: str) -> list[str]:
        """根据技能描述找到最匹配的 Agent"""
        matches = []
        for agent in self._agents:
            for skill in agent["card"].get("skills", []):
                if any(kw in skill["description"]
                       for kw in skill_description.split()):
                    matches.append(agent["url"])
                    break
        return matches


# 使用
registry = AgentRegistry()
await registry.register("http://finance-agent:9001")
await registry.register("http://code-agent:9002")
await registry.register("http://data-agent:9003")

# 动态找到能分析财务数据的 Agent
agents = registry.find_by_skill("财务 分析")
```

## 上下文传递与状态共享

Agent 之间需要传递上下文时，A2A 通过消息的 `contextId` 实现会话关联：

```python
async def multi_turn_collaboration(context_id: str):
    """在同一上下文 ID 下进行多轮协作"""
    agent = A2AClient("http://research-agent:9000")

    # 第一轮：提出问题
    r1 = await agent.send_message(
        "分析 2025 年中国 AI 市场规模",
        # contextId 保证同一会话
    )
    result1 = await agent.wait_for_completion(r1["result"]["id"])

    # 第二轮：基于第一轮追问（Agent 保有上下文）
    r2 = await agent.send_message(
        "其中大模型推理市场占多大比例？和上一轮分析保持一致的口径",
    )
    result2 = await agent.wait_for_completion(r2["result"]["id"])
    return result2["artifacts"][0]["data"]
```

## 安全与认证

生产环境的 A2A 通信必须加认证，避免未授权 Agent 接入：

```python
# 服务端：验证 Bearer Token
from fastapi import HTTPException, Header

async def verify_token(authorization: str = Header(...)):
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid token format")
    token = authorization[7:]
    if not is_valid_token(token):
        raise HTTPException(status_code=403, detail="Unauthorized")


# 客户端：发送 Token
async def send_authenticated_message(self, text: str, token: str) -> dict:
    headers = {"Authorization": f"Bearer {token}"}
    async with httpx.AsyncClient() as client:
        resp = await client.post(self.base_url, json=payload, headers=headers)
        return resp.json()
```

## A2A 与 MCP 的完整协作架构

```text
用户
  │
  ▼
Orchestrator Agent（主协调）
  │  A2A                        A2A
  ├──────────────┐  ┌──────────────────────────┐
  │              │  │                          │
  ▼              ▼  ▼                          ▼
RAG Agent    Code Review Agent         Data Agent
  │                │                      │
  │ MCP            │ MCP                  │ MCP
  ▼                ▼                      ▼
向量数据库       GitHub API            数据仓库
```

- **Orchestrator** 通过 A2A 委托任务给专业 Agent
- 每个专业 Agent 通过 MCP 使用自己的工具
- Agent 之间不直接共享工具权限，保持最小权限原则

## 协议对比：A2A、MCP、ACP

| 特性 | A2A | MCP | ACP（已并入 A2A） |
| --- | --- | --- | --- |
| 发起方 | Google | Anthropic | IBM |
| 对象 | Agent ↔ Agent | Agent → 工具 | Agent ↔ Agent |
| 传输 | HTTP + SSE | Stdio / HTTP | HTTP |
| 状态 | Linux 基金会 | Linux 基金会 | 已合并进 A2A |
| 采用率 | 150+ 组织 | 200+ 服务器 | - |

推荐组合：**MCP 管工具接入 + A2A 管 Agent 协作**，这是目前业界最主流的多 Agent 基础设施方案。
