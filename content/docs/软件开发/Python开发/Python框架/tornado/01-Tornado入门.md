---
title: "Tornado 入门"
weight: 10
date: 2026-06-26
tags: ["Python", "Tornado", "Web框架", "异步"]
---

Tornado 是由 FriendFeed 开发、后被 Facebook 开源的 Python Web 框架与异步网络库。它不依赖 WSGI，直接基于非阻塞 I/O 和事件循环处理请求，单进程可支撑数千并发连接，尤其适合长轮询、WebSocket 等需要维持长连接的场景。

本文介绍 Tornado 的安装与核心概念，并通过最小可运行示例逐步演示路由配置、调试模式及多进程部署。

## 安装

```bash
pip install tornado
```

Tornado 6.x 要求 Python 3.8+，官方推荐在 Python 3.10+ 环境中使用 `async/await` 原生协程。

## 与 Django/Flask 的对比

| 维度 | Django | Flask | Tornado |
| --- | --- | --- | --- |
| 定位 | 全功能同步框架 | 轻量同步框架 | 异步框架 + 网络库 |
| 并发模型 | 多进程/多线程 | 多进程/多线程 | 异步事件循环 |
| ORM | 内置 | 无 | 无 |
| 适用场景 | 传统 Web / 管理后台 | 小型服务 / 原型 | 高并发 / 长连接 |
| 学习曲线 | 中 | 低 | 中（需理解异步） |

## 第一个 Tornado 应用

```python
import tornado.ioloop
import tornado.web

class IndexHandler(tornado.web.RequestHandler):
    def get(self):
        self.write("Hello, Tornado!")

def make_app():
    return tornado.web.Application([
        (r"/", IndexHandler),
    ])

if __name__ == "__main__":
    app = make_app()
    app.listen(8888)
    tornado.ioloop.IOLoop.current().start()
```

三个核心对象：

- `RequestHandler`：每个路由对应一个 Handler 类，每个 HTTP 方法对应同名方法（`get`、`post`、`put`、`delete` 等）。
- `Application`：应用本体，接收路由列表和全局设置。
- `IOLoop`：事件循环，`IOLoop.current().start()` 启动后阻塞运行，直到进程退出。

## 路由配置

路由列表中每项是一个元组 `(pattern, handler)` 或通过 `tornado.web.url()` 构造：

```python
from tornado.web import Application, url

app = Application([
    url(r"/",          IndexHandler,  name="index"),
    url(r"/user/(\d+)", UserHandler,  name="user_detail"),
    url(r"/admin",     AdminHandler,  {"title": "管理后台"}, name="admin"),
])
```

`url()` 的四个参数：

| 参数 | 含义 |
| --- | --- |
| `pattern` | 正则表达式 URL 模式 |
| `handler` | 处理该路由的 Handler 类 |
| `kwargs`（可选）| 传递给 `initialize()` 的关键字参数字典 |
| `name`（可选）| 路由名称，用于 `reverse_url()` 反解析 |

## 全局配置项

`Application` 的第二个参数接收配置字典：

```python
settings = {
    "debug": True,                        # 调试模式
    "template_path": "templates",         # 模板目录
    "static_path": "static",              # 静态文件目录
    "static_url_prefix": "/static/",      # 静态文件 URL 前缀
    "cookie_secret": "your-secret-key",   # 加密 Cookie 密钥
    "login_url": "/login",                # 认证重定向地址
    "xsrf_cookies": True,                 # 启用 XSRF 防护
}

app = Application(handlers, **settings)
```

### 调试模式

`debug: True` 开启后：

- 代码修改后自动重启服务器
- 捕获的异常会输出完整 traceback 到浏览器
- **不要在生产环境开启**

## 终端参数

`tornado.options` 模块提供命令行参数解析，不依赖 `argparse`：

```python
from tornado.options import define, options, parse_command_line

define("port", default=8888, type=int, help="监听端口")
define("debug", default=False, type=bool, help="调试模式")

if __name__ == "__main__":
    parse_command_line()   # 解析 sys.argv
    app = make_app()
    app.listen(options.port)
    tornado.ioloop.IOLoop.current().start()
```

启动时传入参数：

```bash
python app.py --port=9000 --debug=true
```

## 多进程模式

默认 `app.listen()` 是单进程。要充分利用多核 CPU，使用 `HTTPServer` + `server.start(n)`：

```python
import tornado.httpserver

if __name__ == "__main__":
    app = make_app()
    server = tornado.httpserver.HTTPServer(app)
    server.bind(8888)
    server.start(0)   # 0 表示按 CPU 核心数启动子进程
    tornado.ioloop.IOLoop.current().start()
```

`server.start(n)` 参数含义：

- `0`：自动等于当前机器的 CPU 核心数
- `1`：单进程（等同于 `app.listen()`）
- `n > 1`：手动指定进程数

{{< callout type="warning" >}}
多进程模式下，`server.start()` 必须在 `IOLoop.current().start()` 之前调用，且不能在 Windows 上使用（`fork` 不被支持）。生产环境建议改用 Supervisor/Gunicorn 等工具管理多个 Tornado 进程。
{{< /callout >}}
