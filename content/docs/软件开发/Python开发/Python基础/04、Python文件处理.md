---
title: "Python文件处理"
weight: 4
date: 2026-06-23
tags: ["Python", "文件IO", "pathlib", "编码"]
---

本篇介绍 Python 的文件读写操作，包括 `open()` 基础用法、文件模式、编码处理，以及现代推荐的 `pathlib` 路径操作。

## 文件操作基础

Python 通过 `open()` 函数打开文件，得到一个文件对象，然后通过文件对象进行读写操作。操作完毕后必须关闭文件以释放系统资源。

```python
# 手动关闭（不推荐，容易遗忘）
f = open("data.txt", "r", encoding="utf-8")
content = f.read()
f.close()

# 推荐：with 语句自动关闭
with open("data.txt", "r", encoding="utf-8") as f:
    content = f.read()
    print(content)
# 离开 with 块时自动调用 f.close()
```

## 文件打开模式

| 模式 | 含义 |
| ---- | ---- |
| `r` | 只读（默认），文件不存在则报错 |
| `w` | 只写，文件不存在则创建，存在则**清空** |
| `a` | 追加写，不存在则创建，存在则移动指针到末尾 |
| `x` | 独占创建，文件已存在则报错（Python 3+） |
| `r+` | 可读可写，文件不存在则报错 |
| `b` | 二进制模式（与 r/w/a 组合使用，如 `rb`、`wb`） |
| `t` | 文本模式（默认，与 b 互斥） |

```python
# 写入文件
with open("log.txt", "w", encoding="utf-8") as f:
    f.write("第一行\n")
    f.write("第二行\n")

# 追加写入
with open("log.txt", "a", encoding="utf-8") as f:
    f.write("第三行\n")

# 同时打开两个文件（读入 → 写出）
with open("source.txt", "r", encoding="utf-8") as src, \
     open("dest.txt", "w", encoding="utf-8") as dst:
    dst.write(src.read())
```

## 读取方式

```python
with open("data.txt", "r", encoding="utf-8") as f:
    # 一次性读取全部内容为字符串
    content = f.read()

    # 读取一行（包含末尾 \n）
    line = f.readline()

    # 读取所有行，返回列表
    lines = f.readlines()  # ['第一行\n', '第二行\n', ...]

# 推荐：逐行迭代（不会将全文读入内存，适合大文件）
with open("large.txt", "r", encoding="utf-8") as f:
    for line in f:
        print(line.rstrip())  # rstrip() 去掉行末换行符
```

## 二进制模式

处理图片、视频、音频等非文本文件必须使用二进制模式（`b`），不能指定 `encoding`：

```python
# 复制二进制文件
with open("photo.jpg", "rb") as src, open("copy.jpg", "wb") as dst:
    while True:
        chunk = src.read(4096)   # 每次读 4 KB
        if not chunk:
            break
        dst.write(chunk)

# 更简洁的写法
import shutil
shutil.copyfile("photo.jpg", "copy.jpg")
```

## 编码处理

{{< callout type="warning" >}}
在 Windows 下，`open()` 不指定 `encoding` 时默认使用系统编码（`gbk`/`cp936`），可能导致乱码。**始终显式指定 `encoding="utf-8"`**。
{{< /callout >}}

```python
# 读取 UTF-8 文件
with open("utf8.txt", "r", encoding="utf-8") as f:
    print(f.read())

# 处理 GBK 编码的历史文件
with open("gbk.txt", "r", encoding="gbk") as f:
    content = f.read()

# 写入时指定编码
with open("output.txt", "w", encoding="utf-8") as f:
    f.write("你好，世界！\n")

# 遇到无法解码的字节时的容错处理
with open("mixed.txt", "r", encoding="utf-8", errors="ignore") as f:
    content = f.read()   # 跳过无法解码的字节

# errors="replace"：用 ? 替换无法解码的字节
with open("mixed.txt", "r", encoding="utf-8", errors="replace") as f:
    content = f.read()
```

## 文件指针控制

```python
with open("data.txt", "rb") as f:
    # tell()：返回当前指针位置（字节数）
    print(f.tell())    # 0

    f.read(5)
    print(f.tell())    # 5

    # seek(offset, whence)
    f.seek(0)          # 移到文件开头（等价于 f.seek(0, 0)）
    f.seek(0, 2)       # 移到文件末尾（whence=2 表示以末尾为参照）
    print(f.tell())    # 文件总字节数

    f.seek(-3, 2)      # 从末尾往前移 3 字节
    print(f.read().decode("utf-8"))   # 最后 3 字节内容
```

## pathlib — 现代路径操作

`pathlib.Path` 是 Python 3.4+ 推荐的路径操作方式，比 `os.path` 更直观：

```python
from pathlib import Path

# 创建路径对象
data_dir = Path("data")
config = Path("/etc/app/config.yaml")

# 路径拼接（/ 运算符）
log_file = data_dir / "logs" / "app.log"

# 路径属性
p = Path("/home/user/docs/readme.txt")
print(p.name)     # readme.txt
print(p.stem)     # readme
print(p.suffix)   # .txt
print(p.parent)   # /home/user/docs

# 存在性检查
print(p.exists())   # 路径是否存在
print(p.is_file())  # 是否是文件
print(p.is_dir())   # 是否是目录

# 快捷读写（自动管理打开关闭）
output = Path("output.txt")
output.write_text("Hello, World!", encoding="utf-8")
text = output.read_text(encoding="utf-8")

# 创建目录（parents=True 递归创建）
Path("a/b/c").mkdir(parents=True, exist_ok=True)

# 删除
output.unlink(missing_ok=True)    # 删除文件
Path("empty_dir").rmdir()         # 删除空目录

# 遍历目录
for f in Path(".").iterdir():
    if f.is_file():
        print(f.name)

# glob 模式匹配
for py in Path("src").glob("**/*.py"):  # 递归查找
    print(py)
```

## 文件修改（两种方式）

文件内容不可直接修改（硬盘写入是覆盖机制），通常用以下两种方式实现"修改"：

```python
from pathlib import Path

# 方式一：全部读入内存，修改后写回（适合小文件）
path = Path("db.txt")
content = path.read_text(encoding="utf-8")
path.write_text(content.replace("old_value", "new_value"), encoding="utf-8")

# 方式二：逐行读取并写入临时文件（适合大文件）
import shutil, os

src = Path("db.txt")
tmp = Path(".db.txt.swap")

with src.open("r", encoding="utf-8") as r, \
     tmp.open("w", encoding="utf-8") as w:
    for line in r:
        w.write(line.replace("old_value", "new_value"))

tmp.replace(src)   # 原子替换（等价于 os.replace）
```

## 实战：监控日志新增行

```python
import time
from pathlib import Path

def tail_log(path: Path) -> None:
    """类似 tail -f，实时输出日志新增行。"""
    with path.open("rb") as f:
        f.seek(0, 2)   # 跳到文件末尾
        while True:
            line = f.readline()
            if line:
                print(line.decode("utf-8"), end="")
            else:
                time.sleep(0.5)

# tail_log(Path("access.log"))
```
