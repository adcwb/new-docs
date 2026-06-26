---
title: "Python常用模块"
weight: 9
date: 2026-06-23
tags: ["Python", "标准库", "模块", "pathlib", "logging"]
---

Python 标准库提供了大量开箱即用的模块，本篇介绍日常开发中最常用的几个：序列化、路径操作、时间处理、系统接口、日志记录等。

## json — 跨语言序列化

JSON 是各语言通用的数据交换格式，Python 内置 `json` 模块处理与 Python 数据结构的互转：

```python
import json

# Python → JSON 字符串
data = {"name": "Alice", "age": 25, "scores": [90, 85, 92]}
text = json.dumps(data, ensure_ascii=False, indent=2)
print(text)
# {
#   "name": "Alice",
#   "age": 25,
#   "scores": [90, 85, 92]
# }

# JSON 字符串 → Python
parsed = json.loads(text)
print(parsed["name"])   # Alice

# 写入文件
with open("data.json", "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

# 从文件读取
with open("data.json", encoding="utf-8") as f:
    loaded = json.load(f)
```

`json` 支持的类型：`str`、`int`、`float`、`bool`、`list`、`dict`、`None`。自定义对象需要继承 `JSONEncoder`：

```python
import json
from datetime import datetime

class DateEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, datetime):
            return obj.isoformat()
        return super().default(obj)

data = {"created_at": datetime(2024, 6, 1, 12, 0)}
print(json.dumps(data, cls=DateEncoder))
# {"created_at": "2024-06-01T12:00:00"}
```

{{< callout type="info" >}}
**json vs pickle**：JSON 输出为字符串，跨语言通用，但只支持基本类型；pickle 输出为 bytes，仅限 Python，支持几乎所有类型（包括自定义类、函数），但反序列化不受信任的 pickle 数据存在安全风险。
{{< /callout >}}

## pickle — Python 专用序列化

```python
import pickle

class User:
    def __init__(self, name: str, age: int):
        self.name = name
        self.age = age

user = User("Bob", 30)

# 序列化到 bytes
data = pickle.dumps(user)

# 从 bytes 反序列化
user2 = pickle.loads(data)
print(user2.name, user2.age)   # Bob 30

# 写入 / 读取文件（必须用二进制模式）
with open("user.pkl", "wb") as f:
    pickle.dump(user, f)

with open("user.pkl", "rb") as f:
    user3 = pickle.load(f)
```

## pathlib — 现代路径操作（Python 3.4+，推荐）

`pathlib.Path` 以面向对象方式处理文件路径，是 `os.path` 的现代替代：

```python
from pathlib import Path

# 创建路径对象（自动适配系统分隔符）
p = Path("/home/user/docs/readme.txt")
p = Path(".")   # 当前目录

# 路径拼接（用 / 运算符）
config = Path("/etc") / "app" / "config.yaml"

# 路径信息
p = Path("/home/user/docs/readme.txt")
print(p.name)        # readme.txt
print(p.stem)        # readme
print(p.suffix)      # .txt
print(p.parent)      # /home/user/docs
print(p.parts)       # ('/', 'home', 'user', 'docs', 'readme.txt')

# 检查
print(p.exists())    # 是否存在
print(p.is_file())   # 是否是文件
print(p.is_dir())    # 是否是目录

# 读写文本（自动处理打开/关闭）
path = Path("hello.txt")
path.write_text("Hello, World!", encoding="utf-8")
content = path.read_text(encoding="utf-8")

# 读写字节
path.write_bytes(b"\x00\x01\x02")
data = path.read_bytes()

# 遍历目录
for f in Path(".").iterdir():
    print(f)

# glob 模式匹配
for py_file in Path("src").glob("**/*.py"):  # 递归查找所有 .py 文件
    print(py_file)

# 创建/删除
Path("new_dir").mkdir(parents=True, exist_ok=True)
Path("file.txt").unlink(missing_ok=True)  # 删除文件

# 获取文件大小和修改时间
stat = path.stat()
print(stat.st_size)   # 字节数
```

## os — 操作系统接口

```python
import os

# 环境变量
print(os.environ.get("PATH"))
os.environ["MY_VAR"] = "hello"

# 当前工作目录
print(os.getcwd())
os.chdir("/tmp")

# 运行系统命令
os.system("ls -la")   # 不返回输出

# 执行命令并获取输出（推荐用 subprocess）
import subprocess
result = subprocess.run(["ls", "-la"], capture_output=True, text=True)
print(result.stdout)

# 文件/目录操作
os.makedirs("a/b/c", exist_ok=True)   # 递归创建
os.rename("old.txt", "new.txt")
os.remove("file.txt")
os.rmdir("empty_dir")

# 列出目录
print(os.listdir("."))

# 系统信息
print(os.name)    # 'posix'（Linux/Mac）或 'nt'（Windows）
print(os.sep)     # '/' 或 '\\'
print(os.getpid())  # 当前进程 ID
```

