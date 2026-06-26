---
title: "Python基本语法"
weight: 1
date: 2026-06-23
tags: ["Python", "基础语法", "入门"]
---

本篇介绍 Python 的基本概念与核心语法，包括变量、数据类型、运算符、格式化输出和编码机制。所有示例均基于 **Python 3.10+**，不再涉及已停止维护的 Python 2。

## Python简介

Python 是由 Guido van Rossum 于 1989 年设计的高级通用编程语言，以简洁可读著称。它是解释型语言，支持面向对象、函数式和过程式多种编程范式，在 Web 开发、数据科学、自动化运维、人工智能等领域均有广泛应用。

### Python发展历史

| 版本 | 发布时间 | 重要特性 |
| ---- | -------- | -------- |
| Python 1.0 | 1994-01 | lambda、map、filter、reduce |
| Python 2.0 | 2000-10 | 内存回收机制、列表推导式 |
| Python 2.7 | 2010-07 | 最后一个 2.x 版本，2020 年停止支持 |
| Python 3.0 | 2008-12 | 不向后兼容的重大重构，统一字符串为 Unicode |
| Python 3.6 | 2016-12 | f-string、变量注解 |
| Python 3.8 | 2019-10 | 海象运算符 `:=`、位置参数 `/` |
| Python 3.9 | 2020-10 | 内置类型支持泛型（`list[int]`）、字典合并运算符 `\|` |
| Python 3.10 | 2021-10 | 结构化模式匹配 `match/case`、更精确的错误提示 |
| Python 3.11 | 2022-10 | 性能提升 10-60%、异常组 `ExceptionGroup` |
| Python 3.12 | 2023-10 | 类型参数语法、f-string 支持嵌套引号 |
| Python 3.13 | 2024-10 | 无 GIL 实验性支持（`--disable-gil`）、交互式解释器升级 |

{{< callout type="info" >}}
**当前推荐版本**：Python 3.12 / 3.13。Python 2 已于 2020 年 1 月 1 日停止官方支持，所有新项目请使用 Python 3。
{{< /callout >}}

### 编译型与解释型语言对比

| 类型 | 代表语言 | 优点 | 缺点 |
| ---- | -------- | ---- | ---- |
| 编译型 | C、Go、Rust | 执行效率高，可脱离运行环境独立运行 | 跨平台需重新编译，修改后须整体重新编译 |
| 解释型 | Python、Ruby | 跨平台性好，修改后无需重新编译 | 每次运行都需解释，速度相对较慢 |

### 编程语言的分类

- **机器语言**：直接用二进制指令编程，执行效率最高，但极难编写和维护。
- **汇编语言**：用助记符代表二进制指令，本质仍是直接操作硬件，学习成本高。
- **高级语言**：屏蔽硬件细节，贴近人类思维，分编译型和解释型两类。

执行效率：机器语言 > 汇编语言 > 高级语言（编译型 > 解释型）

开发效率：机器语言 < 汇编语言 < 高级语言（编译型 < 解释型）

## Python 解释器

**Python 语言**与 **Python 解释器**是两个不同的概念：

- **Python 语言**：指 Python 的语法规范（如 PEP 规范）。
- **Python 解释器**：识别并执行 Python 语法的程序，常见的有以下几种。

| 解释器 | 说明 |
| ------ | ---- |
| **CPython** | 官方解释器，用 C 语言实现，`python` 命令默认启动，最常用 |
| **PyPy** | 用 Python 实现，采用 JIT 即时编译，速度最快，适合计算密集型任务 |
| **Jython** | 运行在 JVM 上，可直接编译为 Java 字节码 |
| **IronPython** | 运行在 .NET 平台上 |
| **MicroPython** | 在微控制器等嵌入式设备上运行 |

### 安装与第一个程序

