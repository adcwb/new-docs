---
title: "Pandas 使用指南"
weight: 30
date: 2026-06-27
tags: ["Python", "Pandas", "数据分析", "DataFrame"]
---

Pandas 是 Python 数据分析的核心库，弥补了 NumPy 只擅长纯数值运算的短板。它提供两种核心数据结构：**Series**（带标签的一维数组）和 **DataFrame**（带行列标签的二维表格），并内置了数据读写、清洗、聚合、时间序列处理等大量工具。

本文覆盖 Pandas 的核心用法，示例基于 **Pandas 2.x**。

```bash
pip install pandas
```

```python
import pandas as pd
import numpy as np
print(pd.__version__)  # 2.x
```

## Series

Series 是一维带标签数组，每个元素有对应的索引。

### 创建 Series

```python
# 从列表创建（默认 0, 1, 2... 为索引）
s = pd.Series([10, 20, 30])

# 指定自定义索引
s = pd.Series([10, 20, 30], index=["a", "b", "c"])

# 从字典创建（键自动成为索引）
s = pd.Series({"语文": 95, "数学": 88, "英语": 76})
print(s)
# 语文    95
# 数学    88
# 英语    76
# dtype: int64
```

### 索引与切片

```python
s = pd.Series([10, 20, 30], index=["a", "b", "c"])

s["a"]      # 按标签取值：10
s[0]        # 按位置取值：10（Pandas 2.x 中不推荐，优先用 iloc）
s.loc["a"]  # 显式标签索引
s.iloc[0]   # 显式位置索引

# 切片
s.loc["a":"b"]   # 包含终点，返回 a、b 两条
s.iloc[0:2]      # 不含终点，返回前 2 条

# 布尔索引
s[s > 15]        # 筛选大于 15 的元素
```

### 常用属性与方法

```python
s = pd.Series([1, 1, 2, 2, 3, None])

s.index        # 查看索引
s.values       # 查看值（numpy 数组）
s.shape        # (6,)
s.size         # 6
s.dtype        # 元素类型

s.head(3)          # 前 3 条
s.tail(3)          # 后 3 条
s.unique()         # 去重后的值
s.nunique()        # 去重后的元素个数
s.value_counts()   # 每个值出现的次数
s.isnull()         # 是否为空（NaN）
s.notnull()        # 是否非空
s.dropna()         # 删除空值
s.fillna(0)        # 将空值填充为 0
```

### 算术运算

Series 运算按**索引对齐**，索引不匹配的位置结果为 `NaN`：

```python
s1 = pd.Series([1, 2, 3], index=["a", "b", "c"])
s2 = pd.Series([4, 5, 6], index=["a", "d", "c"])

s1 + s2
# a    5.0
# b    NaN   ← b 在 s2 中不存在
# c    9.0
# d    NaN   ← d 在 s1 中不存在
```

## DataFrame

DataFrame 是二维带行列标签的表格，可以把它理解为"一组共享同一行索引的 Series"。

### 创建 DataFrame

```python
# 从字典创建（键为列名）
df = pd.DataFrame({
    "name":   ["Alice", "Bob", "Carol"],
    "score":  [90, 75, 88],
    "grade":  ["A", "C", "B"],
})

# 从 NumPy 数组创建
df = pd.DataFrame(
    np.random.randint(0, 100, size=(4, 3)),
    columns=["语文", "数学", "英语"],
    index=["张三", "李四", "王五", "赵六"],
)
```

### 常用属性

```python
df.shape      # (行数, 列数)
df.index      # 行索引
df.columns    # 列名
df.dtypes     # 各列数据类型
df.info()     # 概览：列名、非空数量、类型、内存
df.describe() # 数值列的统计摘要（均值、标准差、分位数等）
df.head(3)    # 前 3 行
df.tail(3)    # 后 3 行
```

### 行列索引与切片

| 操作 | 写法 | 说明 |
| :--- | :--- | :--- |
| 取列 | `df["col"]` 或 `df.col` | 返回 Series |
| 取多列 | `df[["col1", "col2"]]` | 返回 DataFrame |
| 取行（标签） | `df.loc["idx"]` | 按行索引标签 |
| 取行（位置） | `df.iloc[0]` | 按行位置 |
| 取元素 | `df.loc["idx", "col"]` | 行标签 + 列名 |
| 取元素 | `df.iloc[0, 1]` | 行位置 + 列位置 |
| 行切片 | `df[0:2]` | 前 2 行（位置） |
| 行列同时切片 | `df.iloc[0:2, 0:3]` | 前 2 行 + 前 3 列 |

