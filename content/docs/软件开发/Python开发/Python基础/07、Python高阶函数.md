---
title: "Python高阶函数"
weight: 7
date: 2026-06-23
tags: ["Python", "装饰器", "迭代器", "生成器", "高阶函数"]
---

本篇介绍 Python 的高阶特性：装饰器、迭代器、生成器、lambda 以及 `map`/`filter`/`reduce` 等内置高阶函数。

## 装饰器

装饰器在不修改原函数源码和调用方式的前提下，为函数添加额外功能，遵循**开放封闭原则**。

### 无参装饰器

```python
import time
import functools

def timer(func):
    @functools.wraps(func)   # 保留原函数的 __name__ 和 __doc__
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        elapsed = time.perf_counter() - start
        print(f"{func.__name__} 耗时 {elapsed:.4f}s")
        return result
    return wrapper

@timer
def slow_add(a: int, b: int) -> int:
    """返回两数之和。"""
    time.sleep(0.1)
    return a + b

print(slow_add(1, 2))   # slow_add 耗时 0.1001s → 3
print(slow_add.__name__)  # slow_add（而非 wrapper）
```

### 有参装饰器

当装饰器本身需要参数时，多套一层函数：

```python
def repeat(times: int):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            for _ in range(times):
                result = func(*args, **kwargs)
            return result
        return wrapper
    return decorator

@repeat(3)
def say(message: str) -> None:
    print(message)

say("Hello!")   # 打印三次 Hello!
```

### 装饰器叠加

多个装饰器叠加时，**加载顺序从下到上**（先应用最近的），**执行顺序从外到内**：

```python
@deco_a
@deco_b
@deco_c
def func(): ...
# 等价于 func = deco_a(deco_b(deco_c(func)))
```

### 类装饰器

通过实现 `__call__` 方法，类也可以作为装饰器使用：

```python
class Retry:
    def __init__(self, max_tries: int = 3):
        self.max_tries = max_tries

    def __call__(self, func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(1, self.max_tries + 1):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    if attempt == self.max_tries:
                        raise
                    print(f"第 {attempt} 次失败: {e}，重试中...")
        return wrapper

@Retry(max_tries=3)
def unstable_request(url: str) -> str:
    import random
    if random.random() < 0.7:
        raise ConnectionError("连接失败")
    return "success"
```

### 常用标准库装饰器

```python
from functools import cache, lru_cache, cached_property

# @cache：无限缓存（Python 3.9+，等价于 @lru_cache(maxsize=None)）
@cache
def fib(n: int) -> int:
    if n < 2:
        return n
    return fib(n - 1) + fib(n - 2)

print(fib(50))   # 瞬间完成

# @lru_cache：最近最少使用缓存
@lru_cache(maxsize=128)
def expensive(x: int) -> int:
    return x ** 2

# @cached_property：属性级缓存（只计算一次）
class Circle:
    def __init__(self, r: float):
        self.r = r

    @cached_property
    def area(self) -> float:
        import math
        return math.pi * self.r ** 2
```

## 迭代器

### 可迭代对象与迭代器

- **可迭代对象**：实现了 `__iter__()` 方法（如 list、str、dict）。
- **迭代器**：同时实现了 `__iter__()` 和 `__next__()` 方法，支持逐个取值。

```python
lst = [1, 2, 3]

# 创建迭代器
it = iter(lst)   # 等价于 lst.__iter__()
print(next(it))  # 1
print(next(it))  # 2
print(next(it))  # 3
# next(it)       # StopIteration

# for 循环本质上就是：调用 iter() 获得迭代器，然后反复调用 next()
for x in lst:
    print(x)
```

### 自定义迭代器

```python
class CountUp:
    def __init__(self, start: int, stop: int):
        self.current = start
        self.stop = stop

    def __iter__(self):
        return self

    def __next__(self) -> int:
        if self.current >= self.stop:
            raise StopIteration
        val = self.current
        self.current += 1
        return val

for n in CountUp(1, 5):
    print(n)   # 1 2 3 4
```

