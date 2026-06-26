---
title: "Python内置函数"
weight: 6
date: 2026-06-23
tags: ["Python", "内置函数", "魔术方法", "dunder"]
---

Python 提供了大量内置函数（无需 import 即可使用）以及一套"魔术方法"（dunder methods）协议，允许自定义类与内置操作符和函数协同工作。

## 常用内置函数

### 数学计算

```python
print(abs(-5))             # 5
print(round(3.14159, 2))   # 3.14
print(sum([1, 2, 3, 4]))   # 10
print(max(3, 1, 4, 1, 5))  # 5
print(min([3, 1, 4]))      # 1
print(pow(2, 10))          # 1024
print(divmod(17, 5))       # (3, 2) → 商和余数
```

### 类型转换

```python
print(int("42"))           # 42
print(int("0xff", 16))     # 255（十六进制字符串）
print(float("3.14"))       # 3.14
print(str(123))            # '123'
print(bool(0))             # False
print(list(range(5)))      # [0, 1, 2, 3, 4]
print(tuple([1, 2, 3]))    # (1, 2, 3)
print(set([1, 2, 2, 3]))   # {1, 2, 3}
print(dict(a=1, b=2))      # {'a': 1, 'b': 2}
print(bytes("hello", "utf-8"))  # b'hello'
```

### 进制转换

```python
print(bin(255))   # '0b11111111'（二进制）
print(oct(255))   # '0o377'（八进制）
print(hex(255))   # '0xff'（十六进制）

# 反向：字符串 → 整数
print(int("0b11111111", 2))   # 255
print(int("0xff", 16))        # 255
```

### 字符与编码

```python
print(ord("A"))    # 65（字符 → ASCII/Unicode 码点）
print(chr(65))     # 'A'（码点 → 字符）
print(ord("中"))   # 20013
print(chr(20013))  # '中'
```

### 序列操作

```python
nums = [3, 1, 4, 1, 5, 9, 2, 6]

# sorted：返回新列表，不修改原序列
print(sorted(nums))                           # [1, 1, 2, 3, 4, 5, 6, 9]
print(sorted(nums, reverse=True))             # 降序
print(sorted(["banana", "apple"], key=len))   # 按长度排序

# reversed：返回迭代器
print(list(reversed(nums)))

# enumerate：带索引迭代
for i, v in enumerate(["a", "b", "c"], start=1):
    print(f"{i}: {v}")

# zip：多序列并行迭代
for name, score in zip(["Alice", "Bob"], [90, 85]):
    print(f"{name}: {score}")

# zip 在 Python 3.10+ 支持 strict 参数
# list(zip([1, 2], [1, 2, 3], strict=True))  # 长度不同时报错

# map / filter
doubles = list(map(lambda x: x * 2, nums))
evens = list(filter(lambda x: x % 2 == 0, nums))

# any / all
print(any(x > 8 for x in nums))   # True
print(all(x > 0 for x in nums))   # True
```

### 对象检查

```python
print(type(42))              # <class 'int'>
print(isinstance(42, int))   # True
print(isinstance(42, (int, float)))  # True（多类型检查）
print(issubclass(bool, int)) # True（bool 是 int 的子类）

print(id(42))        # 对象内存地址（Python CPython 实现）
print(len([1, 2, 3]))  # 3
print(hash("hello"))   # 散列值

# 代码执行（谨慎使用，存在安全风险）
result = eval("2 + 3 * 4")   # 14
exec("x = 10; print(x)")     # 执行语句
```

### 输入输出

```python
name = input("请输入姓名: ")  # 始终返回字符串
age = int(input("请输入年龄: "))

print("Hello", "World", sep=", ", end="!\n")  # Hello, World!
print(f"姓名: {name}, 年龄: {age}")

# repr：显示字符串的原始表示（不转义）
print(repr("hello\nworld"))   # 'hello\\nworld'
```

### 其他实用函数

```python
# range
for i in range(0, 10, 2):  # 0, 2, 4, 6, 8
    print(i)

# open（文件操作）
with open("file.txt", "r", encoding="utf-8") as f:
    print(f.read())

# vars / dir
print(vars())         # 当前作用域的变量字典
print(dir(str))       # 查看 str 的所有属性和方法
print(help(sorted))   # 查看函数文档

# iter / next（手动迭代）
it = iter([1, 2, 3])
print(next(it))  # 1
print(next(it))  # 2
```

