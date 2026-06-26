---
title: "Python数据类型"
weight: 2
date: 2026-06-23
tags: ["Python", "数据类型", "字符串", "列表", "字典"]
---

本篇深入介绍 Python 六种内置容器数据类型的操作方法，并补充现代 Python（3.9+）新增的类型工具。

## 字符串

字符串是不可变的字符序列，支持丰富的内置方法。

### 定义与基本操作

```python
# 三种定义方式（本质相同）
s1 = 'hello'
s2 = "world"
s3 = """多行
字符串"""

# 拼接与重复
greeting = "Hello" + ", " + "Python"
line = "-" * 40

# 跨行拼接（反斜线续行，两个相邻字符串字面量自动合并）
long_str = ("这是第一部分"
            "这是第二部分")  # 推荐，括号内换行无需反斜线

# 索引与切片
s = "abcdef"
print(s[0])       # a（正向索引从 0 开始）
print(s[-1])      # f（逆向索引从 -1 开始）
print(s[2:5])     # cde
print(s[::2])     # ace（每隔一个取一个）
print(s[::-1])    # fedcba（反转）
```

### 常用内置方法

```python
s = "Hello World"

# 大小写
print(s.upper())        # HELLO WORLD
print(s.lower())        # hello world
print(s.capitalize())   # Hello world（首字母大写，其余小写）
print(s.title())        # Hello World
print(s.swapcase())     # hELLO wORLD

# 查找与判断
print(s.find("World"))        # 6（找不到返回 -1）
print(s.index("World"))       # 6（找不到抛 ValueError）
print(s.count("l"))           # 3
print(s.startswith("Hello"))  # True
print(s.endswith("World"))    # True
print("123".isdecimal())      # True
print("abc".isalpha())        # True

# 去除空白 / 指定字符
print("  hello  ".strip())        # hello
print("***hello***".strip("*"))   # hello
print("  hello".lstrip())         # hello（去左边）
print("hello  ".rstrip())         # hello（去右边）

# 分割与拼接
words = "a,b,c,d".split(",")       # ['a', 'b', 'c', 'd']
words2 = "a b c".split()           # ['a', 'b', 'c']（默认空白字符）
print(",".join(["a", "b", "c"]))   # a,b,c

# 替换
print("hello python".replace("python", "world"))  # hello world

# 对齐与填充
print("hi".center(10, "*"))   # ****hi****
print("hi".ljust(10, "-"))    # hi--------
print("hi".rjust(10, "-"))    # --------hi
print("42".zfill(5))          # 00042
```

### 格式化（三种方式对比）

```python
name, age = "Alice", 25

# 1. % 格式化（旧式，不推荐）
print("姓名: %s，年龄: %d" % (name, age))

# 2. str.format()
print("姓名: {}，年龄: {}".format(name, age))
print("{name} is {age} years old".format(name=name, age=age))
print("{:.2f}".format(3.14159))    # 3.14
print("{:>10}".format("right"))    # 右对齐，宽度 10
print("{:,}".format(1234567))      # 1,234,567

# 3. f-string（推荐，Python 3.6+）
print(f"姓名: {name}，年龄: {age}")
print(f"π ≈ {3.14159:.2f}")
print(f"{age + 1} 岁")
print(f"{name!r}")                 # 'Alice'（repr 形式）
print(f"{name=}")                  # name='Alice'（Python 3.8+，调试利器）
```

## 列表

列表是有序、可变、元素类型任意的序列。

### 列表的定义与切片

```python
lst = [1, "hello", 3.14, True, [2, 3]]

# 切片（与字符串语法相同）
nums = [0, 1, 2, 3, 4, 5]
print(nums[1:4])     # [1, 2, 3]
print(nums[::2])     # [0, 2, 4]
print(nums[::-1])    # [5, 4, 3, 2, 1]

# 切片赋值（原地修改）
nums[1:3] = [10, 20]
print(nums)          # [0, 10, 20, 3, 4, 5]
```

### 列表的常用方法

```python
lst = ["a", "b", "c"]

# 增
lst.append("d")           # 末尾追加单个元素 → ['a', 'b', 'c', 'd']
lst.insert(1, "x")        # 在索引 1 前插入 → ['a', 'x', 'b', 'c', 'd']
lst.extend([1, 2])        # 迭代追加多个元素 → ['a', 'x', 'b', 'c', 'd', 1, 2]

# 删
lst.pop()                 # 删除并返回最后一个元素
lst.pop(0)                # 删除并返回索引 0 的元素
lst.remove("x")           # 删除第一个值为 "x" 的元素
lst.clear()               # 清空列表

# 查
lst = [3, 1, 4, 1, 5, 9]
print(lst.index(1))       # 1（第一次出现的索引）
print(lst.count(1))       # 2（出现次数）

# 排序与反转
lst.sort()                # 原地升序排序 → [1, 1, 3, 4, 5, 9]
lst.sort(reverse=True)    # 原地降序排序
lst.reverse()             # 原地反转

# 内置函数
print(sorted([3, 1, 2]))  # [1, 2, 3]（返回新列表，不改变原列表）
print(len(lst))
print(max(lst), min(lst), sum(lst))
```

### 列表推导式

```python
# 基本形式
squares = [x ** 2 for x in range(10)]

# 带条件
evens = [x for x in range(20) if x % 2 == 0]

# 嵌套
matrix = [[i * j for j in range(1, 4)] for i in range(1, 4)]

# Python 3.9+：list 直接作为类型注解
def process(items: list[int]) -> list[str]:
    return [str(x) for x in items]
```

## 元组

