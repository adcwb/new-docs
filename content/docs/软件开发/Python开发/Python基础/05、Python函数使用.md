---
title: "Python函数使用"
weight: 5
date: 2026-06-23
tags: ["Python", "函数", "闭包", "作用域"]
---

函数是 Python 中最重要的代码组织单元。本篇涵盖函数定义、参数类型、作用域、闭包，以及现代 Python 的类型注解用法。

## 函数基础

### 定义与调用

```python
def greet(name: str) -> str:
    """返回问候语。"""
    return f"Hello, {name}!"

print(greet("Alice"))   # Hello, Alice!
```

函数体由 `def` 关键字、函数名、参数列表、冒号、函数体、可选的 `return` 组成。

- 没有 `return` 或只写 `return` 时，函数返回 `None`。
- 用 `"""..."""` 写 docstring（文档字符串），可用 `help(greet)` 查看。

### 多返回值

```python
def min_max(lst: list[int]) -> tuple[int, int]:
    return min(lst), max(lst)

lo, hi = min_max([3, 1, 4, 1, 5, 9])
print(lo, hi)   # 1 9
```

Python 实际上返回一个元组，调用处解包。

## 参数类型

### 位置参数与关键字参数

```python
def register(name: str, age: int, city: str = "北京") -> None:
    print(f"{name}，{age} 岁，来自 {city}")

register("Alice", 25)                # 按位置
register("Bob", age=30, city="上海") # 关键字参数可打破顺序
register("Carol", 22, "广州")
```

### 可变位置参数 `*args`

```python
def add(*numbers: int) -> int:
    return sum(numbers)

print(add(1, 2, 3, 4))   # 10

# *args 在调用时展开序列
nums = [1, 2, 3]
print(add(*nums))         # 6
```

### 可变关键字参数 `**kwargs`

```python
def build_url(host: str, **params: str) -> str:
    query = "&".join(f"{k}={v}" for k, v in params.items())
    return f"{host}?{query}" if query else host

print(build_url("example.com", page="1", sort="name"))
# example.com?page=1&sort=name

# **kwargs 在调用时展开字典
options = {"page": "2", "size": "20"}
print(build_url("api.example.com", **options))
```

### 参数顺序规则

完整参数顺序：**位置参数** → **默认参数** → `*args` → **命名关键字参数** → `**kwargs`

```python
def func(pos1, pos2, default="x", *args, kw_only, **kwargs):
    print(pos1, pos2, default, args, kw_only, kwargs)

func(1, 2, "y", 3, 4, kw_only="z", extra=99)
# 1 2 y (3, 4) z {'extra': 99}
```

### 仅位置参数 `/`（Python 3.8+）

```python
def circle_area(radius: float, /, *, precision: int = 2) -> float:
    import math
    return round(math.pi * radius ** 2, precision)

circle_area(5)              # radius 只能按位置传
circle_area(5, precision=4) # precision 只能按关键字传
# circle_area(radius=5)    # TypeError
```

`/` 左边的参数只能按位置传，`*` 右边的参数只能按关键字传。

## 作用域（LEGB 规则）

Python 按 **Local → Enclosing → Global → Built-in** 顺序查找名称：

```python
x = "global"

def outer():
    x = "enclosing"

    def inner():
        x = "local"
        print(x)   # local

    inner()
    print(x)       # enclosing

outer()
print(x)           # global
```

### global 与 nonlocal

```python
counter = 0

def increment() -> None:
    global counter          # 声明修改全局变量
    counter += 1

def make_counter():
    count = 0
    def inc():
        nonlocal count      # 声明修改外层函数的变量
        count += 1
        return count
    return inc

c = make_counter()
print(c(), c(), c())   # 1 2 3
```

## 闭包

闭包是引用了外层函数变量（自由变量）的内嵌函数，即使外层函数已返回，自由变量仍然存活：

```python
def multiplier(factor: int):
    def multiply(x: int) -> int:
        return x * factor   # factor 是自由变量
    return multiply

double = multiplier(2)
triple = multiplier(3)

print(double(5))    # 10
print(triple(5))    # 15

# 查看自由变量
print(double.__closure__[0].cell_contents)   # 2
```

常见用途：工厂函数、延迟计算、保存状态（类的轻量替代）。

## 函数对象

Python 中函数是一等对象，可以赋值、作为参数传递、作为返回值：

```python
def apply(func, values: list) -> list:
    return [func(v) for v in values]

print(apply(str.upper, ["hello", "world"]))
# ['HELLO', 'WORLD']

# 存入字典（策略模式）
ops = {
    "add": lambda x, y: x + y,
    "sub": lambda x, y: x - y,
    "mul": lambda x, y: x * y,
}
print(ops["add"](3, 4))   # 7
```

## 类型注解（推荐）

Python 3.5+ 支持类型注解，配合 mypy / pyright 可进行静态类型检查：

```python
from typing import Callable, Optional
from collections.abc import Sequence

def transform(
    data: Sequence[int],
    func: Callable[[int], int],
    default: Optional[int] = None,
) -> list[int]:
    """对序列中每个元素应用 func 变换。"""
    return [func(x) for x in data] if data else ([default] if default else [])

# Python 3.10+ 简写 Union
def parse(value: int | str | None) -> str:
    if value is None:
        return "null"
    return str(value)
```

## 常用内置函数

```python
nums = [3, 1, 4, 1, 5, 9, 2, 6]

# 排序（返回新列表）
print(sorted(nums))                         # 升序
print(sorted(nums, reverse=True))           # 降序
print(sorted(["banana", "apple"], key=len)) # 按长度排序

# map / filter（返回迭代器）
doubled = list(map(lambda x: x * 2, nums))
evens = list(filter(lambda x: x % 2 == 0, nums))

# zip（多序列并行迭代）
for a, b in zip([1, 2, 3], ["x", "y", "z"]):
    print(a, b)

# enumerate（带索引迭代）
for i, v in enumerate(nums, start=1):
    print(f"{i}: {v}")

# any / all
print(any(x > 8 for x in nums))    # True
print(all(x > 0 for x in nums))    # True
```
