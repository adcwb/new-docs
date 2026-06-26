---
title: "day03"
weight: 3
date: 2026-06-05
---

## 同步和异步

### 概念

**同步**是指代在程序执行多个任务时，按部就班的依次执行，必须上一个任务执行完有了结果以后，才会执行下一个任务。

**异步**是指代在程序执行多个任务时，没有先后依序，可以同时执行，所以在执行上一个任务时不会等待结果，直接执行下一个任务。一般最终在下一个任务中通过状态的改变或者通知、回调的方式来获取上一个任务的执行结果。

#### 同步

server.py，代码：

```python
import time
def client_A():
    """模拟客户端A"""
    print('开始处理请求1-1')
    time.sleep(5)
    print('完成处理请求1-2')


def client_B():
    """模拟客户端B"""
    print('开始处理请求2-1')
    print('完成处理请求2-2')


def tornado():
    """模拟tornado框架"""
    client_A()
    client_B()


if __name__ == "__main__":
    tornado()
```

#### 异步

server.py，代码：

```python
from threading import Thread
from time import sleep

def async(func):
    def wrapper(*args, **kwargs):
        thread = Thread(target=func, args=args, kwargs=kwargs)
        thread.start()
    return wrapper

@async
def funcA():
    sleep(5)
    print("funcA执行了")

def funcB():
    print("funcB执行了")

def tornado():
    funcA()
    funcB()

if __name__ == "__main__":
    tornado()
```



#### 协程

要理解什么是协程（Coroutine），必须先清晰**迭代器**和**生成器**的概念。

##### 迭代器

迭代器就是一个对象，一个可迭代的对象，是可以被for循环遍历输出的对象。当然专业的说，就是实现了迭代器协议的对象。

任何一个对象，只要类中实现了`__iter__()`就是一个可迭代对象（iterable）。

任何一个对象，只要类中实现了`__iter__()`和`__next__()`就是一个迭代器（iterator）。

迭代器一定是可迭代对象，可迭代对象不一定是迭代器。

要了解迭代器，我们先编写一个代码来看看python提供的可迭代对象。常见的有：str，list ，tuple，dic，set，文件对象。

迭代器是惰性执行的，可以节省内存，不能反复, 只能向下取值。

server.py，代码：

```python
# 可迭代对象
# arr = [4,5,6,7]
# arr = "abcd"
# print(dir(arr))
# for item in arr:
#     print(item)

# 不可迭代对象
# num = 123
# print(dir(num))
# for item in num: # TypeError: 'int' object is not iterable
#     print(item)

# 自定义可迭代对象
class Colors(object):
    def __init__(self):
        self.data = ["红色", "橙色", "紫色", "黄色"]

    def __iter__(self):
        # __iter__ 必须有返回值，并且只能返回迭代器对象
        return self.data.__iter__()

colors = Colors()
print(dir(colors))
for item in colors:
    print(item)
```

查看一个对象是否是可迭代对象或迭代器：

```python
from collections import Iterable, Iterator
data = [1,2,3,4]
print(isinstance(data,Iterable)) # True       # 查看是不是可迭代对象
print(isinstance(data,Iterator)) # False      # 查看是不是迭代器
print(isinstance(data.__iter__(),Iterator))   # True，
# 所有的迭代对象都有一个__iter__方法，该方法的作用就是返回一个迭代器对象
```

接下来，动手编写一个迭代器。

server.py，代码：

```python
class Num(object):
    def __init__(self,max):
        self.max = max
        self.current = 0

    def __next__(self):
        # print("current=",self.current)
        if self.current >= self.max:
            raise StopIteration

        self.current += 1
        return self.current

    def __iter__(self):
        return self

num = Num(3) # 迭代器
# print(dir(num))
# for的内部本质上就是不断调用了迭代器的__next__()，
# 并在遇到StopIteration异常以后，终止程序的执行
# for item in num:
#     print(item)

while True:
    try:
        print(num.__next__())
    except StopIteration:
        break
```

>   `__iter__()` 方法返回一个特殊的迭代器对象， 这个迭代器对象实现了 `__next__()` 方法并通过 StopIteration 异常标识迭代的完成。
>
>   `__next__()` 方法返回下一个迭代器对象。
>
>   **StopIteration** 异常用于标识迭代的完成，防止出现无限循环，在 `__next__()` 方法中可以设置在完成**指定循环次数**后触发 **StopIteration** 异常来结束迭代。



##### 生成器

在 Python 中，使用了 **yield** 的函数被称为生成器函数。

生成器函数执行以后的返回结果就是**生成器**（**generator**），是一种特殊的迭代器。生成器只能用于迭代操作。