{{< callout type="info" >}}
路径字符串操作推荐用 `pathlib.Path` 替代 `os.path`。`os.path` 仍可用，但代码更冗长。
{{< /callout >}}

## shutil — 高级文件操作

```python
import shutil

# 复制文件（保留内容）
shutil.copyfile("src.txt", "dst.txt")

# 复制文件（保留内容 + 权限）
shutil.copy("src.txt", "dst/")

# 复制文件（保留内容 + 权限 + 元数据）
shutil.copy2("src.txt", "dst/")

# 递归复制目录
shutil.copytree("src_dir", "dst_dir")   # dst_dir 不能已存在

# 移动文件/目录
shutil.move("old_path", "new_path")

# 递归删除目录（危险，请确认路径！）
shutil.rmtree("dir_to_delete")

# 打包为 zip/tar
shutil.make_archive("output", "zip", "source_dir")
shutil.make_archive("output", "gztar", "source_dir")

# 解包
shutil.unpack_archive("output.zip", "extract_to/")
```

## sys — Python 解释器接口

```python
import sys

# 命令行参数（sys.argv[0] 是脚本名）
# 运行 python script.py arg1 arg2
print(sys.argv)   # ['script.py', 'arg1', 'arg2']

# Python 版本
print(sys.version)         # '3.12.0 (main, ...) [GCC ...]'
print(sys.version_info)    # sys.version_info(major=3, minor=12, ...)

# 平台
print(sys.platform)   # 'linux' / 'darwin' / 'win32'

# 模块搜索路径
print(sys.path)
sys.path.insert(0, "/my/custom/modules")  # 在开头插入自定义路径

# 标准输入输出
sys.stdout.write("Hello\n")
sys.stderr.write("Error message\n")

# 退出程序（0 为正常退出，非 0 为异常）
# sys.exit(0)

# 递归深度限制
print(sys.getrecursionlimit())    # 1000
sys.setrecursionlimit(2000)

# 对象内存大小
import sys
lst = [1, 2, 3]
print(sys.getsizeof(lst))   # bytes
```

## datetime — 日期与时间

`datetime` 是 Python 处理日期时间的现代模块，比 `time` 模块更易用：

```python
from datetime import datetime, date, timedelta, timezone

# 获取当前时间
now = datetime.now()             # 本地时间（无时区）
utcnow = datetime.now(timezone.utc)  # UTC 时间（推荐）

print(now)               # 2024-06-01 14:30:00.123456
print(now.year)          # 2024
print(now.strftime("%Y-%m-%d %H:%M:%S"))  # 2024-06-01 14:30:00

# 解析时间字符串
dt = datetime.strptime("2024-06-01 14:30:00", "%Y-%m-%d %H:%M:%S")

# 时间运算
tomorrow = now + timedelta(days=1)
last_week = now - timedelta(weeks=1)
diff = datetime(2024, 12, 31) - now
print(f"距年末还有 {diff.days} 天")

# 纯日期
today = date.today()
print(today.isoformat())   # 2024-06-01

# 时间戳互转
import time
ts = now.timestamp()           # datetime → 时间戳（float）
dt2 = datetime.fromtimestamp(ts)  # 时间戳 → datetime
```

## math — 数学运算

```python
import math

print(math.pi)            # 3.141592653589793
print(math.e)             # 2.718281828459045
print(math.tau)           # 6.283... (2π)

print(math.ceil(4.1))     # 5（向上取整）
print(math.floor(4.9))    # 4（向下取整）
print(math.trunc(4.9))    # 4（截断小数部分）

print(math.sqrt(16))      # 4.0
print(math.pow(2, 10))    # 1024.0
print(math.log(100, 10))  # 2.0（以 10 为底）
print(math.log2(1024))    # 10.0
print(math.log10(1000))   # 3.0

print(math.fabs(-3.14))   # 3.14（浮点绝对值）
print(math.gcd(48, 18))   # 6（最大公约数，Python 3.9+ 支持多参数）
print(math.lcm(4, 6))     # 12（最小公倍数，Python 3.9+）
print(math.factorial(10)) # 3628800

# 三角函数（参数为弧度）
print(math.sin(math.pi / 2))  # 1.0
print(math.degrees(math.pi))  # 180.0
print(math.radians(180))       # 3.14...
```

