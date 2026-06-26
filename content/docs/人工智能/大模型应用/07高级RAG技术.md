---
title: "高级 RAG 技术"
weight: 7
date: 2026-06-18
tags: ["RAG", "HyDE", "RAPTOR", "Reranking", "混合检索"]
---

基础 RAG（切块 → 向量化 → 检索 → 生成）能解决大部分场景，但在复杂问题、长文档、多跳推理等情况下效果明显下降。这篇系统介绍当前主流的高级 RAG 技术，帮助你从「能跑」升级到「效果好」。

## RAG 效果为什么会差

在升级前先搞清楚问题出在哪一层：

```text
检索层问题（最常见）：
  - 块切得太碎：语义被截断，检索时找不到完整答案
  - 向量匹配失败：用户问"涨价了多少"，文档写"调整了定价策略"
  - Top-K 质量差：相关文档排在第 5 条，但只取了 Top-3

生成层问题：
  - 上下文太长：把 10 个 chunk 全塞进去，模型注意力被稀释
  - 无关噪声：检索到的内容和问题只是词汇相关，不是语义相关
```

诊断方法：**单独评估检索命中率**（给定问题，正确答案所在的 chunk 是否在 Top-K 里），再评估生成质量，分层定位问题。

## 技术一：混合检索（Hybrid Search）

单纯向量检索在**精确词匹配**场景（人名、产品型号、代码片段）效果差。混合 BM25（关键词）+ 向量（语义）往往全面优于纯向量方案。

```python
from qdrant_client import QdrantClient
from qdrant_client.models import SparseVector, NamedSparseVector

# 混合检索：将向量分数和 BM25 分数用 RRF 融合
def hybrid_search(query: str, top_k: int = 10):
    # 向量检索
    dense_results = qdrant.search(
        collection_name="docs",
        query_vector=embed(query),
        limit=top_k * 2,
    )
    # 稀疏向量（BM25）检索
    sparse_results = qdrant.search(
        collection_name="docs",
        query_vector=NamedSparseVector(
            name="text",
            vector=SparseVector(**bm25_encode(query))
        ),
        limit=top_k * 2,
    )
    # Reciprocal Rank Fusion（RRF）融合排序
    return reciprocal_rank_fusion(dense_results, sparse_results, k=60)[:top_k]


def reciprocal_rank_fusion(list_a, list_b, k=60):
    scores = {}
    for rank, doc in enumerate(list_a):
        scores[doc.id] = scores.get(doc.id, 0) + 1 / (rank + k)
    for rank, doc in enumerate(list_b):
        scores[doc.id] = scores.get(doc.id, 0) + 1 / (rank + k)
    return sorted(scores.items(), key=lambda x: x[1], reverse=True)
```

{{< callout type="tip" >}}
RRF（Reciprocal Rank Fusion）不需要对不同来源的分数做归一化，是混合检索最稳健的融合算法。
{{< /callout >}}

## 技术二：重排序（Reranking）

向量检索的 Top-K 是粗排（速度快但精度有限），Reranker 是精排（速度慢但精度高）。用 Cross-Encoder 对初始候选集重新评分，通常能显著提升 Top-3 的准确率。

```python
from sentence_transformers import CrossEncoder

reranker = CrossEncoder("BAAI/bge-reranker-v2-m3")

def rerank(query: str, candidates: list[str], top_n: int = 3) -> list[str]:
    pairs = [(query, doc) for doc in candidates]
    scores = reranker.predict(pairs)
    ranked = sorted(zip(candidates, scores), key=lambda x: x[1], reverse=True)
    return [doc for doc, _ in ranked[:top_n]]

# 流程：向量检索 Top-20 → Reranker 精选 Top-3 → 传给 LLM
chunks = vector_search(query, top_k=20)
best_chunks = rerank(query, chunks, top_n=3)
```

推荐的中文 Reranker 模型：
- `BAAI/bge-reranker-v2-m3`（中英文）
- `Qwen/Qwen3-Reranker-0.6B`（轻量级）

## 技术三：HyDE（假设性文档嵌入）

**问题**：用户的问题通常是短而抽象的（「怎么申请年假」），而文档是长而具体的（「员工手册第 3.2 节：年假申请流程……」）。两者的向量空间差异导致检索失败。

**HyDE 的思路**：先让 LLM 生成一个「假设性的回答文档」，再用这个假设文档去做向量检索——假设文档和真实文档在向量空间里更接近。

```python
import anthropic

client = anthropic.Anthropic()

def hyde_search(question: str, top_k: int = 5) -> list:
    # Step 1：生成假设性文档
    resp = client.messages.create(
        model="claude-haiku-4-5-20251001",
        max_tokens=300,
        messages=[{
            "role": "user",
            "content": (
                f"请为下面的问题写一段可能出现在官方文档中的回答（2-3句话），"
                f"不需要准确，只需要风格和术语接近真实文档。\n问题：{question}"
            )
        }]
    )
    hypothetical_doc = resp.content[0].text

    # Step 2：用假设文档向量化后检索
    results = vector_search(hypothetical_doc, top_k=top_k)
    return results
```

HyDE 在**专业文档、技术手册**场景提升最明显，对口语化问题效果有限。

## 技术四：查询改写与扩展

单一查询视角有限。从多个角度改写同一个问题，合并检索结果，能提升召回率。

