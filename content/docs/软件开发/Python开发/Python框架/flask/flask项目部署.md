---
title: "flask项目部署"
weight: 4
date: 2026-06-23
---

celery封装进flask



原本的celery项目目录

```python
├── mycelery/
    ├── config.py # 这里的配置信息将会复制粘贴到flask项目中的settings.dev配置文件下，并转换成大写。
    ├── main.py   # 入口文件中关于celery初始化的代码将会写到application.__init__主程序文件中。
    ├── relation/
    │   └── tasks.py  # 当前任务文件，将会连文件名一起复制粘贴到flask项目的relation蓝图下，新路径：apps.relation.tasks
    └── sms/
        └── tasks.py  # 当前任务文件，将会连文件名一起复制粘贴到flask项目的home蓝图下，新路径：apps.home.tasks
```

调整原来`mycelery.config`配置文件中的代码，转义到当前flask项目中的配置文件`settings.dev`中，新增代码：

```python
# celery配置

# celery的任务队列地址
BROKER_URL = 'redis://127.0.0.1:6379/15'
# celery的结果队列地址
CELERY_RESULT_BACKEND = "redis://127.0.0.1:6379/14"
# celery的任务结果内容格式
CELERY_ACCEPT_CONTENT = ['json']
# 设置并发的worker数量
CELERYD_CONCURRENCY = 20
# 每个worker最多执行500个任务被销毁，可以防止内存泄漏
CELERYD_MAX_TASKS_PER_CHILD = 500
# 单个任务的最大运行时间，超时会被杀死
CELERYD_TASK_TIME_LIMIT = 10 * 60
# 任务发出后，经过一段时间还未收到acknowledge , 就将任务重新交给其他worker执行
CELERY_DISABLE_RATE_LIMITS = True
# 某些情况下可以防止死锁
CELERYD_FORCE_EXECV = True

# celery的定时任务调度器配置
CELERYBEAT_SCHEDULE = {
    "check_order_outtime": {
        "task": "check_mongo_status",
        "schedule": crontab(),  # 在流量低峰/错峰的时候同步
    }
}
```

调整原来`mycelery.main`入口文件中的代码，转移到当前flask项目的主程序文件`application.__init__`中，代码：

