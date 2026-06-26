---
title: "序列模型：RNN 与 LSTM"
weight: 4
date: 2026-06-18
tags: ["深度学习", "RNN", "LSTM", "时间序列", "序列建模"]
---

文本、语音、时间序列——这些数据的特点是**顺序很重要**，前面的内容影响对后面内容的理解。RNN（循环神经网络）专为此而生，LSTM 解决了 RNN 的记忆退化问题。即使在 Transformer 称霸之后，LSTM 在时间序列预测、小数据集场景仍然实用。

## RNN：带记忆的神经网络

普通 MLP 每次处理一个独立样本，不保留任何「历史」。RNN 在此基础上加了一个**隐状态（hidden state）**，每个时间步的计算同时依赖当前输入和上一步的隐状态：

```text
时间步 t：
  hₜ = tanh(Wₕ · hₜ₋₁ + Wₓ · xₜ + b)
  yₜ = Wₒ · hₜ

其中：
  xₜ  = 当前时间步的输入
  hₜ₋₁ = 上一步的隐状态（记忆）
  hₜ  = 新的隐状态
  yₜ  = 当前步的输出（可选）
```

把多个时间步展开，就能看出 RNN 其实是在「沿时间方向共享权重的深度网络」：

```text
x₁ → [RNN] → h₁ → [RNN] → h₂ → [RNN] → h₃ → ... → 输出
              ↑              ↑              ↑
           同一组参数 W 在每个时间步重复使用
```

### RNN 的问题：梯度消失

由于反向传播需要沿时间步链式乘法，当序列很长时，梯度会指数级缩小（梯度消失）或爆炸：

- 100 步前的信息，梯度传回来时几乎为 0 → 模型完全无法学到长距离依赖
- 梯度爆炸用**梯度裁剪（Gradient Clipping）**缓解：`torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=5)`

---

## LSTM：长短期记忆网络

LSTM（1997 年提出）通过引入**门控机制**和**细胞状态（cell state）**解决梯度消失：

```text
LSTM 的四个核心组件：

遗忘门 fₜ = σ(Wf · [hₜ₋₁, xₜ] + bf)
  → 决定从上一个 cell state 中「忘记」多少（0=全忘，1=全保留）

输入门 iₜ = σ(Wi · [hₜ₋₁, xₜ] + bi)
候选值  c̃ₜ = tanh(Wc · [hₜ₋₁, xₜ] + bc)
  → 决定把多少「新信息」写入 cell state

更新 cell state：
  Cₜ = fₜ ⊙ Cₜ₋₁ + iₜ ⊙ c̃ₜ   （⊙ 是逐元素乘法）

输出门 oₜ = σ(Wo · [hₜ₋₁, xₜ] + bo)
隐状态  hₜ = oₜ ⊙ tanh(Cₜ)
  → 决定从 cell state 中「读出」多少作为输出
```

关键直觉：**Cell state 是「长期记忆」的高速公路**，梯度可以几乎无衰减地沿着它反传，解决了长距离依赖问题。

### GRU：LSTM 的简化版

GRU（2014 年）把 LSTM 的三个门简化为两个，参数更少，训练更快，效果通常与 LSTM 相当：

```python
import torch.nn as nn

# LSTM 和 GRU 的 API 完全一样，直接替换
lstm = nn.LSTM(input_size=10, hidden_size=64, num_layers=2,
               batch_first=True, dropout=0.3)
gru  = nn.GRU(input_size=10,  hidden_size=64, num_layers=2,
              batch_first=True, dropout=0.3)

# 双向 RNN：同时从左到右 + 从右到左处理序列
bilstm = nn.LSTM(input_size=10, hidden_size=64, num_layers=2,
                 batch_first=True, bidirectional=True)
```

---

## 实战一：时间序列预测（股价预测示意）