元组是有序、**不可变**的序列，常用于返回多个值或作为字典的键。

```python
# 定义
t = (1, 2, 3)
single = (42,)          # 单元素元组，必须有逗号

# 解包
x, y, z = (1, 2, 3)
first, *rest = (1, 2, 3, 4, 5)   # first=1, rest=[2, 3, 4, 5]

# 仅支持 index 和 count
print(t.index(2))    # 1
print(t.count(1))    # 1

# 命名元组（Python 3.6+ dataclass 更现代，但 namedtuple 仍常用）
from collections import namedtuple
Point = namedtuple("Point", ["x", "y"])
p = Point(1.0, 2.0)
print(p.x, p.y)      # 1.0  2.0
```

## 字典

字典是键值对容器（Python 3.7+ 保证插入顺序）。

### 字典的定义与基本操作

```python
# 定义
person = {"name": "Alice", "age": 25}

# 访问（推荐 get 避免 KeyError）
print(person["name"])               # Alice
print(person.get("city", "未知"))   # 未知（键不存在时返回默认值）

# 增 / 改
person["email"] = "alice@example.com"
person.update({"age": 26, "city": "Beijing"})

# 删
age = person.pop("age")             # 删除并返回值
person.popitem()                    # 删除并返回最后插入的键值对（Python 3.7+）
del person["email"]

# 遍历
for k, v in person.items():
    print(f"{k}: {v}")

print(list(person.keys()))
print(list(person.values()))
```

### 字典推导式与合并（Python 3.9+）

```python
# 字典推导式
squares = {x: x ** 2 for x in range(5)}

# setdefault：键不存在时设置默认值并返回
d = {"a": 1}
d.setdefault("b", 0)    # d = {"a": 1, "b": 0}

# fromkeys：用键列表批量创建字典
keys = ["x", "y", "z"]
d = dict.fromkeys(keys, 0)   # {"x": 0, "y": 0, "z": 0}

# Python 3.9+ 字典合并运算符
defaults = {"color": "red", "size": 10}
custom = {"color": "blue"}
merged = defaults | custom          # 新字典，custom 覆盖 defaults
defaults |= custom                  # 原地合并

# Python 3.9+：dict 直接作为类型注解
def config() -> dict[str, int]:
    return {"timeout": 30}
```

## 集合

集合是无序、不重复的元素容器，主要用于**去重**和**关系运算**。

```python
# 定义
s = {1, 2, 3, 2, 1}   # 自动去重 → {1, 2, 3}
empty = set()           # 空集合，不能用 {}（那是空字典）

# 常用方法
s.add(4)
s.update([5, 6])
s.discard(99)           # 删除元素，不存在时不报错（推荐）
s.remove(1)             # 删除元素，不存在时抛 KeyError

# 集合运算
a = {1, 2, 3, 4}
b = {3, 4, 5, 6}

print(a | b)            # 并集 {1, 2, 3, 4, 5, 6}
print(a & b)            # 交集 {3, 4}
print(a - b)            # 差集 {1, 2}（属于 a 但不属于 b）
print(a ^ b)            # 对称差集 {1, 2, 5, 6}（各自独有的元素）

print({1, 2} < {1, 2, 3})    # True（子集判断）
print({1, 2, 3} > {1, 2})    # True（父集判断）
print({1, 2}.isdisjoint({3, 4}))  # True（不相交）

# frozenset：不可变集合，可作为字典的键
fs = frozenset([1, 2, 3])
```

## 可变与不可变类型

| 类型 | 可变 | 说明 |
| ---- | :--: | ---- |
| `int`、`float`、`str`、`tuple`、`frozenset` | 否 | 修改时产生新对象，id 改变 |
| `list`、`dict`、`set` | 是 | 原地修改，id 不变 |

```python
# 不可变示例
s = "hello"
old_id = id(s)
s += "!"
print(id(s) == old_id)   # False，s 指向新字符串

# 可变示例
lst = [1, 2, 3]
old_id = id(lst)
lst.append(4)
print(id(lst) == old_id)  # True，原地修改
```

## 深拷贝与浅拷贝

```python
import copy

original = [1, [2, 3], 4]

# 浅拷贝：只复制外层，内层仍共享引用
shallow = copy.copy(original)
shallow = original[:]          # 等价写法

# 修改内层会影响原列表
shallow[1].append(99)
print(original)    # [1, [2, 3, 99], 4]  ← 受影响

# 深拷贝：完全独立的副本
deep = copy.deepcopy(original)
deep[1].append(100)
print(original)    # [1, [2, 3, 99], 4]  ← 不受影响
```

## 现代类型注解工具（Python 3.9+）

### TypedDict

```python
from typing import TypedDict

class Movie(TypedDict):
    title: str
    year: int
    rating: float

m: Movie = {"title": "Inception", "year": 2010, "rating": 8.8}
```

### dataclass

```python
from dataclasses import dataclass, field

@dataclass
class Point:
    x: float
    y: float
    label: str = "origin"
    tags: list[str] = field(default_factory=list)

    def distance(self) -> float:
        return (self.x ** 2 + self.y ** 2) ** 0.5

p = Point(3.0, 4.0, label="A")
print(p.distance())    # 5.0
print(p)               # Point(x=3.0, y=4.0, label='A', tags=[])
```

{{< callout type="info" >}}
`dataclass` 自动生成 `__init__`、`__repr__`、`__eq__` 等方法，是定义数据类的首选方式（Python 3.7+）。对于需要不可变保证的场景，使用 `@dataclass(frozen=True)`。
{{< /callout >}}