## 魔术方法（Dunder Methods）

魔术方法以双下划线开头和结尾（`__xxx__`），Python 会在特定情况下自动调用它们。

### 对象生命周期

```python
class MyClass:
    def __new__(cls, *args, **kwargs):
        """创建对象（在 __init__ 之前）。通常不需要重写。"""
        print("__new__ 被调用")
        return super().__new__(cls)

    def __init__(self, value: int):
        """初始化对象。"""
        print("__init__ 被调用")
        self.value = value

    def __del__(self):
        """对象被垃圾回收时调用。不推荐依赖此方法做资源清理。"""
        print(f"__del__ 被调用，value={self.value}")

obj = MyClass(42)  # 依次调用 __new__ 和 __init__
```

### 字符串表示

```python
class Point:
    def __init__(self, x: float, y: float):
        self.x = x
        self.y = y

    def __str__(self) -> str:
        """print(obj) 或 str(obj) 时调用，面向普通用户的可读表示。"""
        return f"({self.x}, {self.y})"

    def __repr__(self) -> str:
        """repr(obj) 时调用，面向开发者的调试表示，应可复现对象。"""
        return f"Point(x={self.x}, y={self.y})"

p = Point(3.0, 4.0)
print(p)       # (3.0, 4.0)     → 调用 __str__
print(repr(p)) # Point(x=3.0, y=4.0) → 调用 __repr__
```

### 运算符重载

```python
class Vector:
    def __init__(self, x: float, y: float):
        self.x = x
        self.y = y

    def __add__(self, other: "Vector") -> "Vector":
        return Vector(self.x + other.x, self.y + other.y)

    def __sub__(self, other: "Vector") -> "Vector":
        return Vector(self.x - other.x, self.y - other.y)

    def __mul__(self, scalar: float) -> "Vector":
        return Vector(self.x * scalar, self.y * scalar)

    def __abs__(self) -> float:
        return (self.x ** 2 + self.y ** 2) ** 0.5

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Vector):
            return NotImplemented
        return self.x == other.x and self.y == other.y

    def __repr__(self) -> str:
        return f"Vector({self.x}, {self.y})"

v1 = Vector(1, 2)
v2 = Vector(3, 4)
print(v1 + v2)    # Vector(4, 6)
print(abs(v2))    # 5.0
print(v1 == v1)   # True
```

### 容器协议

```python
class Stack:
    def __init__(self):
        self._items: list = []

    def push(self, item) -> None:
        self._items.append(item)

    def pop(self):
        return self._items.pop()

    def __len__(self) -> int:
        """len(obj) 时调用。"""
        return len(self._items)

    def __contains__(self, item) -> bool:
        """in 操作符时调用。"""
        return item in self._items

    def __getitem__(self, index):
        """obj[i] 时调用。"""
        return self._items[index]

    def __iter__(self):
        """for x in obj 时调用。"""
        return iter(self._items)

s = Stack()
s.push(1)
s.push(2)
print(len(s))       # 2
print(1 in s)       # True
print(s[0])         # 1
```

### 可调用对象

```python
class Adder:
    def __init__(self, n: int):
        self.n = n

    def __call__(self, x: int) -> int:
        """obj(args) 时调用，使对象可以像函数一样被调用。"""
        return x + self.n

add5 = Adder(5)
print(add5(10))    # 15
print(callable(add5))  # True
```

### 上下文管理器

```python
class Timer:
    def __enter__(self):
        import time
        self._start = time.perf_counter()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        import time
        self.elapsed = time.perf_counter() - self._start
        print(f"耗时: {self.elapsed:.4f}s")
        return False   # 不吞掉异常

with Timer() as t:
    import time
    time.sleep(0.1)
# 耗时: 0.1001s
```

## 内置属性

```python
class Dog:
    """狗类。"""
    species = "Canis lupus familiaris"

    def __init__(self, name: str):
        self.name = name

fido = Dog("Fido")

print(Dog.__name__)      # 'Dog'
print(Dog.__doc__)       # '狗类。'
print(Dog.__dict__)      # 类的命名空间字典
print(fido.__dict__)     # 实例的属性字典 {'name': 'Fido'}
print(fido.__class__)    # <class '__main__.Dog'>
print(Dog.__bases__)     # (<class 'object'>,)  直接父类元组
print(Dog.__mro__)       # 方法解析顺序
```