**yield** 是一个python内置的关键字，它的作用有一部分类似**return**，可以返回函数的执行结果。但是不同的是，return 会终止函数的执行，yield 不会终止生成器函数的执行。两者都会返回一个结果，但return只能一次给函数的调用处返回值，而yield是可以多次给next()方法返回值，而且yield还可以接受外界send()方法的传值。所以，更准确的来说，**yield是暂停程序的执行权并记录了程序当前的运行状态的标记符.同时也是生成器函数外界和内部进行数据传递的通道**。

server.py，代码：

```python
def func():
    for item in [4,5,6]:
        return item

def gen1():
    for item in [4,5,6]:
        yield item

def gen2():
    key = 0
    print(">>>>> 嘟嘟，开车了")
    while True:
        food = yield "第%s次" % key
        print('接收了，%s'% food)
        key +=1

f = func()
print(f)
g1 = gen1()
print(g1)
for item in g1:
    print(item)

g2 = gen1()
print(g2)
print(next(g2))
print(next(g2))
print(g2.__next__())
# print(next(g2))

g3 = gen2()
g3.send(None) # g3.__next__() 预激活生成器,让生成器内部执行到第一个yield位置，否则无法通过send传递数据给内部的yield
for item in ["苹果","芒果"]:
    print(g3.send(item))
```

>   使用生成器可以让代码量更少，内存使用更加高效节约。
>
>   所以在工作中针对海量数据查询，大文件的读取加载，都可以考虑使用生成器来完成。因为一次性读取大文件或海量数据必然需要存放内容，而往往读取的内容大于内存则可能导致内存不足，而使用生成器可以像挤牙膏一样，一次读取一部分数据通过yield返回，每次yield返回的数据都是保存在同一块内存中的，所以比较起来肯定比一次性读取大文件内容来说，内存的占用更少。



###### yield 和 yield from

yield from 也叫委派生成器.委派生成器的作用主要是用于多个生成器之间进行嵌套调用时使用的.

server.py，代码：

```python
def gen1():
    a = 0
    while True:
        # print("+++++++")
        a = yield a**2

def gen2(gen):
    yield from gen
    # a = 0
    # b = 1
    # gen.send(None)
    # while True:
    #     # print("-------")
    #     b = yield a
    #     a = gen.send(b)

if __name__ == '__main__':
    g1 = gen1()
    g2 = gen2(g1)
    g2.send(None)
    for i in range(5):
        # print(">>>> %s" % i)
        print(g2.send(i))
```



###### 基于生成器来实现协程异步

这也是协程的实现原理，任务交替切换执行（遇到IO操作时进行判断任务切换才有使用价值, 当前此处我们使用的生成器实现的协程,是无法判断当前任务是否是遇到IO的,我们通过第三方模块: geventlet来实现判断是否遇到IO操作.）。

server.py，代码：

```python
import time
def gen1():
    while True:
        print("--1")
        yield
        print("--2")
        time.sleep(1)

def gen2():
    while True:
        print("--3")
        yield
        print("--4")
        time.sleep(1)

if __name__ == "__main__":
    g1 = gen1()
    g2 = gen2()
    for i in range(3):
        next(g1)
        print("主程序!")
        next(g2)
```



## Tornado的协程

Tornado的异步编程也主要体现在网络IO的异步上，即异步Web请求。

### 异步Web请求客户端

Tornado提供了一个异步Web请求客户端tornado.httpclient.AsyncHTTPClient用来进行异步Web请求。

#### fetch(request)

用于执行一个web请求request，并异步返回一个tornado.httpclient.HTTPResponse响应。

request可以是一个url，也可以是一个tornado.httpclient.HTTPRequest对象。如果是url地址，fetch方法内部会自己构造一个HTTPRequest对象。

#### HTTPRequest

HTTP请求类，HTTPRequest的构造函数可以接收众多构造参数，最常用的如下：

-   **url** (string) – 要访问的url，此参数必传，除此之外均为可选参数
-   **method** (string) – HTTP访问方式，如“GET”或“POST”，默认为GET方式
-   **headers** (HTTPHeaders or dict) – 附加的HTTP协议头
-   **body** – HTTP请求的请求体

#### HTTPResponse

HTTP响应类，其常用属性如下：

-   **code**: HTTP状态码，如 200 或 404
-   **reason**: 状态码描述信息
-   **body**: 响应体字符串
-   **error**: 异常（可有可无）

### 基于gen.coroutine的协程异步

