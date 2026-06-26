---
title: "requests进阶操作"
weight: 2
date: 2026-06-23
tags: ["Python", "爬虫", "requests", "Session", "代理", "并发"]
---

本篇在 [requests 基本操作](../requests基本操作) 基础上，介绍爬虫中常见的进阶场景：Session 保持、Cookie 反爬、代理 IP、图片懒加载识别和并发下载。

## Session：模拟登录与 Cookie 保持

有些网站的数据接口需要先访问主页触发 Cookie，再访问目标 API，Session 可以自动管理这个过程：

```python
import requests

headers = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
    )
}

with requests.Session() as sess:
    # 第一次请求：服务端设置 Cookie，Session 自动保存
    sess.get("https://xueqiu.com/", headers=headers, timeout=10)

    # 第二次请求：自动携带 Cookie
    api_url = "https://xueqiu.com/statuses/hot/listV2.json?since_id=-1&max_id=72813&size=15"
    data = sess.get(api_url, headers=headers, timeout=10).json()
    print(data)
```

### 手动指定 Cookie

```python
import requests

# 从浏览器开发者工具 → Application → Cookies 中复制
cookies = {
    "session_id": "abc123",
    "user_token": "xyz789",
}

with requests.Session() as sess:
    sess.headers.update(headers)
    sess.cookies.update(cookies)
    resp = sess.get("https://example.com/api/data", timeout=10)
    print(resp.json())
```

## 代理 IP

当频繁请求同一网站导致 IP 被封禁时，使用代理 IP 转发请求：

```python
import requests
import random

proxies_pool = [
    {"https": "http://1.2.3.4:8080"},
    {"https": "http://5.6.7.8:3128"},
]

headers = {"User-Agent": "Mozilla/5.0"}
url = "https://httpbin.org/ip"

proxy = random.choice(proxies_pool)
try:
    resp = requests.get(url, headers=headers, proxies=proxy, timeout=10)
    print(resp.json())
except requests.exceptions.ProxyError:
    print("代理连接失败，切换代理")
```

### 代理匿名度说明

- **透明代理**：对方知道真实 IP 和代理 IP。
- **匿名代理**：对方知道在使用代理，但不知道真实 IP。
- **高匿代理**：对方无法判断是否使用了代理。

爬虫使用高匿代理效果最佳，可从代理平台 API 动态获取 IP 列表。

## 图片懒加载

部分网站使用**懒加载**反爬：图片的真实地址不放在 `src` 属性中，而放在 `src2`、`data-src`、`original` 等伪属性里，当用户滚动到该区域时才动态赋值给 `src`。

```python
import requests
from lxml import etree
from pathlib import Path

headers = {"User-Agent": "Mozilla/5.0"}
resp = requests.get("https://example.com/gallery", headers=headers, timeout=10)
tree = etree.HTML(resp.text)

# 普通加载：取 src
normal_srcs = tree.xpath('//img/@src')

# 懒加载：取 data-src（不同网站属性名不同）
lazy_srcs = tree.xpath('//img/@data-src')
lazy_srcs2 = tree.xpath('//img/@src2')

print("懒加载图片:", lazy_srcs or lazy_srcs2)
```

**识别懒加载**：在浏览器开发者工具 Elements 面板中查看 img 标签，若 src 为空白图或 base64 占位图，说明使用了懒加载，需找到真实属性名。

## 并发下载（ThreadPoolExecutor）

I/O 密集型的批量下载场景，用线程池可以显著提速：

```python
import requests
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
import time

headers = {"User-Agent": "Mozilla/5.0"}

def download_image(url: str, save_dir: Path) -> str:
    filename = url.rsplit("/", 1)[-1]
    filepath = save_dir / filename
    if filepath.exists():
        return f"已存在: {filename}"

    resp = requests.get(url, headers=headers, timeout=30, stream=True)
    resp.raise_for_status()

    with filepath.open("wb") as f:
        for chunk in resp.iter_content(chunk_size=8192):
            f.write(chunk)

    time.sleep(0.2)   # 礼貌等待，避免触发速率限制
    return f"完成: {filename}"

if __name__ == "__main__":
    img_urls = [
        "https://httpbin.org/image/png",
        "https://httpbin.org/image/jpeg",
    ]
    save_dir = Path("downloads")
    save_dir.mkdir(exist_ok=True)

    with ThreadPoolExecutor(max_workers=4) as executor:
        futures = {executor.submit(download_image, url, save_dir): url for url in img_urls}
        for future in as_completed(futures):
            try:
                print(future.result())
            except Exception as e:
                print(f"下载失败: {futures[future]} → {e}")
```

## 翻页爬取

构建通用 URL 模板，循环生成各页 URL：

```python
import requests
from bs4 import BeautifulSoup
import time

headers = {"User-Agent": "Mozilla/5.0"}

def crawl_page(url: str) -> list[dict]:
    resp = requests.get(url, headers=headers, timeout=10)
    resp.raise_for_status()
    soup = BeautifulSoup(resp.text, "lxml")

    items = []
    for article in soup.select("article.product_pod"):
        items.append({
            "title": article.h3.a["title"],
            "price": article.select_one(".price_color").get_text(strip=True),
        })
    return items

all_data = []
base_url = "https://books.toscrape.com/catalogue/page-{}.html"

for page in range(1, 6):   # 爬前 5 页
    url = base_url.format(page)
    print(f"正在爬取第 {page} 页...")
    try:
        data = crawl_page(url)
        all_data.extend(data)
    except requests.RequestException as e:
        print(f"第 {page} 页失败: {e}")
    time.sleep(0.5)   # 降低请求频率

print(f"共爬取 {len(all_data)} 条数据")
```

## robots.txt 合规

在爬取网站前，先检查 `robots.txt` 了解允许和禁止的路径：

```python
import urllib.robotparser

rp = urllib.robotparser.RobotFileParser()
rp.set_url("https://books.toscrape.com/robots.txt")
rp.read()

url_to_check = "https://books.toscrape.com/catalogue/page-1.html"
user_agent = "my-bot"

if rp.can_fetch(user_agent, url_to_check):
    print(f"允许爬取: {url_to_check}")
else:
    print(f"禁止爬取: {url_to_check}")
```