从 [python.org](https://www.python.org/downloads/) 下载安装包，安装时勾选 **Add Python to PATH**。

```bash
# 验证安装
python --version   # Python 3.13.x

# 交互式运行（适合调试）
python

# 脚本运行
python hello.py
```

```python
# hello.py
print("Hello, World!")
```

## 注释

```python
# 单行注释：用 # 开头

"""
多行注释：
用三引号包裹，常用于函数/类的文档字符串（docstring）
"""

def add(a, b):
    """返回两个数的和。"""
    return a + b
```

## 变量

### 变量基础

变量是内存中数据的标签，Python 中**无需声明类型**，赋值即创建变量。

```python
age = 18           # 整型
name = "Alice"     # 字符串
height = 1.75      # 浮点型
is_adult = True    # 布尔型

# 查看变量的三大属性
print(id(age))     # 内存地址
print(type(age))   # 类型
print(age)         # 值
```

### 命名规则

- 只能包含字母、数字、下划线，不能以数字开头。
- 大小写敏感：`name` 和 `Name` 是两个不同的变量。
- 不能使用 Python 关键字（`if`、`for`、`class` 等）。
- 惯例：变量名用 `snake_case`（小写加下划线），常量全大写如 `MAX_SIZE`。

```python
# 合法变量名
user_name = "Bob"
_private = 42
MAX_RETRY = 3

# 多变量赋值
x = y = z = 0          # 链式赋值，三个变量指向同一对象
a, b = 10, 20          # 解包赋值
a, b = b, a            # 交换两个变量的值

# 扩展解包（Python 3）
first, *rest = [1, 2, 3, 4, 5]
# first=1, rest=[2, 3, 4, 5]
```

### 小整数缓存

CPython 对 `-5` 到 `256` 范围内的整数做了对象缓存（小整数池），同值变量共享同一内存地址：

```python
a = 100
b = 100
print(a is b)   # True，共享对象

a = 300
b = 300
print(a is b)   # False（CPython 中），不在缓存范围
```

{{< callout type="warning" >}}
不要用 `is` 比较数值或字符串是否相等，应始终用 `==`。`is` 比较的是对象身份（内存地址），`==` 比较的是值。
{{< /callout >}}

## 基本数据类型

### 数字类型

```python
# int 整型（精度无限，不会溢出）
age = 18
big = 10 ** 100          # 支持任意大整数

# float 浮点型（64 位双精度）
pi = 3.14159
sci = 1.5e-3             # 科学计数法：0.0015

# complex 复数
c = 3 + 4j
print(c.real, c.imag)    # 3.0  4.0

# 类型转换
int("42")        # 42
float("3.14")    # 3.14
int(3.9)         # 3（截断，不是四舍五入）
```

### 字符串类型

```python
s1 = 'hello'
s2 = "world"
s3 = """多行
字符串"""

# 字符串拼接与重复
greeting = "Hello" + ", " + "Alice"
line = "-" * 40

# 索引与切片
s = "Python"
print(s[0])      # P（正向索引从 0 开始）
print(s[-1])     # n（逆向索引从 -1 开始）
print(s[1:4])    # yth
print(s[::-1])   # nohtyP（反转）
```

### 列表类型

```python
# 有序、可变、元素类型任意
fruits = ["apple", "banana", "cherry"]
print(fruits[0])          # apple
print(fruits[-1])         # cherry

# 嵌套列表
matrix = [[1, 2, 3], [4, 5, 6]]
print(matrix[1][2])       # 6
```

### 字典类型

```python
# 键值对，key 必须是不可变类型
person = {"name": "Alice", "age": 25, "city": "Beijing"}
print(person["name"])     # Alice

# Python 3.9+ 字典合并
defaults = {"color": "red", "size": 10}
custom = {"color": "blue"}
merged = defaults | custom   # {'color': 'blue', 'size': 10}
```

### 元组类型

```python
# 有序、不可变
coords = (10.0, 20.0)
x, y = coords             # 解包

# 单元素元组必须加逗号
single = (42,)            # 不加逗号会被当成普通括号
```

### 集合类型

```python
# 无序、不重复
s = {1, 2, 3, 2, 1}
print(s)                  # {1, 2, 3}

# 集合运算
a = {1, 2, 3}
b = {2, 3, 4}
print(a | b)              # 并集 {1, 2, 3, 4}
print(a & b)              # 交集 {2, 3}
print(a - b)              # 差集 {1}
```

### 布尔类型

```python
print(True, False)
print(type(True))         # <class 'bool'>
print(int(True))          # 1
print(int(False))         # 0

# 隐式布尔值（False 的情况）
# 0、0.0、""、[]、{}、()、set()、None 都为 False
if []:
    print("不会执行")
```

### 类型转换

```python
# 强制类型转换
str(123)          # '123'
list("abc")       # ['a', 'b', 'c']
tuple([1, 2, 3])  # (1, 2, 3)
set([1, 1, 2])    # {1, 2}
dict([("a", 1)])  # {'a': 1}
```

## 格式化输出

Python 有三种字符串格式化方式，推荐使用 **f-string**。

### % 格式化（旧式，不推荐）

```python
name = "Alice"
age = 25
print("姓名: %s，年龄: %d" % (name, age))
```

### str.format()

```python
print("姓名: {}，年龄: {}".format("Alice", 25))
print("{name} is {age} years old".format(name="Bob", age=30))
print("{0:>10}".format("right"))   # 右对齐，宽度 10
print("{:.2f}".format(3.14159))    # 保留两位小数
```

### f-string（推荐，Python 3.6+）

```python
name = "Alice"
age = 25
print(f"姓名: {name}，年龄: {age}")

# 表达式
print(f"明年 {age + 1} 岁")
print(f"π ≈ {3.14159:.2f}")

# Python 3.12+：f-string 内可以使用任意引号（不再需要转义）
items = ["apple", "banana"]
print(f"第一个: {items[0]!r}")

# 调试输出（Python 3.8+，= 号显示变量名和值）
x = 42
print(f"{x=}")   # x=42
```

### 海象运算符（Python 3.8+）

海象运算符 `:=` 允许在表达式内部进行赋值，适用于 `while` 循环或条件判断中避免重复计算：

```python
import re

# 传统写法
data = "Hello 42 World"
m = re.search(r"\d+", data)
if m:
    print(m.group())

# 使用海象运算符
if m := re.search(r"\d+", data):
    print(m.group())   # 42

# 在 while 循环中简化
while chunk := input("输入内容（空行结束）: "):
    print(f"你输入了: {chunk}")
```

## 进制转换

```python
# 十进制转其他进制
print(bin(10))    # 0b1010
print(oct(10))    # 0o12
print(hex(255))   # 0xff

# 其他进制转十进制
print(int("1010", 2))    # 10（二进制 → 十进制）
print(int("ff", 16))     # 255（十六进制 → 十进制）

# 千分位格式化
print(f"{1234567890:,}")   # 1,234,567,890
```

## 运算符

### 算术运算符

| 运算符 | 描述 | 示例（x=9, y=2） |
| :----: | ---- | :-------------- |
| `+` | 加 | `x+y` → 11 |
| `-` | 减 | `x-y` → 7 |
| `*` | 乘 | `x*y` → 18 |
| `/` | 除（结果为 float） | `x/y` → 4.5 |
| `//` | 整除 | `x//y` → 4 |
| `%` | 取余 | `x%y` → 1 |
| `**` | 幂 | `x**y` → 81 |

### 比较与逻辑运算符

```python
# 比较运算符返回 bool
print(3 > 2)     # True
print(3 == 3.0)  # True（值相等）
print(3 is 3.0)  # False（类型不同，对象不同）

# 链式比较（Python 特有）
x = 5
print(1 < x < 10)  # True

# 逻辑运算符：not > and > or
print(True and False)   # False
print(True or False)    # True
print(not True)         # False

# 短路求值：and/or 返回决定结果的那个操作数
print(0 or "default")   # "default"
print(1 and "ok")       # "ok"
```

### 赋值运算符

```python
x = 10
x += 1      # x = 11
x -= 2      # x = 9
x *= 3      # x = 27
x //= 4     # x = 6
x **= 2     # x = 36
```

### 位运算符

```python
a = 60   # 0011 1100
b = 13   # 0000 1101

print(a & b)    # 12   按位与
print(a | b)    # 61   按位或
print(a ^ b)    # 49   按位异或
print(~a)       # -61  按位取反
print(a << 2)   # 240  左移
print(a >> 2)   # 15   右移
```

### 可变与不可变类型

```python
# 不可变类型：int、float、str、tuple、frozenset
# 值改变时 id 也改变（产生新对象）
a = "hello"
print(id(a))
a = a + "!"
print(id(a))    # id 已改变

# 可变类型：list、dict、set
# 原地修改，id 不变
lst = [1, 2, 3]
print(id(lst))
lst.append(4)
print(id(lst))  # id 未变
```

## 字符编码

```python
import sys
print(sys.getdefaultencoding())   # utf-8

# Python 3 内置 str 就是 Unicode，bytes 是字节序列
s = "你好"
b = s.encode("utf-8")             # str → bytes
print(b)                          # b'\xe4\xbd\xa0\xe5\xa5\xbd'
print(b.decode("utf-8"))          # bytes → str

# 源文件默认 UTF-8，无需在顶部写 # -*- coding: utf-8 -*-
```

## 垃圾回收机制

CPython 使用三种机制管理内存：

1. **引用计数**：每个对象记录被引用的次数，降为 0 时立即回收。
2. **标记清除**：解决循环引用导致的内存泄漏问题。
3. **分代回收**：将对象按存活时间分为 0、1、2 三代，降低扫描频率，提升效率。

```python
import gc

# 触发垃圾回收
gc.collect()

# 查看引用计数
import sys
x = [1, 2, 3]
print(sys.getrefcount(x))   # 2（x 本身 + getrefcount 的参数）
```

## 常用 IDE 与开发工具

| 工具 | 特点 |
| ---- | ---- |
| **PyCharm** | JetBrains 出品，功能最全，适合大型项目 |
| **VS Code** | 轻量、插件丰富，配合 Python 扩展非常强大 |
| **Jupyter Notebook** | 数据科学首选，支持代码与可视化混排 |
| **uv** | 现代 Python 包管理和项目工具，速度极快 |
| **Ruff** | 极速 Python Linter & Formatter（替代 flake8/black） |