```python
def multi_query_search(question: str, top_k: int = 5) -> list:
    resp = client.messages.create(
        model="claude-haiku-4-5-20251001",
        max_tokens=200,
        messages=[{
            "role": "user",
            "content": (
                f"为下面的问题生成 3 种不同的改写方式，用于检索文档。"
                f"每行一个，只输出改写后的问题，不要编号和解释。\n原问题：{question}"
            )
        }]
    )
    rewrites = resp.content[0].text.strip().split("\n")
    queries = [question] + rewrites[:3]

    # 对所有查询检索，去重合并
    seen = set()
    results = []
    for q in queries:
        for chunk in vector_search(q, top_k=top_k):
            if chunk.id not in seen:
                seen.add(chunk.id)
                results.append(chunk)
    return results
```

## 技术五：RAPTOR（递归树索引）

**适用场景**：超长文档（几十页 PDF、整本书）、需要跨章节多跳推理的问题。

RAPTOR 的核心思路：**对文档做多层摘要，构建树状索引**。

```text
原始文档（叶节点）
    ↓ 聚类 + 摘要
中层摘要（若干节的概述）
    ↓ 再聚类 + 摘要
顶层摘要（全文概述）
```

检索时在树的不同层级上同时搜索，从而既能回答细节问题（叶节点），也能回答整体性问题（顶层摘要）。

```python
from sklearn.cluster import KMeans
import numpy as np

def build_raptor_tree(chunks: list[str], levels: int = 3) -> dict:
    """构建 RAPTOR 树状摘要索引"""
    current_level = chunks
    tree = {0: chunks}

    for level in range(1, levels + 1):
        embeddings = np.array([embed(c) for c in current_level])
        n_clusters = max(1, len(current_level) // 5)
        kmeans = KMeans(n_clusters=n_clusters).fit(embeddings)

        summaries = []
        for cluster_id in range(n_clusters):
            cluster_chunks = [current_level[i] for i, label in
                              enumerate(kmeans.labels_) if label == cluster_id]
            cluster_text = "\n\n".join(cluster_chunks)

            resp = client.messages.create(
                model="claude-haiku-4-5-20251001",
                max_tokens=300,
                messages=[{"role": "user",
                           "content": f"请将以下内容概括为 200 字以内的摘要：\n{cluster_text}"}]
            )
            summaries.append(resp.content[0].text)

        tree[level] = summaries
        current_level = summaries

    return tree
```

## 技术六：Self-RAG（自我反思检索）

让 LLM 自己决定「是否需要检索」以及「检索结果是否有用」，避免对不需要外部知识的问题也强行检索。

```python
def self_rag(question: str) -> str:
    # Step 1：判断是否需要检索
    decision_resp = client.messages.create(
        model="claude-haiku-4-5-20251001",
        max_tokens=10,
        messages=[{
            "role": "user",
            "content": (
                f"以下问题是否需要查阅外部文档才能回答？"
                f"只回答 yes 或 no。\n问题：{question}"
            )
        }]
    )
    need_retrieval = decision_resp.content[0].text.strip().lower() == "yes"

    if not need_retrieval:
        # 直接回答，无需检索
        return direct_answer(question)

    # Step 2：检索 + 评估相关性
    chunks = hybrid_search(question, top_k=5)
    relevant_chunks = []
    for chunk in chunks:
        relevance_resp = client.messages.create(
            model="claude-haiku-4-5-20251001",
            max_tokens=10,
            messages=[{
                "role": "user",
                "content": (
                    f"以下段落是否与问题相关？只回答 yes 或 no。\n"
                    f"问题：{question}\n段落：{chunk.text}"
                )
            }]
        )
        if relevance_resp.content[0].text.strip().lower() == "yes":
            relevant_chunks.append(chunk)

    # Step 3：基于相关内容生成回答
    return generate_with_context(question, relevant_chunks)
```

## 技术七：GraphRAG（图增强检索）

对于**实体关系密集**的知识库（法律文档、医疗知识、企业组织结构），用知识图谱替代纯向量索引，能更好地处理多跳推理。

```text
传统 RAG：问题 → 向量检索 → 相关 chunks → 生成
GraphRAG：问题 → 实体识别 → 图遍历（多跳） → 相关子图 + chunks → 生成

"X 公司的 CEO 和 Y 公司有什么合作关系？"
→ 识别实体：X公司.CEO、Y公司
→ 图遍历：X公司 --CEO--> 张三 --合作--> Y公司
→ 回答基于图路径，而非单纯文本匹配
```

微软的 [GraphRAG](https://github.com/microsoft/graphrag) 是目前最成熟的开源实现。

## 评估体系

高级 RAG 的评估必须分层进行：

| 层级 | 指标 | 工具 |
| --- | --- | --- |
| 检索层 | Recall@K（答案在 Top-K 里的比例） | RAGAS, TruLens |
| 检索层 | MRR（平均倒数排名） | 自行实现 |
| 生成层 | Faithfulness（答案是否基于资料） | RAGAS |
| 生成层 | Answer Relevancy（答案是否切题） | RAGAS |
| 端到端 | Answer Correctness | LLM-as-judge |

```python
# 用 RAGAS 快速评估
from ragas import evaluate
from ragas.metrics import faithfulness, answer_relevancy, context_recall

result = evaluate(
    dataset=eval_dataset,
    metrics=[faithfulness, answer_relevancy, context_recall]
)
print(result)
```

## 技术选型参考

| 场景 | 推荐技术组合 |
| --- | --- |
| 通用知识库 | 混合检索 + Reranking |
| 口语化查询多 | HyDE + 混合检索 |
| 超长文档 | RAPTOR + Reranking |
| 问题多样性大 | 多查询扩展 + 混合检索 |
| 实体关系复杂 | GraphRAG |
| 需要降低无效检索 | Self-RAG |

从**混合检索 + Reranking** 开始，这是性价比最高的起点；再根据评估结果决定是否引入更复杂的技术。