```python
import os
import sys
import eventlet			# 记得一定要使用携程，不然celery_worker无法正常工作
eventlet.monkey_patch()   # eventlet提供的猴子补丁

# import gevent
# from gevent import monkey
# monkey.patch_all()    # gevent提供的猴子补丁


from celery import Celery
from flask import Flask
from flask_jwt_extended import JWTManager
from flask_script import Manager
from flask_sqlalchemy import SQLAlchemy
from flask_redis import FlaskRedis
from flask_session import Session
from flask_migrate import Migrate, MigrateCommand
from flask_jsonrpc import JSONRPC
from flask_marshmallow import Marshmallow
from flask_admin import Admin, AdminIndexView
from flask_babelex import Babel
from flask_pymongo import PyMongo
from flask_qrcode import QRcode
from flask_socketio import SocketIO
from flask_cors import CORS


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

# 初始化jsonrpc模块
jsonrpc = JSONRPC(service_url='/api')

# 数据转换器的对象创建
ma = Marshmallow()

# jwt认证模块实例化
jwt = JWTManager()

# flask-admin模块实例化
admin = Admin()

# flask-babelex模块实例化
babel = Babel()

# mongodb模块初始化
mongo = PyMongo()

# qrcode二维码生成
QRCode = QRcode()

# socketio
socketio = SocketIO()

# flask_cors
cors = CORS()

# celery
celery = Celery()


def init_app(config_path, app=None):
    """
        全局初始化

        import_name      Flask程序所在的包(模块)，传 __name__ 就可以
                         其可以决定 Flask 在访问静态文件时查找的路径
        static_path      静态文件访问路径(不推荐使用，使用 static_url_path 代替)
        static_url_path  静态文件访问路径，可以不传，默认为：/ + static_folder
        static_folder    静态文件存储的文件夹，可以不传，默认为 static
        template_folder  模板文件存储的文件夹，可以不传，默认为 templates

    """
    # 创建app应用对象
    # if app == None:
        # 实例化 flask
    app = Flask(import_name=__name__)

    # 设置项目根目录
    app.BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    # 加载导包路径
    sys.path.insert(0, os.path.join(app.BASE_DIR, "application/utils/language"))

    # 加载配置
    # flask中支持多种配置方式，通过app.config来进行加载，我们会这里常用的是配置类
    Config = load_config(config_path)
    app.config.from_object(Config)

    # celery
    celery.main = app.name
    celery.app = app
    # celery注册配置
    celery.conf.update(app.config)
    # celery自动搜索注册蓝图下所有的tasks任务
    celery.autodiscover_tasks(app.config.get("INSTALLED_APPS"))

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
    migrate.init_app(app, db)

    # 添加数据迁移的命令到终端脚本工具中
    manager.add_command('db', MigrateCommand)

    # 日志初始化
    app.log_access, app.log_error = log.init_app(app)

    # 蓝图注册
    init_blueprint(app)

    # 初始化json-rpc
    jsonrpc.init_app(app)

    # 初始化终端脚本工具
    manager.app = app

    # 注册自定义命令
    load_command(manager)

    # jwt初始化
    jwt.init_app(app)

    # admin站点
    # admin.init_app(app)

    # 项目语言
    babel.init_app(app)

    # 数据种子生成器[faker]
    # app.faker = Faker(app.config.get("LANGUAGE"))

    # qrcode初始化配置
    # QRCode.init_app(app)

    # cors
    cors.init_app(app, resources={r"/api/*": {"origins": "*"}})

    # socketio
    socketio.init_app(app, cors_allowed_origins=app.config["CORS_ALLOWED_ORIGINS"], async_mode=app.config["ASYNC_MODE"],
                      debug=app.config["SOCKET_DEBUG"])

    return manager

```

调整原来`mycelery.sms.tasks`任务文件中的代码，转移到当前flask项目中`application.apps`蓝图目录中。并调整代码文件中引入flask_app和celery应用对象的代码。

`apps.home.tasks`，代码：

```python
import json
import datetime
from application import mongo, celery

# check_mongo_status就是之前定义的task任务名称
@celery.task(name="check_mongo_status", bind=True)
def check_mongo_status(*args, **kwargs):
    
    res = mongo.db.user_heartbeat.find()
    current_time = datetime.datetime.now()
    expire_time = 60
    ttye = current_time - datetime.timedelta(seconds=expire_time)

    for i in res:
        query = {
            "_id": i.get("_id")
        }
        if i.get("datetime") < ttye.strftime('%Y-%m-%d %H:%M:%S'):
            upsert = {"$set": {"status": 0}}
            mongo.db.user_heartbeat.update_one(query, upsert)

```



`main.py`，代码：

```python
from application import init_app, celery

manager = init_app("application.settings.dev")

app = manager.app


@app.route('/')
def index():
    return "ok"


if __name__ == '__main__':
    # 创建数据库
    # with manager.app.app_context():
    #     from application import db
    #
    #     db.create_all()
    manager.run()

```



## supervisor启动celery

Supervisor是用Python开发的一套通用的进程管理程序,能将一个普通的命令行进程变为后台daemon,并监控进程状态,异常退出时能自动重启。

```python
pip install supervisor
```

初始化配置

```bash
# 在项目根目录下创建存储supervisor配置目录
mkdir -p scripts && cd scripts
# 生成初始化supervisor核心配置文件
echo_supervisord_conf > supervisord.conf
# 可以通过 ls 查看scripts下是否多了supervisord.conf这个文件，表示初始化配置生成了。
# 在编辑器中打开supervisord.conf，并去掉最后一行的注释分号。
# 修改如下，表示让supervisor自动加载当前supervisord.conf所在目录下所有ini配置文件
```

