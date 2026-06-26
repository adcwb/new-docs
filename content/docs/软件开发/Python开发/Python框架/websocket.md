---
title: "websocket"
weight: 5
date: 2026-06-23
---

## websocket协议

文档：https://tools.ietf.org/html/rfc6455

一直以来，HTTP是无状态、单向通信的网络协议，即客户端请求一次，服务器回复一次，默认情况下，只允许浏览器向服务器发出请求后，服务器才能返回相应的数据。如果想让服务器消息及时下发到客户端，需要采用类似于轮询的机制，大部分情况就是客户端通过定时器使用ajax频繁地向服务器发出请求。这样的做法效率很低，而且HTTP数据包头本身的字节量较大，浪费了大量带宽和服务器资源。

为了提高效率，HTML5推出了WebSocket技术。

WebScoket是一种让客户端和服务器之间能进行全双工通信(full-duplex)的技术。它是HTML最新标准HTML5的一个协议规范，本质上是个基于TCP的协议，它通过HTTP/HTTPS协议发送一条特殊的请求进行握手后创建了一个TCP连接，此后浏览器/客户端和服务器之间便可随时随地以通过此连接来进行双向实时通信，且交换的数据包头信息量很小。

同时为了方便使用，HTML5提供了非常简单的操作就可以让前端开发者直接实现socket通讯，开发者只需要在支持WebSocket的浏览器中，创建Socket之后，通过onopen、onmessage、onclose、onerror四个事件的实现即可处理Socket的响应。

注意：websocket是HTML5技术的一部分，但是websocket并非只能在浏览器或者HTML文档中才能使用，事实上在python或者C++等语言中只要能实现websocket协议报文，均可使用。

导读：https://blog.csdn.net/zhusongziye/article/details/80316127

客户端报文：

```json
GET /mofang/websocket HTTP/1.1
Host: 127.0.0.1
Origin: http://127.0.0.1:5000
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Key: sN9cRrP/n9NdMgdcy2VJFQ==      # Sec-WebSocket-Key 是随机生成的
Sec-WebSocket-Version: 13
```

服务端报文：

```json
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Accept: HSmrc0sMlYUkAGmm5OPpG2HaGWk= # 结合客户端提供的Sec-WebSocket-Key基于固定算法计算出来的
Sec-WebSocket-Protocol: chat
```



### WebSocket与Socket的关系

>   他们两的关系就像Java和JavaScript，并非完全没有关系，只能说有点渊源。
>
>   Socket严格来说，其实并不是一个协议，而是为了方便开发者使用TCP或UDP协议而对TCP/IP协议进行封装出来的一组接口，是位于应用层和传输控制层之间的接口。通过Socket接口，我们可以更简单，更方便的使用TCP/IP协议。
>
>   WebSocket是实现了浏览器与服务器的全双工通信协议，一个模拟Socket的应用层协议。



## 服务端基于socket提供服务

在python中实现socket服务端的方式有非常多，一种最常用的有`python-socketio`，而我们现在使用的flask框架也有一个基于`python-socket`模块进行了封装的`flask-socketio`模块.

官方文档：https://flask-socketio.readthedocs.io/en/latest/

> 注意:
>
> 因为目前还有会存在一小部分的设备或者应用是不支持websocket的.所以为了保证功能的可用性,我们使用socektio,但是由此带来了2个问题,必须要注意的:
>
> 1.  python服务端使用基于socketio进行通信服务,则另一端必须也是基于socetio来进行对接通信,否则无法进行通信
>
> 2. socketio还有一个版本对应的问题, 版本不对应则无法通信.回报版本错误.
>
>    如果使用了javascript io 1.x或者2.x版本,则python-socketio或者flask-socketio的版本必须是4.x
>
>    如果使用了javascriptio 3.x版本,则python-socketio或者flask-socketio的版本必须是5.x.
>
>    




我们当前使用的flask-socketio版本是5.x,所以javasctipt的socketio版本就必须是3.x.

终端下执行命令，安装：

```bash
pip install flask-socketio
pip install gevent-websocket
```

模块初始化，`application/__init__.py`，代码：

