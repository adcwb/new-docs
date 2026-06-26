---
title: "Skills 与插件开发"
weight: 9
date: 2026-06-18
tags: ["Skills", "Plugin", "Tool Use", "工具注册", "LLM插件"]
---

Skills（技能）和 Plugin（插件）是同一概念的两种叫法：给 LLM 注册一个「可调用的外部能力」，让它在需要时自主决定是否调用、传什么参数。这篇从架构设计到生产级实现，完整讲清楚如何构建健壮的 LLM 插件体系。

## 插件的本质

插件 = **一段代码** + **一份精确的描述**。LLM 根据描述决定「要不要用这个工具」，根据 JSON Schema 决定「传什么参数」。代码部分由你控制——LLM 永远不会直接执行你的代码，它只负责「建议调用」。

```text
LLM 的视角：
  我有 [get_weather, search_db, send_email] 三个工具
  用户问：明天北京天气怎样，要不要带伞？
  → 调用 get_weather(city="北京", forecast_days=2)
  → 基于返回值给出回答

你的代码视角：
  检测到 stop_reason == "tool_use"
  → 执行实际函数
  → 把结果传回 LLM
```

## 工具描述的重要性

工具描述直接决定 LLM 能否正确调用工具。这是最常被忽视却最影响效果的地方。

{{< tabs >}}

{{< tab name="差描述" >}}
```python
{
    "name": "search",
    "description": "搜索信息",
    "input_schema": {
        "type": "object",
        "properties": {
            "query": {"type": "string"}
        }
    }
}
```
问题：什么信息？什么时候用？返回什么格式？
{{< /tab >}}

{{< tab name="好描述" >}}
```python
{
    "name": "search_knowledge_base",
    "description": (
        "在公司内部知识库中搜索技术文档、FAQ 和操作手册。"
        "当用户询问内部流程、系统操作、技术规范时使用。"
        "不适用于查询实时数据或外部互联网信息。"
        "返回最相关的 3-5 个文档片段，包含来源和相关度分数。"
    ),
    "input_schema": {
        "type": "object",
        "properties": {
            "query": {
                "type": "string",
                "description": "搜索关键词或问题描述，建议使用自然语言"
            },
            "category": {
                "type": "string",
                "enum": ["技术文档", "FAQ", "操作手册", "全部"],
                "description": "限定搜索范围，默认为'全部'"
            }
        },
        "required": ["query"]
    }
}
```
{{< /tab >}}

{{< /tabs >}}

## 构建工具注册系统

生产环境中工具往往有几十上百个，需要一个统一的注册和管理机制。

```python
# tool_registry.py
import inspect
import json
from typing import Callable, Any
from dataclasses import dataclass, field


@dataclass
class ToolDefinition:
    name: str
    description: str
    input_schema: dict
    handler: Callable
    requires_confirmation: bool = False  # 危险操作需要用户确认


class ToolRegistry:
    def __init__(self):
        self._tools: dict[str, ToolDefinition] = {}

    def register(
        self,
        description: str,
        requires_confirmation: bool = False,
    ):
        """装饰器：将函数注册为工具"""
        def decorator(func: Callable):
            schema = self._build_schema(func)
            self._tools[func.__name__] = ToolDefinition(
                name=func.__name__,
                description=description,
                input_schema=schema,
                handler=func,
                requires_confirmation=requires_confirmation,
            )
            return func
        return decorator

    def _build_schema(self, func: Callable) -> dict:
        """从函数签名自动生成 JSON Schema"""
        hints = func.__annotations__
        sig = inspect.signature(func)
        properties = {}
        required = []

        for name, param in sig.parameters.items():
            if name == "return":
                continue
            type_map = {str: "string", int: "integer", float: "number", bool: "boolean"}
            prop_type = type_map.get(hints.get(name, str), "string")
            doc = (func.__doc__ or "").split("\n")
            prop_desc = next(
                (l.strip().split(":", 1)[-1].strip() for l in doc if name + ":" in l),
                ""
            )
            properties[name] = {"type": prop_type, "description": prop_desc}
            if param.default is inspect.Parameter.empty:
                required.append(name)

        return {
            "type": "object",
            "properties": properties,
            "required": required,
        }

    def get_tools_for_api(self) -> list[dict]:
        """返回适用于 Claude API 的工具定义列表"""
        return [
            {
                "name": tool.name,
                "description": tool.description,
                "input_schema": tool.input_schema,
            }
            for tool in self._tools.values()
        ]

    def execute(self, name: str, inputs: dict) -> Any:
        if name not in self._tools:
            raise ValueError(f"工具不存在: {name}")
        return self._tools[name].handler(**inputs)

    def needs_confirmation(self, name: str) -> bool:
        return self._tools.get(name, ToolDefinition("", "", {}, lambda: None)).requires_confirmation
```

### 使用注册器

