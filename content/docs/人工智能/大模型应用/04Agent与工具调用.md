---
title: "Agent 与工具调用"
weight: 4
date: 2026-06-16
tags: ["LLM", "Agent", "Tool Use", "Claude"]
---

让 LLM 接入真实工具——查数据库、调外部 API、执行代码——这就是 Agent 的核心。这篇讲清楚工具调用（Tool Use / Function Calling）的机制，并用 Claude API 实现一个可跑通的多工具 Agent。

## 什么是 Agent

传统 LLM 调用是「一问一答」，输入进去、答案出来、流程结束。**Agent** 则不同：模型能决定「我需要先查一下数据，再推理，再调用工具，最后给出答案」，自主编排多步骤操作。

Agent = **模型** + **工具（Tools）** + **执行循环**：

```text
用户问题
   ↓
模型决策：
  直接回答？→ 输出答案，结束
  需要工具？→ 输出「调用工具 X，参数 Y」
              ↓
           宿主代码实际执行工具，把结果返还给模型
              ↓
           模型基于工具结果继续决策（可能再调其他工具）
              ↓
           直到模型认为可以回答，输出最终答案
```

这个循环完全由宿主代码驱动，模型负责「思考下一步」，代码负责「实际执行」。

## 工具调用机制

在调用 API 时，把可用工具描述以 JSON Schema 形式传给模型。模型如果需要用工具，会在响应里返回一个 `tool_use` 内容块（而不是直接回答），告诉你「我要调用哪个工具、传什么参数」。你执行完工具，把结果作为 `tool_result` 塞回消息列表，模型继续处理。

整个过程 **HTTP 层完全透明**，Claude API 不自动执行工具——执行权始终在你的代码里。

## 实现多工具 Agent

下面实现一个能「查当前时间」和「做单位换算」的 Agent：

```python
import json
import datetime
from anthropic import Anthropic

client = Anthropic()

# 1. 定义工具（用 JSON Schema 描述参数）
tools = [
    {
        "name": "get_current_time",
        "description": "返回当前的本地时间（ISO 格式）",
        "input_schema": {
            "type": "object",
            "properties": {},
            "required": [],
        },
    },
    {
        "name": "convert_units",
        "description": "在不同单位之间做数值换算，支持长度、重量、温度",
        "input_schema": {
            "type": "object",
            "properties": {
                "value":      {"type": "number",  "description": "要换算的数值"},
                "from_unit":  {"type": "string",  "description": "原单位，如 km、kg、celsius"},
                "to_unit":    {"type": "string",  "description": "目标单位，如 mile、lb、fahrenheit"},
            },
            "required": ["value", "from_unit", "to_unit"],
        },
    },
]


# 2. 工具的实际实现
def get_current_time() -> str:
    return datetime.datetime.now().isoformat()


def convert_units(value: float, from_unit: str, to_unit: str) -> str:
    table = {
        ("km", "mile"):         value * 0.621371,
        ("mile", "km"):         value * 1.60934,
        ("kg", "lb"):           value * 2.20462,
        ("lb", "kg"):           value / 2.20462,
        ("celsius", "fahrenheit"): value * 9 / 5 + 32,
        ("fahrenheit", "celsius"): (value - 32) * 5 / 9,
    }
    result = table.get((from_unit, to_unit))
    if result is None:
        return f"不支持 {from_unit} → {to_unit} 的换算"
    return f"{value} {from_unit} = {result:.4f} {to_unit}"


def run_tool(name: str, inputs: dict) -> str:
    if name == "get_current_time":
        return get_current_time()
    if name == "convert_units":
        return convert_units(**inputs)
    return f"未知工具: {name}"


# 3. Agent 执行循环
def agent(user_message: str) -> str:
    messages = [{"role": "user", "content": user_message}]

    while True:
        response = client.messages.create(
            model="claude-opus-4-8",
            max_tokens=1024,
            tools=tools,
            messages=messages,
        )

        # 模型决定直接回答，循环结束
        if response.stop_reason == "end_turn":
            return next(b.text for b in response.content if b.type == "text")

        # 模型请求工具调用
        if response.stop_reason == "tool_use":
            # 先把模型的响应（含 tool_use 块）追加进消息历史
            messages.append({"role": "assistant", "content": response.content})

            # 依次执行所有工具请求，收集结果
            tool_results = []
            for block in response.content:
                if block.type == "tool_use":
                    result = run_tool(block.name, block.input)
                    tool_results.append({
                        "type":        "tool_result",
                        "tool_use_id": block.id,
                        "content":     result,
                    })

            # 把工具结果作为 user 消息回传，让模型继续
            messages.append({"role": "user", "content": tool_results})


# 测试
print(agent("现在几点了？另外帮我把 100 摄氏度换算成华氏度。"))
```

## 关键要点

**消息结构**：工具调用产生一轮额外的「模型回复（含 tool_use 块）→ 用户回复（含 tool_result 块）」往返，之后模型才给出最终答案。必须把这一轮完整地追加进 `messages`，否则 API 报错。

**并行工具调用**：一次响应可以包含多个 `tool_use` 块（如上例），Claude 会在一轮内把能并行的工具一起请求，节省延迟。把每个结果都用对应的 `tool_use_id` 关联起来再回传。

{{< callout type="warning" >}}
工具的 `description` 直接影响模型能否正确选用工具。描述要具体说明「何时用、输入输出是什么」，含糊的描述容易让模型误用或不用工具。
{{< /callout >}}

## Agent 的常见挑战

| 挑战 | 应对策略 |
| --- | --- |
| 无限循环 | 设置最大循环次数（如 20 步），超出则强制终止并报错 |
| 工具错误传播 | 工具执行失败时，把错误信息作为 `tool_result` 回传，让模型自行决定是否重试 |
| 成本失控 | 每轮循环 = 一次 API 调用，长链路会快速消耗 token，设预算上限 |
| 幻觉工具参数 | 模型可能传入不合法参数，工具层要做输入校验并返回清晰的错误信息 |

## 一句话小结

Agent = **工具描述（JSON Schema）+ 执行循环（stop_reason == "tool_use" 时调用并回传）**。Claude API 只负责「建议调用哪个工具」，实际执行权始终在你的代码里——这个设计让安全控制和审计变得很自然。