```python
import os,sys

from flask import Flask
from flask_script import Manager
from flask_sqlalchemy import SQLAlchemy
from flask_redis import FlaskRedis
from flask_session import Session
from flask_migrate import Migrate,MigrateCommand
from flask_jsonrpc import JSONRPC
from flask_marshmallow import Marshmallow
from flask_jwt_extended import JWTManager
from flask_admin import Admin
from flask_babelex import Babel
from faker import Faker
from flask_pymongo import PyMongo
from flask_qrcode import QRcode
from flask_socketio import SocketIO

from application.utils import init_blueprint
from application.utils.config import load_config
from application.utils.session import init_session
from application.utils.logger import Log
from application.utils.commands import load_command

# 创建终端脚本管理对象
manager = Manager()

# 创建数据库链接对象
db = SQLAlchemy()

# redis链接对象
redis = FlaskRedis()

# Session存储对象
session_store = Session()

# 数据迁移实例对象
migrate = Migrate()

# 日志对象
log = Log()

# jsonrpc模块实例对象
jsonrpc = JSONRPC()

# 数据转换器的对象创建
ma = Marshmallow()

# jwt认证模块实例化
jwt = JWTManager()

# flask-admin模块实例化
admin = Admin()

# flask-babelex模块实例化
babel = Babel()

# mongoDB
mongo = PyMongo()


# qrcode
QRCode = QRcode()

# socketio
socketio = SocketIO()

def init_app(config_path):
    """全局初始化"""
    # 创建app应用对象
    app = Flask(__name__)
    # 项目根目录
    app.BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    # 加载导包路径
    sys.path.insert(0, os.path.join(app.BASE_DIR,"application/utils/language"))

    # 加载配置
    Config = load_config(config_path)
    app.config.from_object(Config)

    # 数据库初始化
    db.init_app(app)
    app.db = db
    redis.init_app(app)
    mongo.init_app(app)

    # 数据转换器的初始化
    ma.init_app(app)

    # session存储初始化
    init_session(app)
    session_store.init_app(app)

    # 数据迁移初始化
    migrate.init_app(app,db)
    # 添加数据迁移的命令到终端脚本工具中
    manager.add_command('db', MigrateCommand)

    # 日志初始化
    app.log = log.init_app(app)

    # 蓝图注册
    init_blueprint(app)

    # jsonrpc初始化
    jsonrpc.service_url = "/api" # api接口的url地址前缀
    jsonrpc.init_app(app)

    # jwt初始化
    jwt.init_app(app)

    # admin初始化
    admin.init_app(app)

    # 国际化本地化模块的初始化
    babel.init_app(app)

    # 初始化终端脚本工具
    manager.app = app

    # 数据种子生成器[faker]
    app.faker = Faker(app.config.get("LANGUAGE"))

    # qrcode初始化配置
    QRCode.init_app(app)

    # socketio
    socketio.init_app(app, cors_allowed_origins=app.config["CORS_ALLOWED_ORIGINS"],async_mode=app.config["ASYNC_MODE"], debug=app.config["DEBUG"])
    # 改写runserver命令
    if sys.argv[1] == "runserver":
        manager.add_command("run", socketio.run(app,host=app.config["HOST"],port=app.config["PORT"]))

    # 注册自定义命令
    load_command(manager)

    return manager
```

配置文件,`application/settings/dev.py`,代码:

```python
    # socketio
    CORS_ALLOWED_ORIGINS="*"
    ASYNC_MODE=None
    HOST="0.0.0.0"
    PORT=5000
```



`application/utils/__init__.py`，在加载蓝图的过程中，自动加载socket服务端的api，代码：

```python
def init_blueprint(app):
    """自动注册蓝图"""
    blueprint_path_list = app.config.get("INSTALLED_APPS")
    # 加载admin站点总配置文件
    try:
        import_module(app.config.get("ADMIN_PATH"))
    except:
        pass
    
    for blueprint_path in blueprint_path_list:
        blueprint_name = blueprint_path.split(".")[-1]
        # 自动创建蓝图对象
        blueprint = Blueprint(blueprint_name,blueprint_path)
        # 蓝图自动注册和绑定视图和子路由
        url_module = import_module(blueprint_path+".urls") # 加载蓝图下的子路由文件
        for url in url_module.urlpatterns: # 遍历子路由中的所有路由关系
            blueprint.add_url_rule(**url)  # 注册到蓝图下

        # 读取总路由文件
        url_path = app.config.get("URL_PATH")
        urlpatterns = import_module(url_path).urlpatterns  # 加载蓝图下的子路由文件
        url_prefix = "" # 蓝图路由前缀
        for urlpattern in urlpatterns:
            if urlpattern["blueprint_path"] == blueprint_name+".urls":
                url_prefix = urlpattern["url_prefix"]
                break

        # 注册模型
        import_module(blueprint_path+".models")

        # 加载蓝图内部的admin站点配置
        try:
            import_module(blueprint_path+".admin")
        except:
            pass

        # 加载蓝图内部的socket接口
        try:
            import_module(blueprint_path+".socket")
        except:
            pass

        # 注册蓝图对象到app应用对象中,  url_prefix 蓝图的路由前缀
        app.register_blueprint(blueprint,url_prefix=url_prefix)
```



