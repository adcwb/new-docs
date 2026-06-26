---
title: "with语法与上下文管理"
weight: 15
date: 2026-06-23
tags: ["Python", "上下文管理器", "with", "contextlib"]
---

`with` 语句是 Python 处理资源获取/释放的标准方式，确保即使发生异常，资源也能被正确释放。本篇介绍其工作原理和自定义方法。

## with 语句基础

```python
# 文件操作：离开 with 块时自动调用 f.close()
with open("data.txt", "r", encoding="utf-8") as f:
    content = f.read()

# 同时管理多个资源（Python 3.10+ 可用括号跨行）
with (
    open("source.txt", "r", encoding="utf-8") as src,
    open("dest.txt", "w", encoding="utf-8") as dst,
):
    dst.write(src.read())
```

## 上下文管理协议

实现了 `__enter__` 和 `__exit__` 两个方法的对象就是上下文管理器：

- `__enter__(self)`：进入 `with` 块时调用，返回值被 `as` 变量接收。
- `__exit__(self, exc_type, exc_val, exc_tb)`：离开 `with` 块时调用，无论是否发生异常。返回 `True` 表示异常已处理（不再向上传播），返回 `False` 或 `None` 则重新抛出。

```python
class DBConnection:
    def __init__(self, dsn: str):
        self.dsn = dsn
        self.conn = None

    def __enter__(self):
        print(f"连接数据库: {self.dsn}")
        self.conn = {"connected": True}   # 模拟连接
        return self.conn                  # 返回给 as 变量

    def __exit__(self, exc_type, exc_val, exc_tb):
        print(f"关闭连接（异常类型: {exc_type}）")
        self.conn = None
        return False   # 不吞掉异常

with DBConnection("postgres://localhost/app") as conn:
    print(f"使用连接: {conn}")
    # raise RuntimeError("查询失败")  # 即使发生异常，__exit__ 也会被调用
```

## contextlib.contextmanager — 用生成器实现

`contextlib.contextmanager` 装饰器允许用一个生成器函数实现上下文管理器，比定义类更简洁：

```python
from contextlib import contextmanager

@contextmanager
def managed_resource(name: str):
    print(f"获取资源: {name}")    # 相当于 __enter__
    resource = {"name": name}
    try:
        yield resource             # yield 的值被 as 变量接收
    finally:
        print(f"释放资源: {name}") # 相当于 __exit__

with managed_resource("数据库连接") as r:
    print(f"使用: {r['name']}")
```

`yield` 语句之前的代码对应 `__enter__`，之后的代码对应 `__exit__`。将 `yield` 放在 `try/finally` 中，可确保无论是否发生异常都会执行清理逻辑。

### 计时器示例

```python
import time
from contextlib import contextmanager

@contextmanager
def timer(label: str = ""):
    start = time.perf_counter()
    try:
        yield
    finally:
        elapsed = time.perf_counter() - start
        print(f"{label} 耗时: {elapsed:.4f}s")

with timer("数据处理"):
    import time
    time.sleep(0.1)
    # 数据处理 耗时: 0.1001s
```

## contextlib 其他工具

### suppress — 忽略指定异常

```python
from contextlib import suppress
from pathlib import Path

# 等价于 try: ... except FileNotFoundError: pass
with suppress(FileNotFoundError):
    Path("nonexistent.txt").unlink()

# 忽略多种异常
with suppress(KeyError, IndexError):
    data = {}
    print(data["missing"])   # 静默忽略 KeyError
```

### ExitStack — 动态管理多个上下文

当需要动态决定打开多少个上下文时，`ExitStack` 非常有用：

```python
from contextlib import ExitStack

files = ["a.txt", "b.txt", "c.txt"]

with ExitStack() as stack:
    handles = [
        stack.enter_context(open(f, "w", encoding="utf-8"))
        for f in files
    ]
    for i, fh in enumerate(handles):
        fh.write(f"内容 {i}\n")
# 离开 with 块时，所有文件都会被自动关闭
```

### nullcontext — 占位上下文（Python 3.7+）

```python
from contextlib import nullcontext

def process(f=None):
    ctx = nullcontext(f) if f else open("default.txt", "r")
    with ctx as file:
        print(file.read())
```

## 实际应用：事务性文件写入

```python
from contextlib import contextmanager
from pathlib import Path

@contextmanager
def atomic_write(path: Path, encoding: str = "utf-8"):
    """先写到临时文件，成功后原子替换；失败则删除临时文件。"""
    tmp = path.with_suffix(path.suffix + ".tmp")
    try:
        with tmp.open("w", encoding=encoding) as f:
            yield f
        tmp.replace(path)   # 原子替换
    except Exception:
        if tmp.exists():
            tmp.unlink()
        raise

with atomic_write(Path("config.json")) as f:
    import json
    json.dump({"version": 2}, f, indent=2)
```
