---
title: "Flask基础"
weight: 1
date: 2026-06-23
tags: ["Python", "Flask", "Web框架", "HTTP"]
---

Flask 诞生于 2010 年，是 Armin Ronacher 基于 Werkzeug 工具箱编写的轻量级 Web 开发框架，当前稳定版本为 **Flask 3.x**（需要 Python 3.8+）。

Flask 本身只提供核心功能（路由、请求/响应、模板），其余功能通过扩展实现（数据库、认证、表单等）。这种设计让 Flask 极为灵活，适合从小型 API 到中型 Web 应用的各种场景。

其 WSGI 工具箱采用 Werkzeug（路由和请求），模板引擎使用 Jinja2。这两个是 Flask 框架的核心。

官网：[flask.palletsprojects.com](https://flask.palletsprojects.com/)

**Flask 常用第三方扩展包：**

- Flask-SQLalchemy：操作数据库,ORM；
- Flask-script：终端脚本工具，脚手架；
- Flask-migrate：管理迁移数据库；
- Flask-Session：Session存储方式指定；
- Flask-WTF：表单；
- Flask-Mail：邮件；
- Flask-Bable：提供国际化和本地化支持，翻译；
- Flask-Login：认证用户状态；
- Flask-OpenID：认证, OAuth；
- Flask-RESTful：开发REST API的工具；
- Flask JSON-RPC:  开发rpc远程服务[过程]调用
- Flask-Bootstrap：集成前端Twitter Bootstrap框架
- Flask-Moment：本地化日期和时间
- Flask-Admin：简单而可扩展的管理接口的框架

更多扩展可在 [PyPI Flask 分类](https://pypi.org/search/?c=Framework+%3A%3A+Flask) 中查找。

## 安装

```bash
# 创建虚拟环境（推荐）
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate

# 安装 Flask（当前稳定版 3.x）
pip install flask
```

## 创建 Flask 项目

与 Django 不同，Flask 不提供脚手架命令，需要手动创建项目目录和入口文件。

创建一个 Flask 框架的主程序，文件名可以是 `app.py`、`run.py` 或 `main.py`：

```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def index():
    return 'Hello World'

if __name__ == '__main__':
    app.run()
```

代码分析: 

```python
# 导入Flask类
from flask import Flask

"""
import_name      Flask程序所在的包(模块)，传 __name__ 就可以
                 其可以决定 Flask 在访问静态文件时查找的路径
static_path      静态文件访问路径(不推荐使用，使用 static_url_path 代替)
static_url_path  静态文件访问路径，可以不传，默认为：/ + static_folder
static_folder    静态文件存储的文件夹，可以不传，默认为 static
template_folder  模板文件存储的文件夹，可以不传，默认为 templates
"""
app = Flask(import_name=__name__)

# 编写路由视图
# flask的路由是通过给视图添加装饰器的方式进行编写的。当然也可以分离到另一个文件中。
# flask的视图函数，flask中默认允许通过return返回html格式数据给客户端。
@app.route('/')
def index():
    return "<h1>hello world</h1>"

# 加载项目配置
class Config(object):
    # 开启调试模式
    DEBUG = True

# flask中支持多种配置方式，通过app.config来进行加载，我们会这里常用的是配置类
app.config.from_object( Config )

# 指定服务器IP和端口
if __name__ == '__main__':
    # 运行flask
    app.run(host="0.0.0.0", port=5000)
```

## 路由的基本定义

路由和视图的名称必须全局唯一，不能出现重复，否则报错。

```python
# 指定访问路径为 demo1
@app.route('/demo1')
def demo1():
    return 'demo1'
```

###  url中可以传递路由参数, 2种方式

>   路由参数就是url路径的一部分。

任意路由参数接收

```python
# 路由传递参数[没有限定类型]
@app.route('/user/<user_id>')
def user_info(user_id):
    return 'hello %s' % user_id
```

限定路由参数接收

>   通过路由转换器限定路由参数的类型，flask系统自带转换器编写在werkzeug.routing.py文件中。底部可以看到以下字典：
>
>   ```python
>   DEFAULT_CONVERTERS = {
>       "default": UnicodeConverter,
>       "string": UnicodeConverter,
>       "any": AnyConverter,
>       "path": PathConverter,
>       "int": IntegerConverter,
>       "float": FloatConverter,
>       "uuid": UUIDConverter,
>   }
>   ```
>
>   系统自带的转换器具体使用方式在每种转换器的注释代码中有写，请留意每种转换器初始化的参数。

| 转换器名称 | 描述                                                    |
| ---------- | ------------------------------------------------------- |
| string     | 默认类型，接受不带斜杠的任何文本                        |
| int        | 接受正整数                                              |
| float      | 接受正浮点值                                            |
| path       | 接收`string`但也接受斜线                                |
| uuid       | 接受UUID（通用唯一识别码）字符串  xxxx-xxxx-xxxxx-xxxxx |

代码：

```python
# flask提供了路由转换器可以让我们对路由参数进行限定
# 路由传递参数[限定数据类型]
@app.route('/user/<int:user_id>')
def user_info(user_id):
    return 'hello %d' % user_id
```

#### 自定义路由参数转换器

也叫正则匹配路由参数.

在 web 开发中，可能会出现限制用户访问规则的场景，那么这个时候就需要用到正则匹配，根据自己的规则去限定请求参数再进行访问

具体实现步骤为：

- 导入转换器基类：在 Flask 中，所有的路由的匹配规则都是使用转换器对象进行记录
- 自定义转换器：自定义类继承于转换器基类
- 添加转换器到默认的转换器字典中
- 使用自定义转换器实现自定义匹配规则

#### 代码实现

- 导入转换器基类

```python
from werkzeug.routing import BaseConverter
```

- 自定义转换器

```python
# 自定义正则转换器
from werkzeug.routing import BaseConverter
class RegexConverter(BaseConverter):
    def __init__(self,map,*args):
        super().__init__(map)
        # 正则参数
        self.regex = args[0]
```

- 添加转换器到默认的转换器字典中，并指定转换器使用时名字为: re

```python
# 将自定义转换器添加到转换器字典中，并指定转换器使用时名字为: re
app.url_map.converters['re'] = RegexConverter
```

- 使用转换器去实现自定义匹配规则
  - 当前此处定义的规则是：手机号码

```python
# 正则匹配路由
@app.route("/login/<re('1\d{10}'):mobile>")
def login(mobile):
    return mobile
```

> 运行测试：<http://127.0.0.1:5000/login/1311111111> ，如果访问的url不符合规则，会提示找不到页面

课堂代码：

```python
from flask import Flask,request
# 初始化
app = Flask(import_name=__name__)

# 编写路由视图
@app.route(rule='/')
def index():
    return "<h1>hello world!</h1>"

# 关于路由参数的限制，flask内置的类型不够具体，在开发中，我们经常接受参数，需要更加精确的限制
# 这时候，可以使用正则匹配路由参数
# 正则匹配路由参数，其实就是扩展flask内置的路由限定类型，需要完成4个步骤
# 1. 引入flask的路由转换器
from werkzeug.routing import BaseConverter
# 2. 创建自定义路由转换器
class MobileConverter(BaseConverter):
    """手机号码类型限制"""
    def __init__(self,map,*args):
        super().__init__(map)
        self.regex = "1[3-9]\d{9}"
# 3. 把自定义转换器添加到flask默认的转换器字典中，也就是和原来的int,float等放在一块
app.url_map.converters['mob'] = MobileConverter

# 4. 类似原来的路由参数限制一样，调用自定义转换器名称即可
@app.route(rule='/user/<mob:mobile>')
def user(mobile):
    return mobile

# 1. 引入flask的路由转换器
from werkzeug.routing import BaseConverter
# 2. 创建自定义路由转换器
class RegexConverter(BaseConverter):
    """根据正则进行参数限制"""
    def __init__(self,map,*args):
        super().__init__(map)
        self.regex = args[0]
# 3. 把自定义转换器添加到flask默认的转换器字典中，也就是和原来的int,float等放在一块
app.url_map.converters['re'] = RegexConverter

# 4. 类似原来的路由参数限制一样，调用自定义转换器名称即可
@app.route(rule='/user/<re("\w+@\w+\.\w+"):email>')
def user2(email):
    print(app.url_map) # 获取所有的路由列表
    return email

# 声明和加载配置
class Config():
    DEBUG = True
app.config.from_object(Config)

if __name__ == '__main__':
    # 运行flask
    app.run(host="0.0.0.0")
```

### 路由限定请求方式

```python
from flask import Flask,request
# 限制客户端的http请求方法，注意这里与django不一样，flask并没有默认没有内置csrf攻击防范
@app.route(rule="/user", methods=["post","put","get","delete","patch"])
def user():
    
    # 例如:地址栏中通过  http://127.0.0.1:5000/user?user=1 返回本视图
    
    print(request.method) # 获取本次客户端的http请求方法         GET
    print(request.query_string)  # 获取本次客户端的查询字符串    b'user=1'
    print(request.path)  # 获取本次客户端请求的路由路径部分[去掉域名端口]    /user
    print(request.url) # 获取本次客户端请求的http url地址        http://127.0.0.1:5000/user?user=1
    # 直接从请求中取到请求方式并返回
    return request.method
```

## http的请求与响应

### 请求

文档: http://docs.jinkan.org/docs/flask/api.html#flask.request

- **request**：flask中代表当前请求的 `request 对象`
- **作用**：在视图函数中取出本次请求数据
- **导入**：``from flask import request``
- **代码位置**：from flask.app import Request

常用的属性如下：

| 属性    | 说明                                                         | 类型           |
| ------- | ------------------------------------------------------------ | -------------- |
| data    | 记录请求体的数据，并转换为字符串<br>只要是通过其他属性无法识别转换的请求体数据<br>最终都是保留到data属性中 | bytes类型      |
| form    | 记录请求中的html表单数据                                     | MultiDict      |
| args    | 记录请求中的查询字符串,也可以是query_string                  | MultiDict      |
| cookies | 记录请求中的cookie信息                                       | Dict           |
| headers | 记录请求中的请求头                                           | EnvironHeaders |
| method  | 记录请求使用的HTTP方法                                       | GET/POST       |
| url     | 记录请求的URL地址                                            | string         |
| files   | 记录请求上传的文件列表                                       | *              |
| json    | 记录ajax请求的json数据                                       | json           |

#### 获取请求中各项数据

```python
from flask import Flask,request

# 初始化
app = Flask(import_name=__name__)
# 编写路由视图
@app.route(rule='/')
def index():
    return "<h1>hello world!</h1>"

"""== 获取查询字符串 =="""
@app.route(rule="/args",methods=["post","get"])
def args():
    print(request.args) # 获取查询字符串
    """
    请求地址：
        http://127.0.0.1:5000/args?name=xiaoming&password=123&lve=swimming&lve=shopping
    打印效果：
        ImmutableMultiDict([('name', 'xiaoming'), ('password', '123')])
        ImmutableMultiDict是一个由flask封装的字典类，在字典的基础上，提供了一些其他的方法而已。
        格式：
            ImmutableMultiDict([('键', '值'), ('键', '值')])
        字典本身不支持同名键的，ImmutableMultiDict类解决了键同名问题
        操作ImmutableMultiDict，完全可以操作字典操作，同时还提供了get，getlist方法，获取指定键的1个值或多个值    
    """
    print(request.args["name"]) # xiaoming
    print(request.args.get("name")) # xiaoming
    print(request.args.getlist("lve")) # ['swimming', 'shopping']

    # 把ImmutableMultiDict转换成普通字典
    print(request.args.to_dict(flat=False)) # {'name': ['xiaoming'], 'password': ['123'], 'lve': ['swimming', 'shopping']}
    print(request.args.to_dict(flat=True)) # {'name': 'xiaoming', 'password': '123', 'lve': 'swimming'}

    return "ok"

"""== 获取请求体数据 =="""
@app.route(rule="/data",methods=["post","put","patch"])
def data():
    """接受客户端发送过来的请求体数据，是request.json,request.form,request.files等无法接受的数据，全部会保留到这里"""
    print(request.data) #

    # 接受表单提交的数据
    print(request.form) # ImmutableMultiDict([('username', 'root'), ('password', '123456')])

    # 接受ajax或其他客户端提交过来的json数据
    print(request.json) # {'username': 'root', 'password': '123456'}

    # 接受上传文件
    avatar = request.files["avatar"] # ImmutableMultiDict([('avatar', <FileStorage: '123.jpg' ('image/jpeg')>)])
    print(avatar) # <FileStorage: '123.jpg' ('image/jpeg')>

    # 获取请求头信息
    print( request.headers ) # 获取全部的而请求头信息
    print( request.headers.get("Host") )
    # 获取自定义请求头
    print( request.headers.get("company") ) # oldboy
    print( request.headers["company"] )     # oldboy
    
    # 本次请求的url地址
    print( request.url) # http://127.0.0.1:5000/data
    print( request.path ) # /data
    
    return "ok"

# 声明和加载配置
class Config():
    DEBUG = True
app.config.from_object(Config)

if __name__ == '__main__':
    # 运行flask
    app.run(host="0.0.0.0")
```

### 响应

flask默认支持2种响应方式:

数据响应: 默认响应html文本,也可以返回 JSON格式,或其他格式

页面响应: 重定向

                  url_for  视图之间的跳转

响应的时候,flask也支持自定义http响应状态码

#### 响应html文本

```python
from flask import make_response

@app.route("/")
def index():
    # [默认支持]响应html文本
    return "<img src='http://flask.pocoo.org/static/logo.png'>"
	return make_response("<h1>hello user</h1>") # 等同于上面的一段
```

#### 返回JSON数据

在 Flask 中可以直接使用 **jsonify** 生成一个 JSON 的响应

```python
from flask import Flask, request, jsonify
# jsonify 就是json里面的jsonify

@app.route("/")
def index():
    # 也可以响应json格式代码
    data = [
        {"id":1,"username":"liulaoshi","age":18},
        {"id":2,"username":"liulaoshi","age":17},
        {"id":3,"username":"liulaoshi","age":16},
        {"id":4,"username":"liulaoshi","age":15},
    ]
    return jsonify(data)
```

> flask中返回json 数据,都是flask的jsonify方法返回就可以了.

#### 重定向

重定向到百度页面

```python
from flask import redirect
# 页面跳转响应
@app.route("/user")
def user():
    # 页面跳转 redirect函数就是response对象的页面跳转的封装
    # Location: http://www.baidu.com
    return redirect("http://www.baidu.com")
```

##### 重定向到自己写的视图函数

可以直接填写自己 url 路径

也可以使用 url_for 生成指定视图函数所对应的 url

`from flask import url_for`

```python
# 内容响应
@app.route("/")
def index():
    # [默认支持]响应html文本
    # return "<img src='http://flask.pocoo.org/static/logo.png'>"

    # 也可以响应json格式代码
    data = [
        {"id":1,"username":"liulaoshi","age":18},
        {"id":2,"username":"liulaoshi","age":17},
        {"id":3,"username":"liulaoshi","age":16},
        {"id":4,"username":"liulaoshi","age":15},
    ]
    return jsonify(data)

#使用url_for可以实现视图方法之间的内部跳转
# url_for("视图方法名")
@app.route("/login")
def login():
    return redirect( url_for("index") )
```

##### 重定向到带有参数的视图函数

在 url_for 函数中传入参数

```python
# 路由传递参数
@app.route('/user/<user_id>')
def user_info(user_id):
    return 'hello %d' % user_id

# 重定向
@app.route('/demo4')
def demo4():
    # 使用 url_for 生成指定视图函数所对应的 url
    return redirect( url_for(endpoint="user",user_id=100) )
```

#### 自定义状态码和响应头

在 Flask 中，可以很方便的返回自定义状态码，以实现不符合 http 协议的状态码，例如：status code: 666

```python
@app.route('/demo4')
def demo4():
    return '状态码为 666', 400
  
"""还可以使用make_response创建Response对象，然后通过response对象返回数据"""
from flask import make_response
@app.route("/rep")
def index7():
    response = make_response("ok")
    print(response)
    response.headers["Company"] = "oldboy" # 自定义响应头
    response.status_code = 201 # 自定义响应状态码
    return response
```

## http的会话控制

所谓的会话,就是客户端浏览器和服务端网站之间一次完整的交互过程.

会话的开始是在用户通过浏览器第一次访问服务端网站开始.

会话的结束时在用户通过关闭浏览器以后，与服务端断开.

所谓的会话控制，就是在客户端浏览器和服务端网站之间，进行多次http请求响应之间，记录、跟踪和识别用户的信息而已。

因为 http 是一种无状态协议，浏览器请求服务器是无状态的。

**无状态**：指一次用户请求时，浏览器、服务器无法知道之前这个用户做过什么，每次请求都是一次新的请求。

**无状态原因**：浏览器与服务器是使用 socket 套接字进行通信的，服务器将请求结果返回给浏览器之后，会关闭当前的 socket 连接，而且服务器也会在处理页面完毕之后销毁页面对象。

有时需要保持下来用户浏览的状态，比如用户是否登录过，浏览过哪些商品等

实现状态保持主要有两种类型：

- 在客户端存储信息使用`url`,`Cookie`，`token令牌[jwt.csrf,oauth]`
- 在服务器端存储信息使用`Session`

### Cookie

Cookie是由服务器端生成，发送给客户端浏览器，浏览器会将Cookie的key/value保存，下次请求同一网站时就发送该Cookie给服务器（前提是浏览器设置为启用cookie）。Cookie的key/value可以由服务器端自己定义。

使用场景: 登录状态, 浏览历史, 网站足迹,购物车 [不登录也可以使用购物车]

Cookie是存储在浏览器中的一段纯文本信息，建议不要存储敏感信息如密码，因为电脑上的浏览器可能被其它人使用

Cookie基于域名安全，不同域名的Cookie是不能互相访问的

如访问luffy.com时向浏览器中写了Cookie信息，使用同一浏览器访问baidu.com时，无法访问到luffy.com写的Cookie信息

浏览器的同源策略针对cookie也有限制作用.

当浏览器请求某网站时，会将本网站下所有Cookie信息提交给服务器，所以在request中可以读取Cookie信息

#### 设置cookie

设置cookie需要通过flask的Response响应对象来进行设置,由响应对象会提供了方法set_cookie给我们可以快速设置cookie信息。

```python
@app.route("/set_cookie")
def set_cookie():
    """设置cookie"""
    response = make_response("ok")
    # response.set_cookie(key="变量名",value="变量值",max_age="有效时间/秒")
    response.set_cookie("username","xiaoming",100)
    """如果cookie没有设置过期时间，则默认过期为会话结束过期"""
    """cookie在客户端中保存时，用一个站点下同变量名的cookie会覆盖"""
    response.set_cookie("age","100")

    return response

```

#### 获取cookie

```python
@app.route("/get_cookie")
def get_cookie():
    """获取cookie"""
    print(request.cookies)
    print(request.cookies.get("username"))
    print(request.cookies.get("age"))
    """打印效果：
    {'username': 'xiaoming'}
    """
    return ""
```

#### 删除cookie

```python
@app.route("/del_cookie")
def del_cookie():
    """删除cookie"""
    response = make_response("ok")
    #把对应名称的cookie设置为过期时间，则可以达到删除cookie
    response.set_cookie("username","",0)
    return response
```

### Session

session相关配置项文档:`https://dormousehole.readthedocs.io/en/latest/config.html?highlight=session_cookie_path`

对于敏感、重要的信息，建议要存储在服务器端，不能存储在浏览器中，如用户名、余额、等级、验证码等信息

在服务器端进行状态保持的方案就是`Session`

**Session依赖于Cookie**,session的ID一般默认通过cookie来保存到客户端。

flask中的session需要加密,所以使用session之前必须配置SECRET_KEY选项,否则报错.

session的有效期默认是会话期，会话结束了，session就废弃了。

```text
如果将来希望session的生命周期延长，可以通过修改cookie中的sessionID来完成配置。
```

#### 设置session

```python
from flask import Flask, make_response, request,session

app = Flask(__name__)

class Config():
    SECRET_KEY = "123456asdadad"
    DEBUG = True

app.config.from_object(Config)

# 查看当前flask默认支持的所有配置项
# print(app.config)
"""
<Config {
 'DEBUG': False,
 'TESTING': False,
 'PROPAGATE_EXCEPTIONS': None,
 'PRESERVE_CONTEXT_ON_EXCEPTION': None,
 'SECRET_KEY': None,
 'PERMANENT_SESSION_LIFETIME': datetime.timedelta(31),
 'USE_X_SENDFILE': False,
 'LOGGER_NAME': '__main__',
 'LOGGER_HANDLER_POLICY': 'always',
 'SERVER_NAME': None,
 'APPLICATION_ROOT': None,
 'SESSION_COOKIE_NAME': 'session',
 'SESSION_COOKIE_DOMAIN': None,
 'SESSION_COOKIE_PATH': None,
 'SESSION_COOKIE_HTTPONLY': True,
 'SESSION_COOKIE_SECURE': False,
 'SESSION_REFRESH_EACH_REQUEST': True,
 'MAX_CONTENT_LENGTH': None,
 'SEND_FILE_MAX_AGE_DEFAULT': datetime.timedelta(0, 43200),
 'TRAP_BAD_REQUEST_ERRORS': False,
 'TRAP_HTTP_EXCEPTIONS': False,
 'EXPLAIN_TEMPLATE_LOADING': False,
 'PREFERRED_URL_SCHEME': 'http',
 'JSON_AS_ASCII': True,
 'JSON_SORT_KEYS': True,
 'JSONIFY_PRETTYPRINT_REGULAR': True,
 'JSONIFY_MIMETYPE': 'application/json',
 'TEMPLATES_AUTO_RELOAD': None
"""
@app.route("/set_session")
def set_session():
    """设置session"""
    """与cookie不同，session支持python基本数据类型作为值"""
    session["username"] = "xiaohuihui"
    session["info"] = {
        "age":11,
        "sex":True,
    }

    return "ok"

if __name__ == '__main__':
    app.run(debug=True)
```

#### 获取session

```python
@app.route("/get_session")
def get_session():
    """获取session"""
    print( session.get("username") )
    print( session.get("info") )
    return "ok"

```

#### 删除session

```python
@app.route("/del_session")
def del_session():
    """删除session"""
    try:
        del session["username"]
        # session.clear() # 删除所有
    except:
        pass
    return "ok"
```