因为我们是基于`python-socketio`模块提供的服务端，所以客户端必须基于`socketIO.js`才能与其进行通信，所以客户端引入socketio.js。

socket.io.js的官方文档: https://socket.io/docs/v3

socket.io.js的github: https://github.com/socketio/socket.io/releases

我们可以新建一个orchard.html作为将来种植园模块的主页面，并在这个页面中使用socketio和服务端的flask-socketIO进行通信。

代码：

```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title></title>
    <script type="text/javascript" src="../static/js/socket.io.js"></script>
</head>
<body>

<script>
    // 命名空间
    namespace = '/mofang';
    var socket = io.connect('ws://192.168.20.251:5000' + namespace, {transports: ['websocket']});
    // socket.on('connect', function() {
    //     console.log("客户端连接socket服务端");
    // });
</script>
</body>
</html>
```

服务端创建并注册蓝图目录orchard，终端命令如下：

```bash
cd application/apps/
python ../../manage.py blue -n=orchard
```

`application/urls.py`，代码：

```python
from application.utils import include
urlpatterns = [
    include("","home.urls"),
    include("/users","users.urls"),
    include("/marsh","marsh.urls"),
    include("/orchard","orchard.urls"),
]
```

`applicaion/settings/dev.py`，代码:

```python
    # 注册蓝图
    INSTALLED_APPS = [
        "application.apps.home",
        "application.apps.users",
        "application.apps.marsh",
        "application.apps.orchard",
    ]
```

### 创建socket连接

在蓝图下面创建socket.py文件，并提供连接接口, `orchard/socket.py`：

```python
from application import socketio
from flask import request
@socketio.on("connect", namespace="/mofang")
def user_connect():
    # request.sid socketIO基于客户端生成的唯一会话ID
    print("用户%s连接过来了!" % request.sid)

@socketio.on("disconnect", namespace="/mofang")
def user_disconnect():
    print("用户%s退出了种植园" % request.sid )
```

### 客户端vue结合socketio

客户端代码：

```html
<!DOCTYPE html>
<html>
<head>
	<title>用户中心</title>
	<meta name="viewport" content="width=device-width,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no">
	<meta charset="utf-8">
	<link rel="stylesheet" href="../static/css/main.css">
	<script src="../static/js/vue.js"></script>
	<script src="../static/js/axios.js"></script>
	<script src="../static/js/main.js"></script>
	<script src="../static/js/uuid.js"></script>
	<script src="../static/js/settings.js"></script>
	<script src="../static/js/socket.io.js"></script>
</head>
<body>
	<div class="app orchard" id="app">
    <img class="music" :class="music_play?'music2':''" @click="music_play=!music_play" src="../static/images/player.png">
    <div class="orchard-bg">
			<img src="../static/images/bg2.png">
			<img class="board_bg2" src="../static/images/board_bg2.png">
		</div>
    <img class="back" @click="go_index" src="../static/images/user_back.png" alt="">

	</div>
	<script>
	apiready = function(){
		init();
		new Vue({
			el:"#app",
			data(){
				return {
          music_play:true,
          namespace: '/mofang_orchard',
          token:"",
          socket: null,
          timeout: 0,
					prev:{name:"",url:"",params:{}},
					current:{name:"orchard",url:"orchard.html",params:{}},
				}
			},
      created(){
        this.checkout();

      },
			methods:{
        checkout(){
          var token = this.game.get("access_token") || this.game.fget("access_token");
          this.game.checkout(this,token,(new_access_token)=>{
            this.connect();
          });
        },
        connect(){
          // socket连接
          this.socket = io.connect(this.settings.socket_server + this.namespace, {transports: ['websocket']});
          this.socket.on('connect', ()=>{
              this.game.print("开始连接服务端");
          });
        },
        go_index(){
          this.game.outWin("orchard");
        },
			}
		});
	}
	</script>
</body>
</html>
```

