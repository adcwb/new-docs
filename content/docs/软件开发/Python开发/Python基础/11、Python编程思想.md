---
title: "Python编程思想"
weight: 11
date: 2026-06-23
tags: ["Python", "编程范式", "面向过程", "面向对象", "函数式"]
---

本篇介绍 Python 支持的主要编程范式：面向过程、函数式编程、面向对象，以及它们各自的适用场景。

## 什么是编程范式

编程范式是解决问题的思维框架和代码组织方式。Python 是**多范式语言**，同一问题可以用不同范式解决：

- **面向过程**：用函数将解决步骤顺序化。
- **函数式**：把计算视为数学函数的求值，强调无副作用。
- **面向对象**：将数据与操作封装在对象里，通过对象协作解决问题。

## 面向过程

面向过程以"过程（步骤）"为核心，先做什么、再做什么，适合线性的数据处理流程。

```python
# 示例：统计文件中各单词出现次数
import re
from pathlib import Path

def read_file(path: str) -> str:
    return Path(path).read_text(encoding="utf-8")

def extract_words(text: str) -> list[str]:
    return re.findall(r"\b\w+\b", text.lower())

def count_words(words: list[str]) -> dict[str, int]:
    result: dict[str, int] = {}
    for word in words:
        result[word] = result.get(word, 0) + 1
    return result

def top_n(counts: dict[str, int], n: int = 10) -> list[tuple[str, int]]:
    return sorted(counts.items(), key=lambda x: x[1], reverse=True)[:n]

# 主流程：步骤清晰，但可扩展性差
text = read_file("article.txt")
words = extract_words(text)
counts = count_words(words)
print(top_n(counts))
```

**优点**：逻辑直观，适合一次性脚本。  
**缺点**：随需求变化，各步骤紧密耦合，难以扩展和维护。

## 函数式编程

函数式编程的核心理念：函数是一等公民，避免共享状态和副作用，强调用数据变换（map/filter/reduce）来描述逻辑。

```python
from functools import reduce
import re

# 用函数式风格重写单词统计
text = "Hello world hello Python world"

# 每个步骤是一个纯函数（相同输入 → 相同输出，无副作用）
words = list(map(str.lower, re.findall(r"\b\w+\b", text)))

counts = reduce(
    lambda acc, w: {**acc, w: acc.get(w, 0) + 1},
    words,
    {}
)

top5 = sorted(counts.items(), key=lambda x: x[1], reverse=True)[:5]
print(top5)
```

函数式特性在 Python 中的体现：

```python
from functools import partial, reduce

# 高阶函数：函数接受函数或返回函数
def apply_twice(f, x):
    return f(f(x))

print(apply_twice(lambda x: x * 2, 3))   # 12

# partial：固定部分参数，生成新函数
from functools import partial

def power(base: int, exp: int) -> int:
    return base ** exp

square = partial(power, exp=2)
cube = partial(power, exp=3)

print(square(5))   # 25
print(cube(3))     # 27

# 不可变数据 + 推导式：避免修改原始数据
original = [1, 2, 3, 4, 5]
doubled = [x * 2 for x in original]   # 生成新列表，原列表不变
```

## 面向对象

面向对象以"对象"为核心，将相关数据和行为封装在一起，适合复杂系统和需要长期维护的项目。

```python
from dataclasses import dataclass, field
from collections import Counter
import re

@dataclass
class WordCounter:
    """统计文本中的词频。"""
    text: str
    _words: list[str] = field(default_factory=list, init=False, repr=False)

    def __post_init__(self):
        self._words = re.findall(r"\b\w+\b", self.text.lower())

    @property
    def counts(self) -> dict[str, int]:
        return dict(Counter(self._words))

    def top_n(self, n: int = 10) -> list[tuple[str, int]]:
        return Counter(self._words).most_common(n)

    def __len__(self) -> int:
        return len(self._words)

# 使用
wc = WordCounter("Hello world hello Python world")
print(wc.counts)       # {'hello': 2, 'world': 2, 'python': 1}
print(wc.top_n(3))     # [('hello', 2), ('world', 2), ('python', 1)]
print(len(wc))         # 5
```

面向对象的三大特性在 Python 中的应用：

```python
# 封装：通过属性控制访问
class BankAccount:
    def __init__(self, balance: float):
        self.__balance = balance   # 私有，外部无法直接访问

    @property
    def balance(self) -> float:
        return self.__balance

    def deposit(self, amount: float) -> None:
        if amount > 0:
            self.__balance += amount

# 继承：复用父类逻辑
class SavingsAccount(BankAccount):
    def __init__(self, balance: float, interest_rate: float):
        super().__init__(balance)
        self.interest_rate = interest_rate

    def apply_interest(self) -> None:
        self.deposit(self.balance * self.interest_rate)

# 多态：不同类型对象响应相同接口
class Shape:
    def area(self) -> float:
        raise NotImplementedError

class Circle(Shape):
    def __init__(self, r: float):
        self.r = r
    def area(self) -> float:
        import math
        return math.pi * self.r ** 2

class Rectangle(Shape):
    def __init__(self, w: float, h: float):
        self.w = w
        self.h = h
    def area(self) -> float:
        return self.w * self.h

shapes: list[Shape] = [Circle(5), Rectangle(4, 6)]
total_area = sum(s.area() for s in shapes)   # 各自调用自己的 area()
```

## 抽象类与接口

Python 通过 `abc` 模块实现抽象类，强制子类实现特定方法：

```python
from abc import ABC, abstractmethod

class DataSource(ABC):
    """数据源抽象基类：统一读取接口。"""

    @abstractmethod
    def connect(self) -> None:
        """建立连接。"""

    @abstractmethod
    def fetch(self, query: str) -> list[dict]:
        """执行查询，返回结果列表。"""

    def close(self) -> None:
        """关闭连接（提供默认实现）。"""
        print("连接已关闭")

class PostgresSource(DataSource):
    def connect(self) -> None:
        print("连接 PostgreSQL")

    def fetch(self, query: str) -> list[dict]:
        print(f"执行: {query}")
        return [{"id": 1, "name": "Alice"}]

# DataSource()          # TypeError：不能实例化抽象类
source = PostgresSource()
source.connect()
print(source.fetch("SELECT * FROM users"))
```

## 如何选择范式

| 场景 | 推荐范式 |
| ---- | -------- |
| 一次性脚本、数据处理流水线 | 面向过程 |
| 数据变换、无状态逻辑 | 函数式 |
| 复杂业务逻辑、长期维护的项目 | 面向对象 |
| 大型系统 | 混合使用，核心领域用 OOP，工具函数用函数式 |

Python 最推崇的风格是"**实用主义**"：不强制某种范式，而是选择最清晰、最易维护的方式。