```python
from tornado import web,httpclient,gen,ioloop
import json
class Home(web.RequestHandler):
    @gen.coroutine
    def get(self):
        http = httpclient.AsyncHTTPClient()
        ip = "123.112.18.111"
        response = yield http.fetch("http://ip-api.com/json/%s?lang=zh-CN" % ip)
        if response.error:
            self.send_error(500)
        else:
            data = json.loads(response.body)
            if 'success' == data["status"]:
                self.write("国家：%s 省份: %s 城市: %s" % (data["country"], data["regionName"], data["city"]))
            else:
                self.write("查询IP信息错误")

# 设置路由列表
urls = [
    (r"/", Home),
]

if __name__ == "__main__":
    # 创建应用实例对象
    app = web.Application(urls, debug=True)
    # 设置监听的端口和地址
    app.listen(port=8888)
    # ioloop，全局的tornado事件循环，是服务器的引擎核心，start表示创建IO事件循环
    ioloop.IOLoop.current().start()
```



将异步Web请求单独抽取出来

```python
from tornado import web,httpclient,gen,ioloop
import json
class Home(web.RequestHandler):
    @gen.coroutine
    def get(self):

        ip = "123.112.18.111"
        data = yield self.get_ip_info(ip)
        if data["status"] == 'success':
            self.write("国家：%s 省份: %s 城市: %s" % (data["country"], data["regionName"], data["city"]))
        else:
            self.write("查询IP信息错误")


    @gen.coroutine
    def get_ip_info(self,ip):
        http = httpclient.AsyncHTTPClient()
        response = yield http.fetch("http://ip-api.com/json/%s?lang=zh-CN" % ip)
        if response.error:
            rep = {"status": "fail"}
        else:
            rep = json.loads(response.body)

        raise gen.Return(rep)
        # 此处需要注意，生成器函数中是不能直接return 返回数据的，否则出错，
        # 所以我们需要再此通过tornado 封装的异常对象gen.Return(rep)把结果进行抛出

# 设置路由列表
urls = [
    (r"/", Home),
]

if __name__ == "__main__":
    # 创建应用实例对象
    app = web.Application(urls, debug=True)
    # 设置监听的端口和地址
    app.listen(port=8888)
    # ioloop，全局的tornado事件循环，是服务器的引擎核心，start表示创建IO事件循环
    ioloop.IOLoop.current().start()
```



### 并行协程

Tornado可以同时执行多个异步，并发的异步可以使用列表或字典，如下：

```python
from tornado import web,httpclient,gen,ioloop
import json
class Home(web.RequestHandler):
    @gen.coroutine
    def get(self):
        ips = ["123.112.18.111",
               "112.112.233.89",
               "119.112.23.3",
               "120.223.70.76"]
        rep1, rep2 = yield [self.get_ip_info(ips[0]), self.get_ip_info(ips[1])]
        self.write_response(ips[0], rep1)
        self.write_response(ips[1], rep2)
        rep_dict = yield dict(rep3=self.get_ip_info(ips[2]), rep4=self.get_ip_info(ips[3]))
        self.write_response(ips[2], rep_dict['rep3'])
        self.write_response(ips[3], rep_dict['rep4'])

    def write_response(self,ip, rep):
        if 'success' == rep["status"]:
            self.write("IP:%s 国家：%s 省份: %s 城市: %s<br>" % (ip,rep["country"], rep["regionName"], rep["city"]))
        else:
            self.write("查询IP信息错误<br>")
    @gen.coroutine
    def get_ip_info(self, ip):
        http = httpclient.AsyncHTTPClient()
        response = yield http.fetch("http://ip-api.com/json/%s?lang=zh-CN" % ip)
        if response.error:
            rep = {"status":"fail"}
        else:
            rep = json.loads(response.body)
        raise gen.Return(rep)  # 此处需要注意

# 设置路由列表
urls = [
    (r"/", Home),
]

if __name__ == "__main__":
    # 创建应用实例对象
    app = web.Application(urls, debug=True)
    # 设置监听的端口和地址
    app.listen(port=8888)
    # ioloop，全局的tornado事件循环，是服务器的引擎核心，start表示创建IO事件循环
    ioloop.IOLoop.current().start()
```



## Tornado的WebSocket

WebSocket是HTML5规范中新提出的客户端-服务器通信协议，协议本身使用新的ws://URL格式。

WebSocket 是独立的、创建在 TCP 上的协议，和 HTTP 的唯一关联是使用 HTTP 协议的101状态码进行协议升级，使用的 TCP 端口是80，可以用于绕过大多数防火墙的限制。

WebSocket 使得客户端和服务器之间的数据交换变得更加简单，允许服务端直接向客户端主动推送数据而不需要客户端进行再次请求，两者之间可以创建持久性连接，并允许数据进行双向通信。

Tornado提供支持WebSocket的模块是tornado.websocket，其中提供了一个WebSocketHandler类用来处理通讯。

### 常用方法

#### open()

