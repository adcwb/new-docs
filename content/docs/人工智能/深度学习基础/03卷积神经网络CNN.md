---
title: "卷积神经网络（CNN）"
weight: 3
date: 2026-06-18
tags: ["深度学习", "CNN", "卷积", "图像识别", "PyTorch"]
---

图像识别、目标检测、医疗影像分析——这些任务背后几乎都是卷积神经网络。CNN 的核心思想是：**用局部感知替代全连接，让网络自动学习图像的空间特征**。这篇从卷积运算的直觉出发，搭建一个完整的图像分类模型。

## 为什么全连接网络处理不了图像

一张 224×224 的彩色图片有 `224 × 224 × 3 = 150,528` 个像素值。如果用全连接网络，第一层隐藏节点（假设 1024 个）就需要 `150,528 × 1024 ≈ 1.5 亿`个参数——参数爆炸，而且完全没利用像素的**空间相关性**（相邻像素往往属于同一物体）。

CNN 的解决思路：
- **局部感知**：每个神经元只看图像的一小块区域（感受野）
- **权重共享**：同一个卷积核扫过整张图，参数量大幅减少
- **层次特征**：浅层学边缘/颜色，深层学纹理/部件/物体

## 卷积运算：核心直觉

卷积核（滤波器）是一个小矩阵（如 3×3），在图像上**滑动扫描**，每次对覆盖区域做点积，输出一个值：

```text
输入图像（5×5）      卷积核（3×3）      输出特征图（3×3）
┌─────────────┐    ┌─────────┐        ┌─────────┐
│ 1  1  1  0  0│   │ 1  0  1 │        │ 4  3  4 │
│ 0  1  1  1  0│ × │ 0  1  0 │   =    │ 2  4  3 │
│ 0  0  1  1  1│   │ 1  0  1 │        │ 2  3  4 │
│ 0  0  1  1  0│   └─────────┘        └─────────┘
│ 0  1  1  0  0│
└─────────────┘
```

不同的卷积核学到不同的特征：有的学水平边缘，有的学垂直边缘，有的学斜线。**这些卷积核的参数完全由反向传播自动学习**，不需要人工设计。

### 池化层：降采样

池化（Pooling）把特征图缩小，减少计算量并提高平移不变性：

```text
最大池化（2×2，步长 2）：
┌────────┐        ┌────┐
│ 1  3   │  →     │ 3  │    取每个 2×2 区域的最大值
│ 2  4   │        └────┘
└────────┘
```

```python
import torch
import torch.nn as nn

# 卷积层：输入 3 通道（RGB），输出 32 通道（32 个卷积核），核大小 3×3
conv = nn.Conv2d(in_channels=3, out_channels=32, kernel_size=3, padding=1)
# padding=1 保持输出尺寸与输入相同

# 最大池化：2×2，步长 2，把特征图缩小一半
pool = nn.MaxPool2d(kernel_size=2, stride=2)

# 演示尺寸变化
x = torch.randn(1, 3, 224, 224)    # [batch, channels, H, W]
x = conv(x);  print(x.shape)        # [1, 32, 224, 224]
x = pool(x);  print(x.shape)        # [1, 32, 112, 112]
```

## 搭建一个完整的 CNN：CIFAR-10 图像分类

CIFAR-10 包含 60,000 张 32×32 的彩色图片，10 个类别（飞机、汽车、鸟……）。