css样式，`main.css`，代码：

```css
.app .orchard-bg{
	margin: 0 auto;
	width: 100%;
	max-width: 100rem;
	position: absolute;;
	z-index: -1;
  top: -6rem;
}
.app .orchard-bg .board_bg2{
  position: absolute;
  top: 1rem;
}
.orchard .back{
	position: absolute;
	width: 3.83rem;
	height: 3.89rem;
  z-index: 1;
  top: 2rem;
  left: 2rem;
}
.orchard .music{
  right: 2rem;
}
.orchard .header{
  position: absolute;
  top: 0rem;
  left: 0;
  right: 0;
  margin: auto;
  width: 32rem;
  height: 19.28rem;
}

.orchard .info{
  position: absolute;
  z-index: 1;
  top: 0rem;
  left: 4.4rem;
  width: 8rem;
  height: 9.17rem;
}
.orchard .info .avata{
  width: 8rem;
  height: 8rem;
  position: relative;
}
.orchard .info .avatar_bf{
  position: absolute;
  z-index: 1;
  margin: auto;
  width: 6rem;
  height: 6rem;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
}
.orchard .info .user_avatar{
  position: absolute;
  z-index: 1;
  width: 6rem;
  height: 6rem;
  margin: auto;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  border-radius: 1rem;
}
.orchard .info .avatar_border{
  position: absolute;
  z-index: 1;
  margin: auto;
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  width: 7.2rem;
  height: 7.2rem;
}
.orchard .info .user_name{
  position: absolute;
  left: 8rem;
  top: 1rem;
  width: 11rem;
  height: 3rem;
  line-height: 3rem;
  font-size: 1.5rem;
  text-shadow: 1px 1px 1px #aaa;
  border-radius: 3rem;
  background: #ff9900;
  text-align: center;
}

.orchard .wallet{
  position: absolute;
  top: 3.4rem;
  right: 4rem;
  width: 16rem;
  height: 10rem;
}
.orchard .wallet .balance{
  margin-top: 1.4rem;
  float: left;
  margin-right: 1rem;
}
.orchard .wallet .title{
  color: #fff;
  font-size: 1.2rem;
  width: 6.4rem;
  text-align: center;
}
.orchard .wallet .title img{
  width: 1.4rem;
  margin-right: 0.2rem;
  vertical-align: sub;
  height: 1.4rem;
}
.orchard .wallet .num{
  background: url("../images/btn3.png") no-repeat 0 0;
  background-size: 100%;
  width: 6.4rem;
  font-size: 0.8rem;
  color: #fff;
  height: 2rem;
  line-height: 1.8rem;
  text-indent: 1rem;
}
.orchard .header .menu-list{
  position: absolute;
  top: 9rem;
  left: 2rem;
}
.orchard .header .menu-list .menu{
  color: #fff;
  font-size: 1rem;
  float: left;
  width: 4rem;
  height: 4rem;
  text-align: center;
  margin-right: 2rem;
}
.orchard .header .menu-list .menu img{
  width: 3.33rem;
  height: 3.61rem;
  display: block;
  margin: auto;
  margin-bottom: 0.4rem;
}
.orchard .footer{
  position: absolute;
  width: 100%;
  height: 6rem;
  bottom: -2rem;
  background: url("../images/board_bg3.png") no-repeat -1rem 0;
  background-size: 110%;
}
.orchard .footer .menu-list{
  width: 100%;
  height: 4rem;
  display: flex;
  position: absolute;
  top: -1rem;
}
.orchard .footer .menu-list .menu,
.orchard .footer .menu-list .menu-center{
  float: left;
  width: 4.44rem;
  height: 5.2rem;
  font-size: 1.5rem;
  color: #fff;
  line-height: 4.44rem;
  text-align: center;
  background: url("../images/btn5.png") no-repeat 0 0;
  background-size: 100%;
  flex: 1;
  margin-left: 4px;
  margin-right: 4px;
}
.orchard .footer .menu-list .menu-center{
  background: url("../images/btn6.png") no-repeat 0 0;
  background-size: 100%;
  flex: 2;
}
```