```python
# tools/builtin.py
import datetime
import registry from tool_registry

reg = ToolRegistry()


@reg.register(
    description="获取当前日期和时间，用于回答'今天几号''现在几点'等时间相关问题"
)
def get_current_datetime() -> str:
    return datetime.datetime.now().isoformat()


@reg.register(
    description=(
        "在公司订单数据库中查询订单信息。"
        "需要提供订单号（order_id）。"
        "返回订单状态、金额、收货地址等详情。"
    )
)
def get_order_info(order_id: str) -> dict:
    """
    order_id: 订单号，格式为 ORD-XXXXXXXX
    """
    # 实际项目中替换为真实数据库查询
    return {
        "order_id": order_id,
        "status": "已发货",
        "amount": 299.00,
        "tracking": "SF1234567890",
    }


@reg.register(
    description="向用户发送短信通知。仅在用户明确要求发送通知时使用。",
    requires_confirmation=True,  # 标记为需要确认的危险操作
)
def send_sms(phone: str, message: str) -> str:
    """
    phone: 手机号，11位数字
    message: 短信内容，不超过70字
    """
    # 实际项目接短信服务商 API
    return f"短信已发送至 {phone}"
```

## 完整 Agent 执行流程

```python
# agent.py
import anthropic

client = anthropic.Anthropic()


def run_agent(user_message: str, max_turns: int = 10) -> str:
    messages = [{"role": "user", "content": user_message}]
    tools = reg.get_tools_for_api()

    for turn in range(max_turns):
        response = client.messages.create(
            model="claude-opus-4-8",
            max_tokens=2048,
            tools=tools,
            messages=messages,
        )

        if response.stop_reason == "end_turn":
            return next(b.text for b in response.content if b.type == "text")

        if response.stop_reason == "tool_use":
            messages.append({"role": "assistant", "content": response.content})
            tool_results = []

            for block in response.content:
                if block.type != "tool_use":
                    continue

                # 需要确认的操作，询问用户
                if reg.needs_confirmation(block.name):
                    confirm = input(
                        f"[确认] 即将执行 {block.name}，参数：{block.input}。是否继续？(y/n) "
                    )
                    if confirm.lower() != "y":
                        result = "用户取消了此操作"
                    else:
                        result = reg.execute(block.name, block.input)
                else:
                    try:
                        result = reg.execute(block.name, block.input)
                    except Exception as e:
                        result = f"工具执行失败: {e}"

                tool_results.append({
                    "type": "tool_result",
                    "tool_use_id": block.id,
                    "content": str(result),
                })

            messages.append({"role": "user", "content": tool_results})

    return "已达到最大执行步数，任务未完成。"
```

## 并行工具调用

Claude 支持在一次响应中请求多个工具，应当**并发执行**以降低延迟：

```python
import asyncio

async def execute_tools_parallel(tool_calls: list) -> list[dict]:
    async def call_one(block):
        loop = asyncio.get_event_loop()
        # 在线程池中执行同步函数
        result = await loop.run_in_executor(
            None, reg.execute, block.name, block.input
        )
        return {
            "type": "tool_result",
            "tool_use_id": block.id,
            "content": str(result),
        }

    return await asyncio.gather(*[call_one(b) for b in tool_calls])
```

## 工具安全设计

{{< callout type="warning" >}}
工具是 LLM 和真实系统之间的桥梁，安全问题比普通 API 更复杂：
{{< /callout >}}

**防提示注入**：工具返回值可能包含恶意指令，要对外部数据做标记：

```python
def safe_tool_result(raw_result: str) -> str:
    """把工具返回值包在标签里，防止被当作指令执行"""
    return f"<tool_output>{raw_result}</tool_output>"
```

**参数校验**：不要信任 LLM 生成的参数：

```python
import re

def validate_order_id(order_id: str) -> str:
    if not re.match(r"^ORD-[A-Z0-9]{8}$", order_id):
        raise ValueError(f"无效的订单号格式: {order_id}")
    return order_id
```

**权限沙箱**：每个工具只拥有完成它职责所需的最小权限（数据库只读账户、只写入特定目录等）。

## 工具搜索（大规模工具集）

当工具超过 20 个，全部放在 `tools` 参数里会占用大量 token 并干扰选择。可以先让模型「搜索」需要的工具：

```python
ALL_TOOLS = reg.get_tools_for_api()

# 先用一个小模型从工具库中选出本次需要的工具子集
def select_relevant_tools(user_message: str, top_k: int = 5) -> list[dict]:
    resp = client.messages.create(
        model="claude-haiku-4-5-20251001",
        max_tokens=200,
        messages=[{
            "role": "user",
            "content": (
                f"以下是可用工具列表（仅名称和简介）：\n"
                + "\n".join(f"- {t['name']}: {t['description'][:50]}" for t in ALL_TOOLS)
                + f"\n\n用户请求：{user_message}\n\n"
                + f"请列出最可能需要的 {top_k} 个工具名称，每行一个，不要解释。"
            )
        }]
    )
    selected_names = set(resp.content[0].text.strip().split("\n"))
    return [t for t in ALL_TOOLS if t["name"] in selected_names]
```

## 插件版本管理

生产环境中工具会不断迭代，需要管理版本兼容性：

```python
@reg.register(
    description="查询产品库存（v2：支持多仓库查询）",
)
def check_inventory_v2(product_id: str, warehouse: str = "all") -> dict:
    """
    product_id: 产品 SKU
    warehouse: 仓库代码，传 'all' 查询所有仓库合计
    """
    ...
```

建议保留旧版工具 1–2 个版本，在描述里注明「推荐使用 v2」，待流量全切换后再下线旧版。
