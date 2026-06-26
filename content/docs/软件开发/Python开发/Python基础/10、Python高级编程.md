---
title: "Python高级编程"
weight: 10
date: 2026-06-23
tags: ["Python", "OOP", "面向对象", "类型注解"]
---

本篇介绍 Python 面向对象编程（OOP）的核心特性：封装、继承、多态，以及现代 Python 中的类型注解、抽象类等高级用法。

## 封装

封装将数据与操作数据的方法绑定在一起，并通过访问控制来限制外部的直接访问。

### 私有属性（双下划线变形）

```python
class BankAccount:
    def __init__(self, owner: str, balance: float):
        self.owner = owner        # 公有属性
        self.__balance = balance  # 私有属性（变形为 _BankAccount__balance）

    def deposit(self, amount: float) -> None:
        if amount <= 0:
            raise ValueError("存款金额必须为正数")
        self.__balance += amount

    def get_balance(self) -> float:
        return self.__balance

acc = BankAccount("Alice", 1000.0)
acc.deposit(500)
print(acc.get_balance())       # 1500.0
# print(acc.__balance)         # AttributeError（外部无法直接访问）
print(acc._BankAccount__balance)  # 1500.0（知道变形规则仍可访问，不建议）
```

### @property 装饰器

`@property` 将方法伪装成属性访问，同时可以添加 getter / setter / deleter 逻辑：

```python
class Circle:
    def __init__(self, radius: float):
        self.__radius = radius

    @property
    def radius(self) -> float:
        return self.__radius

    @radius.setter
    def radius(self, value: float) -> None:
        if value < 0:
            raise ValueError("半径不能为负数")
        self.__radius = value

    @property
    def area(self) -> float:
        import math
        return math.pi * self.__radius ** 2

c = Circle(5)
print(c.radius)    # 5
print(c.area)      # 78.539...
c.radius = 10      # 触发 setter
c.radius = -1      # ValueError
```

## 继承

继承允许子类复用父类的属性和方法，并可以扩展或覆盖父类行为。

### 单继承

```python
class Animal:
    def __init__(self, name: str):
        self.name = name

    def speak(self) -> str:
        raise NotImplementedError("子类必须实现 speak 方法")

    def __repr__(self) -> str:
        return f"{self.__class__.__name__}(name={self.name!r})"

class Dog(Animal):
    def speak(self) -> str:
        return f"{self.name} says: Woof!"

class Cat(Animal):
    def speak(self) -> str:
        return f"{self.name} says: Meow!"

dog = Dog("Rex")
print(dog.speak())   # Rex says: Woof!
print(dog)           # Dog(name='Rex')
```

### super() 调用父类方法

```python
class Vehicle:
    def __init__(self, brand: str, speed: int):
        self.brand = brand
        self.speed = speed

    def info(self) -> str:
        return f"{self.brand}，最高速度 {self.speed} km/h"

class ElectricCar(Vehicle):
    def __init__(self, brand: str, speed: int, battery: int):
        super().__init__(brand, speed)   # 调用父类 __init__
        self.battery = battery           # 新增属性

    def info(self) -> str:
        base = super().info()
        return f"{base}，电池容量 {self.battery} kWh"

tesla = ElectricCar("Tesla", 250, 100)
print(tesla.info())
# Tesla，最高速度 250 km/h，电池容量 100 kWh
```

### 多继承与 MRO

Python 使用 C3 线性化算法计算方法解析顺序（MRO），可通过 `ClassName.mro()` 查看：

```python
class A:
    def method(self): return "A"

class B(A):
    def method(self): return "B"

class C(A):
    def method(self): return "C"

class D(B, C):
    pass

print(D.mro())   # [D, B, C, A, object]
print(D().method())  # "B"
```

### Mixin 模式

当需要多继承时，推荐用 Mixin 类来混入功能，而不是混入"是什么"的概念：

```python
class JSONMixin:
    def to_json(self) -> str:
        import json
        return json.dumps(self.__dict__)

class LogMixin:
    def log(self, message: str) -> None:
        print(f"[{self.__class__.__name__}] {message}")

class User(JSONMixin, LogMixin):
    def __init__(self, name: str, age: int):
        self.name = name
        self.age = age

u = User("Alice", 25)
print(u.to_json())   # {"name": "Alice", "age": 25}
u.log("用户已创建")
```

## 多态

多态意味着不同类型的对象可以使用相同的接口（方法名），而无需关心其具体类型：

```python
animals: list[Animal] = [Dog("Rex"), Cat("Luna"), Dog("Max")]

for animal in animals:
    print(animal.speak())  # 每个对象调用各自的 speak 实现
```

### 鸭子类型（Duck Typing）

Python 的多态不依赖继承，只要对象实现了需要的方法，就可以使用：

```python
class Duck:
    def quack(self): print("Quack!")

class Person:
    def quack(self): print("I'm quacking like a duck!")

def make_it_quack(obj) -> None:
    obj.quack()   # 不检查类型，只要有 quack 方法即可

make_it_quack(Duck())    # Quack!
make_it_quack(Person())  # I'm quacking like a duck!
```