## 生成器

生成器是用 `yield` 关键字定义的特殊迭代器，**惰性计算**，节省内存。

### 生成器函数

```python
def fibonacci():
    a, b = 0, 1
    while True:
        yield a
        a, b = b, a + b

gen = fibonacci()
print([next(gen) for _ in range(10)])
# [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]

# yield from：委托给另一个可迭代对象（Python 3.3+）
def chain(*iterables):
    for it in iterables:
        yield from it

print(list(chain([1, 2], [3, 4], [5])))   # [1, 2, 3, 4, 5]
```

### 生成器表达式

```python
# 圆括号 → 生成器（惰性）
gen = (x ** 2 for x in range(1_000_000))

# 方括号 → 列表（立即求值，占用内存）
lst = [x ** 2 for x in range(1_000_000)]

# 作为函数参数时无需额外括号
total = sum(x ** 2 for x in range(100))
```

### send() 与双向通信

```python
def accumulator():
    total = 0
    while True:
        value = yield total   # yield 同时返回值并接收外部传入值
        if value is None:
            break
        total += value

gen = accumulator()
next(gen)          # 启动生成器，运行到第一个 yield
print(gen.send(10))  # 10
print(gen.send(20))  # 30
print(gen.send(30))  # 60
```

## lambda 匿名函数

```python
# lambda 参数: 表达式（只能写单个表达式）
square = lambda x: x ** 2
print(square(5))   # 25

# 常与 sorted/map/filter 配合使用
students = [("Alice", 90), ("Bob", 85), ("Charlie", 95)]
sorted_students = sorted(students, key=lambda s: s[1], reverse=True)
# [('Charlie', 95), ('Alice', 90), ('Bob', 85)]
```

{{< callout type="warning" >}}
`lambda` 只适合简单表达式。有名字、有逻辑的函数请用 `def` 定义，不要把复杂逻辑塞进 `lambda`。
{{< /callout >}}

## 内置高阶函数

### map

```python
# map(func, iterable) → 惰性迭代器
nums = [1, 2, 3, 4, 5]
squares = list(map(lambda x: x ** 2, nums))
# [1, 4, 9, 16, 25]

# 现代写法：列表推导式更清晰
squares = [x ** 2 for x in nums]
```

### filter

```python
# filter(func, iterable) → 保留 func 返回 True 的元素
evens = list(filter(lambda x: x % 2 == 0, range(10)))
# [0, 2, 4, 6, 8]

# 现代写法
evens = [x for x in range(10) if x % 2 == 0]
```

### reduce

```python
from functools import reduce

# reduce(func, iterable[, initial])
# 将序列中的元素累积计算
product = reduce(lambda x, y: x * y, [1, 2, 3, 4, 5])
# 120（等价于 ((((1*2)*3)*4)*5)）

total = reduce(lambda acc, x: acc + x, range(1, 101), 0)
# 5050
```

## 递归

```python
def factorial(n: int) -> int:
    if n <= 1:
        return 1
    return n * factorial(n - 1)

print(factorial(10))   # 3628800

# Python 默认递归深度限制为 1000
import sys
print(sys.getrecursionlimit())   # 1000
# sys.setrecursionlimit(5000)    # 可调整，但不推荐

# 尾递归优化技巧：用 @cache 避免重复计算
@cache
def fib(n: int) -> int:
    if n < 2:
        return n
    return fib(n - 1) + fib(n - 2)
```

## sorted 的高级用法

```python
data = [
    {"name": "Charlie", "age": 30},
    {"name": "Alice", "age": 25},
    {"name": "Bob", "age": 28},
]

# 按 age 升序
by_age = sorted(data, key=lambda d: d["age"])

# 多键排序（先按 age 升序，再按 name 字母顺序）
from operator import itemgetter
multi = sorted(data, key=itemgetter("age", "name"))

# operator 模块（比 lambda 更高效）
from operator import attrgetter
# sorted(objects, key=attrgetter("attr1", "attr2"))
```