## random — 随机数

```python
import random

# 基本随机数
print(random.random())          # [0.0, 1.0)
print(random.uniform(1.5, 3.5)) # 指定范围内的浮点数
print(random.randint(1, 6))     # [1, 6] 闭区间整数（模拟骰子）
print(random.randrange(0, 10, 2))  # 0, 2, 4, 6, 8 中的一个

# 序列操作
items = ["apple", "banana", "cherry", "date"]
print(random.choice(items))          # 随机选一个
print(random.choices(items, k=3))    # 有放回地选 3 个（可重复）
print(random.sample(items, k=3))     # 无放回地选 3 个（不重复）

shuffled = items.copy()
random.shuffle(shuffled)             # 原地打乱
print(shuffled)

# 指定随机种子（可复现结果）
random.seed(42)
print([random.randint(1, 100) for _ in range(5)])
# 每次都相同：[2, 7, 39, 5, 56]（取决于实现）
```

## logging — 日志记录

`logging` 比 `print` 更适合生产代码，提供日志级别、格式化、输出目标等控制：

```python
import logging

# 五个级别（从低到高）：DEBUG < INFO < WARNING < ERROR < CRITICAL
logging.basicConfig(
    level=logging.DEBUG,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)

logger = logging.getLogger(__name__)   # 以模块名命名

logger.debug("调试信息，仅开发时查看")
logger.info("程序正常运行的记录")
logger.warning("警告：配置项缺失，使用默认值")
logger.error("错误：数据库连接失败")
logger.critical("严重错误：系统即将崩溃")
```

### 同时输出到文件和控制台

```python
import logging

logger = logging.getLogger("myapp")
logger.setLevel(logging.DEBUG)

# 文件 Handler
file_handler = logging.FileHandler("app.log", encoding="utf-8")
file_handler.setLevel(logging.WARNING)   # 文件只记录 WARNING 以上

# 控制台 Handler
stream_handler = logging.StreamHandler()
stream_handler.setLevel(logging.DEBUG)   # 控制台输出所有级别

# 统一格式
fmt = logging.Formatter("%(asctime)s [%(levelname)-8s] %(message)s")
file_handler.setFormatter(fmt)
stream_handler.setFormatter(fmt)

logger.addHandler(file_handler)
logger.addHandler(stream_handler)

logger.info("服务器已启动")
logger.error("连接超时")
```

### 日志配置（推荐方式）

```python
import logging.config

LOGGING_CONFIG = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "standard": {"format": "%(asctime)s [%(levelname)s] %(name)s: %(message)s"},
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "standard",
            "level": "DEBUG",
        },
        "file": {
            "class": "logging.FileHandler",
            "filename": "app.log",
            "formatter": "standard",
            "level": "WARNING",
            "encoding": "utf-8",
        },
    },
    "root": {"handlers": ["console", "file"], "level": "DEBUG"},
}

logging.config.dictConfig(LOGGING_CONFIG)
logger = logging.getLogger(__name__)
```

## zipfile — ZIP 压缩

```python
import zipfile

# 创建 zip 压缩包
with zipfile.ZipFile("archive.zip", "w", zipfile.ZIP_DEFLATED) as zf:
    zf.write("file1.txt")
    zf.write("file2.txt", arcname="renamed.txt")  # 存储时重命名

# 解压
with zipfile.ZipFile("archive.zip", "r") as zf:
    zf.extractall("output_dir/")               # 解压全部
    zf.extract("renamed.txt", "output_dir/")   # 解压指定文件
    print(zf.namelist())                        # 查看内容列表

# 追加文件
with zipfile.ZipFile("archive.zip", "a") as zf:
    zf.write("new_file.txt")
```

## tarfile — TAR 压缩

```python
import tarfile

# 创建 .tar.gz
with tarfile.open("archive.tar.gz", "w:gz") as tf:
    tf.add("src_dir/", arcname="backup")  # 目录整体打包

# 解压
with tarfile.open("archive.tar.gz", "r:gz") as tf:
    tf.extractall("output_dir/")
    print(tf.getnames())   # 查看内容列表

# 格式说明：
# "w"     → .tar（仅打包，不压缩）
# "w:gz"  → .tar.gz（gzip 压缩）
# "w:bz2" → .tar.bz2（bzip2 压缩，通常更小）
# "w:xz"  → .tar.xz（xz 压缩，压缩率最高）
```