## 抽象类（ABC）

使用 `abc` 模块强制子类实现特定接口：

```python
from abc import ABC, abstractmethod

class Shape(ABC):
    @abstractmethod
    def area(self) -> float:
        """计算面积"""

    @abstractmethod
    def perimeter(self) -> float:
        """计算周长"""

    def describe(self) -> str:
        return f"面积: {self.area():.2f}，周长: {self.perimeter():.2f}"

class Rectangle(Shape):
    def __init__(self, width: float, height: float):
        self.width = width
        self.height = height

    def area(self) -> float:
        return self.width * self.height

    def perimeter(self) -> float:
        return 2 * (self.width + self.height)

rect = Rectangle(4, 6)
print(rect.describe())   # 面积: 24.00，周长: 20.00
# Shape()  # TypeError: Can't instantiate abstract class
```

## 类方法与静态方法

```python
class DateParser:
    fmt = "%Y-%m-%d"

    def __init__(self, year: int, month: int, day: int):
        self.year = year
        self.month = month
        self.day = day

    @classmethod
    def from_string(cls, date_str: str) -> "DateParser":
        """工厂方法：从字符串创建实例"""
        from datetime import datetime
        d = datetime.strptime(date_str, cls.fmt)
        return cls(d.year, d.month, d.day)

    @staticmethod
    def is_valid_date(date_str: str) -> bool:
        """工具方法：不依赖类或实例"""
        try:
            from datetime import datetime
            datetime.strptime(date_str, "%Y-%m-%d")
            return True
        except ValueError:
            return False

d = DateParser.from_string("2024-06-01")
print(d.year, d.month, d.day)          # 2024 6 1
print(DateParser.is_valid_date("2024-13-01"))  # False
```

## 反射

反射允许通过字符串动态操作对象的属性和方法，常用于插件系统或动态路由：

```python
class Config:
    debug = False
    port = 8080
    host = "localhost"

cfg = Config()

# 检查属性是否存在
print(hasattr(cfg, "port"))           # True

# 获取属性值（getattr 支持默认值）
print(getattr(cfg, "port"))           # 8080
print(getattr(cfg, "timeout", 30))    # 30（不存在时返回默认值）

# 设置属性
setattr(cfg, "debug", True)
print(cfg.debug)                      # True

# 删除属性
setattr(cfg, "temp", "value")
delattr(cfg, "temp")

# 动态调用方法
class Router:
    def get(self): return "GET handler"
    def post(self): return "POST handler"

router = Router()
method = "get"
if hasattr(router, method):
    handler = getattr(router, method)
    print(handler())   # GET handler
```

## 元类（Metaclass）

元类是创建类的类，`type` 是所有类的默认元类：

```python
# type 动态创建类
Dog = type("Dog", (object,), {
    "sound": "Woof",
    "speak": lambda self: f"{self.sound}!"
})

d = Dog()
print(d.speak())   # Woof!

# 自定义元类（不常用，了解即可）
class SingletonMeta(type):
    _instances: dict = {}

    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super().__call__(*args, **kwargs)
        return cls._instances[cls]

class Database(metaclass=SingletonMeta):
    def __init__(self, url: str):
        self.url = url

db1 = Database("postgres://localhost/app")
db2 = Database("mysql://localhost/app")
print(db1 is db2)   # True（单例，db2 被忽略）
```

## 类型注解（Python 3.5+）

现代 Python 推荐为函数参数和返回值添加类型注解，配合工具（mypy、pyright）进行静态检查：

```python
from typing import Optional, Union, Callable
from collections.abc import Sequence

# 基本注解
def greet(name: str, times: int = 1) -> str:
    return (f"Hello, {name}! " * times).strip()

# 可选参数（Python 3.10+ 可用 str | None）
def find_user(user_id: int) -> Optional[str]:
    users = {1: "Alice", 2: "Bob"}
    return users.get(user_id)

# Python 3.10+ Union 简写
def process(value: int | str | None) -> str:
    return str(value) if value is not None else "empty"

# 泛型（Python 3.9+ 内置类型支持）
def flatten(matrix: list[list[int]]) -> list[int]:
    return [x for row in matrix for x in row]

# Protocol（结构化子类型，鸭子类型的正式表达）
from typing import Protocol

class Drawable(Protocol):
    def draw(self) -> None: ...

def render(obj: Drawable) -> None:
    obj.draw()
```

{{< callout type="info" >}}
**Python 3.12 新语法**：可以用 `type` 关键字定义类型别名，用 `[T]` 语法定义泛型类，比 `TypeVar` 更简洁：

```python
type Vector = list[float]

class Stack[T]:
    def __init__(self) -> None:
        self._items: list[T] = []
    def push(self, item: T) -> None:
        self._items.append(item)
    def pop(self) -> T:
        return self._items.pop()
```

{{< /callout >}}
