---
title: "NumPy 使用指南"
weight: 20
date: 2026-06-27
tags: ["Python", "NumPy", "数据分析", "科学计算"]
---

NumPy（Numerical Python）是 Python 科学计算的基础库，提供高性能的多维数组对象 `ndarray` 以及配套的数学函数。相比 Python 原生列表，NumPy 数组在**内存布局更紧凑、批量运算速度更快**（底层用 C 实现），是 Pandas、Matplotlib、Scikit-learn 等数据科学库共同依赖的基石。

本文覆盖 NumPy 的核心用法：数组创建、属性、索引切片、形状变换、拼接、聚合与数学运算。示例基于 **NumPy 2.x**。

## 安装与导入

```bash
pip install numpy
```

```python
import numpy as np
print(np.__version__)  # 2.x
```

## 创建数组

### 从 Python 序列创建

```python
# 一维数组
a = np.array([1, 2, 3, 4, 5])
print(a)        # [1 2 3 4 5]
print(type(a))  # <class 'numpy.ndarray'>

# 二维数组
b = np.array([[1, 2, 3], [4, 5, 6]])
print(b.shape)  # (2, 3)
```

数组要求所有元素类型一致；若混入字符串，数值会被自动提升为字符串：

```python
np.array([1, "a", 2])  # array(['1', 'a', '2'], dtype='<U21')
```

### 常用构建函数

```python
np.zeros((3, 4))          # 全 0 数组，默认 float64
np.ones((2, 3), dtype=int) # 全 1 数组，指定 int 类型
np.eye(3)                  # 3×3 单位矩阵
np.full((2, 3), 7)         # 全部填充为 7

# 等差序列：[start, stop)，步长 step
np.arange(0, 10, 2)        # array([0, 2, 4, 6, 8])

# 等间隔数列：在 [start, stop] 内生成 num 个点
np.linspace(0, 1, 5)       # array([0., 0.25, 0.5, 0.75, 1.])
```

### 随机数组（NumPy 2.x 推荐写法）

NumPy 1.17 起引入了 `default_rng`，是替代 `np.random.*` 老接口的推荐方式：

```python
rng = np.random.default_rng(seed=42)   # 固定种子，结果可复现

rng.integers(0, 100, size=(3, 4))      # 整数数组，取值 [0, 100)
rng.random(size=(3, 4))                # [0, 1) 均匀浮点
rng.standard_normal(size=(3, 4))       # 标准正态分布
rng.choice([10, 20, 30, 40], size=5)   # 从给定序列随机采样
```

{{< callout type="info" >}}
老写法 `np.random.randint()`、`np.random.rand()` 在 NumPy 2.x 中仍然可用，但官方推荐迁移到 `default_rng`，因为后者线程安全且随机质量更好。
{{< /callout >}}

## 数组属性与数据类型

```python
a = np.arange(15).reshape(3, 5)

a.shape     # (3, 5)  — 各维度大小
a.ndim      # 2       — 维度数
a.dtype     # dtype('int64') — 元素类型
a.size      # 15      — 元素总数
a.itemsize  # 8       — 每个元素占用字节数（int64 = 8 字节）
```

### 常用数据类型

| 类型 | 说明 | 示例 |
| :--- | :--- | :--- |
| `int8` / `int32` / `int64` | 整数，位宽不同 | `np.array([1], dtype='int8')` |
| `float32` / `float64` | 浮点，64 为默认 | `np.array([1.0])` |
| `bool` | 布尔 | `np.array([True, False])` |
| `complex64` / `complex128` | 复数 | `np.array([1+2j])` |
| `str_` / `bytes_` | 字符串 / 字节 | `np.array(['a', 'b'])` |

查看整数类型的数值范围：

```python
np.iinfo('int8')   # iinfo(min=-128, max=127, dtype=int8)
np.iinfo('int64')  # iinfo(min=-9223372036854775808, max=9223372036854775807, dtype=int64)
np.finfo('float32')  # 查看浮点精度范围
```

## 索引与切片

NumPy 的索引语法与 Python 列表基本一致，多维数组用逗号分隔各轴。

```python
rng = np.random.default_rng(0)
arr = rng.integers(0, 100, size=(4, 5))
# [[85 58 70 77 31]
#  [16 68 21 43 50]
#  [60 13 95 60 38]
#  [95  9 64 56  2]]

arr[0]          # 第 0 行：[85 58 70 77 31]
arr[0, 2]       # 第 0 行第 2 列：70
arr[0:2]        # 前 2 行
arr[:, 0:2]     # 所有行的前 2 列
arr[0:2, 0:2]   # 前 2 行的前 2 列

# 行列反转（可用于图像翻转）
arr[::-1]       # 上下翻转
arr[:, ::-1]    # 左右翻转
arr[::-1, ::-1] # 同时翻转
```

**布尔索引**——按条件筛选元素：

```python
arr[arr > 50]       # 取出所有大于 50 的元素，返回一维数组
arr[arr % 2 == 0]   # 取出所有偶数
```

## 形状变换

变形前后元素总数必须保持一致。