```python
df = pd.DataFrame(
    {"语文": [90, 75], "数学": [88, 60]},
    index=["张三", "李四"]
)

df["语文"]                    # 取一列
df.loc["张三"]                # 取一行
df.loc["张三", "数学"]        # 取一个元素：88
df.iloc[0, 1]                 # 等效：88
df.loc["张三":"李四", "语文"]  # 行列同时切片
```

### 新增、修改与删除

```python
# 新增列
df["总分"] = df["语文"] + df["数学"]

# 修改单个值
df.loc["张三", "语文"] = 95

# 删除列
df.drop(columns=["总分"], inplace=True)

# 删除行
df.drop(index=["张三"], inplace=True)
```

### 布尔过滤

```python
df[df["语文"] > 80]                          # 语文分数大于 80 的行
df[(df["语文"] > 80) & (df["数学"] > 70)]    # 多条件（& 且，| 或）
df[df["语文"].isin([75, 90])]               # 值在列表中
```

## 数据读写

```python
# 读取 CSV
df = pd.read_csv("data.csv", encoding="utf-8")
df = pd.read_csv("data.csv", index_col=0)       # 第 0 列作为行索引
df = pd.read_csv("data.csv", parse_dates=["date"])  # 自动解析日期列

# 读取 Excel
df = pd.read_excel("data.xlsx", sheet_name="Sheet1")

# 写出
df.to_csv("output.csv", index=False)    # 不写出行索引
df.to_excel("output.xlsx", index=False)
```

## 缺失值处理

```python
df.isnull().sum()          # 每列的缺失值数量
df.isnull().any()          # 每列是否有缺失值

df.dropna()                # 删除含 NaN 的行
df.dropna(axis=1)          # 删除含 NaN 的列
df.dropna(thresh=2)        # 保留至少有 2 个非空值的行

df.fillna(0)               # 用 0 填充
df.fillna(df.mean())       # 用均值填充
df.fillna(method="ffill")  # 向前填充（用上一个有效值填充）
```

## 分组聚合

`groupby` 是 Pandas 最常用的聚合工具，思路类似 SQL 的 `GROUP BY`。

```python
df = pd.DataFrame({
    "部门": ["研发", "研发", "销售", "销售", "研发"],
    "姓名": ["Alice", "Bob", "Carol", "Dave", "Eve"],
    "薪资": [15000, 12000, 9000, 11000, 14000],
})

# 按部门统计平均薪资
df.groupby("部门")["薪资"].mean()
# 部门
# 研发    13666.67
# 销售    10000.00

# 同时计算多个统计量
df.groupby("部门")["薪资"].agg(["mean", "max", "count"])

# 多列分组
df.groupby(["部门", "姓名"])["薪资"].sum()
```

## 时间序列

Pandas 对时间序列有一流支持，时间索引使 `resample`、`shift`、滚动统计等操作非常简便。

```python
# 生成时间索引
dates = pd.date_range("2024-01-01", periods=10, freq="B")  # B = 工作日

df = pd.DataFrame({
    "price": [100, 102, 98, 105, 103, 107, 104, 108, 106, 110]
}, index=dates)

# 按月重采样（取每月最后一个值）
df.resample("ME").last()

# 计算日涨跌幅
df["return"] = df["price"].pct_change()

# 5 日移动平均
df["ma5"] = df["price"].rolling(window=5).mean()

# 数据平移（shift(1) 取前一日收盘价）
df["prev_price"] = df["price"].shift(1)
```

## 综合示例：成绩分析

用内置数据演示完整的数据分析流程：

```python
import pandas as pd
import numpy as np

# 构造示例数据
rng = np.random.default_rng(42)
df = pd.DataFrame({
    "姓名":  ["张三", "李四", "王五", "赵六", "钱七"],
    "班级":  ["A", "B", "A", "B", "A"],
    "语文":  rng.integers(60, 100, 5),
    "数学":  rng.integers(60, 100, 5),
    "英语":  rng.integers(60, 100, 5),
})

# 新增总分与平均分
df["总分"] = df[["语文", "数学", "英语"]].sum(axis=1)
df["平均分"] = df["总分"] / 3

# 筛选总分高于 240 的学生
df[df["总分"] > 240]

# 按班级统计平均分
df.groupby("班级")[["语文", "数学", "英语"]].mean().round(1)

# 按总分降序排列
df.sort_values("总分", ascending=False)

# 各科缺考情况（模拟）
df.loc[2, "英语"] = np.nan
df.isnull().sum()       # 查看缺失
df.fillna(df["英语"].mean(), inplace=True)  # 用均值填充
```
