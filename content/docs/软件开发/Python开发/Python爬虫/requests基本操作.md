---
title: "requests基本操作"
weight: 1
date: 2026-06-23
tags: ["Python", "爬虫", "requests", "HTTP"]
---

`requests` 是 Python 中最流行的 HTTP 客户端库，语法简洁直观。本篇介绍基本的 GET/POST 请求、响应处理和常用参数。

## 安装

```bash
pip install requests
```

## 发起请求

```python
import requests

# GET 请求
response = requests.get("https://httpbin.org/get")

# POST 请求
response = requests.post("https://httpbin.org/post", data={"key": "value"})

# 其他 HTTP 方法
requests.put("https://api.example.com/items/1", json={"name": "new"})
requests.delete("https://api.example.com/items/1")
requests.patch("https://api.example.com/items/1", json={"name": "patch"})
requests.head("https://example.com")
```

## Response 对象

```python
import requests

resp = requests.get("https://httpbin.org/get")

print(resp.status_code)          # 200
print(resp.ok)                   # True（状态码 < 400）
print(resp.headers)              # 响应头字典
print(resp.headers["Content-Type"])

# 响应体
print(resp.text)                 # 文本（自动解码）
print(resp.encoding)             # 当前解码字符集
print(resp.content)              # 原始字节（用于图片/文件）
print(resp.json())               # 解析 JSON → Python 字典

# 手动指定编码（解决乱码）
resp.encoding = "utf-8"
print(resp.text)
```

## URL 参数（params）

```python
import requests

params = {
    "q": "Python requests",
    "page": 1,
    "size": 20,
}

# 等价于 GET /search?q=Python+requests&page=1&size=20
resp = requests.get("https://httpbin.org/get", params=params)
print(resp.url)   # 查看完整 URL
```

## POST 请求参数

```python
import requests

# 表单提交（Content-Type: application/x-www-form-urlencoded）
resp = requests.post(
    "https://httpbin.org/post",
    data={"username": "alice", "password": "secret"},
)

# JSON 提交（Content-Type: application/json，推荐用于 REST API）
resp = requests.post(
    "https://httpbin.org/post",
    json={"user": "alice", "age": 25},
)

# 上传文件（multipart/form-data）
with open("avatar.png", "rb") as f:
    resp = requests.post(
        "https://httpbin.org/post",
        files={"file": ("avatar.png", f, "image/png")},
    )
```

## 请求头（headers）

浏览器访问与爬虫最关键的区别在于 `User-Agent`：

```python
import requests

headers = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/124.0.0.0 Safari/537.36"
    ),
    "Accept-Language": "zh-CN,zh;q=0.9",
    "Referer": "https://www.google.com",
}

resp = requests.get("https://httpbin.org/headers", headers=headers)
print(resp.json())
```

## 超时与异常处理

```python
import requests
from requests.exceptions import (
    Timeout,
    ConnectionError,
    HTTPError,
    RequestException,
)

try:
    resp = requests.get(
        "https://httpbin.org/delay/5",
        timeout=(3, 10),   # (连接超时, 读取超时) 秒
    )
    resp.raise_for_status()  # 4xx/5xx 自动抛出 HTTPError
    print(resp.json())

except Timeout:
    print("请求超时")
except ConnectionError:
    print("网络连接失败")
except HTTPError as e:
    print(f"HTTP 错误: {e.response.status_code}")
except RequestException as e:
    print(f"请求失败: {e}")
```

## 代理

```python
import requests

proxies = {
    "http":  "http://127.0.0.1:7890",
    "https": "http://127.0.0.1:7890",
}

resp = requests.get("https://httpbin.org/ip", proxies=proxies, timeout=10)
print(resp.json())
```

## Cookie

```python
import requests

# 方式一：字典
resp = requests.get(
    "https://httpbin.org/cookies",
    cookies={"session": "abc123"},
)

# 方式二：Session 自动管理 Cookie（推荐，模拟登录场景）
session = requests.Session()
session.get("https://example.com/login")   # 服务器设置 cookie
session.get("https://example.com/profile") # 自动携带 cookie

# 查看当前 session 的 cookie
print(dict(session.cookies))
```

## Session — 复用连接

```python
import requests

# Session 会复用 TCP 连接，提升批量请求性能，并自动保持 Cookie
with requests.Session() as s:
    s.headers.update({
        "User-Agent": "Mozilla/5.0",
        "Authorization": "Bearer my-token",
    })

    for url in urls:
        resp = s.get(url, timeout=10)
        print(resp.status_code)
```

## SSL 验证

```python
import requests

# 关闭 SSL 验证（仅用于内网/自签名证书，生产环境不推荐）
resp = requests.get("https://self-signed.example.com", verify=False)

# 指定 CA 证书
resp = requests.get("https://example.com", verify="/path/to/ca.crt")
```

## 下载文件

```python
import requests
from pathlib import Path

def download_file(url: str, dest: Path) -> None:
    """流式下载文件，避免将整个文件载入内存。"""
    with requests.get(url, stream=True, timeout=30) as resp:
        resp.raise_for_status()
        with dest.open("wb") as f:
            for chunk in resp.iter_content(chunk_size=8192):
                f.write(chunk)

download_file("https://example.com/large-file.zip", Path("file.zip"))
```