```python
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader
from torchvision import datasets, transforms
import time


# 1. 数据加载与数据增强
transform_train = transforms.Compose([
    transforms.RandomHorizontalFlip(),          # 随机水平翻转（数据增强）
    transforms.RandomCrop(32, padding=4),       # 随机裁剪（数据增强）
    transforms.ToTensor(),
    transforms.Normalize((0.4914, 0.4822, 0.4465),
                         (0.2023, 0.1994, 0.2010)),  # CIFAR-10 均值/标准差
])
transform_test = transforms.Compose([
    transforms.ToTensor(),
    transforms.Normalize((0.4914, 0.4822, 0.4465),
                         (0.2023, 0.1994, 0.2010)),
])

train_set = datasets.CIFAR10(root="./data", train=True,  transform=transform_train, download=True)
test_set  = datasets.CIFAR10(root="./data", train=False, transform=transform_test,  download=True)
train_loader = DataLoader(train_set, batch_size=128, shuffle=True,  num_workers=4, pin_memory=True)
test_loader  = DataLoader(test_set,  batch_size=256, shuffle=False, num_workers=4)


# 2. 定义 CNN 结构
class SimpleCNN(nn.Module):
    def __init__(self, num_classes=10):
        super().__init__()
        # 特征提取部分
        self.features = nn.Sequential(
            # Block 1：32×32 → 16×16
            nn.Conv2d(3, 32, 3, padding=1),
            nn.BatchNorm2d(32),
            nn.ReLU(inplace=True),
            nn.Conv2d(32, 32, 3, padding=1),
            nn.BatchNorm2d(32),
            nn.ReLU(inplace=True),
            nn.MaxPool2d(2, 2),
            nn.Dropout2d(0.25),

            # Block 2：16×16 → 8×8
            nn.Conv2d(32, 64, 3, padding=1),
            nn.BatchNorm2d(64),
            nn.ReLU(inplace=True),
            nn.Conv2d(64, 64, 3, padding=1),
            nn.BatchNorm2d(64),
            nn.ReLU(inplace=True),
            nn.MaxPool2d(2, 2),
            nn.Dropout2d(0.25),

            # Block 3：8×8 → 4×4
            nn.Conv2d(64, 128, 3, padding=1),
            nn.BatchNorm2d(128),
            nn.ReLU(inplace=True),
            nn.MaxPool2d(2, 2),
        )

        # 分类头：全连接层
        self.classifier = nn.Sequential(
            nn.Flatten(),
            nn.Linear(128 * 4 * 4, 512),
            nn.ReLU(inplace=True),
            nn.Dropout(0.5),
            nn.Linear(512, num_classes),
        )

    def forward(self, x):
        x = self.features(x)
        return self.classifier(x)


# 3. 训练配置
device    = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model     = SimpleCNN().to(device)
optimizer = optim.Adam(model.parameters(), lr=1e-3, weight_decay=1e-4)
scheduler = optim.lr_scheduler.CosineAnnealingLR(optimizer, T_max=50)
criterion = nn.CrossEntropyLoss()

print(f"参数总量: {sum(p.numel() for p in model.parameters()):,}")


# 4. 训练 & 评估循环
def train_epoch(model, loader, optimizer, criterion, device):
    model.train()
    total_loss, correct, total = 0.0, 0, 0
    for X, y in loader:
        X, y = X.to(device), y.to(device)
        optimizer.zero_grad()
        out  = model(X)
        loss = criterion(out, y)
        loss.backward()
        optimizer.step()
        total_loss += loss.item() * len(y)
        correct    += (out.argmax(1) == y).sum().item()
        total      += len(y)
    return total_loss / total, correct / total


@torch.no_grad()
def eval_epoch(model, loader, criterion, device):
    model.eval()
    total_loss, correct, total = 0.0, 0, 0
    for X, y in loader:
        X, y = X.to(device), y.to(device)
        out  = model(X)
        loss = criterion(out, y)
        total_loss += loss.item() * len(y)
        correct    += (out.argmax(1) == y).sum().item()
        total      += len(y)
    return total_loss / total, correct / total


for epoch in range(1, 51):
    t0 = time.time()
    train_loss, train_acc = train_epoch(model, train_loader, optimizer, criterion, device)
    val_loss,   val_acc   = eval_epoch(model, test_loader, criterion, device)
    scheduler.step()

    if epoch % 5 == 0:
        print(f"Epoch {epoch:3d} | "
              f"Train Loss {train_loss:.3f} Acc {train_acc:.3f} | "
              f"Val Loss {val_loss:.3f} Acc {val_acc:.3f} | "
              f"{time.time()-t0:.1f}s")
```

训练 50 轮后，这个简单 CNN 在 CIFAR-10 上可达约 **84% 准确率**。

## 经典 CNN 架构演进

| 模型 | 年份 | 创新点 | ImageNet Top-1 |
| --- | --- | --- | --- |
| AlexNet | 2012 | ReLU + Dropout + GPU | 63.3% |
| VGG-16 | 2014 | 全用 3×3 小卷积核堆叠 | 74.5% |
| GoogLeNet | 2014 | Inception 模块，多尺度并行 | 74.8% |
| ResNet-50 | 2015 | 残差连接，首次训练 100+ 层 | 79.3% |
| EfficientNet-B7 | 2019 | 复合缩放（宽/深/分辨率） | 88.4% |
| ConvNeXt | 2022 | 用 Transformer 思路改造 CNN | 87.8% |

### 残差连接（ResNet）

深网络（50层+）训练时梯度消失严重，ResNet 用**跳跃连接**解决：

```python
class ResidualBlock(nn.Module):
    def __init__(self, channels):
        super().__init__()
        self.conv1 = nn.Conv2d(channels, channels, 3, padding=1, bias=False)
        self.bn1   = nn.BatchNorm2d(channels)
        self.conv2 = nn.Conv2d(channels, channels, 3, padding=1, bias=False)
        self.bn2   = nn.BatchNorm2d(channels)
        self.relu  = nn.ReLU(inplace=True)

    def forward(self, x):
        residual = x                       # 保存输入
        out = self.relu(self.bn1(self.conv1(x)))
        out = self.bn2(self.conv2(out))
        out = out + residual               # 残差连接：输出 = F(x) + x
        return self.relu(out)
```

直觉：即使 `conv1` 和 `conv2` 都学成了零，网络至少还有恒等映射（直接传递 `x`），不会退化。

## 实用技巧

**Grad-CAM：可视化模型「看哪里」**

```python
import torch.nn.functional as F

def grad_cam(model, image, target_class, target_layer):
    """计算目标层的 Grad-CAM 热力图"""
    activations, gradients = {}, {}

    def forward_hook(m, i, o):
        activations["value"] = o

    def backward_hook(m, gi, go):
        gradients["value"] = go[0]

    h1 = target_layer.register_forward_hook(forward_hook)
    h2 = target_layer.register_full_backward_hook(backward_hook)

    out = model(image.unsqueeze(0))
    model.zero_grad()
    out[0, target_class].backward()

    # 对梯度做全局平均池化得到权重
    weights = gradients["value"].mean(dim=[2, 3], keepdim=True)
    cam = (weights * activations["value"]).sum(dim=1, keepdim=True)
    cam = F.relu(cam)
    cam = F.interpolate(cam, size=image.shape[1:], mode="bilinear")

    h1.remove(); h2.remove()
    return cam.squeeze().detach().numpy()
```

## 一句话小结

CNN = **卷积（局部感知 + 权重共享）+ 池化（降维）+ 全连接（分类）**。浅层学边缘，深层学语义；残差连接让百层网络得以训练；数据增强和 BatchNorm 是打好精度的关键。计算机视觉任务，先试 ResNet 或 EfficientNet，不要自己从头设计架构。