当一个WebSocket连接建立后被调用。

#### on_message(message)

当客户端发送消息message过来时被调用，**注意此方法必须被重写**。

#### on_close()

当WebSocket连接关闭后被调用。

#### write_message(message, binary=False)

向客户端发送消息messagea，message可以是字符串或字典（字典会被转为json字符串）。若binary为False，则message以utf8编码发送；二进制模式（binary=True）时，可发送任何字节码。

#### close()

关闭WebSocket连接。

#### check_origin(origin)

判断源origin，对于符合条件（返回判断结果为True）的请求源origin允许其连接，否则返回403。可以重写此方法来解决WebSocket的跨域请求（如始终return True）。

### 快速使用

server.py，代码：

```python
from tornado import web,ioloop
from tornado.websocket import WebSocketHandler

class Index(web.RequestHandler):
    def get(self):
        self.render("templates/index.html")

class Home(WebSocketHandler):
    def open(self):
        # 
        self.write_message("欢迎来到socket.html")

    def on_message(self, message):
        print("接收数据：%s" % message)

    def on_close(self):
        print("socket连接断开")

    def check_origin(self, origin):
        return True  # 允许WebSocket的跨域请求

# 设置路由列表
urls = [
    (r"/", Index),
    (r"/home", Home),
]

if __name__ == "__main__":
    # 创建应用实例对象
    app = web.Application(urls, debug=True)
    # 设置监听的端口和地址
    app.listen(port=8888)
    # ioloop，全局的tornado事件循环，是服务器的引擎核心，start表示创建IO事件循环
    ioloop.IOLoop.current().start()
```

tempales/index.html，代码：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title></title>
</head>
<body>
<div id="content"></div>
<script>
    var ws = new WebSocket("ws://127.0.0.1:8888/home"); // 新建一个ws连接
    ws.onopen = function() {  // 连接建立好后的回调
       ws.send("Hello, world");  // 向建立的连接发送消息
    };
    ws.onmessage = function (evt) {  // 收到服务器发送的消息后执行的回调
       content.innerHTML+=evt.data+"<br>";  // 接收的消息内容在事件参数evt的data属性中
    };
</script>
</body>
</html>
```

### 案例：聊天室

server.py，代码：

```python
from tornado import web,ioloop,httpserver,options
import datetime

from tornado.web import RequestHandler
from tornado.websocket import WebSocketHandler

class Index(RequestHandler):
    def get(self):
        self.render("templates/chat.html")

class Chat(WebSocketHandler):
    users = set()  # 用来存放用户的容器，必须类静态属性

    def open(self):
        self.users.add(self)  # 建立连接后保存客户端的socket连接对象到users容器中
        key = list(self.users).index(self)
        for user in self.users:  # 向已在线用户发送消息
            user.write_message("[%s]-%02d-[%s]-登录" % (self.request.remote_ip, key, datetime.datetime.now().strftime("%H:%M:%S")))

    def on_message(self, message):
        key = list(self.users).index(self)
        for user in self.users:  # 向在线用户广播消息
            user.write_message("[%s]-%02d-[%s]-发送：%s" % (self.request.remote_ip, key, datetime.datetime.now().strftime("%H:%M:%S"), message))

    def on_close(self):
        key = list(self.users).index(self)
        self.users.remove(self) # 用户关闭连接后从容器中移除用户
        for user in self.users:
            user.write_message("[%s]-%02d-[%s]-退出" % (self.request.remote_ip, key, datetime.datetime.now().strftime("%H:%M:%S")))

    def check_origin(self, origin):
        return True  # 允许WebSocket的跨域请求

urls = [
    (r"/", Index),
    (r"/chat", Chat),
]


if __name__ == '__main__':
    # 创建应用实例对象
    app = web.Application(urls)
    server = httpserver.HTTPServer(app)
    # 设置监听的端口和地址
    server.listen(port=8888,address="0.0.0.0")
    server.start(1)
    # ioloop，全局的tornado事件循环，是服务器的引擎核心，start表示创建IO事件循环
    ioloop.IOLoop.current().start()
```



templates/index.html，代码：

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>聊天室</title>
</head>
<body>
    <div>
        <textarea id="msg"></textarea>
        <button onclick="sendMsg()">发送</button>
    </div>
    <div id="content" style="height:500px;overflow:auto;"></div>
    <script>
        var ws = new WebSocket("ws://127.0.0.1:8888/chat");
        ws.onmessage = function(message) {
            console.log("接收数据:", message);
            content.innerHTML +="<p>" + message.data + "</p>";
        };

        function sendMsg() {
            console.log("发送数据:", msg.value);
            ws.send(msg.value);
            msg.value = "";
        }
    </script>
</body>
</html>
```