`supervisord.conf`，主要修改文件中的`39, 40,75,76,169,170`行去掉左边注释，其中170修改成`当前目录`。配置代码：

```python
; Sample supervisor config file.
;
; For more information on the config file, please see:
; http://supervisord.org/configuration.html
;
; Notes:
;  - Shell expansion ("~" or "$HOME") is not supported.  Environment
;    variables can be expanded using this syntax: "%(ENV_HOME)s".
;  - Quotes around values are not supported, except in the case of
;    the environment= options as shown below.
;  - Comments must have a leading space: "a=b ;comment" not "a=b;comment".
;  - Command will be truncated if it looks like a config file comment, e.g.
;    "command=bash -c 'foo ; bar'" will truncate to "command=bash -c 'foo ".
;
; Warning:
;  Paths throughout this example file use /tmp because it is available on most
;  systems.  You will likely need to change these to locations more appropriate
;  for your system.  Some systems periodically delete older files in /tmp.
;  Notably, if the socket file defined in the [unix_http_server] section below
;  is deleted, supervisorctl will be unable to connect to supervisord.

[unix_http_server]
file=/tmp/supervisor.sock   ; the path to the socket file
;chmod=0700                 ; socket file mode (default 0700)
;chown=nobody:nogroup       ; socket file uid:gid owner
;username=user              ; default is no username (open server)
;password=123               ; default is no password (open server)

; Security Warning:
;  The inet HTTP server is not enabled by default.  The inet HTTP server is
;  enabled by uncommenting the [inet_http_server] section below.  The inet
;  HTTP server is intended for use within a trusted environment only.  It
;  should only be bound to localhost or only accessible from within an
;  isolated, trusted network.  The inet HTTP server does not support any
;  form of encryption.  The inet HTTP server does not use authentication
;  by default (see the username= and password= options to add authentication).
;  Never expose the inet HTTP server to the public internet.

[inet_http_server]         ; inet (TCP) server disabled by default
port=0.0.0.0:9001        ; ip_address:port specifier, *:port for all iface
;username=user              ; default is no username (open server)
;password=123               ; default is no password (open server)

[supervisord]
logfile=/tmp/supervisord.log ; main log file; default $CWD/supervisord.log
logfile_maxbytes=50MB        ; max main logfile bytes b4 rotation; default 50MB
logfile_backups=10           ; # of main logfile backups; 0 means none, default 10
loglevel=info                ; log level; default info; others: debug,warn,trace
pidfile=/tmp/supervisord.pid ; supervisord pidfile; default supervisord.pid
nodaemon=false               ; start in foreground if true; default false
silent=false                 ; no logs to stdout if true; default false
minfds=1024                  ; min. avail startup file descriptors; default 1024
minprocs=200                 ; min. avail process descriptors;default 200
;umask=022                   ; process file creation umask; default 022
;user=supervisord            ; setuid to this UNIX account at startup; recommended if root
;identifier=supervisor       ; supervisord identifier, default is 'supervisor'
;directory=/tmp              ; default is not to cd during start
;nocleanup=true              ; don't clean up tempfiles at start; default false
;childlogdir=/tmp            ; 'AUTO' child log dir, default $TEMP
;environment=KEY="value"     ; key value pairs to add to environment
;strip_ansi=false            ; strip ansi escape codes in logs; def. false

; The rpcinterface:supervisor section must remain in the config file for
; RPC (supervisorctl/web interface) to work.  Additional interfaces may be
; added by defining them in separate [rpcinterface:x] sections.

[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

; The supervisorctl section configures how supervisorctl will connect to
; supervisord.  configure it match the settings in either the unix_http_server
; or inet_http_server section.

[supervisorctl]
;serverurl=unix:///tmp/supervisor.sock ; use a unix:// URL  for a unix socket
serverurl=http://0.0.0.0:9001 ; use an http:// url to specify an inet socket
;username=chris              ; should be same as in [*_http_server] if set
;password=123                ; should be same as in [*_http_server] if set
;prompt=mysupervisor         ; cmd line prompt (default "supervisor")
;history_file=~/.sc_history  ; use readline history if available

; The sample program section below shows all possible program subsection values.
; Create one or more 'real' program: sections to be able to control them under
; supervisor.

;[program:theprogramname]
;command=/bin/cat              ; the program (relative uses PATH, can take args)
;process_name=%(program_name)s ; process_name expr (default %(program_name)s)
;numprocs=1                    ; number of processes copies to start (def 1)
;directory=/tmp                ; directory to cwd to before exec (def no cwd)
;umask=022                     ; umask for process (default None)
;priority=999                  ; the relative start priority (default 999)
;autostart=true                ; start at supervisord start (default: true)
;startsecs=1                   ; # of secs prog must stay up to be running (def. 1)
;startretries=3                ; max # of serial start failures when starting (default 3)
;autorestart=unexpected        ; when to restart if exited after running (def: unexpected)
;exitcodes=0                   ; 'expected' exit codes used with autorestart (default 0)
;stopsignal=QUIT               ; signal used to kill process (default TERM)
;stopwaitsecs=10               ; max num secs to wait b4 SIGKILL (default 10)
;stopasgroup=false             ; send stop signal to the UNIX process group (default false)
;killasgroup=false             ; SIGKILL the UNIX process group (def false)
;user=chrism                   ; setuid to this UNIX account to run the program
;redirect_stderr=true          ; redirect proc stderr to stdout (default false)
;stdout_logfile=/a/path        ; stdout log path, NONE for none; default AUTO
;stdout_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
;stdout_logfile_backups=10     ; # of stdout logfile backups (0 means none, default 10)
;stdout_capture_maxbytes=1MB   ; number of bytes in 'capturemode' (default 0)
;stdout_events_enabled=false   ; emit events on stdout writes (default false)
;stdout_syslog=false           ; send stdout to syslog with process name (default false)
;stderr_logfile=/a/path        ; stderr log path, NONE for none; default AUTO
;stderr_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
;stderr_logfile_backups=10     ; # of stderr logfile backups (0 means none, default 10)
;stderr_capture_maxbytes=1MB   ; number of bytes in 'capturemode' (default 0)
;stderr_events_enabled=false   ; emit events on stderr writes (default false)
;stderr_syslog=false           ; send stderr to syslog with process name (default false)
;environment=A="1",B="2"       ; process environment additions (def no adds)
;serverurl=AUTO                ; override serverurl computation (childutils)

; The sample eventlistener section below shows all possible eventlistener
; subsection values.  Create one or more 'real' eventlistener: sections to be
; able to handle event notifications sent by supervisord.

;[eventlistener:theeventlistenername]
;command=/bin/eventlistener    ; the program (relative uses PATH, can take args)
;process_name=%(program_name)s ; process_name expr (default %(program_name)s)
;numprocs=1                    ; number of processes copies to start (def 1)
;events=EVENT                  ; event notif. types to subscribe to (req'd)
;buffer_size=10                ; event buffer queue size (default 10)
;directory=/tmp                ; directory to cwd to before exec (def no cwd)
;umask=022                     ; umask for process (default None)
;priority=-1                   ; the relative start priority (default -1)
;autostart=true                ; start at supervisord start (default: true)
;startsecs=1                   ; # of secs prog must stay up to be running (def. 1)
;startretries=3                ; max # of serial start failures when starting (default 3)
;autorestart=unexpected        ; autorestart if exited after running (def: unexpected)
;exitcodes=0                   ; 'expected' exit codes used with autorestart (default 0)
;stopsignal=QUIT               ; signal used to kill process (default TERM)
;stopwaitsecs=10               ; max num secs to wait b4 SIGKILL (default 10)
;stopasgroup=false             ; send stop signal to the UNIX process group (default false)
;killasgroup=false             ; SIGKILL the UNIX process group (def false)
;user=chrism                   ; setuid to this UNIX account to run the program
;redirect_stderr=false         ; redirect_stderr=true is not allowed for eventlisteners
;stdout_logfile=/a/path        ; stdout log path, NONE for none; default AUTO
;stdout_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
;stdout_logfile_backups=10     ; # of stdout logfile backups (0 means none, default 10)
;stdout_events_enabled=false   ; emit events on stdout writes (default false)
;stdout_syslog=false           ; send stdout to syslog with process name (default false)
;stderr_logfile=/a/path        ; stderr log path, NONE for none; default AUTO
;stderr_logfile_maxbytes=1MB   ; max # logfile bytes b4 rotation (default 50MB)
;stderr_logfile_backups=10     ; # of stderr logfile backups (0 means none, default 10)
;stderr_events_enabled=false   ; emit events on stderr writes (default false)
;stderr_syslog=false           ; send stderr to syslog with process name (default false)
;environment=A="1",B="2"       ; process environment additions
;serverurl=AUTO                ; override serverurl computation (childutils)

; The sample group section below shows all possible group values.  Create one
; or more 'real' group: sections to create "heterogeneous" process groups.

;[group:thegroupname]
;programs=progname1,progname2  ; each refers to 'x' in [program:x] definitions
;priority=999                  ; the relative start priority (default 999)

; The [include] section can just contain the "files" setting.  This
; setting can list multiple files (separated by whitespace or
; newlines).  It can also contain wildcards.  The filenames are
; interpreted as relative to this file.  Included files *cannot*
; include files themselves.

[include]
files = *.ini

```