### 基于事件接受信息

#### 基于未定义事件进行通信

客户端代码:

```html
<!DOCTYPE html>
<html>
<head>
	<title>用户中心</title>
	<meta name="viewport" content="width=device-width,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no">
	<meta charset="utf-8">
	<link rel="stylesheet" href="../static/css/main.css">
	<script src="../static/js/vue.js"></script>
	<script src="../static/js/axios.js"></script>
	<script src="../static/js/main.js"></script>
	<script src="../static/js/uuid.js"></script>
	<script src="../static/js/settings.js"></script>
	<script src="../static/js/socket.io.js"></script>
</head>
<body>
	<div class="app orchard" id="app">
    <img class="music" :class="music_play?'music2':''" @click="music_play=!music_play" src="../static/images/player.png">
    <div class="orchard-bg">
			<img src="../static/images/bg2.png">
			<img class="board_bg2" src="../static/images/board_bg2.png">
		</div>
    <img class="back" @click="go_index" src="../static/images/user_back.png" alt="">
	</div>
	<script>
	apiready = function(){
		init();
		new Vue({
			el:"#app",
			data(){
				return {
          music_play:true,
          token:"",
          socket: null,
          timeout: 0,
					prev:{name:"",url:"",params:{}},
					current:{name:"orchard",url:"orchard.html",params:{}},
				}
			},
      created(){
        this.checkout();
      },
			methods:{
        checkout(){
          var token = this.game.get("access_token") || this.game.fget("access_token");
          this.game.checkout(this,token,(new_access_token)=>{
            this.connect();
          });
        },
        connect(){
          // socket连接
          this.socket = io.connect(this.settings.socket_server + this.settings.socket_namespace, {transports: ['websocket']});
          this.socket.on('connect', ()=>{
              this.game.print("开始连接服务端");
              this.login();
          });
        },
        login(){
          var id = this.game.fget("id");
          // 通过send方法可以直接发送数据,不需要自定义事件,数据格式是json格式
          this.socket.send({"uid":id}); 
        },
        go_index(){
          this.game.outWin("orchard");
        },
			}
		});
	}
	</script>
</body>
</html>

```

服务端代码:

```python
from application import socketio
from flask import request

# 建立socket通信
@socketio.on("connect", namespace="/mofang")
def user_connect():
    # request.sid socketIO基于客户端生成的唯一会话ID
    print("用户%s连接过来了!" % request.sid)

# 断开socket通信
@socketio.on("disconnect", namespace="/mofang")
def user_disconnect():
    print("用户%s退出了种植园" % request.sid )

# 未定义事件通信，客户端没有指定事件名称
@socketio.on("message",namespace="/mofang")
def user_message(data):
    print("接收到来自%s发送的数据:" % request.sid)
    print(data)
    print(data["uid"])
```

#### 基于自定义事件进行通信

客户端代码:

```html
<!DOCTYPE html>
<html>
<head>
	<title>用户中心</title>
	<meta name="viewport" content="width=device-width,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no">
	<meta charset="utf-8">
	<link rel="stylesheet" href="../static/css/main.css">
	<script src="../static/js/vue.js"></script>
	<script src="../static/js/axios.js"></script>
	<script src="../static/js/main.js"></script>
	<script src="../static/js/uuid.js"></script>
	<script src="../static/js/settings.js"></script>
	<script src="../static/js/socket.io.js"></script>
</head>
<body>
	<div class="app orchard" id="app">
    <img class="music" :class="music_play?'music2':''" @click="music_play=!music_play" src="../static/images/player.png">
    <div class="orchard-bg">
			<img src="../static/images/bg2.png">
			<img class="board_bg2" src="../static/images/board_bg2.png">
		</div>
    <img class="back" @click="go_index" src="../static/images/user_back.png" alt="">
	</div>
	<script>
	apiready = function(){
		init();
		new Vue({
			el:"#app",
			data(){
				return {
          music_play:true,
          token:"",
          socket: null,
          timeout: 0,
					prev:{name:"",url:"",params:{}},
					current:{name:"orchard",url:"orchard.html",params:{}},
				}
			},
      created(){
        this.checkout();
      },
			methods:{
        checkout(){
          var token = this.game.get("access_token") || this.game.fget("access_token");
          this.game.checkout(this,token,(new_access_token)=>{
            this.connect();
          });
        },
        connect(){
          // socket连接
          this.socket = io.connect(this.settings.socket_server + this.settings.socket_namespace, {transports: ['websocket']});
          this.socket.on('connect', ()=>{
              this.game.print("开始连接服务端");
              this.login();
          });
        },
        login(){
          var id = this.game.fget("id");
          this.socket.emit("login",{"uid":id});
        },
        go_index(){
          this.game.outWin("orchard");
        },
			}
		});
	}
	</script>
</body>
</html>
```