| 方法 | 说明 |
| :--- | :--- |
| `arr.reshape(m, n)` | 返回新形状的视图，**不修改原数组** |
| `arr.resize(m, n)` | **原地**修改数组形状 |
| `arr.T` | 转置（交换轴） |
| `arr.ravel()` | 展平为一维，尽量返回视图 |
| `arr.flatten()` | 展平为一维，始终返回副本 |

```python
arr = np.arange(12)          # [0, 1, 2, ..., 11]

arr.reshape(3, 4)            # 3 行 4 列
arr.reshape(3, -1)           # -1 表示自动推算列数（等同 3×4）
arr.reshape(2, 2, 3)         # 三维：2 个 2×3 矩阵

arr.reshape(3, 4).T          # 转置为 4 行 3 列
arr.reshape(3, 4).flatten()  # 展平回 [0, 1, ..., 11]
```

## 数组拼接

```python
a = np.arange(6).reshape(2, 3)
b = np.arange(6, 12).reshape(2, 3)

np.concatenate([a, b], axis=0)  # 纵向拼接，结果 4×3
np.concatenate([a, b], axis=1)  # 横向拼接，结果 2×6

# 简写形式
np.vstack([a, b])  # 等同 axis=0
np.hstack([a, b])  # 等同 axis=1
```

## 聚合与统计函数

NumPy 的聚合函数默认对全部元素操作，通过 `axis` 参数可指定沿某个轴计算。

```python
arr = np.array([[1, 2, 3], [4, 5, 6]])

np.sum(arr)           # 21（所有元素之和）
np.sum(arr, axis=0)   # [5, 7, 9]（按列求和）
np.sum(arr, axis=1)   # [6, 15]（按行求和）

np.mean(arr)          # 3.5
np.std(arr)           # 标准差
np.var(arr)           # 方差
np.min(arr)           # 1
np.max(arr)           # 6
np.argmin(arr)        # 最小值的扁平索引
np.argmax(arr)        # 最大值的扁平索引
np.median(arr)        # 中位数
np.percentile(arr, 75)  # 第 75 百分位数
np.any(arr > 5)       # True（是否有元素满足条件）
np.all(arr > 0)       # True（是否所有元素满足条件）
```

## 数学运算

### 元素级算术函数

NumPy 对数组的四则运算默认逐元素执行（**广播机制**让不同形状的数组也能运算）：

```python
a = np.array([1, 2, 3])
b = np.array([4, 5, 6])

np.add(a, b)       # [5, 7, 9]，等同 a + b
np.subtract(a, b)  # [-3, -3, -3]，等同 a - b
np.multiply(a, b)  # [4, 10, 18]，等同 a * b
np.divide(a, b)    # [0.25, 0.4, 0.5]，等同 a / b
np.power(a, 2)     # [1, 4, 9]，等同 a ** 2
np.mod(b, a)       # [0, 1, 0]，等同 b % a
np.abs(np.array([-1, -2, 3]))  # [1, 2, 3]

# 标量广播
a * 2    # [2, 4, 6]
a + 10   # [11, 12, 13]
```

### 三角与舍入函数

```python
angles = np.array([0, np.pi / 4, np.pi / 2])

np.sin(angles)    # [0., 0.707, 1.]
np.cos(angles)    # [1., 0.707, 0.]
np.tan(angles)    # [0., 1., 1.633e+16]（π/2 处趋近无穷）

np.around(np.array([1.234, 5.678]), decimals=1)  # [1.2, 5.7]
np.floor(np.array([1.7, 2.3]))    # [1., 2.]（向下取整）
np.ceil(np.array([1.2, 2.8]))     # [2., 3.]（向上取整）
```

### 字符串函数

NumPy 通过 `np.char` 模块对字符串数组进行向量化操作，避免 Python 层面的循环：

```python
s = np.array(["hello", "world", "numpy"])

np.char.upper(s)           # ['HELLO', 'WORLD', 'NUMPY']
np.char.capitalize(s)      # ['Hello', 'World', 'Numpy']
np.char.add(s, "!")        # ['hello!', 'world!', 'numpy!']
np.char.replace(s, "l", "L")  # ['heLLo', 'worLd', 'numpy']
np.char.find(s, "o")       # [4, 1, -1]（找不到返回 -1）
np.char.split(np.array(["a b", "c d"]))  # 按空格拆分
```

## 矩阵运算

在 NumPy 中，矩阵运算直接用 `ndarray` 完成，无需使用已过时的 `numpy.matrix` 类。

```python
A = np.array([[1, 2], [3, 4]])
B = np.array([[5, 6], [7, 8]])

A.T            # 转置
A @ B          # 矩阵乘法（Python 3.5+，等同 np.matmul）
np.dot(A, B)   # 矩阵点积，与 @ 等效（二维时）
np.linalg.det(A)    # 行列式
np.linalg.inv(A)    # 逆矩阵
np.linalg.eig(A)    # 特征值与特征向量
```

{{< callout type="warning" >}}
`*` 运算符在 ndarray 上是**逐元素乘法**，不是矩阵乘法。矩阵乘法请用 `@` 或 `np.matmul()`。
{{< /callout >}}