```python
import torch
import torch.nn as nn
import numpy as np
from torch.utils.data import Dataset, DataLoader


class TimeSeriesDataset(Dataset):
    def __init__(self, data: np.ndarray, seq_len: int = 30, pred_len: int = 1):
        """
        data:     一维时间序列
        seq_len:  用过去多少步预测
        pred_len: 预测未来多少步
        """
        self.X, self.y = [], []
        for i in range(len(data) - seq_len - pred_len + 1):
            self.X.append(data[i: i + seq_len])
            self.y.append(data[i + seq_len: i + seq_len + pred_len])
        self.X = torch.FloatTensor(self.X).unsqueeze(-1)  # [N, seq_len, 1]
        self.y = torch.FloatTensor(self.y)

    def __len__(self):  return len(self.X)
    def __getitem__(self, i): return self.X[i], self.y[i]


class LSTMForecaster(nn.Module):
    def __init__(self, input_size=1, hidden_size=64, num_layers=2,
                 dropout=0.2, pred_len=1):
        super().__init__()
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers,
                            batch_first=True, dropout=dropout)
        self.fc   = nn.Linear(hidden_size, pred_len)

    def forward(self, x):
        out, _ = self.lstm(x)           # [batch, seq_len, hidden]
        return self.fc(out[:, -1, :])   # 只用最后时间步的隐状态预测


# 生成示例数据：带噪声的正弦波
t    = np.linspace(0, 100, 2000)
data = np.sin(t) + np.sin(0.5*t) + 0.1 * np.random.randn(2000)

# 归一化到 [-1, 1]
from sklearn.preprocessing import MinMaxScaler
scaler = MinMaxScaler(feature_range=(-1, 1))
data_scaled = scaler.fit_transform(data.reshape(-1, 1)).flatten()

split = int(len(data_scaled) * 0.8)
train_ds = TimeSeriesDataset(data_scaled[:split], seq_len=50)
test_ds  = TimeSeriesDataset(data_scaled[split:], seq_len=50)
train_loader = DataLoader(train_ds, batch_size=64, shuffle=True)
test_loader  = DataLoader(test_ds,  batch_size=64, shuffle=False)

device    = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model     = LSTMForecaster().to(device)
optimizer = torch.optim.Adam(model.parameters(), lr=1e-3)
criterion = nn.MSELoss()

for epoch in range(50):
    model.train()
    for X_b, y_b in train_loader:
        X_b, y_b = X_b.to(device), y_b.to(device)
        optimizer.zero_grad()
        loss = criterion(model(X_b), y_b)
        loss.backward()
        # 梯度裁剪，防止 RNN/LSTM 的梯度爆炸
        nn.utils.clip_grad_norm_(model.parameters(), max_norm=5.0)
        optimizer.step()

    if epoch % 10 == 9:
        model.eval()
        val_losses = []
        with torch.no_grad():
            for X_b, y_b in test_loader:
                X_b, y_b = X_b.to(device), y_b.to(device)
                val_losses.append(criterion(model(X_b), y_b).item())
        print(f"Epoch {epoch+1:3d} | Val MSE: {np.mean(val_losses):.6f}")
```

---

## 实战二：文本情感分类

```python
import torch
import torch.nn as nn
from torch.nn.utils.rnn import pad_sequence, pack_padded_sequence, pad_packed_sequence


class TextLSTM(nn.Module):
    def __init__(self, vocab_size, embed_dim=128, hidden_size=256,
                 num_layers=2, num_classes=2, dropout=0.3):
        super().__init__()
        self.embedding = nn.Embedding(vocab_size, embed_dim, padding_idx=0)
        self.lstm = nn.LSTM(embed_dim, hidden_size, num_layers,
                            batch_first=True, dropout=dropout,
                            bidirectional=True)
        # 双向 LSTM：hidden_size × 2
        self.classifier = nn.Sequential(
            nn.Linear(hidden_size * 2, 128),
            nn.ReLU(),
            nn.Dropout(dropout),
            nn.Linear(128, num_classes),
        )

    def forward(self, x, lengths):
        # x: [batch, seq_len]，lengths: 各样本真实长度
        emb = self.embedding(x)    # [batch, seq_len, embed_dim]

        # packed sequence 避免 padding 参与 LSTM 计算
        packed = pack_padded_sequence(emb, lengths.cpu(),
                                      batch_first=True, enforce_sorted=False)
        out, (h, _) = self.lstm(packed)

        # 取最后一层双向的隐状态拼接
        h_last = torch.cat([h[-2], h[-1]], dim=1)  # [batch, hidden*2]
        return self.classifier(h_last)
```

{{< callout type="tip" >}}
`pack_padded_sequence` 和 `pad_packed_sequence` 是处理变长序列的标准方法，能让 LSTM 跳过 padding 位置，结果更准确，训练更快。
{{< /callout >}}

---

## RNN / LSTM vs Transformer：怎么选

| 维度 | RNN / LSTM | Transformer |
| --- | --- | --- |
| 序列长度 | 短中序列（< 1000 步）较好 | 支持超长序列（Flash Attention 后） |
| 训练速度 | 慢（必须顺序计算） | 快（全并行） |
| 长距离依赖 | LSTM 改善，仍有限 | 天然全局依赖 |
| 小数据集 | 参数少，表现稳定 | 容易过拟合 |
| 实时流式推理 | 天然支持（逐步更新隐状态） | 需要额外工程处理 |
| 可解释性 | 隐状态可分析 | 注意力权重可可视化 |

**推荐**：时间序列预测（传感器、金融）和小数据集序列任务优先试 LSTM / GRU；NLP 任务用预训练的 Transformer 模型（BERT、Qwen 等）远快于自己训练。

## 一句话小结

RNN 给网络加了「时间维度的记忆」；LSTM 用门控机制解决了梯度消失，让模型能记住几百步前的信息。两者在时间序列预测、小数据序列任务上仍是实用选择，掌握它们也是理解 Transformer「为什么要替代 RNN」的前提。