服务端代码:

```python
from application import socketio
from flask import request

# 建立socket通信
@socketio.on("connect", namespace="/mofang")
def user_connect():
    # request.sid socketIO基于客户端生成的唯一会话ID
    print("用户%s连接过来了!" % request.sid)

# 断开socket通信
@socketio.on("disconnect", namespace="/mofang")
def user_disconnect():
    print("用户%s退出了种植园" % request.sid )

# 未定义事件通信，客户端没有指定事件名称
@socketio.on("message",namespace="/mofang")
def user_message(data):
    print("接收到来自%s发送的数据:" % request.sid)
    print(data)
    print(data["uid"])

# 自定义事件通信
@socketio.on("login", namespace="/mofang")
def user_login(data):
    print("接受来自客户端%s发送的数据:" % request.sid)
    print(data)
    print(data["uid"])
```



### 服务端响应信息

```python
from application import socketio
from flask import request
from application.apps.users.models import User
# 建立socket通信
@socketio.on("connect", namespace="/mofang")
def user_connect():
    # request.sid socketIO基于客户端生成的唯一会话ID
    print("用户%s连接过来了!" % request.sid)

    # 主动响应数据给客户端
    length = User.query.count()
    socketio.emit("server_response",{"count":length},namespace="/mofang")

# 断开socket通信
@socketio.on("disconnect", namespace="/mofang")
def user_disconnect():
    print("用户%s退出了种植园" % request.sid )

# 未定义事件通信，客户端没有指定事件名称
@socketio.on("message",namespace="/mofang")
def user_message(data):
    print("接收到来自%s发送的数据:" % request.sid)
    print(data)
    print(data["uid"])

# 自定义事件通信
@socketio.on("login", namespace="/mofang")
def user_login(data):
    print("接受来自客户端%s发送的数据:" % request.sid)
    print(data)
```

客户端接收响应信息,代码:

```html
<!DOCTYPE html>
<html>
<head>
	<title>用户中心</title>
	<meta name="viewport" content="width=device-width,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no">
	<meta charset="utf-8">
	<link rel="stylesheet" href="../static/css/main.css">
	<script src="../static/js/vue.js"></script>
	<script src="../static/js/axios.js"></script>
	<script src="../static/js/main.js"></script>
	<script src="../static/js/uuid.js"></script>
	<script src="../static/js/settings.js"></script>
	<script src="../static/js/socket.io.js"></script>
</head>
<body>
	<div class="app orchard" id="app">
    <img class="music" :class="music_play?'music2':''" @click="music_play=!music_play" src="../static/images/player.png">
    <div class="orchard-bg">
			<img src="../static/images/bg2.png">
			<img class="board_bg2" src="../static/images/board_bg2.png">
		</div>
    <img class="back" @click="go_index" src="../static/images/user_back.png" alt="">
	</div>
	<script>
	apiready = function(){
		init();
		new Vue({
			el:"#app",
			data(){
				return {
          music_play:true,
          token:"",
          socket: null,
          timeout: 0,
					prev:{name:"",url:"",params:{}},
					current:{name:"orchard",url:"orchard.html",params:{}},
				}
			},
      created(){
        this.checkout();
      },
			methods:{
        checkout(){
          var token = this.game.get("access_token") || this.game.fget("access_token");
          this.game.checkout(this,token,(new_access_token)=>{
            this.connect();
          });
        },
        connect(){
          // socket连接
          this.socket = io.connect(this.settings.socket_server + this.settings.socket_namespace, {transports: ['websocket']});
          this.socket.on('connect', ()=>{
              this.game.print("开始连接服务端");
              this.login();
              this.get_count();
          });
        },
        get_count(){
          this.socket.on("server_response",(res)=>{
            this.game.print(res.count);
            alert(`欢迎来到种植园,当前有${res.count}人在忙碌着~`)
          });
        },
        login(){
          var id = this.game.fget("id");
          this.socket.emit("login",{"uid":id});
        },
        go_index(){
          this.game.outWin("orchard");
        },
			}
		});
	}
	</script>
</body>
</html>

```



