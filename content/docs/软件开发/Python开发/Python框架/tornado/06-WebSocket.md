---
title: "WebSocket"
weight: 60
date: 2026-06-29
tags: ["Python", "Tornado", "WebSocket", "实时通信", "聊天室"]
---

WebSocket 是一种在单个 TCP 连接上进行全双工通信的协议，由客户端发起 HTTP Upgrade 握手（101 Switching Protocols）升级而来，之后双方可以任意时刻互发消息，无需反复建立连接。Tornado 对 WebSocket 有原生支持，适合构建聊天室、实时数据推送、多人协作等场景。

本文介绍 Tornado `WebSocketHandler` 的核心接口，并通过两个完整示例演示基础连接和多用户聊天室的实现。

## WebSocketHandler 核心接口

继承 `tornado.websocket.WebSocketHandler` 并重写以下方法即可处理 WebSocket 连接：

| 方法 | 触发时机 |
| --- | --- |
| `open(*args, **kwargs)` | WebSocket 握手成功，连接建立 |
| `on_message(message)` | 收到客户端消息（文本为 `str`，二进制为 `bytes`） |
| `on_close()` | 连接关闭（客户端或服务端均可触发） |
| `on_ping(data)` | 收到客户端 Ping 帧（可选重写） |
| `on_pong(data)` | 收到客户端 Pong 帧（可选重写） |

主动发送与关闭：

| 方法 | 说明 |
| --- | --- |
| `write_message(message, binary=False)` | 向客户端发送消息（异步，建议 `await`） |
| `close(code=None, reason=None)` | 主动关闭连接 |
| `ping(data)` | 发送 Ping 帧 |

其他常用属性：

- `self.close_code` / `self.close_reason`：关闭时的状态码和原因
- `self.request`：握手时的 HTTP 请求对象（可读取 Headers、Cookie 等）

## 跨域处理

浏览器在 WebSocket 握手时会携带 `Origin` 头，Tornado 默认只允许与当前域名相同的请求。跨域时需重写 `check_origin()`：

```python
class MyWebSocketHandler(tornado.websocket.WebSocketHandler):
    def check_origin(self, origin):
        return True   # 允许所有来源（开发环境）
        # 生产环境应检查 origin 白名单
```

## 基础示例

服务端：

```python
import tornado.ioloop
import tornado.web
import tornado.websocket

class EchoWebSocket(tornado.websocket.WebSocketHandler):
    def check_origin(self, origin):
        return True

    async def open(self):
        print(f"新连接：{self.request.remote_ip}")
        await self.write_message("欢迎连接 Echo 服务！")

    async def on_message(self, message):
        print(f"收到消息：{message}")
        await self.write_message(f"你发送了：{message}")

    def on_close(self):
        print(f"连接断开，code={self.close_code}")

def make_app():
    return tornado.web.Application([
        (r"/ws", EchoWebSocket),
    ])

if __name__ == "__main__":
    app = make_app()
    app.listen(8888)
    tornado.ioloop.IOLoop.current().start()
```

客户端（浏览器 JavaScript）：

```javascript
const ws = new WebSocket("ws://localhost:8888/ws");

ws.onopen = () => {
    console.log("连接成功");
    ws.send("你好，Tornado！");
};

ws.onmessage = (event) => {
    console.log("收到：", event.data);
};

ws.onerror = (error) => {
    console.error("连接出错：", error);
};

ws.onclose = (event) => {
    console.log(`连接关闭，code=${event.code}`);
};
```

## 聊天室案例

聊天室的核心是维护一个全局在线用户集合，每当有新消息时广播给所有在线用户。

### 服务端

```python
import tornado.ioloop
import tornado.web
import tornado.websocket

class ChatHandler(tornado.websocket.WebSocketHandler):
    users = set()   # 所有在线连接

    def check_origin(self, origin):
        return True

    def open(self):
        ChatHandler.users.add(self)
        self.nickname = self.get_argument("name", f"用户{id(self) % 10000}")
        self.broadcast(f"[系统] {self.nickname} 加入了聊天室")

    async def on_message(self, message):
        self.broadcast(f"[{self.nickname}] {message}")

    def on_close(self):
        ChatHandler.users.discard(self)
        self.broadcast(f"[系统] {self.nickname} 离开了聊天室")

    def broadcast(self, message):
        for user in ChatHandler.users:
            try:
                user.write_message(message)
            except tornado.websocket.WebSocketClosedError:
                ChatHandler.users.discard(user)

class IndexHandler(tornado.web.RequestHandler):
    def get(self):
        self.render("chat.html")

def make_app():
    return tornado.web.Application(
        [
            (r"/", IndexHandler),
            (r"/ws", ChatHandler),
        ],
        template_path="templates",
        debug=True,
    )

if __name__ == "__main__":
    app = make_app()
    app.listen(8888)
    print("聊天室已启动：http://localhost:8888")
    tornado.ioloop.IOLoop.current().start()
```

### 客户端页面 templates/chat.html

```html
<!DOCTYPE html>
<html lang="zh">
<head>
  <meta charset="UTF-8">
  <title>Tornado 聊天室</title>
  <style>
    #messages { height: 400px; overflow-y: auto; border: 1px solid #ccc; padding: 8px; }
    #input-row { display: flex; gap: 8px; margin-top: 8px; }
    #msg-input { flex: 1; }
  </style>
</head>
<body>
  <h2>Tornado 聊天室</h2>
  <div id="messages"></div>
  <div id="input-row">
    <input id="msg-input" type="text" placeholder="输入消息..." autofocus>
    <button onclick="sendMessage()">发送</button>
  </div>

  <script>
    const name = prompt("请输入你的昵称：") || "匿名";
    const ws = new WebSocket(`ws://${location.host}/ws?name=${encodeURIComponent(name)}`);
    const messages = document.getElementById("messages");
    const input = document.getElementById("msg-input");

    ws.onmessage = (event) => {
        const div = document.createElement("div");
        div.textContent = event.data;
        messages.appendChild(div);
        messages.scrollTop = messages.scrollHeight;
    };

    ws.onclose = () => {
        const div = document.createElement("div");
        div.textContent = "[连接已断开]";
        div.style.color = "gray";
        messages.appendChild(div);
    };

    function sendMessage() {
        const text = input.value.trim();
        if (text && ws.readyState === WebSocket.OPEN) {
            ws.send(text);
            input.value = "";
        }
    }

    input.addEventListener("keydown", (e) => {
        if (e.key === "Enter") sendMessage();
    });
  </script>
</body>
</html>
```

## 心跳保活

长时间无数据传输时，中间网络设备（代理、NAT）可能断开连接。可用 Ping/Pong 机制维持连接：

```python
import asyncio

class ChatHandler(tornado.websocket.WebSocketHandler):
    HEARTBEAT_INTERVAL = 30   # 秒

    def open(self):
        self._heartbeat = asyncio.get_event_loop().call_later(
            self.HEARTBEAT_INTERVAL, self._send_ping
        )

    def _send_ping(self):
        try:
            self.ping(b"ping")
            self._heartbeat = asyncio.get_event_loop().call_later(
                self.HEARTBEAT_INTERVAL, self._send_ping
            )
        except tornado.websocket.WebSocketClosedError:
            pass

    def on_close(self):
        if hasattr(self, "_heartbeat"):
            self._heartbeat.cancel()
```

{{< callout type="info" >}}
`write_message()` 是协程，在高并发广播场景中应使用 `asyncio.gather()` 并行发送，避免逐个 `await` 串行阻塞。
{{< /callout >}}