创建`sd_wan_celery_worker.ini`文件，启动我们项目worker任务队列

```bash
cd scripts
touch sd_wan_celery_worker.ini
```

```ini
[root@MyCloudServer scripts]# cat sd_wan_celery_worker.ini 
[program:sd_wan_celery_worker]
# 启动命令
command=/root/.virtualenvs/sd-wan/bin/celery -A main.celery worker -P eventlet -l info -n worker1
# 项目根目录的绝对路径，通过pwd查看
directory=/root/projects/sd_wan_demo
# 项目虚拟环境
enviroment=PATH="/root/.virtualenvs/sd-wan/bin/"
# 输出日志绝对路径
stdout_logfile=/root/projects/sd_wan_demo/logs/celery_worker_info.log
# 错误日志绝对路径
stderr_logfile=/root/projects/sd_wan_demo/logs/celery_worker_error.log
# 自动启动
autostart=true
# 重启
autorestart=true
# 进程启动后跑了几秒钟，才被认定为成功启动，默认1
startsecs=10
# 进程结束后60秒才被认定结束
stopwatisecs=60
# 优先级

```

创建`sd_wan_celery_beat.ini`文件，来触发我们的beat定时任务

```bash
cd scripts
touch sd_wan_celery_beat.ini
```

```ini
[root@MyCloudServer scripts]# cat sd_wan_celery_beat.ini 
[program:sd_wan_celery_beat]
command=/root/.virtualenvs/sd-wan/bin/celery -A main.celery beat -l info
directory=/root/projects/sd_wan_demo
enviroment=PATH="/root/.virtualenvs/sd-wan/bin/"
stdout_logfile=/root/projects/sd_wan_demo/logs/celery_beat_info.log
stderr_logfile=/root/projects/sd_wan_demo/logs/celery_beat_error.log
autostart=true
autorestart=true
startsecs=10
stopwaitsecs=60
[program:mofang_celery_beat]
command=/home/moluo/.virtualenvs/mofang/bin/celery -A manage.celery beat -l info
directory=/home/moluo/Desktop/mofangapi
enviroment=PATH="/home/moluo/.virtualenvs/mofang/bin"
stdout_logfile=/home/moluo/Desktop/mofangapi/logs/celery.beat.info.log
stderr_logfile=/home/moluo/Desktop/mofangapi/logs/celery.beat.error.log
autostart=true
autorestart=true
startsecs=10
stopwaitsecs=60
priority=998
```

