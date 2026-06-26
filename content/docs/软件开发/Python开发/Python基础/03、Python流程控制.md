---
title: "Python流程控制"
weight: 3
date: 2026-06-23
tags: ["Python", "流程控制", "循环", "推导式"]
---

本篇介绍 Python 的条件判断、循环和推导式，并包含 Python 3.10 引入的结构化模式匹配（`match/case`）。

## if 语句

```python
age = 19
is_member = True

if age >= 18 and is_member:
    print("欢迎，成年会员！")
elif age >= 18:
    print("欢迎，普通访客！")
elif age >= 13:
    print("未成年用户，部分功能受限")
else:
    print("不符合年龄要求")
```

- 缩进必须一致，官方推荐 4 个空格。
- `if` 判断由上到下，一旦某分支匹配成功，其余分支不再执行。
- 嵌套深度建议不超过 3 层，过深应重构为函数。

### 三元表达式

```python
x, y = 3, 5
smaller = x if x < y else y   # 3

# 嵌套三元（可读性差，慎用）
grade = "A" if score >= 90 else ("B" if score >= 80 else "C")
```

## match/case（结构化模式匹配，Python 3.10+）

`match/case` 是比 `if/elif` 更强大的模式匹配语法，支持值匹配、解构、类型匹配等：

```python
# 基本值匹配
status = 404

match status:
    case 200:
        print("OK")
    case 404:
        print("Not Found")
    case 500:
        print("Internal Server Error")
    case _:
        print(f"未知状态码: {status}")
```

```python
# 序列解构匹配
command = ("move", 10, 20)

match command:
    case ("quit",):
        print("退出")
    case ("move", x, y):
        print(f"移动到 ({x}, {y})")
    case ("say", message):
        print(f"说: {message}")
    case _:
        print("未知命令")
```

```python
# 类匹配（配合 __match_args__）
from dataclasses import dataclass

@dataclass
class Point:
    x: float
    y: float

def describe(point: Point) -> str:
    match point:
        case Point(x=0, y=0):
            return "原点"
        case Point(x=0, y=y):
            return f"Y 轴上，y={y}"
        case Point(x=x, y=0):
            return f"X 轴上，x={x}"
        case Point(x=x, y=y):
            return f"点 ({x}, {y})"

# 带守卫条件（guard）
match point:
    case Point(x, y) if x == y:
        print(f"在对角线上，坐标 {x}")
    case Point(x, y):
        print(f"不在对角线上")
```

## while 循环

```python
count = 0
while count < 5:
    print(count)
    count += 1

# while-else：循环正常结束（未被 break 中断）时执行 else
attempts = 0
while attempts < 3:
    password = input("输入密码：")
    if password == "secret":
        print("登录成功")
        break
    attempts += 1
else:
    print("密码错误次数过多，账户锁定")
```

### 海象运算符简化 while（Python 3.8+）

```python
# 传统写法
line = input()
while line:
    process(line)
    line = input()

# 海象运算符写法
while line := input("> "):
    process(line)
```

## for 循环

```python
# 遍历列表
fruits = ["apple", "banana", "cherry"]
for fruit in fruits:
    print(fruit)

# 带索引：enumerate
for i, fruit in enumerate(fruits, start=1):
    print(f"{i}. {fruit}")

# 同时遍历多个序列：zip
names = ["Alice", "Bob", "Charlie"]
scores = [90, 85, 92]
for name, score in zip(names, scores):
    print(f"{name}: {score}")

# range
for i in range(10):          # 0-9
    print(i)

for i in range(1, 10, 2):   # 1, 3, 5, 7, 9
    print(i)

# for-else：循环正常结束时执行 else
for i in range(5):
    if i == 3:
        break
else:
    print("循环正常结束")   # 有 break 时不执行
```

### break / continue

```python
# break：立即终止整个循环
for i in range(10):
    if i == 5:
        break
    print(i)    # 0 1 2 3 4

# continue：跳过当次循环，继续下一次
for i in range(10):
    if i % 2 == 0:
        continue
    print(i)    # 1 3 5 7 9
```

## 推导式

推导式是 Python 中简洁创建集合的语法糖，常见有四种：

### 列表推导式

```python
# [表达式 for 变量 in 可迭代对象 if 条件]
squares = [x ** 2 for x in range(10)]
# [0, 1, 4, 9, 16, 25, 36, 49, 64, 81]

evens = [x for x in range(20) if x % 2 == 0]
# [0, 2, 4, 6, 8, 10, 12, 14, 16, 18]

# 嵌套（展平二维矩阵）
matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
flat = [x for row in matrix for x in row]
# [1, 2, 3, 4, 5, 6, 7, 8, 9]
```

### 字典推导式

```python
# {key表达式: value表达式 for 变量 in 可迭代对象}
squares = {x: x ** 2 for x in range(5)}
# {0: 0, 1: 1, 2: 4, 3: 9, 4: 16}

# 翻转字典的键值
d = {"a": 1, "b": 2}
reversed_d = {v: k for k, v in d.items()}
# {1: "a", 2: "b"}
```

### 集合推导式

```python
# {表达式 for 变量 in 可迭代对象 if 条件}
unique_chars = {c.lower() for c in "Hello World" if c != " "}
# {'h', 'e', 'l', 'o', 'w', 'r', 'd'}
```

### 生成器表达式

```python
# 圆括号：不立即创建整个序列，按需生成（节省内存）
gen = (x ** 2 for x in range(1_000_000))
print(next(gen))   # 0
print(next(gen))   # 1

# 常用于传参给接受可迭代对象的函数
total = sum(x ** 2 for x in range(100))
```

{{< callout type="warning" >}}
推导式虽然简洁，但可读性是首要原则。超过两层嵌套、逻辑复杂时，请改用普通 `for` 循环。
{{< /callout >}}
