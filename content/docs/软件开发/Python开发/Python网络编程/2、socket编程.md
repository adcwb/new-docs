---
title: "Socket 编程"
weight: 2
date: 2026-06-23
tags: ["Python", "Socket", "TCP", "UDP", "网络编程"]
---

`socket` 是 Python 标准库中进行网络通信的底层模块。所有高层网络库（`http`、`asyncio`、`aiohttp` 等）都基于 socket 实现。

## Socket 基本函数

| 函数 | 说明 |
| ---- | ---- |
| `socket.socket(family, type)` | 创建套接字。`AF_INET`=IPv4，`SOCK_STREAM`=TCP，`SOCK_DGRAM`=UDP |
| `s.bind((host, port))` | 绑定地址和端口（服务端） |
| `s.listen(backlog)` | 开始监听，`backlog` 为等待队列长度 |
| `s.accept()` | 阻塞，等待客户端连接，返回 `(conn, addr)` |
| `s.connect((host, port))` | 连接服务端（客户端） |
| `s.send(data)` | 发送字节数据 |
| `s.recv(bufsize)` | 接收最多 `bufsize` 字节 |
| `s.close()` | 关闭套接字 |
| `s.setsockopt(level, option, value)` | 设置套接字选项 |
| `s.settimeout(seconds)` | 设置超时时间 |

## TCP 通信示例

TCP 是可靠的面向连接协议，通信前需要三次握手建立连接。

### TCP 服务端

```python
import socket

def run_server(host: str = "127.0.0.1", port: int = 9000) -> None:
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

    # SO_REUSEADDR：允许重用端口，避免 TIME_WAIT 状态导致的"端口占用"错误
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    server.bind((host, port))
    server.listen(5)
    print(f"服务器监听 {host}:{port}")

    while True:
        conn, addr = server.accept()   # 阻塞，等待新连接
        print(f"客户端连接: {addr}")

        try:
            while True:
                data = conn.recv(1024)
                if not data:
                    break   # 客户端断开连接

                message = data.decode("utf-8")
                print(f"收到: {message}")

                reply = f"服务端已收到: {message}"
                conn.sendall(reply.encode("utf-8"))
        finally:
            conn.close()
            print(f"客户端 {addr} 断开")

if __name__ == "__main__":
    run_server()
```

### TCP 客户端

```python
import socket

def run_client(host: str = "127.0.0.1", port: int = 9000) -> None:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as client:
        client.connect((host, port))
        print(f"已连接到 {host}:{port}")

        messages = ["Hello!", "Python socket", "再见"]
        for msg in messages:
            client.sendall(msg.encode("utf-8"))
            data = client.recv(1024)
            print(f"服务端回复: {data.decode('utf-8')}")

if __name__ == "__main__":
    run_client()
```

## 处理多客户端（多线程）

单进程服务器每次只能处理一个客户端，使用多线程可并发处理多个连接：

```python
import socket
import threading

def handle_client(conn: socket.socket, addr: tuple) -> None:
    print(f"新连接: {addr}")
    try:
        while True:
            data = conn.recv(1024)
            if not data:
                break
            conn.sendall(data)   # echo server：原样返回
    finally:
        conn.close()

def run_echo_server(host: str = "0.0.0.0", port: int = 9001) -> None:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server:
        server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        server.bind((host, port))
        server.listen(10)
        print(f"Echo 服务器启动 {host}:{port}")

        while True:
            conn, addr = server.accept()
            t = threading.Thread(target=handle_client, args=(conn, addr), daemon=True)
            t.start()

if __name__ == "__main__":
    run_echo_server()
```

## UDP 通信示例

UDP 无连接，不保证送达，但速度快，适合实时场景（视频流、游戏等）。

### UDP 服务端

```python
import socket

def run_udp_server(host: str = "127.0.0.1", port: int = 9002) -> None:
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as server:
        server.bind((host, port))
        print(f"UDP 服务器监听 {host}:{port}")

        while True:
            data, addr = server.recvfrom(1024)   # 同时返回数据和来源地址
            print(f"来自 {addr}: {data.decode()}")

            reply = f"已收到: {data.decode()}"
            server.sendto(reply.encode(), addr)

if __name__ == "__main__":
    run_udp_server()
```

### UDP 客户端

```python
import socket

def run_udp_client(host: str = "127.0.0.1", port: int = 9002) -> None:
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as client:
        client.settimeout(5)   # 超时 5 秒

        for msg in ["Hello", "World"]:
            client.sendto(msg.encode(), (host, port))
            try:
                reply, server_addr = client.recvfrom(1024)
                print(f"服务端回复: {reply.decode()}")
            except socket.timeout:
                print("等待回复超时")

if __name__ == "__main__":
    run_udp_client()
```

## 超时与非阻塞

```python
import socket

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind(("127.0.0.1", 9003))
server.listen(5)

# 设置 accept 超时时间
server.settimeout(10)

try:
    conn, addr = server.accept()
    print(f"连接: {addr}")
except socket.timeout:
    print("10 秒内无客户端连接，退出")
finally:
    server.close()
```

## 获取本机信息

```python
import socket

hostname = socket.gethostname()
local_ip = socket.gethostbyname(hostname)
print(f"主机名: {hostname}")
print(f"本机 IP: {local_ip}")

# 查询远程主机 IP
remote_ip = socket.gethostbyname("www.python.org")
print(f"python.org IP: {remote_ip}")
```