### 基于房间管理分发信息

```python
from application import socketio
from flask import request
from application.apps.users.models import User
from flask_socketio import join_room, leave_room
# 建立socket通信
@socketio.on("connect", namespace="/mofang")
def user_connect():
    # request.sid socketIO基于客户端生成的唯一会话ID
    print("用户%s连接过来了!" % request.sid)
    # 主动响应数据给客户端
    length = User.query.count()
    socketio.emit("server_response",{"count":length,"sid":"%s"% request.sid},namespace="/mofang")

# 断开socket通信
@socketio.on("disconnect", namespace="/mofang")
def user_disconnect():
    print("用户%s退出了种植园" % request.sid )

# 未定义事件通信，客户端没有指定事件名称
@socketio.on("message",namespace="/mofang")
def user_message(data):
    print("接收到来自%s发送的数据:" % request.sid)
    print(data)
    print(data["uid"])

# 自定义事件通信
@socketio.on("login", namespace="/mofang")
def user_login(data):
    print("接受来自客户端%s发送的数据:" % request.sid)
    print(data)
    # 一般基于用户id分配不同的房间
    room = data["uid"]
    join_room(room)
    socketio.emit("login_response", {"data": "登录成功"}, namespace="/mofang", room=room)

```

客户端代码:

```html
<!DOCTYPE html>
<html>
<head>
	<title>用户中心</title>
	<meta name="viewport" content="width=device-width,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no">
	<meta charset="utf-8">
	<link rel="stylesheet" href="../static/css/main.css">
	<script src="../static/js/vue.js"></script>
	<script src="../static/js/axios.js"></script>
	<script src="../static/js/main.js"></script>
	<script src="../static/js/uuid.js"></script>
	<script src="../static/js/settings.js"></script>
	<script src="../static/js/socket.io.js"></script>
</head>
<body>
	<div class="app orchard" id="app">
    <img class="music" :class="music_play?'music2':''" @click="music_play=!music_play" src="../static/images/player.png">
    <div class="orchard-bg">
			<img src="../static/images/bg2.png">
			<img class="board_bg2" src="../static/images/board_bg2.png">
		</div>
    <img class="back" @click="go_index" src="../static/images/user_back.png" alt="">
	</div>
	<script>
	apiready = function(){
		init();
		new Vue({
			el:"#app",
			data(){
				return {
          music_play:true,
          token:"",
          socket: null,
          timeout: 0,
					prev:{name:"",url:"",params:{}},
					current:{name:"orchard",url:"orchard.html",params:{}},
				}
			},
      created(){
        this.checkout();
      },
			methods:{
        checkout(){
          var token = this.game.get("access_token") || this.game.fget("access_token");
          this.game.checkout(this,token,(new_access_token)=>{
            this.connect();
          });
        },
        connect(){
          // socket连接
          this.socket = io.connect(this.settings.socket_server + this.settings.socket_namespace, {transports: ['websocket']});
          this.socket.on('connect', ()=>{
              this.game.print("开始连接服务端");
              this.login();
              this.get_count();
              this.login_response();
          });
        },
        login_response(){
          this.socket.on("login_response",(res)=>{
            alert(res.data);
          });
        },
        get_count(){
          this.socket.on("server_response",(res)=>{
            this.game.print(res.count);
            alert(`欢迎${res.sid}来到种植园,当前有${res.count}人在忙碌着~`);
          });
        },
        login(){
          var id = this.game.fget("id");
          this.socket.emit("login",{"uid":id});
        },
        go_index(){
          this.game.outWin("orchard");
        },
			}
		});
	}
	</script>
</body>
</html>
```



### 服务端定时推送数据