创建`sd_wan_celery_flower.ini`文件，来启动我们的celery监控管理工具

```bash
# 默认是没有这个监控工具的，需要安装一个包
pip install flower	# 安装任务监控器

cd scripts
touch sd_wan_celery_flower.ini
```

```ini
[root@MyCloudServer scripts]# cat sd_wan_celery_flower.ini 
[program:sd_wan_celery_flower]
command=/root/.virtualenvs/sd-wan/bin/celery --broker=redis://127.0.0.1:6379/13 flower --address=0.0.0.0 --port=5555
directory=/root/projects/sd_wan_demo
enviroment=PATH="/root/.virtualenvs/sd-wan/bin/"
stdout_logfile=/root/projects/sd_wan_demo/logs/celery_flower_info.log
stderr_logfile=/root/projects/sd_wan_demo/logs/celery_flower_error.log
autostart=true
autorestart=true
startsecs=10
stopwaitsecs=60
priority=990
```

启动`supervisor`，确保此时你在项目路径下

```bash
cd ../
supervisord -c scripts/supervisord.conf
```

启动`supervisorctl`命令行，管理上面的celery的运行。

```bash
# 重新加载配置信息
supervisorctl reload
# 设置supervisor开机自启
systemctl enable supervisord
# 如果作为服务让supervisord，那么command里面的命令必须采用绝对路径。
```

