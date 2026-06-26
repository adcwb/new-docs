---
title: "Python模块使用"
weight: 8
date: 2026-06-23
tags: ["Python", "模块", "包", "import", "命名空间"]
---

模块是 Python 代码复用的基本单位——每个 `.py` 文件就是一个模块。本篇介绍导入机制、包的组织方式以及最佳实践。

## 模块的三种来源

- **内置模块**：随解释器一起安装，如 `os`、`sys`、`json`、`re`。
- **第三方模块**：通过 `pip install` 安装，如 `requests`、`pydantic`。
- **自定义模块**：项目内自己编写的 `.py` 文件。

## import 语句

```python
# 导入整个模块（推荐：命名空间清晰）
import os
import json

print(os.getcwd())
data = json.dumps({"key": "value"})

# 导入特定名称（减少前缀，适合常用名称）
from pathlib import Path
from datetime import datetime

p = Path(".")
now = datetime.now()

# 起别名（名称过长时或避免冲突）
import numpy as np
from collections import defaultdict as dd

# 一次导入多个（不推荐写成一行，可读性差）
import os
import sys
import re
```

{{< callout type="warning" >}}
`from module import *` 会将模块所有公开名称导入当前命名空间，容易造成名称冲突，**不推荐使用**。模块作者可在文件中定义 `__all__` 列表来控制 `*` 的范围。
{{< /callout >}}

## 导入的执行过程

```python
# foo.py
x = 1
print("foo 模块被执行了")

def get():
    return x
```

首次 `import foo` 时发生三件事：

1. 执行 `foo.py` 中的所有顶层代码（只执行一次）。
2. 创建一个新的命名空间，存放执行过程中产生的名称。
3. 在当前命名空间中创建名称 `foo`，指向新命名空间。

```python
import foo           # 打印 "foo 模块被执行了"
import foo           # 不再重复执行（已缓存在 sys.modules 中）

print(foo.x)         # 1
print(foo.get())     # 1
```

## sys.modules — 模块缓存

```python
import sys

# 查看已加载的模块
print("json" in sys.modules)   # True（如果之前 import json 过）

# 强制重新加载（开发时修改模块后使用）
import importlib
import foo
importlib.reload(foo)
```

## 模块搜索路径

导入时，Python 按以下顺序查找模块：

1. `sys.modules`（内存中的缓存）
2. 内置模块（`sys.builtin_module_names`）
3. `sys.path` 中的目录（从左到右）

```python
import sys
print(sys.path)
# ['', '/usr/lib/python312.zip', '/usr/lib/python3.12', ...]
# 第一个元素 '' 代表执行文件所在目录

# 临时添加搜索路径
sys.path.insert(0, "/my/custom/modules")
```

## 包（Package）

包是含有 `__init__.py` 文件的目录，用于组织多个模块：

```text
mypackage/
├── __init__.py        # 包的入口，可为空
├── core.py
├── utils.py
└── sub/
    ├── __init__.py
    └── helper.py
```

```python
# 导入包中的模块
import mypackage.core
from mypackage import utils
from mypackage.sub import helper
from mypackage.sub.helper import some_func

# __init__.py 可以定义包级别的公开接口
# mypackage/__init__.py
# from .core import CoreClass
# from .utils import helper_func
# __all__ = ["CoreClass", "helper_func"]
```

### 相对导入（在包内部使用）

```python
# 在 mypackage/core.py 中
from .utils import format_data        # 同包
from ..other_pkg import something     # 上层包
```

相对导入只在包内部有效，不能在顶层脚本中使用。

## `if __name__ == "__main__"` 守卫

每个 `.py` 文件都有内置变量 `__name__`：

- 作为**主脚本**运行时：`__name__ == "__main__"`
- 作为**模块导入**时：`__name__ == "模块名"`

```python
# mymodule.py

def add(a: int, b: int) -> int:
    return a + b

# 仅在直接运行时执行测试代码，被导入时不执行
if __name__ == "__main__":
    print(add(1, 2))   # 3
    print(add(10, 20)) # 30
```

## 循环导入问题

```python
# a.py
from b import func_b   # ← 导入时 b.py 还未加载完 a.py

# b.py
from a import func_a   # ← 导入时 a.py 还未加载完 b.py
```

循环导入通常意味着设计问题。解决方案：

1. 将共享数据/函数提取到第三个模块。
2. 将导入语句移到函数内部（延迟导入）。

```python
# b.py — 延迟导入
def func_b():
    from a import func_a  # 函数调用时才导入，避免初始化时的循环
    return func_a()
```

## 标准规范：导入顺序

按 PEP 8 规范，导入语句应在文件顶部，分三组，组间空一行：

```python
# 1. 标准库模块
import os
import sys
from pathlib import Path

# 2. 第三方模块
import requests
from pydantic import BaseModel

# 3. 本地/项目模块
from myapp.core import Engine
from myapp.utils import logger
```

工具 `ruff` 或 `isort` 可以自动整理导入顺序。
