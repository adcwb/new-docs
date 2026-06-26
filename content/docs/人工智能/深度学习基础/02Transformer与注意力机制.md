---
title: "Transformer 与注意力机制"
weight: 2
date: 2026-06-16
tags: ["深度学习", "Transformer", "注意力机制", "LLM"]
---

GPT、BERT、Claude——当代所有主流大模型都建立在同一个架构上：**Transformer**。这篇从「为什么需要注意力」出发，把 Self-Attention、Multi-Head、Transformer 块的直觉讲清楚，并连接到你实际用的 LLM。

## 为什么 RNN 不够用

在 Transformer 之前，序列数据用 RNN（循环神经网络）处理：逐步读入每个词，把「记忆」藏在隐状态里往下传。

问题：
- **长距离依赖消失**：500 个词前的关键信息，传到最后时梯度早已消弭（梯度消失）。
- **顺序计算**：必须一个词一个词地算，无法并行，训练很慢。

Transformer 的核心思路：**不逐步读，而是让每个词一次性「看到」序列里所有其他词，再按相关度加权聚合**。这就是注意力机制。

## Self-Attention：核心直觉

给序列里的每个词分配三个向量：**Query（我在问什么）**、**Key（我是什么）**、**Value（我的内容）**。

注意力分数计算过程：

```text
每个词的 Query 对所有词的 Key 算点积  →  按维度开方后 Softmax  →  得到注意力权重
注意力权重 × 各词的 Value 加权求和  →  该词的「上下文感知」表示
```

用公式写：

```text
Attention(Q, K, V) = Softmax(Q·Kᵀ / √d_k) · V
```

直觉：`Q·Kᵀ` 算词对之间的相似度，除以 `√d_k` 防止维度大时点积太大（导致 Softmax 饱和）；Softmax 把相似度变成概率权重；最后按权重聚合 Value。

{{< callout type="info" >}}
「Self」是指 Q、K、V 都来自**同一个**序列本身，不像编码器-解码器注意力那样 Q 来自解码器、K/V 来自编码器。Self-Attention 让句子内部做全局上下文建模。
{{< /callout >}}

## Multi-Head Attention

单个注意力头可能只能关注一种类型的关系（如语法依赖）。**Multi-Head Attention** 并行跑多个注意力头，每个头学习关注不同类型的关系（依存、指代、语义相似），最后拼接。

```text
head_i = Attention(Q·Wᵢᵠ, K·Wᵢᵏ, V·Wᵢᵛ)    # 每个头有各自的线性投影矩阵
MultiHead(Q, K, V) = Concat(head₁, …, head_h) · Wᴼ
```

实践中，GPT-4 用了 128 个头；Claude 等模型的头数也达到同量级。

## Transformer 块

一个完整的 Transformer 块 = 两个子层 + 残差连接 + 层归一化：

```text
输入 x
  ├─→ Multi-Head Self-Attention(x)
  │         ↓
  ├─→ + x（残差连接）→ LayerNorm → 中间量 z
  │
  └─→ FFN(z)           # 两层全连接，中间维度 4× 扩展
         ↓
    + z（残差连接）→ LayerNorm → 块输出
```

- **残差连接**：解决深网络的梯度消失，让低层梯度能直接流回。
- **层归一化（LayerNorm）**：稳定训练，比 BatchNorm 更适合变长序列。
- **FFN（前馈网络）**：每个位置独立做非线性变换，补充注意力的局部能力。

把 N 个这样的块堆叠，就是一个 Transformer。大模型通常堆 32~128 层。

## 三种主流架构

同样基于 Transformer，但不同任务有不同变体：

| 架构 | 代表模型 | 注意力类型 | 适用任务 |
| --- | --- | --- | --- |
| 仅编码器（Encoder-only） | BERT、RoBERTa | 双向（每个词看全部词） | 文本分类、NER、语义相似度 |
| 仅解码器（Decoder-only） | GPT 系列、Claude、Llama | 单向（只看左侧已生成的词） | 文本生成、对话、代码 |
| 编码器-解码器 | T5、mT5、BART | 混合 | 翻译、摘要、问答 |

当代主流大模型（Claude、GPT-4、Llama 3）都是 **Decoder-only**——训练目标就是预测下一个词，天然适合生成任务，且可以用提示词驱动几乎所有 NLP 子任务。

## 位置编码

注意力机制本身不感知词序（全部词同时看），必须显式注入位置信息。常见方案：

- **正弦位置编码（原始 Transformer）**：用不同频率的正弦/余弦函数编码位置，固定不可学。
- **可学习位置编码（BERT/GPT）**：位置作为参数直接学，但长度受限。
- **旋转位置编码 RoPE（LLaMA、Qwen 等）**：在 Q/K 计算时旋转向量以编码相对位置，支持更长上下文外推，已成新标准。

## 为什么 Transformer 能做大

Transformer 的计算量大约和序列长度的平方（`O(n²)`）成正比（因为每对词都要算注意力分数），所以早期上下文窗口受限。但它的**参数量可以无限扩展**（更多层、更大隐藏维度），且高度并行，能充分利用 GPU。这使得「用更多算力训更大模型」这条路在 Transformer 上走通了——这正是 GPT-3、Claude 1 到今天 Claude Opus 4 的演进逻辑。

## 一句话小结

Transformer = 全局注意力（任意词对直接交互）+ 残差归一化堆叠 + 可并行训练。现代 LLM 就是在数万亿 token 上，用梯度下降把几百亿参数的 Decoder-only Transformer 调到「预测下一个词」这一件事上极度准确。明白了这点，再看 LLM 的种种「涌现能力」就不神秘了。