常用操作

```bash
# 停止某一个进程，program 就是进程名称，在ini文件首行定义的[program:mofang_celery_flower] 里的 :的名称
supervisorctl stop program

supervisorctl start program  # 启动某个进程
supervisorctl restart program  # 重启某个进程
supervisorctl stop groupworker:  # 结束所有属于名为 groupworker 这个分组的进程 (start，restart 同理)
supervisorctl stop groupworker:name1  # 结束 groupworker:name1 这个进程 (start，restart 同理)
supervisorctl stop all  # 停止全部进程，注：start、restartUnlinking stale socket /tmp/supervisor.sock、stop 都不会载入最新的配置文件
supervisorctl reload  # 载入最新的配置文件，停止原有进程并按新的配置启动、管理所有进程
supervisorctl update  # 根据最新的配置文件，启动新配置或有改动的进程，配置没有改动的进程不会受影响而重启

# 查看supervisor是否启动
ps aux | grep supervisord
```



把supervisor注册到ubuntu系统服务中并设置开机自启

```bash
cd scripts
touch supervisor.service
```

supervisor.service，配置内容，并保存。

```ini
# 涉及到路径的地方，记得自己修改
[root@MyCloudServer scripts]# cat supervisor.service 
[Unit]
Description=supervisor
After=network.target

[Service]
Type=forking
ExecStart=/root/.virtualenvs/sd-wan/bin/supervisord -c /root/projects/sd_wan_demo/scripts/supervisord.conf
ExecStop=/root/.virtualenvs/sd-wan/bin/supervisorctl $OPTIONS shutdown
ExecReload=/root/.virtualenvs/sd-wan/bin/supervisorctl $OPTIONS reload
KillMode=process
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
```

设置开机自启

```bash
# 赋予权限
chmod 766 supervisor.service
# 复制到系统开启服务目录下
sudo cp supervisor.service /lib/systemd/system/	# ubuntu
cp supervisor.service /usr/lib/systemd/system/	# centos

# 设置允许开机自启
systemctl enable supervisor.service
# 判断是否已经设置为开机自启了
systemctl is-enabled  supervisor.service
# 通过systemctl查看supervisor运行状态
systemctl status  supervisor.service
```



```bash
我项目根路径

/root/projects/sd_wan_demo

```