```python
from application import socketio
from flask import request
from application.apps.users.models import User
from flask_socketio import join_room, leave_room
# 建立socket通信
@socketio.on("connect", namespace="/mofang")
def user_connect():
    # request.sid socketIO基于客户端生成的唯一会话ID
    print("用户%s连接过来了!" % request.sid)
    # 主动响应数据给客户端
    length = User.query.count()
    socketio.emit("server_response",{"count":length,"sid":"%s"% request.sid},namespace="/mofang")

# 断开socket通信
@socketio.on("disconnect", namespace="/mofang")
def user_disconnect():
    print("用户%s退出了种植园" % request.sid )

# 未定义事件通信，客户端没有指定事件名称
@socketio.on("message",namespace="/mofang")
def user_message(data):
    print("接收到来自%s发送的数据:" % request.sid)
    print(data)
    print(data["uid"])

# 自定义事件通信
@socketio.on("login", namespace="/mofang")
def user_login(data):
    print("接受来自客户端%s发送的数据:" % request.sid)
    print(data)
    # 一般基于用户id分配不同的房间
    room = data["uid"]
    join_room(room)
    socketio.emit("login_response", {"data": "登录成功"}, namespace="/mofang", room=room)

"""定时推送数据"""
from threading import Lock
import random
thread = None
thread_lock = Lock()

@socketio.on('chat', namespace='/mofang')
def chat(data):
    global thread
    with thread_lock:
        if thread is None:
            thread = socketio.start_background_task(target=background_thread)

def background_thread(uid):
    while True:
        socketio.sleep(1)
        t = random.randint(1, 100)
        socketio.emit('server_response',
                      {'count': t},namespace='/mofang')
```

客户端代码:

```html
<!DOCTYPE html>
<html>
<head>
	<title>用户中心</title>
	<meta name="viewport" content="width=device-width,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no">
	<meta charset="utf-8">
	<link rel="stylesheet" href="../static/css/main.css">
	<script src="../static/js/vue.js"></script>
	<script src="../static/js/axios.js"></script>
	<script src="../static/js/main.js"></script>
	<script src="../static/js/uuid.js"></script>
	<script src="../static/js/settings.js"></script>
	<script src="../static/js/socket.io.js"></script>
</head>
<body>
	<div class="app orchard" id="app">
    <img class="music" :class="music_play?'music2':''" @click="music_play=!music_play" src="../static/images/player.png">
    <div class="orchard-bg">
			<img src="../static/images/bg2.png">
			<img class="board_bg2" src="../static/images/board_bg2.png">
		</div>
    <img class="back" @click="go_index" src="../static/images/user_back.png" alt="">
    <h1 style="position:absolute;top:20rem;">{{num}}</h1>
  </div>
	<script>
	apiready = function(){
		init();
		new Vue({
			el:"#app",
			data(){
				return {
          music_play:true,
          token:"",
          num:"",
          socket: null,
          timeout: 0,
					prev:{name:"",url:"",params:{}},
					current:{name:"orchard",url:"orchard.html",params:{}},
				}
			},
      created(){
        this.checkout();
      },
			methods:{
        checkout(){
          var token = this.game.get("access_token") || this.game.fget("access_token");
          this.game.checkout(this,token,(new_access_token)=>{
            this.connect();
          });
        },
        connect(){
          // socket连接
          this.socket = io.connect(this.settings.socket_server + this.settings.socket_namespace, {transports: ['websocket']});
          this.socket.on('connect', ()=>{
              this.game.print("开始连接服务端");
              this.login();
              this.get_count();
              this.login_response();
          });
        },
        login_response(){
          this.socket.on("login_response",(res)=>{
            alert(res.data);
          });
        },
        get_count(){
          this.socket.on("server_response",(res)=>{
            this.num = res.count;
            // alert(`欢迎${res.sid}来到种植园,当前有${res.count}人在忙碌着~`);
          });
        },
        login(){
          var id = this.game.fget("id");
          // this.socket.emit("login",{"uid":id});
          this.socket.emit("chat",{"uid":id})
        },
        go_index(){
          this.game.outWin("orchard");
        },
			}
		});
	}
	</script>
</body>
</html>

```



### 服务端推送广播信息

```python
from flask_socketio import emit
@socketio.on('my_broadcast', namespace='/mofang')
def my_broadcast(data):
    emit('broadcast_response', data, broadcast=True)
    socketio.emit('some event', {'data': 42}) 
    # 只要不声明房间ID,则默认返回给整个命名空间下所有的用户都可以接收
```

