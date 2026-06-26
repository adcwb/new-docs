---
title: "Django"
weight: 12
date: 2026-06-23
---

## 框架本质

```python
纯手工框架：
    1.socket代码需要我们自己写
    2.http格式的数据自己处理(只能拿到用户输入的路由)
    
基于wsgiref模块：
    1.帮助你封装了socket代码
    2.帮你处理http格式的数据(大字典)

    web服务网关接口
        1.请求来的时候帮助你自动拆分http格式数据并封装成非常方便处理的数据格式
        2.响应走的时候帮你讲数据再打包成符合http格式
        
根据功能的不同拆分为不同的py文件：
    urls.py
        路由与视图函数对应关系
    views.py(后端业务逻辑)
        业务逻辑的视图函数
        ps:视图函数可以是函数其实也可以是类
          面向函数式编程
          面向对象式编程
    templates模版文件夹
        存储html文件
    # 拆分完成后 后续要想添加功能 只需要在urls.py和views.py中书写对应的代码即可
    
动静态网页：
# 根据html页面内容是写死的还是从后端动态获取的
	1.后端获取当前时间
  2.从数据库获取数据
  ...
"""
如何讲后端的数据传递给html文件(在后端发生的不在浏览器上)
	1.lowb版本 利用字符串的替换
	2.jinja2模版语法
		即支持给html传数据
		还提供了一系列快捷方式操作数据(模版语法)
			{{ user_list }}
			
			{%for i in user_list %}
			{%enfor%}
		jinja2的模版语法及其的贴近python语法 并且有时候比python语法更加的简单
"""

# 利用wsgiref模块封装的web框架加上jinja2模版语法 结合前端后端数据库
```



## Python三大主流web框架

```python
django
	特点:
        大而全 自带的功能特别特别特别的多 类似于航空母舰
	不足:
		有时候过于笨重
        
flask
	特点:
        小而精  自带的功能特别特别特别的少 类似于游骑兵
		第三方的模块特别特别特别的多，如果将flask第三方的模块加起来完全可以盖过django
		并且也越来越像django
	不足:
		比较依赖于第三方的开发者
		
tornado
	特点:异步非阻塞 支持高并发
		牛逼到甚至可以开发游戏服务器
	不足:
		暂时不会

一个web框架大概可以分为三部分：
		A：socket部分     B：路由与视图函数对应关系	C：模板语法
Django  用的是自己的，wsgiref模块	用的是自己的		用的是自己的
flask	werkzeug(内部还是wsgiref模块) 用的是自己的		用的jinja2	
tornado 都是用的自己的
        
```

## Django安装

```python
命令行操作：
	1.创建Django项目
    	django-admin startproject mysite(项目名)
	2.启动Django项目
    	cd mysite
    	python3 manage.py runserver
	3.创建应用
    	python manage.py startapp app01

pycharm操作：
	1.new project
    	选择左侧第二个django即可
	2.启动
    3.创建应用，同上

注意:
# 如何让你的计算机能够正常的启动django项目
	1.计算机的名称不能有中文
	2.一个pycharm窗口只开一个项目
	3.项目里面所有的文件也尽量不要出现中文
	4.python解释器尽量使用3.4~3.6之间的版本
  		(如果你的项目报错 你点击最后一个报错信息去源码中把逗号删掉)
    
# django版本问题
	1.X 2.X 3.X(直接忽略)
  		1.X和2.X本身差距也不大 我们讲解主要以1.X为例 会讲解2.X区别
  		公司之前用的1.8 满满过渡到了1.11版本 有一些项目用的2.0
 
# django安装
	pip3 install django==1.11.22
        如果已经安装了其他版本 无需自己卸载,直接重新装 会自动卸载安装新的
        如果报错 看看是不是timeout 如果是 那么只是网速波动重新安装即可
        验证是否安装成功的方式: 终端输入django-admin看看有没有反应
	若Python解释器用的是3.7+，建议安装Python1.17+版本，否则会启动失败
```



## Django基本操作

```python
主要文件介绍：
-mysite项目总文件夹
	--mysite文件夹
  	---settings.py	    配置文件
    ---urls.py			路由与视图函数对应关系(路由层)
    ---wsgi.py			wsgiref模块(不考虑)
  --manage.py			django的入口文件
  --db.sqlite3			django自带的sqlite3数据库(小型数据库 功能不是很多还有bug)
  --app01文件夹
  	---admin.py			django后台管理
    ---apps.py			注册使用
    ---migrations文件夹  数据库迁移记录
    ---models.py		数据库相关的 模型类(orm)
  	---tests.py			测试文件
    ---views.py			视图函数(视图层)
    
```

## Django应用

```python
django是一款专门用来开发app的web框架
django框架就类似于是一所大学，app就是大学里面各个学院，一个app就是一个独立的功能模块
创建的应用一定要去配置文件中注册，不注册django框架不识别
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'app01.apps.App01Config',  # 全写
  	'app01',			 # 简写
]
注：用pycharm创建项目的时候 pycharm可以帮你创建一个app并且自动注册
```

## Django小白必回三板斧

```python
views.py
	from django.shortcuts import HttpResponse,render,redirect

HttpResponse
	返回字符串类型的数据
		return HttpResponse('字符串')
render
	返回html文件的
		return render(request,'login.html')
redirect
	重定向
		return redirect('https://www.mzitu.com/')
		return redirect('/home/')

urls.py
	
    from app01 import views
    urlpatterns = [
        url(r'^admin/', admin.site.urls),
        url(r'^index/', views.index)
    ]
    
views.py
    def ab_render(request):
        # 视图函数必须要接受一个形参request
        user_dict = {'username':'jason','age':18}
        # 第一种传值方式:更加的精确 节省资源
        # return render(request,'01 ab_render.html',{'data':user_dict,'date':123})
        # 第二种传值方式:当你要传的数据特别多的时候
        """locals会将所在的名称空间中所有的名字全部传递给html页面"""
        return render(request,'01 ab_render.html',locals())
取消自动加斜杠，在settings.py中加上以下字段
	APPEND_SLASH = False
```

## 静态文件配置

```python
一般情况下，我们将HTML文件默认都放在templates文件夹下
将网站所使用的静态文件默认都放在static文件夹下
什么是静态文件：
	前端已经写好了的，能够直接调用使用的文件
    	例如网站写好的js，css文件，图片，第三方前端框架等等
Django默认是不会自动帮你创建static文件夹的，需要自己手动创建
一般情况下我们在static文件夹内还会做进一步的划分处理
	-static
  	--js
    --css
    --img
    其他第三方文件

在浏览器中输入url能够看到对应的资源，是因为后端提前开设了该资源的接口，若访问不到资源，说明后端没有开设该资源的访问接口
	http://127.0.0.1:8000/static/bootstrap-3.3.7-dist/css/bootstrap.min.css

静态文件配置：
    ****************************************************************
    当你在写django项目的时候 可能会出现后端代码修改了但是前端页面没有变化的情况
        1.你在同一个端口开了好几个django项目 
            一直在跑的其实是第一个django项目

        2.浏览器缓存的问题
            settings
                network
                    disable cache 勾选上	
    *****************************************************************
    
静态文件配置：
    STATIC_URL = '/static/'  # HTML中使用的静态文件夹前缀
    STATICFILES_DIRS = [
        os.path.join(BASE_DIR, "static"),  # 静态文件存放位置，可以放多个，第一个找不到去第二个里面找，直到找完或者找打，优先级从上往下依次查找，查找到一个就不会继续往下找了
    ]
静态文件动态解析：
	{% load static %}       #类似于导模块，加载静态资源
    <link rel="stylesheet" href="{% static 'bootstrap-3.3.7-dist/css/bootstrap.min.css' %}">   #动态加载来自STATIC_URL下的路径
    <script src="{% static 'bootstrap-3.3.7-dist/js/bootstrap.min.js' %}"></script>

在前期我们使用Django提交post请求的时候，需要在配置文件中取消csrf中间件
    MIDDLEWARE = [
        'django.middleware.security.SecurityMiddleware',
        'django.contrib.sessions.middleware.SessionMiddleware',
        'django.middleware.common.CommonMiddleware',
        # 'django.middleware.csrf.CsrfViewMiddleware',
        'django.contrib.auth.middleware.AuthenticationMiddleware',
        'django.contrib.messages.middleware.MessageMiddleware',
        'django.middleware.clickjacking.XFrameOptionsMiddleware',
    ]
补充：
	form表单默认是get请求数据
		http://127.0.0.1:8000/login/?username=jason&password=123

    form表单action参数
        1.不写 默认朝当前所在的url提交数据
        2.全写 指名道姓
        3.只写后缀 /login/


```

## request对象方法初识

```python
request.method # 返回请求方式 并且是全大写的字符串形式  <class 'str'>
request.POST  # 获取用户post请求提交的普通数据不包含文件
	request.POST.get()  # 只获取列表最后一个元素
  	request.POST.getlist()  # 直接将列表取出
request.GET  # 获取用户提交的get请求数据
	request.GET.get()  # 只获取列表最后一个元素
  	request.GET.getlist()  # 直接将列表取出
    
案例：登录页面
	def login(request):
    if request.method == 'GET':
        print('GET')
        return render(request, 'login.html')
    
    if request.method == 'POST':
        return HttpResponse("POST")
    return render(request, 'login.html')


两种提交方式的区别：
	get：
    	请求携带的数据是在URL中
        请求的数据有大小限制2048
        效率比post好
        可以回退，数据不会丢失
        只允许 ASCII 字符。
    post：
		所有的数据都是放在头部中
        没有数据限制
        不可回退，回退之后数据需要重新提交
        没有限制。也允许二进制数据。
        
```

## Django链接数据库(MySQL)

```python
Django默认用的数据库是sqlite3
在setting.py中找到关于SQL的配置项：
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
        }
    }

若要改为MySQL数据库，要先在配置文件中配置
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.mysql',
            'NAME': 'django_base',
            'USER': 'root',
            'PASSWORD': 'your_password',
            'HOST': '118.25.65.95',
            'PORT': '3306',
            'CHARSET': 'UTF8'
        }
    }
配置完成后，需要做一个声明：
	django默认用的是mysqldb模块链接MySQL，但是该模块的兼容性不好，需要手动改为用pymysql连接
    需要告诉django不要用默认的mysqldb 而是用pymysql
	在项目名下的init或者任意的应用名下的init文件中书写以下代码都可以
    	import pymysql
		pymysql.install_as_MySQLdb()

```

## Django之路由层

```pythom
什么是路由：
	路由即请求地址与视图函数的映射关系
路由配置：
	from django.conf.urls import url
    from django.contrib import admin
    from app01 import views

    urlpatterns = [
		url(正则表达式, views视图函数，参数，别名),
    ]
        正则表达式：一个正则表达式字符串
        views视图函数：一个可调用对象，通常为一个视图函数或一个指定视图函数路径的字符串
        参数：可选的要传递给视图函数的默认参数（字典形式）
        别名：一个可选的name参数
        
正则表达式：
    1、urlpatterns中的元素按照书写顺序从上往下逐一匹配正则表达式，一旦匹配成功则不再继续。
    2、若要从URL中捕获一个值，只需要在它周围放置一对圆括号（分组匹配）。
    3、不需要添加一个前导的反斜杠，因为每个URL 都有。例如，应该是^articles 而不是 ^/articles。
    4、每个正则表达式前面的'r' 是可选的但是建议加上。
	在Djangosettings.py配置文件中，有一个参数，可以控制是否自动在网址结尾加/
		APPEND_SLASH=True   默认是开启的

分组：
	简单来说，分组就是给某一段正则表达式用小括号括起来，可以分为有名分组和无名分组
	
无名分组：
	无名分组就是将括号内正则表达式匹配到的内容当作位置参数传递给后面的视图函数
        urlpatterns = [
            url(r'^admin/', admin.site.urls),

            # 下述正则表达式会匹配url地址的路径部分为:article/数字/，匹配成功的分组部分会以位置参数的形式传给视图函数，有几个分组就传几个位置参数
            url(r'^aritcle/(\d+)/$',views.article), 
        ]
    此外，在views.py文件中，需要额外增加一个形参用于接收传递过来的分组数据
        def article(request,article_id):
            return HttpResponse('id为 %s 的文章内容...' %article_id)
            
有名分组：
	有名分组就是将括号内正则表达式匹配到的内容当作关键字参数传递给后面的视图函数
        urlpatterns = [
            url(r'^admin/', admin.site.urls),

            # 该正则会匹配url地址的路径部分为:article/数字/，匹配成功的分组部分会以关键字参数（article_id=匹配成功的数字）的形式传给视图函数，有几个有名分组就会传几个关键字参数
            url(r'^aritcle/(?P<article_id>\d+)/$',views.article), 
        ]
	此外，在views.py中需要增加一个形参，形参名必须是urls.py中指定的名字
        形参名必须为article_id
        def article(request,article_id):
            return HttpResponse('id为 %s 的文章内容...' %article_id)

有名分组和无名分组的区别：
	有名分组和无名分组都是为了获取路径中的参数，并传递给视图函数，区别在于无名分组是以位置参数的形式传递，有名分组是以关键字参数的形式传递。
	有名分组和无名分组不可以混合使用，但是同一种分组可以多次使用

反向解析：
	通过一些方法得到一个结果，该结果可以直接访问对应的url触发视图函数
配置反向解析:
	先给路由与视图函数起一个别名
		url(r'^func_kkk/',views.func,name='ooo')
	后端反向解析
		from django.shortcuts import render,HttpResponse,redirect,reverse
  			reverse('ooo')
  	前端反向解析
  		<a href="{% url 'ooo' %}">111</a>
	注意：起的别名不可以出现重复
	
有名分组与无名分组的反向解析：
	无名分组反向解析：
		url(r'^index/(\d+)/',views.index,name='xxx')
		前端：{% url 'xxx' 123 %}
		后端：reverse('xxx', args=(1,))
	有名分组反向解析：
		url(r'^func/(?P<year>\d+)/',views.func,name='ooo')
		前端：
            <a href="{% url 'ooo' year=123 %}">111</a>  方法一
            <a href="{% url 'ooo' 123 %}">222</a>  		方法二
        后端：
        	reverse('ooo',kwargs={'year':123})          方法一
 			reverse('ooo',args=(111,))					方法二

=========================================================================================
路由分发：
	django的每一个应用都可以有自己的templates文件夹 urls.py static文件夹
	在公司中一个项目可能有很多个模块，每个模块有不同的人负责，当一个django项目中的url特别多的时候 总路由urls.py代码非常冗余不好维护，这个时候也可以利用路由分发来减轻总路由的压力
	利用路由分发之后，总路由不在干涉路由与视图函数的直接对应关系，而是做一个分发处理，识别当前的url是属于哪个应用下的，直接分发给对应的应用去处理
	总路由：
        from app01 import urls as app01_urls
        from app02 import urls as app02_urls
        urlpatterns = [
            url(r'^admin/', admin.site.urls),
            # 1.路由分发
            url(r'^app01/',include(app01_urls)),  # 只要url前缀是app01开头 全部交给app01处理
            url(r'^app02/',include(app02_urls))   # 只要url前缀是app02开头 全部交给app02处理

            # 2.终极写法  推荐使用
            url(r'^app01/',include('app01.urls')),
            url(r'^app02/',include('app02.urls'))
            # 注意事项:总路由里面的url千万不能加$结尾
        ]
	子路由：
        # app01 urls.py
        from django.conf.urls import url
        from app01 import views

        urlpatterns = [
          url(r'^reg/',views.reg)
        ]
        
        # app02 urls.py
        from django.conf.urls import url
        from app02 import views

        urlpatterns = [
          url(r'^reg/',views.reg)
        ]
        
=========================================================================================
名称空间
	当多个应用出现了相同别名的时候，反向解析没有办法自动识别前缀，所以在配置的时候，可以直接指定名称空间
        # 总路由
        url(r'^app01/',include('app01.urls',namespace='app01')),
        url(r'^app02/',include('app02.urls',namespace='app02'))
        # 解析的时候
        # app01
        urlpatterns = [
        url(r'^reg/',views.reg,name='reg')
            ]
        # app02
        urlpatterns = [
        url(r'^reg/',views.reg,name='reg')
            ]
	后端：
        reverse('app01:reg')
        reverse('app02:reg')
	前端：
        {% url 'app01:reg' %}
        {% url 'app02:reg' %}
	一般情况下，只要保证名字不冲突，就没有必要使用名称空间
	在有多个app的时候，我们会在起别名的时候会加上app前缀，这样便可确保多个app之间名字不冲突的问题
        urlpatterns = [
            url(r'^reg/',views.reg,name='app01_reg')
        ]
        urlpatterns = [
            url(r'^reg/',views.reg,name='app02_reg')
        ]
        
=========================================================================================
伪静态：
	将一个动态网页伪装成静态网页
	伪装的目的在于增大网站的seo查询力度
	但是无论怎么优化，都不如RMB玩家
        urlpatterns = [
            url(r'^reg.html',views.reg,name='app02_reg')
        ]

========================================================================================= 
虚拟环境：
    在正常开发中 我们会给每一个项目配备一个该项目独有的解释器环境
    该环境内只有该项目用到的模块 用不到一概不装

linux；缺什么才装什么

虚拟环境：
	你每创建一个虚拟环境就类似于重新下载了一个纯净的python解释器
	但是虚拟环境不要创建太多，是需要消耗硬盘空间的

扩展:
	每一个项目都需要用到很多模块 并且每个模块版本可能还不一样
	那我该如何安装呢？ 一个个看一个个装？？？
	
	开发当中我们会给每一个项目配备一个requirements.txt文件
	里面书写了该项目所有的模块即版本
	你只需要直接输入一条命令即可一键安装所有模块即版本
	
```



## Django之视图层

```python
视图函数：
	简称为视图属于Django的视图层，默认定义在views.py文件中，是用来处理web请求信息以及返回响应信息的函数
定义：
	from django.http import HttpResponse
    import datetime

    def current_datetime(request):
        now = datetime.datetime.now()
        html = "<html><body>It is now %s.</body></html>" % now
        return HttpResponse(html)
    每个视图函数都使用HttpRequest对象作为第一个参数，并且通常称之为request
    视图函数的名称并不重要；不需要用一个统一的命名方式来命名，以便让Django识别它
 
render内部原理
	from django.template import Template,Context
    res = Template('<h1>{{ user }}</h1>')
    con = Context({'user':{'username':'jason','password':123}})
    ret = res.render(con)
    print(ret)
    return HttpResponse(ret)
=========================================================================================
JsonResponse对象
	json格式的数据，可以实现前后端数据交互过度，实现跨语言传输数据
    前端序列化
        JSON.stringify()					json.dumps()
        JSON.parse()						json.loads()
        
    import json
    from django.http import JsonResponse
    def ab_json(request):
        user_dict = {'username':'json666','password':'123','hobby':'girl'}

        l = [111,222,333,444,555]
        # 先转成json格式字符串
        # json_str = json.dumps(user_dict,ensure_ascii=False)
        # 将该字符串返回
        # return HttpResponse(json_str)
        # 读源码掌握用法
        # return JsonResponse(user_dict,json_dumps_params={'ensure_ascii':False})
        # In order to allow non-dict objects to be serialized set the safe parameter to False.
        # return JsonResponse(l,safe=False)  
        # 默认只能序列化字典 序列化其他需要加safe参数	
=========================================================================================form表单上传文件及后端操作：
    form表单上传文件类型的数据
        1.method必须指定成post
        2.enctype必须换成formdata

    def ab_file(request):
        if request.method == 'POST':
            # print(request.POST)  # 只能获取普通的简直对数据 文件不行
            print(request.FILES)  # 获取文件数据
            # <MultiValueDict: {'file': [<InMemoryUploadedFile: u=1288812541,1979816195&fm=26&gp=0.jpg (image/jpeg)>]}>
            file_obj = request.FILES.get('file')  # 文件对象
            print(file_obj.name)
            with open(file_obj.name,'wb') as f:
                for line in file_obj.chunks():  # 推荐加上chunks方法 其实跟不加是一样的都是一行行的读取
                    f.write(line)

        return render(request,'form.html')

requeset对象方法：
    request.method
    request.POST
    request.GET
    request.FILES
    request.body  # 原生的浏览器发过来的二进制数据  后面详细的讲
    request.path 
    request.path_info
    request.get_full_path()  能过获取完整的url及问号后面的参数 

        print(request.path)  # /app01/ab_file/
        print(request.path_info)  # /app01/ab_file/
        print(request.get_full_path())  # /app01/ab_file/?username=json
    
=========================================================================================
FBV与CBV
# 视图函数既可以是函数也可以是类
def index(request):
  return HttpResponse('index')

# CBV
    # CBV路由
    url(r'^login/',views.MyLogin.as_view())


		from django.views import View


		class MyLogin(View):
    	def get(self,request):
        return render(request,'form.html')

    	def post(self,request):
        return HttpResponse('post方法')
      
"""
FBV和CBV各有千秋
CBV特点
	能够直接根据请求方式的不同直接匹配到对应的方法执行
	
	内部到底是怎么实现的？
		CBV内部源码(******)
"""

# 你自己不要修改源码 除了bug很难找

# 突破口在urls.py
url(r'^login/',views.MyLogin.as_view())
# url(r'^login/',views.view)  FBV一模一样
# CBV与FBV在路由匹配上本质是一样的 都是路由 对应 函数内存地址
"""
函数名/方法名 加括号执行优先级最高
猜测
    as_view()
        要么是被@staicmethod修饰的静态方法
        要么是被@classmethod修饰的类方法  正确
        
    @classonlymethod
    def as_view(cls, **initkwargs):
        pass
"""

    @classonlymethod
    def as_view(cls, **initkwargs):
        """
        cls就是我们自己写的类   MyCBV
        Main entry point for a request-response process.
        """
        def view(request, *args, **kwargs):
            self = cls(**initkwargs)  # cls是我们自己写的类
            # self = MyLogin(**initkwargs)  产生一个我们自己写的类的对象
            return self.dispatch(request, *args, **kwargs)
            """
            以后你们会经常需要看源码 但是在看python源码的时候 一定要时刻提醒自己面向对象属性方法查找顺序
                先从对象自己找
                再去产生对象的类里面找
                之后再去父类找
                ...
            总结:看源码只要看到了self点一个东西 一定要问你自己当前这个self到底是谁
            """
        return view
      
		# CBV的精髓
    def dispatch(self, request, *args, **kwargs):
        # 获取当前请求的小写格式 然后比对当前请求方式是否合法
        # get请求为例
        # post请求
        if request.method.lower() in self.http_method_names:
            handler = getattr(self, request.method.lower(), self.http_method_not_allowed)
            """
            反射:通过字符串来操作对象的属性或者方法
                handler = getattr(自己写的类产生的对象,'get',当找不到get属性或者方法的时候就会用第三个参数)
                handler = 我们自己写的类里面的get方法
            """
        else:
            handler = self.http_method_not_allowed
        return handler(request, *args, **kwargs)
        """
        自动调用get方法
        """

# 要求掌握到不看源码也能够描述出CBV的内部执行流程(******)
```



## Django之模板层

```python
模板语法：
	{{ }}：变量相关
    {% %}：逻辑相关
def index(request):
    # 模版语法可以传递的后端python数据类型
    n = 123
    f = 11.11
    s = '我也想奔现'
    b = True
    l = ['小红','姗姗','花花','茹茹']
    t = (111,222,333,444)
    d = {'username':'jason','age':18,'info':'这个人有点意思'}
    se = {'晶晶','洋洋','嘤嘤'}

    def func():
        print('我被执行了')
        return '你的另一半在等你'

    class MyClass(object):
        def get_self(self):
            return 'self'

        @staticmethod
        def get_func():
            return 'func'

        @classmethod
        def get_class(cls):
            return 'cls'
        
        # 对象被展示到html页面上 就类似于执行了打印操作也会触发__str__方法
        def __str__(self):
            return '到底会不会？'  
        
    obj = MyClass()

    # return render(request,'index.html',{})  # 一个个传
    return render(request,'index.html',locals())


<p>{{ n }}</p>
<p>{{ f }}</p>
<p>{{ s }}</p>
<p>{{ b }}</p>
<p>{{ l }}</p>
<p>{{ d }}</p>
<p>{{ t }}</p>
<p>{{ se }}</p>
<p>传递函数名会自动加括号调用 但是模版语法不支持给函数传额外的参数:{{ func }}</p>
<p>传类名的时候也会自动加括号调用(实例化){{ MyClass }}</p>
<p>内部能够自动判断出当前的变量名是否可以加括号调用 如果可以就会自动执行  针对的是函数名和类名</p>
<p>{{ obj }}</p>
<p>{{ obj.get_self }}</p>
<p>{{ obj.get_func }}</p>
<p>{{ obj.get_class }}</p>


# django模版语法的取值 是固定的格式 只能采用“句点符” .
<p>{{ d.username }}</p>
<p>{{ l.0 }}</p>
<p>{{ d.hobby.3.info }}</p>
# 即可以点键也可以点索引 还可以两者混用

=========================================================================================
过滤器：
	过滤器就类似是模板语法内置的方法
    Django内置有60多个过滤器，过滤器最多只能有两个参数
基本语法：
	{{数据|过滤器:参数}}
# 转义
# 前端
	|safe
# 后端
	from django.utils.safestring import mark_safe
  res = mark_safe('<h1>新新</h1>')

以后你在全栈项目的时候 前端代码不一定非要在前端页面书写
也可以现在先在后端写好 然后传递给前端页面

    <h1>过滤器</h1>
    <p>统计长度:{{ s|length }}</p>
    <p>默认值(第一个参数布尔值是True就展示第一个参数的值否在展示冒号后面的值):{{ b|default:'啥也不是' }}</p>
    <p>文件大小:{{ file_size|filesizeformat }}</p>
    <p>日期格式化:{{ current_time|date:'Y-m-d H:i:s' }}</p>
    <p>切片操作(支持步长):{{ l|slice:'0:4:2' }}</p>
    <p>切取字符(包含三个点):{{ info|truncatechars:9 }}</p>
    <p>切取单词(不包含三个点 按照空格切):{{ egl|truncatewords:9 }}</p>
    <p>切取单词(不包含三个点 按照空格切):{{ info|truncatewords:9 }}</p>
    <p>移除特定的字符:{{ msg|cut:' ' }}</p>
    <p>拼接操作:{{ l|join:'$' }}</p>
    <p>拼接操作(加法):{{ n|add:10 }}</p>
    <p>拼接操作(加法):{{ s|add:msg }}</p>
    <p>转义:{{ hhh|safe }}</p>
    <p>转义:{{ sss|safe }}</p>
    <p>转义:{{ res }}</p>
        
=========================================================================================
标签：
# for循环
	{% for foo in l %}
    <p>{{ forloop }}</p>
    <p>{{ foo }}</p>  一个个元素
	{% endfor %}
  {'parentloop': {}, 'counter0': 0, 'counter': 1, 'revcounter': 6, 'revcounter0': 5, 'first': True, 'last': False}

# if判断
{% if b %}
    <p>baby</p>
{% elif s%}
    <p>都来把</p>
{% else %}
    <p>老baby</p>
{% endif %}


# for与if混合使用
{% for foo in lll %}
    {% if forloop.first %}
        <p>这是我的第一次</p>
    {% elif forloop.last %}
        <p>这是最后一次啊</p>
    {% else %}
        <p>{{ foo }}</p>
    {% endif %}
    {% empty %}
        <p>for循环的可迭代对象内部没有元素 根本没法循环</p>
{% endfor %}



# 处理字典其他方法
{% for foo in d.keys %}
    <p>{{ foo }}</p>
{% endfor %}
{% for foo in d.values %}
    <p>{{ foo }}</p>
{% endfor %}
{% for foo in d.items %}
    <p>{{ foo }}</p>
{% endfor %}


# with起别名
{% with d.hobby.3.info as nb  %}
    <p>{{ nb }}</p>
    在with语法内就可以通过as后面的别名快速的使用到前面非常复杂获取数据的方式
    <p>{{ d.hobby.3.info }}</p>
{% endwith %}

=========================================================================================
自定义过滤器、标签、inclusion_tag

"""
先三步走
	1.在应用下创建一个名字”必须“叫templatetags文件夹
	2.在该文件夹内创建“任意”名称的py文件 eg:mytag.py
	3.在该py文件内"必须"先书写下面两句话(单词一个都不能错)
		from django import template
		
		register = template.Library()
"""

# 自定义过滤器
@register.filter(name='baby')
def my_sum(v1, v2):
    return v1 + v2
# 使用
{% load mytag %}
<p>{{ n|baby:666 }}</p>


# 自定义标签(参数可以有多个)			类似于自定义函数
@register.simple_tag(name='plus')
def index(a,b,c,d):
    return '%s-%s-%s-%s'%(a,b,c,d)
# 使用
标签多个参数彼此之间空格隔开
<p>{% plus 'jason' 123 123 123 %}</p>


# 自定义inclusion_tag
"""
内部原理
	先定义一个方法 
	在页面上调用该方法 并且可以传值
	该方法会生成一些数据然后传递给一个html页面
	之后将渲染好的结果放到调用的位置
"""
@register.inclusion_tag('left_menu.html')
def left(n):
    data = ['第{}项'.format(i) for i in range(n)]
    # 第一种
    # return {'data':data}  # 将data传递给left_menu.html
    # 第二种
    return locals()  # 将data传递给left_menu.html
  
{% left 5 %}
# 总结:当html页面某一个地方的页面需要传参数才能够动态的渲染出来，并且在多个页面上都需要使用到该局部 那么就考虑将该局部页面做成inclusion_tag形式
(在讲bbs的时候会使用到)

=========================================================================================
模板的继承：
"""
你们有没有见过一些网站
	这些网站页面整体都大差不差 只是某一些局部在做变化	
"""
# 模版的继承 你自己先选好一个你要想继承的模版页面
{% extends 'home.html' %}

# 继承了之后子页面跟模版页面长的是一模一样的 你需要在模版页面上提前划定可以被修改的区域
{% block content %}
	模版内容
{% endblock %}

# 子页面就可以声明想要修改哪块划定了的区域
{% block content %}
	子页面内容	
{% endblock %}


# 一般情况下模版页面上应该至少有三块可以被修改的区域
	1.css区域
  2.html区域
  3.js区域
  {% block css %}

	{% endblock %}
  
  {% block content %}

	{% endblock %}
  
  {% block js %}

	{% endblock %}
  # 每一个子页面就都可以有自己独有的css代码 html代码 js代码
  
"""
一般情况下 模版的页面上划定的区域越多 那么该模版的扩展性就越高
但是如果太多 那还不如自己直接写
"""


模板的导入

"""
将页面的某一个局部当成模块的形式
哪个地方需要就可以直接导入使用即可
"""
{% include 'wasai.html' %}

```



## Django之ORM

```python
ORM. 对象关系映射，只能创建表的层面，不能创建库
作用:能够让一个不用sql语句的小白也能够通过python 面向对象的代码简单快捷的操作数据库
不足之处:封装程度太高 有时候sql语句的效率偏低 需要你自己写SQL语句

类									 表

对象									记录
	
对象属性							   记录某个字段对应的值


应用下面的models.py文件
如何创建表：
	1、先去models.py中定义一个类
    	class User(models.Model):
            id = models.AutoField(primary_key=True)
            username = models.CharField(max_length=32)
            password = models.IntegerField()
	2、将数据同步到MySQL中
    	python3 manage.py makemigrations 将操作记录记录到小本本上(migrations文件夹)
		python3 manage.py migrate  将操作真正的同步到数据库中
			注：只要你修改了models.py中跟数据库相关的代码 就必须重新执行上述的两条命令

class User(models.Model):
    # id int primary_key auto_increment
    id = models.AutoField(primary_key=True,verbose_name='主键')
    # username varchar(32)
    username = models.CharField(max_length=32,verbose_name='用户名')
    """
    CharField：必须要指定max_length参数 不指定会直接报错
    verbose_name：该参数是所有字段都有的 就是用来对字段进行解释
    """
    # password int
    password = models.IntegerField(verbose_name='密码')


class Author(models.Model):
    # 由于一张表中必须要有一个主键字段 并且一般情况下都叫id字段
    # 所以orm当你不定义主键字段的时候 orm会自动帮你创建一个名为id主键字段
    # 也就意味着 后续我们在创建模型表的时候如果主键字段名没有额外的叫法 那么主键字段可以省略不写
    # username varchar(32)
    username = models.CharField(max_length=32)
    # password int
    password = models.IntegerField()
    
======================================================================================

字段的增删查改：
	字段的增加：
    	在增加字段的时候，若没有指定默认值，则会抛出异常：
You are trying to add a non-nullable field 'hobby' to user without a default; we can't do that (the database needs something to populate existing rows).
Please select a fix:
 1) Provide a one-off default now (will be set on all existing rows with a null value for this column)
 2) Quit, and let me add a default in models.py
Select an option: 
    解决方法有三种：
        1、直接在终端中给出默认值
        2、在增加字段的时候，指定该字段可以为空
        	info = models.CharField(max_length=32,verbose_name='个人简介',null=True)
        3、在增加字段时候，直接设置默认值
            hobby = models.CharField(max_length=32,verbose_name='兴趣爱好',default='study')
            
	字段的修改：
    	直接修改代码然后执行数据库同步的两条命令即可

	字段的删除：
    	直接注释对应的字段然后执行数据库迁移的两条命令即可
         注：执行完毕之后字段对应的数据也都没有了
            因此，在操作models.py文件时候一定要仔细，执行迁移的命令之前，最好先检查一下自己的代码

======================================================================================
            
数据的增删查改简介：
数据的查询：
    在查询的时候，要用到modes.py，所以应先导入
		res = models.User.objects.filter(username=username)  查
        res = models.User.objects.all() 查
        user_obj = models.User.objects.filter(username=username).first()   取
        <QuerySet [<User: User object>]> [数据对象1,数据对象2...]
            # user_obj = res[0]
            # print(user_obj)
            # print(user_obj.username) 
            # print(user_obj.password)
	返回值可以看成是列表套数据对象的格式
    支持索引取值，切片操作，但是不支持负数索引，同样也不推荐使用索引取值(源码是用的索引取值)
    推荐使用.first()方法取值
    filter括号内可以携带多个参数 参数与参数之间默认是and关系，类似于where
    
数据的增加：
	方法一：直接获取用于数据存入数据库中
        from app01 import models
        res = models.User.objects.create(username=username,password=password)
        会有一个返回值，该返回值就是对象本身
    方法二：利用对象的方法
    	user_obj = models.User(username=username,password=password)
		user_obj.save()  # 保存数据
        
数据的修改：
	方式一：批量更新，只修改被修改过的字段
    	models.User.objects.filter().update(username=username,password=password)
        
	方式二：全部更新，从头到尾将数据的所有字段全部更新一边 无论该字段是否被修改
        edit_obj.username = username
        edit_obj.password= password
        edit_obj.save()

数据的删除：
	批量删除，只删除被修改过的字段
    	models.User.objects.filter().delete()
	删除数据内部其实并不是真正的删除 我们会给数据添加一个标识字段用来表示当前数据是否被删除了，如果数据被删了仅仅只是讲字段修改一个状态

======================================================================================
★★★表与表关系☆☆☆
表与表之间的关系：
	一对多
    多对多
    一对一
    没有关系
    判断表关系的方法：换位思考
    
图书和出版社是一对多的关系 外键字段建在多的那一方 book	
图书和作者是多对多的关系 需要创建第三张表来专门存储
作者与作者详情表是一对一

"""
from django.db import models

# Create your models here.


# 创建表关系  先将基表创建出来 然后再添加外键字段
class Book(models.Model):
    title = models.CharField(max_length=32)
    price = models.DecimalField(max_digits=8,decimal_places=2)
    # 总共八位 小数点后面占两位
    """
    图书和出版社是一对多 并且书是多的一方 所以外键字段放在书表里面
    """
    publish = models.ForeignKey(to='Publish')  # 默认就是与出版社表的主键字段做外键关联
    """
    如果字段对应的是ForeignKey 那么会orm会自动在字段的后面加_id
    如果你自作聪明的加了_id那么orm还是会在后面继续加_id
    
    后面在定义ForeignKey的时候就不要自己加_id
    """


    """
    图书和作者是多对多的关系 外键字段建在任意一方均可 但是推荐你建在查询频率较高的一方
    """
    authors = models.ManyToManyField(to='Author')
    """
    authors是一个虚拟字段 主要是用来告诉orm 书籍表和作者表是多对多关系
    让orm自动帮你创建第三张关系表
    """


class Publish(models.Model):
    name = models.CharField(max_length=32)
    addr = models.CharField(max_length=32)


class Author(models.Model):
    name = models.CharField(max_length=32)
    age = models.IntegerField()
    """
    作者与作者详情是一对一的关系 外键字段建在任意一方都可以 但是推荐你建在查询频率较高的表中
    """
    author_detail = models.OneToOneField(to='AuthorDetail')
    """
    OneToOneField也会自动给字段加_id后缀
    所以你也不要自作聪明的自己加_id
    """

class AuthorDetail(models.Model):
    phone = models.BigIntegerField()  # 或者直接字符类型
    addr = models.CharField(max_length=32)


"""
	orm中如何定义三种关系
		publish = models.ForeignKey(to='Publish')  # 默认就是与出版社表的主键字段做外键关联
		
		authors = models.ManyToManyField(to='Author')
		
		author_detail = models.OneToOneField(to='AuthorDetail')
		
		
		ForeignKey
		OneToOneField
			会自动在字段后面加_id后缀


# 在django1.X版本中外键默认都是级联更新删除的
# 多对多的表关系可以有好几种创建方式 这里暂且先介绍一种
# 针对外键字段里面的其他参数 暂时不要考虑 如果感兴趣自己可以百度试试看

======================================================================================

ORM常用字段

F与Q查询

事务

```

## ORM进阶操作

```python
单表操作：
# django自带的sqlite3数据库对日期格式不是很敏感 处理的时候容易出错
# 增
    # res = models.User.objects.create(name='jason',age=18,register_time='2002-1-21')
    # print(res)
    # import datetime
    # ctime = datetime.datetime.now()
    # user_obj = models.User(name='egon',age=84,register_time=ctime)
    # user_obj.save()

    # 删
    # res = models.User.objects.filter(pk=2).delete()
    # print(res)
    """
    pk会自动查找到当前表的主键字段 指代的就是当前表的主键字段
    用了pk之后 你就不需要指代当前表的主键字段到底叫什么了
        uid
        pid
        sid
        ...
    """
    # user_obj = models.User.objects.filter(pk=1).first()
    # user_obj.delete()

    # 修改
    # models.User.objects.filter(pk=4).update(name='egonDSB')

    # user_obj = models.User.objects.get(pk=4)
    # user_obj = models.User.objects.filter(pk=6)
    """
    get方法返回的直接就是当前数据对象
    但是该方法不推荐使用
        一旦数据不存在该方法会直接报错
        而filter则不会
            所以我们还是用filter
    """
    # user_obj.name = 'egonPPP'
    # user_obj.save()
    
=========================================================================================
必知必会13条：
# 必知必会13条
    # 1.all()  查询所有数据

    # 2.filter()     带有过滤条件的查询
    # 3.get()        直接拿数据对象 但是条件不存在直接报错
    # 4.first()      拿queryset里面第一个元素
    # res = models.User.objects.all().first()
    # print(res)
    # 5.last()
    # res = models.User.objects.all().last()
    # print(res)

    # 6.values()  可以指定获取的数据字段  select name,age from ...     列表套字典
    # res = models.User.objects.values('name','age')  # <QuerySet [{'name': 'jason', 'age': 18}, {'name': 'egonPPP', 'age': 84}]>
    # print(res)
    # 7.values_list()  列表套元祖
    # res = models.User.objects.values_list('name','age')  # <QuerySet [('jason', 18), ('egonPPP', 84)]>
    # print(res)
    # """
    #  # 查看内部封装的sql语句
    #  上述查看sql语句的方式  只能用于queryset对象
    #  只有queryset对象才能够点击query查看内部的sql语句
    #
    # """
    # 8.distinct()  去重
    # res = models.User.objects.values('name','age').distinct()
    # print(res)
    """
    去重一定要是一模一样的数据
    如果带有主键那么肯定不一样 你在往后的查询中一定不要忽略主键
    
    """
    # 9.order_by()
    # res = models.User.objects.order_by('age')  # 默认升序
    # res = models.User.objects.order_by('-age')  # 降序
    #
    # print(res)
    # 10.reverse()  反转的前提是 数据已经排过序了  order_by()
    # res = models.User.objects.all()
    # res1 = models.User.objects.order_by('age').reverse()
    # print(res,res1)

    # 11.count()  统计当前数据的个数
    # res = models.User.objects.count()
    # print(res)
    # 12.exclude()  排除在外
    # res = models.User.objects.exclude(name='jason')
    # print(res)

    # 13.exists()  基本用不到因为数据本身就自带布尔值  返回的是布尔值
    # res = models.User.objects.filter(pk=10).exists()
    # print(res)
    
=========================================================================================
Django测试脚本：

"""
当你只是想测试django中的某一个py文件内容 那么你可以不用书写前后端交互的形式
而是直接写一个测试脚本即可

脚本代码无论是写在应用下的tests.py还是自己单独开设py文件都可以
"""
# 测试环境的准备 去manage.py中拷贝前四行代码 然后自己写两行
import os
import sys

if __name__ == "__main__":
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "day64.settings")
    import django
    django.setup()
    # 在这个代码块的下面就可以测试django里面的单个py文件了
    
=========================================================================================
查看内部SQL语句的方式：
# 方式1
res = models.User.objects.values_list('name','age')  # <QuerySet [('jason', 18), ('egonPPP', 84)]>
print(res.query)
queryset对象才能够点击query查看内部的sql语句

# 方式2:所有的sql语句都能查看
# 去配置文件中配置一下即可
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console':{
            'level':'DEBUG',
            'class':'logging.StreamHandler',
        },
    },
    'loggers': {
        'django.db.backends': {
            'handlers': ['console'],
            'propagate': True,
            'level':'DEBUG',
        },
    }
}

=========================================================================================
神奇的双下划线查询
# 神奇的双下划线查询
    # 1 年龄大于35岁的数据
    # res = models.User.objects.filter(age__gt=35)
    # print(res)
    # 2 年龄小于35岁的数据
    # res = models.User.objects.filter(age__lt=35)
    # print(res)
    # 大于等于 小于等于
    # res = models.User.objects.filter(age__gte=32)
    # print(res)
    # res = models.User.objects.filter(age__lte=32)
    # print(res)

    # 年龄是18 或者 32 或者40
    # res = models.User.objects.filter(age__in=[18,32,40])
    # print(res)

    # 年龄在18到40岁之间的  首尾都要
    # res = models.User.objects.filter(age__range=[18,40])
    # print(res)

    # 查询出名字里面含有s的数据  模糊查询
    # res = models.User.objects.filter(name__contains='s')
    # print(res)
    #
    # 是否区分大小写  查询出名字里面含有p的数据  区分大小写
    # res = models.User.objects.filter(name__contains='p')
    # print(res)
    # 忽略大小写
    # res = models.User.objects.filter(name__icontains='p')
    # print(res)

    # res = models.User.objects.filter(name__startswith='j')
    # res1 = models.User.objects.filter(name__endswith='j')
    #
    # print(res,res1)


    # 查询出注册时间是 2020 1月
    # res = models.User.objects.filter(register_time__month='1')
    # res = models.User.objects.filter(register_time__year='2020')
    
    
=========================================================================================
一对多外键增删改查
# 一对多外键增删改查
    # 增
    # 1  直接写实际字段 id
    # models.Book.objects.create(title='论语',price=899.23,publish_id=1)
    # models.Book.objects.create(title='聊斋',price=444.23,publish_id=2)
    # models.Book.objects.create(title='老子',price=333.66,publish_id=1)
    # 2  虚拟字段 对象
    # publish_obj = models.Publish.objects.filter(pk=2).first()
    # models.Book.objects.create(title='红楼梦',price=666.23,publish=publish_obj)

    # 删
    # models.Publish.objects.filter(pk=1).delete()  # 级联删除

    # 修改
    # models.Book.objects.filter(pk=1).update(publish_id=2)
    # publish_obj = models.Publish.objects.filter(pk=1).first()
    # models.Book.objects.filter(pk=1).update(publish=publish_obj)
    
多对多外键增删改查
# 如何给书籍添加作者？
    book_obj = models.Book.objects.filter(pk=1).first()
    # print(book_obj.authors)  # 就类似于你已经到了第三张关系表了
    # book_obj.authors.add(1)  # 书籍id为1的书籍绑定一个主键为1 的作者
    # book_obj.authors.add(2,3)

    # author_obj = models.Author.objects.filter(pk=1).first()
    # author_obj1 = models.Author.objects.filter(pk=2).first()
    # author_obj2 = models.Author.objects.filter(pk=3).first()
    # book_obj.authors.add(author_obj)
    # book_obj.authors.add(author_obj1,author_obj2)
    """
    add给第三张关系表添加数据
        括号内既可以传数字也可以传对象 并且都支持多个
    """

    # 删
    # book_obj.authors.remove(2)
    # book_obj.authors.remove(1,3)

    # author_obj = models.Author.objects.filter(pk=2).first()
    # author_obj1 = models.Author.objects.filter(pk=3).first()
    # book_obj.authors.remove(author_obj,author_obj1)
    """
    remove
        括号内既可以传数字也可以传对象 并且都支持多个
    """


    # 修改
    # book_obj.authors.set([1,2])  # 括号内必须给一个可迭代对象
    # book_obj.authors.set([3])  # 括号内必须给一个可迭代对象

    # author_obj = models.Author.objects.filter(pk=2).first()
    # author_obj1 = models.Author.objects.filter(pk=3).first()
    # book_obj.authors.set([author_obj,author_obj1])  # 括号内必须给一个可迭代对象

    """
    set
        括号内必须传一个可迭代对象，该对象内既可以数字也可以对象 并且都支持多个
    """


    # 清空
    # 在第三张关系表中清空某个书籍与作者的绑定关系
    book_obj.authors.clear()
    """
    clear
        括号内不要加任何参数
    
    """
    
=========================================================================================
正反向的概念：
# 正向
# 反向
	外键字段在我手上那么，我查你就是正向
  外键字段如果不在手上，我查你就是反向
  
  book >>>外键字段在书那儿(正向)>>> publish
  publish	>>>外键字段在书那儿(反向)>>>book
  
  一对一和多对多正反向的判断也是如此
  
"""
正向查询按字段
反向查询按表名小写
				_set
				...
"""

=========================================================================================
多表查询
	子查询(基于对象的跨表查询)
# 1.查询书籍主键为1的出版社
    # book_obj = models.Book.objects.filter(pk=1).first()
    # # 书查出版社 正向
    # res = book_obj.publish
    # print(res)
    # print(res.name)
    # print(res.addr)

    # 2.查询书籍主键为2的作者
    # book_obj = models.Book.objects.filter(pk=2).first()
    # # 书查作者 正向
    # # res = book_obj.authors  # app01.Author.None
    # res = book_obj.authors.all()  # <QuerySet [<Author: Author object>, <Author: Author object>]>
    #
    # print(res)

    # 3.查询作者jason的电话号码
    # author_obj = models.Author.objects.filter(name='jason').first()
    # res = author_obj.author_detail
    # print(res)
    # print(res.phone)
    # print(res.addr)

    """
    在书写orm语句的时候跟写sql语句一样的
    不要企图一次性将orm语句写完 如果比较复杂 就写一点看一点
    
    正向什么时候需要加.all()
        当你的结果可能有多个的时候就需要加.all()
        如果是一个则直接拿到数据对象
            book_obj.publish
            book_obj.authors.all()
            author_obj.author_detail
    """
    # 4.查询出版社是东方出版社出版的书
    # publish_obj = models.Publish.objects.filter(name='东方出版社').first()
    # 出版社查书  反向
    # res = publish_obj.book_set  # app01.Book.None
    # res = publish_obj.book_set.all()
    # print(res)

    # 5.查询作者是jason写过的书
    # author_obj = models.Author.objects.filter(name='jason').first()
    # 作者查书      反向
    # res = author_obj.book_set  # app01.Book.None
    # res = author_obj.book_set.all()
    # print(res)

    # 6.查询手机号是110的作者姓名
    # author_detail_obj = models.AuthorDetail.objects.filter(phone=110).first()
    # res = author_detail_obj.author
    # print(res.name)
    """
    基于对象 
        反向查询的时候
            当你的查询结果可以有多个的时候 就必须加_set.all()
            当你的结果只有一个的时候 不需要加_set.all()
        自己总结出 自己方便记忆的即可 每个人都可以不一样
    """
========================================================================================= 
联表查询(基于双下划线的跨表查询)
# 基于双下划线的跨表查询


    # 1.查询jason的手机号和作者姓名
    # res = models.Author.objects.filter(name='jason').values('author_detail__phone','name')
    # print(res)
    # 反向
    # res = models.AuthorDetail.objects.filter(author__name='jason')  # 拿作者姓名是jason的作者详情
    # res = models.AuthorDetail.objects.filter(author__name='jason').values('phone','author__name')
    # print(res)


    # 2.查询书籍主键为1的出版社名称和书的名称
    # res = models.Book.objects.filter(pk=1).values('title','publish__name')
    # print(res)
    # 反向
    # res = models.Publish.objects.filter(book__id=1).values('name','book__title')
    # print(res)

    # 3.查询书籍主键为1的作者姓名
    # res = models.Book.objects.filter(pk=1).values('authors__name')
    # print(res)
    # 反向
    # res = models.Author.objects.filter(book__id=1).values('name')
    # print(res)


    # 查询书籍主键是1的作者的手机号
    # book author authordetail
    # res = models.Book.objects.filter(pk=1).values('authors__author_detail__phone')
    # print(res)
    """
    你只要掌握了正反向的概念
    以及双下划线
    那么你就可以无限制的跨表
    
    """
=========================================================================================
聚合查询：
# 聚合查询      aggregate
    """
    聚合查询通常情况下都是配合分组一起使用的
    只要是跟数据库相关的模块 
        基本上都在django.db.models里面
        如果上述没有那么应该在django.db里面
    """
    from app01 import models
    from django.db.models import Max,Min,Sum,Count,Avg
    # 1 所有书的平均价格
    # res = models.Book.objects.aggregate(Avg('price'))
    # print(res)
    # 2.上述方法一次性使用
    res = models.Book.objects.aggregate(Max('price'),Min('price'),Sum('price'),Count('pk'),Avg('price'))
    print(res)

=========================================================================================
分组查询
# 分组查询  annotate
    """
    MySQL分组查询都有哪些特点
        分组之后默认只能获取到分组的依据 组内其他字段都无法直接获取了
            严格模式
                ONLY_FULL_GROUP_BY
                
    """
    from django.db.models import Max, Min, Sum, Count, Avg
    # 1.统计每一本书的作者个数
    # res = models.Book.objects.annotate()  # models后面点什么 就是按什么分组
    # res = models.Book.objects.annotate(author_num=Count('authors')).values('title','author_num')
    """
    author_num是我们自己定义的字段 用来存储统计出来的每本书对应的作者个数
    """
    # res1 = models.Book.objects.annotate(author_num=Count('authors__id')).values('title','author_num')
    # print(res,res1)
    """
    代码没有补全 不要怕 正常写
    补全给你是pycharm给你的 到后面在服务器上直接书写代码 什么补全都没有 颜色提示也没有
    
    """

    # 2.统计每个出版社卖的最便宜的书的价格(作业:复习原生SQL语句 写出来)
    # res = models.Publish.objects.annotate(min_price=Min('book__price')).values('name','min_price')
    # print(res)

    # 3.统计不止一个作者的图书
        # 1.先按照图书分组 求每一本书对应的作者个数
        # 2.过滤出不止一个作者的图书
    # res = models.Book.objects.annotate(author_num=Count('authors')).filter(author_num__gt=1).values('title','author_num')
    # """
    # 只要你的orm语句得出的结果还是一个queryset对象
    # 那么它就可以继续无限制的点queryset对象封装的方法
    #
    # """
    # print(res)

    # 4.查询每个作者出的书的总价格
    # res = models.Author.objects.annotate(sum_price=Sum('book__price')).values('name','sum_price')
    # print(res)

    """
    如果我想按照指定的字段分组该如何处理呢？
        models.Book.objects.values('price').annotate()
    后续BBS作业会使用
    
    
    你们的机器上如果出现分组查询报错的情况
        你需要修改数据库严格模式
    """
=========================================================================================
F与Q查询
# F查询
    # 1.查询卖出数大于库存数的书籍
    # F查询
    """
    能够帮助你直接获取到表中某个字段对应的数据
    """
    from django.db.models import F
    # res = models.Book.objects.filter(maichu__gt=F('kucun'))
    # print(res)


    # 2.将所有书籍的价格提升500块
    # models.Book.objects.update(price=F('price') + 500)


    # 3.将所有书的名称后面加上爆款两个字
    """
    在操作字符类型的数据的时候 F不能够直接做到字符串的拼接
    """
    from django.db.models.functions import Concat
    from django.db.models import Value
    models.Book.objects.update(title=Concat(F('title'), Value('爆款')))
    # models.Book.objects.update(title=F('title') + '爆款')  # 所有的名称会全部变成空白

# Q查询
    # 1.查询卖出数大于100或者价格小于600的书籍
    # res = models.Book.objects.filter(maichu__gt=100,price__lt=600)
    """filter括号内多个参数是and关系"""
    from django.db.models import Q
    # res = models.Book.objects.filter(Q(maichu__gt=100),Q(price__lt=600))  # Q包裹逗号分割 还是and关系
    # res = models.Book.objects.filter(Q(maichu__gt=100)|Q(price__lt=600))  # | or关系
    # res = models.Book.objects.filter(~Q(maichu__gt=100)|Q(price__lt=600))  # ~ not关系
    # print(res)  # <QuerySet []>

    # Q的高阶用法  能够将查询条件的左边也变成字符串的形式
    q = Q()
    q.connector = 'or'
    q.children.append(('maichu__gt',100))
    q.children.append(('price__lt',600))
    res = models.Book.objects.filter(q)  # 默认还是and关系
    print(res)
    
=========================================================================================
Django开启事务

"""
事务
	ACID
		原子性
			不可分割的最小单位
		一致性
			跟原子性是相辅相成
		隔离性
			事务之间互相不干扰
		持久性
			事务一旦确认永久生效
	
	事务的回滚 
		rollback
	事务的确认
		commit
"""
# 目前你只需要掌握Django中如何简单的开启事务
# 事务
    from django.db import transaction
    try:
        with transaction.atomic():
            # sql1
            # sql2
            ...
            # 在with代码快内书写的所有orm操作都是属于同一个事务
    except Exception as e:
        print(e)
    print('执行其他操作')
    
=========================================================================================
ORM中常用字段及参数

AutoField
	主键字段 primary_key=True
  
CharField				varchar
	verbose_name	字段的注释
  max_length		长度
  
IntegerField			int
BigIntegerField		bigint

DecimalField
	max_digits=8
  decimal_places=2

EmailFiled				varchar(254)

DateField					date
DateTimeField			datetime
	auto_now:每次修改数据的时候都会自动更新当前时间
  auto_now_add:只在创建数据的时候记录创建时间后续不会自动修改了
    
BooleanField(Field)				- 布尔值类型
	该字段传布尔值(False/True) 	数据库里面存0/1

TextField(Field)					- 文本类型
	该字段可以用来存大段内容(文章、博客...)  没有字数限制
  后面的bbs作业 文章字段用的就是TextField


FileField(Field)					- 字符类型
   upload_to = "/data"
  给该字段传一个文件对象，会自动将文件保存到/data目录下然后将文件路径保存到数据库中
  /data/a.txt
  后面bbs作业也会涉及

# 更多字段
直接参考博客:https://www.cnblogs.com/Dominic-Ji/p/9203990.html

    
# django除了给你提供了很多字段类型之外 还支持你自定义字段
class MyCharField(models.Field):
    def __init__(self,max_length,*args,**kwargs):
        self.max_length = max_length
        # 调用父类的init方法
        super().__init__(max_length=max_length,*args,**kwargs)  # 一定要是关键字的形式传入

    def db_type(self, connection):
        """
        返回真正的数据类型及各种约束条件
        :param connection:
        :return:
        """
        return 'char(%s)'%self.max_length

# 自定义字段使用
myfield = MyCharField(max_length=16,null=True)



# 外键字段及参数
unique=True
	ForeignKey(unique=True)   ===			OneToOneField()
  # 你在用前面字段创建一对一 orm会有一个提示信息 orm推荐你使用后者但是前者也能用
  
db_index
	如果db_index=True 则代表着为此字段设置索引
  (复习索引是什么)

to_field
	设置要关联的表的字段  默认不写关联的就是另外一张的主键字段

on_delete
	当删除关联表中的数据时，当前表与其关联的行的行为。
  """
  django2.X及以上版本 需要你自己指定外键字段的级联更新级联删除
  """

=========================================================================================
数据库查询优化
only与defer	
select_related与prefetch_related

"""
orm语句的特点:
	惰性查询
		如果你仅仅只是书写了orm语句 在后面根本没有用到该语句所查询出来的参数
		那么orm会自动识别 直接不执行
"""
# only与defer
# res = models.Book.objects.all()
    # print(res)  # 要用数据了才会走数据库

    # 想要获取书籍表中所有数的名字
    # res = models.Book.objects.values('title')
    # for d in res:
    #     print(d.get('title'))
    # 你给我实现获取到的是一个数据对象 然后点title就能够拿到书名 并且没有其他字段
    # res = models.Book.objects.only('title')
    # res = models.Book.objects.all()
    # print(res)  # <QuerySet [<Book: 三国演义爆款>, <Book: 红楼梦爆款>, <Book: 论语爆款>, <Book: 聊斋爆款>, <Book: 老子爆款>]>
    # for i in res:
        # print(i.title)  # 点击only括号内的字段 不会走数据库
        # print(i.price)  # 点击only括号内没有的字段 会重新走数据库查询而all不需要走了

    res = models.Book.objects.defer('title')  # 对象除了没有title属性之外其他的都有
    for i in res:
        print(i.price)
    """
    defer与only刚好相反
        defer括号内放的字段不在查询出来的对象里面 查询该字段需要重新走数据
        而如果查询的是非括号内的字段 则不需要走数据库了

    """
    

# select_related与prefetch_related
# select_related与prefetch_related  跟跨表操作有关
    # res = models.Book.objects.all()
    # for i in res:
    #     print(i.publish.name)  # 每循环一次就要走一次数据库查询

    # res = models.Book.objects.select_related('authors')  # INNER JOIN
    """
    select_related内部直接先将book与publish连起来 然后一次性将大表里面的所有数据
    全部封装给查询出来的对象
        这个时候对象无论是点击book表的数据还是publish的数据都无需再走数据库查询了
    
    select_related括号内只能放外键字段    一对多 一对一
        多对多也不行
    
    """
    # for i in res:
    #     print(i.publish.name)  # 每循环一次就要走一次数据库查询

    res = models.Book.objects.prefetch_related('publish')  # 子查询
    """
    prefetch_related该方法内部其实就是子查询
        将子查询查询出来的所有结果也给你封装到对象中
        给你的感觉好像也是一次性搞定的
    """
    for i in res:
        print(i.publish.name)
        
=========================================================================================
choices参数(数据库字段设计常见)
"""
用户表	
	性别
	学历
	工作经验
	是否结婚
	是否生子
	客户来源
	...
针对某个可以列举完全的可能性字段，我们应该如何存储

只要某个字段的可能性是可以列举完全的，那么一般情况下都会采用choices参数
"""
class User(models.Model):
    username = models.CharField(max_length=32)
    age = models.IntegerField()
    # 性别
    gender_choices = (
        (1,'男'),
        (2,'女'),
        (3,'其他'),
    )
    gender = models.IntegerField(choices=gender_choices)
    
    score_choices = (
        ('A','优秀'),
        ('B','良好'),
        ('C','及格'),
        ('D','不合格'),
    )
    # 保证字段类型跟列举出来的元祖第一个数据类型一致即可
    score = models.CharField(choices=score_choices,null=True)
    """
    该gender字段存的还是数字 但是如果存的数字在上面元祖列举的范围之内
    那么可以非常轻松的获取到数字对应的真正的内容
    
    1.gender字段存的数字不在上述元祖列举的范围内容
    2.如果在 如何获取对应的中文信息
    """
    
      
    from app01 import models
    # models.User.objects.create(username='jason',age=18,gender=1)
    # models.User.objects.create(username='egon',age=85,gender=2)
    # models.User.objects.create(username='tank',age=40,gender=3)
    # 存的时候 没有列举出来的数字也能存（范围还是按照字段类型决定）
    # models.User.objects.create(username='tony',age=45,gender=4)

    # 取
    # user_obj = models.User.objects.filter(pk=1).first()
    # print(user_obj.gender)
    # 只要是choices参数的字段 如果你想要获取对应信息 固定写法 get_字段名_display()
    # print(user_obj.get_gender_display())

    user_obj = models.User.objects.filter(pk=4).first()
    # 如果没有对应关系 那么字段是什么还是展示什么
    print(user_obj.get_gender_display())  # 4
    
 
# 实际项目案例
# CRM相关内部表
class School(models.Model):
    """
    校区表
    如：
        北京沙河校区
        上海校区

    """
    title = models.CharField(verbose_name='校区名称', max_length=32)

    def __str__(self):
        return self.title

class Course(models.Model):
    """
    课程表
    如：
        Linux基础
        Linux架构师
        Python自动化开发精英班
        Python自动化开发架构师班
        Python基础班
        go基础班
    """
    name = models.CharField(verbose_name='课程名称', max_length=32)

    def __str__(self):
        return self.name

class Department(models.Model):
    """
    部门表
    市场部     1000
    销售       1001

    """
    title = models.CharField(verbose_name='部门名称', max_length=16)
    code = models.IntegerField(verbose_name='部门编号', unique=True, null=False)

    def __str__(self):
        return self.title

class UserInfo(models.Model):
    """
    员工表
    """

    name = models.CharField(verbose_name='员工姓名', max_length=16)
    email = models.EmailField(verbose_name='邮箱', max_length=64)
    depart = models.ForeignKey(verbose_name='部门', to="Department",to_field="code")
    user=models.OneToOneField("User",default=1)
    def __str__(self):
        return self.name

class ClassList(models.Model):
    """
    班级表
    如：
        Python全栈  面授班  5期  10000  2017-11-11  2018-5-11
    """
    school = models.ForeignKey(verbose_name='校区', to='School')
    course = models.ForeignKey(verbose_name='课程名称', to='Course')
    semester = models.IntegerField(verbose_name="班级(期)")


    price = models.IntegerField(verbose_name="学费")
    start_date = models.DateField(verbose_name="开班日期")
    graduate_date = models.DateField(verbose_name="结业日期", null=True, blank=True)
    memo = models.CharField(verbose_name='说明', max_length=256, blank=True, null=True, )

    teachers = models.ManyToManyField(verbose_name='任课老师', to='UserInfo',limit_choices_to={'depart':1002})
    tutor = models.ForeignKey(verbose_name='班主任', to='UserInfo',related_name="class_list",limit_choices_to={'depart':1006})


    def __str__(self):
        return "{0}({1}期)".format(self.course.name, self.semester)


class Customer(models.Model):
    """
    客户表
    """
    qq = models.CharField(verbose_name='qq', max_length=64, unique=True, help_text='QQ号必须唯一')

    name = models.CharField(verbose_name='学生姓名', max_length=16)
    gender_choices = ((1, '男'), (2, '女'))
    gender = models.SmallIntegerField(verbose_name='性别', choices=gender_choices)

    education_choices = (
        (1, '重点大学'),
        (2, '普通本科'),
        (3, '独立院校'),
        (4, '民办本科'),
        (5, '大专'),
        (6, '民办专科'),
        (7, '高中'),
        (8, '其他')
    )
    education = models.IntegerField(verbose_name='学历', choices=education_choices, blank=True, null=True, )
    graduation_school = models.CharField(verbose_name='毕业学校', max_length=64, blank=True, null=True)
    major = models.CharField(verbose_name='所学专业', max_length=64, blank=True, null=True)

    experience_choices = [
        (1, '在校生'),
        (2, '应届毕业'),
        (3, '半年以内'),
        (4, '半年至一年'),
        (5, '一年至三年'),
        (6, '三年至五年'),
        (7, '五年以上'),
    ]
    experience = models.IntegerField(verbose_name='工作经验', blank=True, null=True, choices=experience_choices)
    work_status_choices = [
        (1, '在职'),
        (2, '无业')
    ]
    work_status = models.IntegerField(verbose_name="职业状态", choices=work_status_choices, default=1, blank=True,
                                      null=True)
    company = models.CharField(verbose_name="目前就职公司", max_length=64, blank=True, null=True)
    salary = models.CharField(verbose_name="当前薪资", max_length=64, blank=True, null=True)

    source_choices = [
        (1, "qq群"),
        (2, "内部转介绍"),
        (3, "官方网站"),
        (4, "百度推广"),
        (5, "360推广"),
        (6, "搜狗推广"),
        (7, "腾讯课堂"),
        (8, "广点通"),
        (9, "高校宣讲"),
        (10, "渠道代理"),
        (11, "51cto"),
        (12, "智汇推"),
        (13, "网盟"),
        (14, "DSP"),
        (15, "SEO"),
        (16, "其它"),
    ]
    source = models.SmallIntegerField('客户来源', choices=source_choices, default=1)
    referral_from = models.ForeignKey(
        'self',
        blank=True,
        null=True,
        verbose_name="转介绍自学员",
        help_text="若此客户是转介绍自内部学员,请在此处选择内部学员姓名",
        related_name="internal_referral"
    )
    course = models.ManyToManyField(verbose_name="咨询课程", to="Course")

    status_choices = [
        (1, "已报名"),
        (2, "未报名")
    ]
    status = models.IntegerField(
        verbose_name="状态",
        choices=status_choices,
        default=2,
        help_text=u"选择客户此时的状态"
    )

    consultant = models.ForeignKey(verbose_name="课程顾问", to='UserInfo', related_name='consultanter',limit_choices_to={'depart':1001})

    date = models.DateField(verbose_name="咨询日期", auto_now_add=True)
    recv_date = models.DateField(verbose_name="当前课程顾问的接单日期", null=True)
    last_consult_date = models.DateField(verbose_name="最后跟进日期", )

    def __str__(self):
        return self.name

class ConsultRecord(models.Model):
    """
    客户跟进记录
    """
    customer = models.ForeignKey(verbose_name="所咨询客户", to='Customer')
    consultant = models.ForeignKey(verbose_name="跟踪人", to='UserInfo',limit_choices_to={'depart':1001})
    date = models.DateField(verbose_name="跟进日期", auto_now_add=True)
    note = models.TextField(verbose_name="跟进内容...")

    def __str__(self):
        return self.customer.name + ":" + self.consultant.name

class Student(models.Model):
    """
    学生表（已报名）
    """
    customer = models.OneToOneField(verbose_name='客户信息', to='Customer')
    class_list = models.ManyToManyField(verbose_name="已报班级", to='ClassList', blank=True)

    emergency_contract = models.CharField(max_length=32, blank=True, null=True, verbose_name='紧急联系人')
    company = models.CharField(verbose_name='公司', max_length=128, blank=True, null=True)
    location = models.CharField(max_length=64, verbose_name='所在区域', blank=True, null=True)
    position = models.CharField(verbose_name='岗位', max_length=64, blank=True, null=True)
    salary = models.IntegerField(verbose_name='薪资', blank=True, null=True)
    welfare = models.CharField(verbose_name='福利', max_length=256, blank=True, null=True)
    date = models.DateField(verbose_name='入职时间', help_text='格式yyyy-mm-dd', blank=True, null=True)
    memo = models.CharField(verbose_name='备注', max_length=256, blank=True, null=True)

    def __str__(self):
        return self.customer.name

class ClassStudyRecord(models.Model):
    """
    上课记录表 （班级记录）
    """
    class_obj = models.ForeignKey(verbose_name="班级", to="ClassList")
    day_num = models.IntegerField(verbose_name="节次", help_text=u"此处填写第几节课或第几天课程...,必须为数字")
    teacher = models.ForeignKey(verbose_name="讲师", to='UserInfo',limit_choices_to={'depart':1002})
    date = models.DateField(verbose_name="上课日期", auto_now_add=True)

    course_title = models.CharField(verbose_name='本节课程标题', max_length=64, blank=True, null=True)
    course_memo = models.TextField(verbose_name='本节课程内容概要', blank=True, null=True)
    has_homework = models.BooleanField(default=True, verbose_name="本节有作业")
    homework_title = models.CharField(verbose_name='本节作业标题', max_length=64, blank=True, null=True)
    homework_memo = models.TextField(verbose_name='作业描述', max_length=500, blank=True, null=True)
    exam = models.TextField(verbose_name='踩分点', max_length=300, blank=True, null=True)

    def __str__(self):
        return "{0} day{1}".format(self.class_obj, self.day_num)

class StudentStudyRecord(models.Model):
    '''
    学生学习记录
    '''
    classstudyrecord = models.ForeignKey(verbose_name="第几天课程", to="ClassStudyRecord")
    student = models.ForeignKey(verbose_name="学员", to='Student')







    record_choices = (('checked', "已签到"),
                      ('vacate', "请假"),
                      ('late', "迟到"),
                      ('noshow', "缺勤"),
                      ('leave_early', "早退"),
                      )
    record = models.CharField("上课纪录", choices=record_choices, default="checked", max_length=64)
    score_choices = ((100, 'A+'),
                     (90, 'A'),
                     (85, 'B+'),
                     (80, 'B'),
                     (70, 'B-'),
                     (60, 'C+'),
                     (50, 'C'),
                     (40, 'C-'),
                     (0, ' D'),
                     (-1, 'N/A'),
                     (-100, 'COPY'),
                     (-1000, 'FAIL'),
                     )
    score = models.IntegerField("本节成绩", choices=score_choices, default=-1)
    homework_note = models.CharField(verbose_name='作业评语', max_length=255, blank=True, null=True)
    note = models.CharField(verbose_name="备注", max_length=255, blank=True, null=True)

    homework = models.FileField(verbose_name='作业文件', blank=True, null=True, default=None)
    stu_memo = models.TextField(verbose_name='学员备注', blank=True, null=True)
    date = models.DateTimeField(verbose_name='提交作业日期', auto_now_add=True)

    def __str__(self):
        return "{0}-{1}".format(self.classstudyrecord, self.student)
         
"""
chocies参数使用场景是非常广泛的
"""

=========================================================================================
MTV与MVC模型
# MTV:Django号称是MTV模型
M:models
T:templates
V:views
# MVC:其实django本质也是MVC
M:models
V:views
C:controller
  
# vue框架:MVVM模型

=========================================================================================
多对多三种创建方式：
# 全自动:利用orm自动帮我们创建第三张关系表
	class Book(models.Model):
    name = models.CharField(max_length=32)
    authors = models.ManyToManyField(to='Author')
	class Author(models.Model):
    name = models.CharField(max_length=32)
	"""
	优点:代码不需要你写 非常的方便 还支持orm提供操作第三张关系表的方法...
	不足之处:第三张关系表的扩展性极差(没有办法额外添加字段...)
	"""
# 纯手动
	class Book(models.Model):
    name = models.CharField(max_length=32)
    
	class Author(models.Model):
    name = models.CharField(max_length=32)
  
  class Book2Author(models.Model):
    book_id = models.ForeignKey(to='Book')
    author_id = models.ForeignKey(to='Author')
  '''
  优点:第三张表完全取决于你自己进行额外的扩展
  不足之处:需要写的代码较多，不能够再使用orm提供的简单的方法
  不建议你用该方式
  '''

# 半自动
class Book(models.Model):
    name = models.CharField(max_length=32)
    authors = models.ManyToManyField(to='Author',
                                     through='Book2Author',
                                     through_fields=('book','author')
                                     )
class Author(models.Model):
    name = models.CharField(max_length=32)
    # books = models.ManyToManyField(to='Book',
    #                                  through='Book2Author',
    #                                  through_fields=('author','book')
    #                                  )
class Book2Author(models.Model):
    book = models.ForeignKey(to='Book')
    author = models.ForeignKey(to='Author')

"""
through_fields字段先后顺序
    判断的本质：
        通过第三张表查询对应的表 需要用到哪个字段就把哪个字段放前面
    你也可以简化判断
        当前表是谁 就把对应的关联字段放前面
        
        
半自动:可以使用orm的正反向查询 但是没法使用add,set,remove,clear这四个方法
"""

# 总结:你需要掌握的是全自动和半自动 为了扩展性更高 一般我们都会采用半自动(写代码要给自己留一条后路)



```



## 批量插入数据

```python
def ab_pl(request):
    # 先给Book插入一万条数据
    # for i in range(10000):
    #     models.Book.objects.create(title='第%s本书'%i)
    # # 再将所有的数据查询并展示到前端页面
    book_queryset = models.Book.objects.all()

    # 批量插入
    # book_list = []
    # for i in range(100000):
    #     book_obj = models.Book(title='第%s本书'%i)
    #     book_list.append(book_obj)
    # models.Book.objects.bulk_create(book_list)
    """
    当你想要批量插入数据的时候 使用orm给你提供的bulk_create能够大大的减少操作时间
    :param request: 
    :return: 
    """
    return render(request,'ab_pl.html',locals())
```

## 自定义分页器

```python
"""
总数据100 每页展示10 需要10
总数据101 每页展示10 需要11
总数据99 每页展示10  需要10

如何通过代码动态的计算出到底需要多少页？


在制作页码个数的时候 一般情况下都是奇数个		符合中国人对称美的标准
"""
# 分页
    book_list = models.Book.objects.all()

    # 想访问哪一页
    current_page = request.GET.get('page',1)  # 如果获取不到当前页码 就展示第一页
    # 数据类型转换
    try:
        current_page = int(current_page)
    except Exception:
        current_page = 1
    # 每页展示多少条
    per_page_num = 10
    # 起始位置
    start_page = (current_page - 1) * per_page_num
    # 终止位置
    end_page = current_page * per_page_num

    # 计算出到底需要多少页
    all_count = book_list.count()

    page_count, more = divmod(all_count, per_page_num)
    if more:
        page_count += 1

    page_html = ''
    xxx = current_page
    if current_page < 6:
        current_page = 6
    for i in range(current_page-5,current_page+6):
        if xxx == i:
            page_html += '<li class="active"><a href="?page=%s">%s</a></li>'%(i,i)
        else:
            page_html += '<li><a href="?page=%s">%s</a></li>'%(i,i)



    book_queryset =  book_list[start_page:end_page]
    
"""
django中有自带的分页器模块 但是书写起来很麻烦并且功能太简单
所以我们自己想法和设法的写自定义分页器

上述推导代码你无需掌握 只需要知道内部逻辑即可

我们基于上述的思路 已经封装好了我们自己的自定义分页器 
之后需要使用直接拷贝即可
"""

"""
django也有内置的分页器模块 但是功能较少代码繁琐不便于使用
所以我们自己自定义我们自己的分页器
"""
1.queryset对象是直接切片操作的
2.用户到底要访问哪一页 如何确定?		url?page=1
	current_page = request.GET.get('page',1)
  # 获取到的数据都是字符串类型 你需要注意类型转换
3.自己规定每页展示多少条数据
	per_page_num = 10
4.切片的起始位置和终止位置
	start_page = （current_page - 1）* per_page_num
  end_page = current_page * per_page_num
  # 利用简单找规律 找出上述四个参数的规律
5.当前数据的总条数
	book_queryset.count()
6.如何确定总共需要多少页才能展示完所有的数据
	# 利用python内置函数divmod()
  page_count, more = divmod(all_count,per_page_num)
  if more:
    page_count += 1
7.前端模版语法是没有range功能的
	# 前端代码不一定非要在前端书写 也可以在后端生成传递给页面
8.针对需要展示的页码需要你自己规划好到底展示多少个页码
	# 一般情况下页码的个数设计都是奇数(符合审美标准)  11个页码
  当前页减5
  当前页加6
  你可以给标签价样式从而让选中的页码高亮显示
9.针对页码小于6的情况 你需要做处理 不能再减

自定义分页器推导到第九部就可以 无需你继续推到了 代码也无需掌握

=========================================================================================
自定义分页器的拷贝及使用
"""
当我们需要使用到非django内置的第三方功能或者组件代码的时候
我们一般情况下会创建一个名为utils文件夹 在该文件夹内对模块进行功能性划分
	utils可以在每个应用下创建 具体结合实际情况

我们到了后期封装代码的时候 不再局限于函数
还是尽量朝面向对象去封装

我们自定义的分页器是基于bootstrap样式来的 所以你需要提前导入bootstrap
	bootstrap 版本 v3
	jQuery		版本 v3
"""
# 后端
book_queryset = models.Book.objects.all()
current_page = request.GET.get('page',1)
all_count = book_queryset.count()
# 1 传值生成对象
page_obj = Pagination(current_page=current_page,all_count=all_count)
# 2 直接对总数据进行切片操作
page_queryset = book_queryset[page_obj.start:page_obj.end]
# 3 将page_queryset传递到页面 替换之前的book_queryset


# 前端
{% for book_obj in page_queryset %}
    <p>{{ book_obj.title }}</p>
    <nav aria-label="Page navigation">
</nav>
{% endfor %}
{#利用自定义分页器直接显示分页器样式#}
{{ page_obj.page_html|safe }}
  
"""
你们只需要掌握如何拷贝使用 以及大致的推导思路即可
"""
    
    

```

## form组件

```python
前夕

"""
写一个注册功能
	获取用户名和密码 利用form表单提交数据
	在后端判断用户名和密码是否符合一定的条件
		用户名中不能含有金瓶梅
		密码不能少于三位
	
	如何符合条件需要你将提示信息展示到前端页面
"""
def ab_form(request):
    back_dic = {'username':'','password':''}
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        if '金瓶梅' in username:
            back_dic['username'] = '不符合社会主义核心价值观'
        if len(password) < 3:
            back_dic['password'] = '不能太短 不好!'
    """
    无论是post请求还是get请求
    页面都能够获取到字典 只不过get请求来的时候 字典值都是空的
    而post请求来之后 字典可能有值
    """
    return render(request,'ab_form.html',locals())

<form action="" method="post">
    <p>username:
        <input type="text" name="username">
        <span style="color: red">{{ back_dic.username }}</span>
    </p>
    <p>password:
        <input type="text" name="password">
        <span style="color: red">{{ back_dic.password }}</span>
    </p>
    <input type="submit" class="btn btn-info">
</form>


"""
1.手动书写前端获取用户数据的html代码						渲染html代码
2.后端对用户数据进行校验											 校验数据
3.对不符合要求的数据进行前端提示								展示提示信息

forms组件
	能够完成的事情
			1.渲染html代码
			2.校验数据
			3.展示提示信息

为什么数据校验非要去后端 不能在前端利用js直接完成呢？
	数据校验前端可有可无
	但是后端必须要有!!!
	
	因为前端的校验是弱不禁风的 你可以直接修改
	或者利用爬虫程序绕过前端页面直接朝后端提交数据
	
	购物网站	
		选取了货物之后 会计算一个价格发送给后端 如果后端不做价格的校验
		
		实际是获取到用户选择的所有商品的主键值
		然后在后端查询出所有商品的价格 再次计算一遍
		如果跟前端一致 那么完成支付如果不一致直接拒绝
"""

=========================================================================================
基本使用：
from django import forms


class MyForm(forms.Form):
    # username字符串类型最小3位最大8位
    username = forms.CharField(min_length=3,max_length=8)
    # password字符串类型最小3位最大8位
    password = forms.CharField(min_length=3,max_length=8)
    # email字段必须符合邮箱格式  xxx@xx.com
    email = forms.EmailField()
    
=========================================================================================
校验数据：
"""
1.测试环境的准备 可以自己拷贝代码准备
2.其实在pycharm里面已经帮你准备一个测试环境
	python console
"""
from app01 import views
# 1 将带校验的数据组织成字典的形式传入即可
form_obj = views.MyForm({'username':'jason','password':'123','email':'123'})
# 2 判断数据是否合法		注意该方法只有在所有的数据全部合法的情况下才会返回True
form_obj.is_valid()
False
# 3 查看所有校验通过的数据
form_obj.cleaned_data
{'username': 'jason', 'password': '123'}
# 4 查看所有不符合校验规则以及不符合的原因
form_obj.errors
{
  'email': ['Enter a valid email address.']
}
# 5 校验数据只校验类中出现的字段 多传不影响 多传的字段直接忽略
form_obj = views.MyForm({'username':'jason','password':'123','email':'123@qq.com','hobby':'study'})
form_obj.is_valid()
True
# 6 校验数据 默认情况下 类里面所有的字段都必须传值
form_obj = views.MyForm({'username':'jason','password':'123'})
form_obj.is_valid()
False
"""
也就意味着校验数据的时候 默认情况下数据可以多传但是绝不可能少传
"""

=========================================================================================
渲染标签
"""
forms组件只会自动帮你渲染获取用户输入的标签(input select radio checkbox)
不能帮你渲染提交按钮
"""
def index(request):
    # 1 先产生一个空对象
    form_obj = MyForm()
    # 2 直接将该空对象传递给html页面
    return render(request,'index.html',locals())

# 前端利用空对象做操作
    <p>第一种渲染方式:代码书写极少，封装程度太高 不便于后续的扩展 一般情况下只在本地测试使用</p>
    {{ form_obj.as_p }}
    {{ form_obj.as_ul }}
    {{ form_obj.as_table }}
    <p>第二种渲染方式:可扩展性很强 但是需要书写的代码太多  一般情况下不用</p>
    <p>{{ form_obj.username.label }}:{{ form_obj.username }}</p>
    <p>{{ form_obj.password.label }}:{{ form_obj.password }}</p>
    <p>{{ form_obj.email.label }}:{{ form_obj.email }}</p>
    <p>第三种渲染方式(推荐使用):代码书写简单 并且扩展性也高</p>
    {% for form in form_obj %}
        <p>{{ form.label }}:{{ form }}</p>
    {% endfor %}
 
"""
label属性默认展示的是类中定义的字段首字母大写的形式
也可以自己修改 直接给字段对象加label属性即可
	 username = forms.CharField(min_length=3,max_length=8,label='用户名')
"""

=========================================================================================

展示提示信息
"""
浏览器会自动帮你校验数据 但是前端的校验弱不禁风
如何让浏览器不做校验
	<form action="" method="post" novalidate>
"""
def index(request):
    # 1 先产生一个空对象
    form_obj = MyForm()
    if request.method == 'POST':
        # 获取用户数据并且校验
        """
        1.数据获取繁琐
        2.校验数据需要构造成字典的格式传入才行
        ps:但是request.POST可以看成就是一个字典
        """
        # 3.校验数据
        form_obj = MyForm(request.POST)
        # 4.判断数据是否合法
        if form_obj.is_valid():
            # 5.如果合法 操作数据库存储数据
            return HttpResponse('OK')
        # 5.不合法 有错误
    # 2 直接将该空对象传递给html页面
    return render(request,'index.html',locals())

{% for form in form_obj %}
        <p>
            {{ form.label }}:{{ form }}
            <span style="color: red">{{ form.errors.0 }}</span>
        </p>
{% endfor %}

"""
1.必备的条件 get请求和post传给html页面对象变量名必须一样
2.forms组件当你的数据不合法的情况下 会保存你上次的数据 让你基于之前的结果进行修改
更加的人性化
"""
# 针对错误的提示信息还可以自己自定制
class MyForm(forms.Form):
    # username字符串类型最小3位最大8位
    username = forms.CharField(min_length=3,max_length=8,label='用户名',
                               error_messages={
                                   'min_length':'用户名最少3位',
                                   'max_length':'用户名最大8位',
                                   'required':"用户名不能为空"
                               }
                               )
    # password字符串类型最小3位最大8位
    password = forms.CharField(min_length=3,max_length=8,label='密码',
                               error_messages={
                                   'min_length': '密码最少3位',
                                   'max_length': '密码最大8位',
                                   'required': "密码不能为空"
                               }
                               )
    # email字段必须符合邮箱格式  xxx@xx.com
    email = forms.EmailField(label='邮箱',
                             error_messages={
                                 'invalid':'邮箱格式不正确',
                                 'required': "邮箱不能为空"
                             }
                             )


=========================================================================================
钩子函数
"""
在特定的节点自动触发完成响应操作

钩子函数在forms组件中就类似于第二道关卡，能够让我们自定义校验规则

在forms组件中有两类钩子
	1.局部钩子
		当你需要给单个字段增加校验规则的时候可以使用
	2.全局钩子
  	当你需要给多个字段增加校验规则的时候可以使用
"""
# 实际案例

# 1.校验用户名中不能含有666				只是校验username字段  局部钩子

# 2.校验密码和确认密码是否一致			password confirm两个字段	全局钩子

# 钩子函数  在类里面书写方法即可
    # 局部钩子
    def clean_username(self):
        # 获取到用户名
        username = self.cleaned_data.get('username')
        if '666' in username:
            # 提示前端展示错误信息
            self.add_error('username','光喊666是不行滴～')
        # 将钩子函数钩去出来数据再放回去
        return username

    # 全局钩子
    def clean(self):
        password = self.cleaned_data.get('password')
        confirm_password = self.cleaned_data.get('confirm_password')
        if not confirm_password == password:
            self.add_error('confirm_password','两次密码不一致')
        # 将钩子函数钩出来数据再放回去
        return self.cleaned_data
    
=========================================================================================
forms组件其他参数及补充知识点
label		字段名
error_messages  自定义报错信息
initial  默认值
required  控制字段是否必填
"""
1.字段没有样式
2.针对不同类型的input如何修改
	text
	password
	date
	radio
	checkbox
	...
"""
widget=forms.widgets.PasswordInput(attrs={'class':'form-control c1 c2'})
# 多个属性值的话 直接空格隔开即可

# 第一道关卡里面还支持正则校验
validators=[
            RegexValidator(r'^[0-9]+$', '请输入数字'),
            RegexValidator(r'^159[0-9]+$', '数字必须以159开头')
        ]

其它类型渲染

# radio
    gender = forms.ChoiceField(
        choices=((1, "男"), (2, "女"), (3, "保密")),
        label="性别",
        initial=3,
        widget=forms.widgets.RadioSelect()
    )
    # select
    hobby = forms.ChoiceField(
        choices=((1, "篮球"), (2, "足球"), (3, "双色球"),),
        label="爱好",
        initial=3,
        widget=forms.widgets.Select()
    )
    # 多选
    hobby1 = forms.MultipleChoiceField(
        choices=((1, "篮球"), (2, "足球"), (3, "双色球"),),
        label="爱好",
        initial=[1, 3],
        widget=forms.widgets.SelectMultiple()
    )
    # 单选checkbox
    keep = forms.ChoiceField(
        label="是否记住密码",
        initial="checked",
        widget=forms.widgets.CheckboxInput()
    )
    # 多选checkbox
    hobby2 = forms.MultipleChoiceField(
        choices=((1, "篮球"), (2, "足球"), (3, "双色球"),),
        label="爱好",
        initial=[1, 3],
        widget=forms.widgets.CheckboxSelectMultiple()
    )

=========================================================================================
forms组件源码
"""
切入点:
	form_obj.is_valid()
"""
def is_valid(self):
        """
        Returns True if the form has no errors. Otherwise, False. If errors are
        being ignored, returns False.
        """
   return self.is_bound and not self.errors
   # 如果is_valid要返回True的话 那么self.is_bound要为True self.errors要为Flase
  
  
self.is_bound = data is not None or files is not None  # 只要你传值了肯定为True


@property
def errors(self):
        "Returns an ErrorDict for the data provided for the form"
        if self._errors is None:
            self.full_clean()
        return self._errors

# forms组件所有的功能基本都出自于该方法
def full_clean(self):
  	self._clean_fields()  # 校验字段 + 局部钩子
    self._clean_form()  # 全局钩子
    self._post_clean()  
    
    


```

## Django中间件

```python
什么是中间件：
	中间件是一个用来处理Django的请求和响应的框架级别的钩子。它是一个轻量、低级别的插件系统，用于在全局范围内改变Django的输入和输出。每个中间件组件都负责做一些特定的功能。
    中间件影响的是全局，所以需要谨慎使用，使用不当可能会影响性能

	MIDDLEWARE配置项是一个列表(列表是有序的)，列表中是一个个字符串，这些字符串其实是一个个类，也就是一个个中间件。

自定义中间件方法：
	process_request(self,request)
    process_view(self, request, view_func, view_args, view_kwargs)
    process_template_response(self,request,response)
    process_exception(self, request, exception)
    process_response(self, request, response)
如何自定义中间件：
	1.在项目名或者应用名下创建一个任意名称的文件夹
    2.在该文件夹内创建一个任意名称的py文件
    3.在该py文件内需要书写类(这个类必须继承MiddlewareMixin)
        然后在这个类里面就可以自定义五个方法了
        (这五个方法并不是全部都需要书写，用几个写几个)
    4.需要将类的路径以字符串的形式注册到配置文件中才能生效

process_request 
    1.请求来的时候需要经过每一个中间件里面的process_request方法，结果的顺序是按照配置文件中注册的中间件从上往下的顺序依次执行
    2.如果中间件里面没有定义该方法，那么直接跳过执行下一个中间件
    3.如果该方法返回了HttpResponse对象，那么请求将不再继续往后执行，而是直接原路返回(校验失败不允许访问...)
    process_request方法就是用来做全局相关的所有限制功能
			
process_response
    1.响应走的时候需要结果每一个中间件里面的process_response方法，该方法有两个额外的参数request,response
    2.该方法必须返回一个HttpResponse对象
        1.默认返回的就是形参response
        2.你也可以自己返回自己的
    3.顺序是按照配置文件中注册了的中间件从下往上依次经过
        如果你没有定义的话 直接跳过执行下一个
	response是视图函数返回的HttpResponse对象(也就是说这是Django后台处理完之后给出一个的一个具体的视图)。该方法的返回值(必须要有返回值)也必须是HttpResponse对象。如果不返回response而返回其他对象，则浏览器不会拿到Django后台给他的视图，而是自定义的中间件返回的对象
	flask框架也有一个中间件但是它的规律
		只要返回数据了就必须经过所有中间件里面的类似于process_reponse方法
			
process_view
    路由匹配成功之后执行视图函数之前，会自动执行中间件里面的该放法
    顺序是按照配置文件中注册的中间件从上往下的顺序依次执行

process_template_response
    返回的HttpResponse对象有render属性的时候才会触发
    顺序是按照配置文件中注册了的中间件从下往上依次经过

process_exception
    当视图函数中出现异常的情况下触发
    顺序是按照配置文件中注册了的中间件从下往上依次经过      

CSRF跨站请求伪造：
    内部本质
        我们在钓鱼网站的页面 针对对方账户 只给用户提供一个没有name属性的普通input框
        然后我们在内部隐藏一个已经写好name和value的input框

    如何规避上述问题
        csrf跨站请求伪造校验
            网站在给用户返回一个具有提交数据功能页面的时候会给这个页面加一个唯一标识
            当这个页面朝后端发送post请求的时候 我的后端会先校验唯一标识，如果唯一标识不对直接拒绝(403 forbbiden)如果成功则正常执行	

如何符合校验：
    # form表单如何符合校验
    <form action="" method="post">
        {% csrf_token %}
        <p>username:<input type="text" name="username"></p>
        <p>target_user:<input type="text" name="target_user"></p>
        <p>money:<input type="text" name="money"></p>
        <input type="submit">
    </form>

    # ajax如何符合校验
    // 第一种 利用标签查找获取页面上的随机字符串
    {#data:{"username":'jason','csrfmiddlewaretoken':$('[name=csrfmiddlewaretoken]').val()},#}
    // 第二种 利用模版语法提供的快捷书写
    {#data:{"username":'jason','csrfmiddlewaretoken':'{{ csrf_token }}'},#}
    // 第三种 通用方式直接拷贝js代码并应用到自己的html页面上即可
    data:{"username":'jason'}

CSRF相关装饰器：

"""
1.网站整体都不校验csrf，就单单几个视图函数需要校验
2.网站整体都校验csrf，就单单几个视图函数不校验
"""
from django.views.decorators.csrf import csrf_protect,csrf_exempt
from django.utils.decorators import method_decorator
"""
csrf_protect  需要校验
    针对csrf_protect符合我们之前所学的装饰器的三种玩法
csrf_exempt   忽视校验
    针对csrf_exempt只能给dispatch方法加才有效
"""
# @csrf_exempt
# @csrf_protect
def transfer(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        target_user = request.POST.get('target_user')
        money = request.POST.get('money')
        print('%s给%s转了%s元'%(username,target_user,money))
    return render(request,'transfer.html')



from django.views import View

# @method_decorator(csrf_protect,name='post')  # 针对csrf_protect 第二种方式可以
# @method_decorator(csrf_exempt,name='post')  # 针对csrf_exempt 第二种方式不可以
@method_decorator(csrf_exempt,name='dispatch')
class MyCsrfToken(View):
    # @method_decorator(csrf_protect)  # 针对csrf_protect 第三种方式可以
    # @method_decorator(csrf_exempt)  # 针对csrf_exempt 第三种方式可以
    def dispatch(self, request, *args, **kwargs):
        return super(MyCsrfToken, self).dispatch(request,*args,**kwargs)

    def get(self,request):
        return HttpResponse('get')

    # @method_decorator(csrf_protect)  # 针对csrf_protect 第一种方式可以
    # @method_decorator(csrf_exempt)  # 针对csrf_exempt 第一种方式不可以
    def post(self,request):
        return HttpResponse('post')
补充知识点：
    # 模块:importlib
    import importlib
    res = 'myfile.b'
    ret = importlib.import_module(res)  # from myfile import b
    # 该方法最小只能到py文件名
    print(ret)
重要思想：
    import settings
    import importlib

    def send_all(content):
        for path_str in settings.NOTIFY_LIST:  #'notify.email.Email'
            module_path,class_name = path_str.rsplit('.',maxsplit=1)
            # module_path = 'notify.email'  class_name = 'Email'
            # 1 利用字符串导入模块
            module = importlib.import_module(module_path)  # from notify import email
            # 2 利用反射获取类名
            cls = getattr(module,class_name)  # Email、QQ、Wechat
            # 3 生成类的对象
            obj = cls()
            # 4 利用鸭子类型直接调用send方法
            obj.send(content)
        
      
=========================================================================================

"""
django中间件是django的门户
1.请求来的时候需要先经过中间件才能到达真正的django后端
2.响应走的时候最后也需要经过中间件才能发送出去

django自带七个中间件
"""
django请求生命周期流程图

研究django中间件代码规律
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

class SessionMiddleware(MiddlewareMixin):
    def process_request(self, request):
        session_key = request.COOKIES.get(settings.SESSION_COOKIE_NAME)
        request.session = self.SessionStore(session_key)
    def process_response(self, request, response):
        return response
      
class CsrfViewMiddleware(MiddlewareMixin):
  	def process_request(self, request):
        csrf_token = self._get_token(request)
        if csrf_token is not None:
            # Use same token next time.
            request.META['CSRF_COOKIE'] = csrf_token
    def process_view(self, request, callback, callback_args, callback_kwargs):
        return self._accept(request)

    def process_response(self, request, response):
        return response
      
class AuthenticationMiddleware(MiddlewareMixin):
    def process_request(self, request):
        request.user = SimpleLazyObject(lambda: get_user(request))
"""
django支持程序员自定义中间件并且暴露给程序员五个可以自定义的方法
	1.必须掌握
		process_request
		
		process_response
	2.了解即可
		process_view
			
		process_template_response
		
		process_exception
"""
        
=========================================================================================
自定义中间件
"""
1.在项目名或者应用名下创建一个任意名称的文件夹
2.在该文件夹内创建一个任意名称的py文件
3.在该py文件内需要书写类(这个类必须继承MiddlewareMixin)
	然后在这个类里面就可以自定义五个方法了
	(这五个方法并不是全部都需要书写，用几个写几个)
4.需要将类的路径以字符串的形式注册到配置文件中才能生效
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    '你自己写的中间件的路径1',
    '你自己写的中间件的路径2',
    '你自己写的中间件的路径3',
]

"""
"""
1.必须掌握
		process_request 
			1.请求来的时候需要经过每一个中间件里面的process_request方法
			结果的顺序是按照配置文件中注册的中间件从上往下的顺序依次执行
			2.如果中间件里面没有定义该方法，那么直接跳过执行下一个中间件
			3.如果该方法返回了HttpResponse对象，那么请求将不再继续往后执行
			而是直接原路返回(校验失败不允许访问...)
			process_request方法就是用来做全局相关的所有限制功能
			
		process_response
			1.响应走的时候需要结果每一个中间件里面的process_response方法
			该方法有两个额外的参数request,response
			2.该方法必须返回一个HttpResponse对象
				1.默认返回的就是形参response
				2.你也可以自己返回自己的
			3.顺序是按照配置文件中注册了的中间件从下往上依次经过
				如果你没有定义的话 直接跳过执行下一个
		
		研究如果在第一个process_request方法就已经返回了HttpResponse对象，那么响应走的时候是经过所有的中间件里面的process_response还是有其他情况
		是其他情况
			就是会直接走同级别的process_reponse返回
		
		flask框架也有一个中间件但是它的规律
			只要返回数据了就必须经过所有中间件里面的类似于process_reponse方法
			
			
2.了解即可
		process_view
			路由匹配成功之后执行视图函数之前，会自动执行中间件里面的该放法
			顺序是按照配置文件中注册的中间件从上往下的顺序依次执行
			
		process_template_response
			返回的HttpResponse对象有render属性的时候才会触发
			顺序是按照配置文件中注册了的中间件从下往上依次经过
			
		process_exception
			当视图函数中出现异常的情况下触发
			顺序是按照配置文件中注册了的中间件从下往上依次经过
"""
=======================================================================================	
csrf跨站请求伪造
"""
钓鱼网站
	我搭建一个跟正规网站一模一样的界面(中国银行)
	用户不小心进入到了我们的网站，用户给某个人打钱
	打钱的操作确确实实是提交给了中国银行的系统，用户的钱也确确实实减少了
	但是唯一不同的时候打钱的账户不适用户想要打的账户变成了一个莫名其妙的账户

大学英语四六级
	考之前需要学生自己网站登陆缴费

内部本质
	我们在钓鱼网站的页面 针对对方账户 只给用户提供一个没有name属性的普通input框
	然后我们在内部隐藏一个已经写好name和value的input框

如何规避上述问题
	csrf跨站请求伪造校验
		网站在给用户返回一个具有提交数据功能页面的时候会给这个页面加一个唯一标识
		当这个页面朝后端发送post请求的时候 我的后端会先校验唯一标识，如果唯一标识不对直接拒绝(403 forbbiden)如果成功则正常执行	
"""

如何符合校验
    # form表单如何符合校验
    <form action="" method="post">
        {% csrf_token %}
        <p>username:<input type="text" name="username"></p>
        <p>target_user:<input type="text" name="target_user"></p>
        <p>money:<input type="text" name="money"></p>
        <input type="submit">
    </form>

    # ajax如何符合校验
    // 第一种 利用标签查找获取页面上的随机字符串
    {#data:{"username":'jason','csrfmiddlewaretoken':$('[name=csrfmiddlewaretoken]').val()},#}
    // 第二种 利用模版语法提供的快捷书写
    {#data:{"username":'jason','csrfmiddlewaretoken':'{{ csrf_token }}'},#}
    // 第三种 通用方式直接拷贝js代码并应用到自己的html页面上即可
    data:{"username":'jason'}
    

    function getCookie(name) {
        var cookieValue = null;
        if (document.cookie && document.cookie !== '') {
            var cookies = document.cookie.split(';');
            for (var i = 0; i < cookies.length; i++) {
                var cookie = jQuery.trim(cookies[i]);
                // Does this cookie string begin with the name we want?
                if (cookie.substring(0, name.length + 1) === (name + '=')) {
                    cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                    break;
                }
            }
        }
        return cookieValue;
    }
    var csrftoken = getCookie('csrftoken');


    function csrfSafeMethod(method) {
      // these HTTP methods do not require CSRF protection
      return (/^(GET|HEAD|OPTIONS|TRACE)$/.test(method));
    }

    $.ajaxSetup({
      beforeSend: function (xhr, settings) {
        if (!csrfSafeMethod(settings.type) && !this.crossDomain) {
          xhr.setRequestHeader("X-CSRFToken", csrftoken);
        }
      }
    });


=========================================================================================
csrf相关装饰器
    """
    1.网站整体都不校验csrf，就单单几个视图函数需要校验
    2.网站整体都校验csrf，就单单几个视图函数不校验
    """
    from django.views.decorators.csrf import csrf_protect,csrf_exempt
    from django.utils.decorators import method_decorator
    """
    csrf_protect  需要校验
        针对csrf_protect符合我们之前所学的装饰器的三种玩法
    csrf_exempt   忽视校验
        针对csrf_exempt只能给dispatch方法加才有效
    """
    # @csrf_exempt
    # @csrf_protect
    def transfer(request):
        if request.method == 'POST':
            username = request.POST.get('username')
            target_user = request.POST.get('target_user')
            money = request.POST.get('money')
            print('%s给%s转了%s元'%(username,target_user,money))
        return render(request,'transfer.html')



    from django.views import View

    # @method_decorator(csrf_protect,name='post')  # 针对csrf_protect 第二种方式可以
    # @method_decorator(csrf_exempt,name='post')  # 针对csrf_exempt 第二种方式不可以
    @method_decorator(csrf_exempt,name='dispatch')
    class MyCsrfToken(View):
        # @method_decorator(csrf_protect)  # 针对csrf_protect 第三种方式可以
        # @method_decorator(csrf_exempt)  # 针对csrf_exempt 第三种方式可以
        def dispatch(self, request, *args, **kwargs):
            return super(MyCsrfToken, self).dispatch(request,*args,**kwargs)

        def get(self,request):
            return HttpResponse('get')

        # @method_decorator(csrf_protect)  # 针对csrf_protect 第一种方式可以
        # @method_decorator(csrf_exempt)  # 针对csrf_exempt 第一种方式不可以
        def post(self,request):
            return HttpResponse('post')

        

补充知识点
# 模块:importlib
import importlib
res = 'myfile.b'
ret = importlib.import_module(res)  # from myfile import b
# 该方法最小只能到py文件名
print(ret)
        


重要思想
import settings
import importlib


def send_all(content):
    for path_str in settings.NOTIFY_LIST:  #'notify.email.Email'
        module_path,class_name = path_str.rsplit('.',maxsplit=1)
        # module_path = 'notify.email'  class_name = 'Email'
        # 1 利用字符串导入模块
        module = importlib.import_module(module_path)  # from notify import email
        # 2 利用反射获取类名
        cls = getattr(module,class_name)  # Email、QQ、Wechat
        # 3 生成类的对象
        obj = cls()
        # 4 利用鸭子类型直接调用send方法
        obj.send(content)        

```

## cookie与session

```python
"""
发展史
	1.网站都没有保存用户功能的需求 所有用户访问返回的结果都是一样的
		eg:新闻、博客、文章...
	
	2.出现了一些需要保存用户信息的网站
		eg:淘宝、支付宝、京东...
		
		以登陆功能为例:如果不保存用户登陆状态 也就意味着用户每次访问网站都需要重复的输入用户名和密码(你觉得这样的网站你还想用吗？)
		当用户第一次登陆成功之后 将用户的用户名密码返回给用户浏览器 让用户浏览器保存在本地，之后访问网站的时候浏览器自动将保存在浏览器上的用户名和密码发送给服务端，服务端获取之后自动验证
		早起这种方式具有非常大的安全隐患
		
		
		优化:
			当用户登陆成功之后，服务端产生一个随机字符串(在服务端保存数据,用kv键值对的形式)，交由客户端浏览器保存
			随机字符串1:用户1相关信息
			随机字符串2:用户2相关信息
			随机字符串3:用户3相关信息
			之后访问服务端的时候，都带着该随机字符串，服务端去数据库中比对是否有对应的随机字符串从而获取到对应的用户信息
			
	
  
但是如果你拿到了截获到了该随机字符串，那么你就可以冒充当前用户 其实还是有安全隐患的


你要知道在web领域没有绝对的安全也没有绝对的不安全
"""
cookie
	服务端保存在客户端浏览器上的信息都可以称之为cookie
  它的表现形式一般都是k:v键值对(可以有多个)
session
	数据是保存在服务端的并且它的表现形式一般也是k:v键值对(可以有多个)
    
    
下述内容暂时了解即可 先给我搞明白最简单的cookie与session使用再说话！
token
	session虽然数据是保存在服务端的 但是禁不住数据量大
  服务端不再保存数据
  	登陆成功之后 将一段用户信息进行加密处理(加密算法之后你公司开发知道)
    将加密之后的结果拼接在信息后面 整体返回给浏览器保存 
    浏览器下次访问的时候带着该信息 服务端自动切去前面一段信息再次使用自己的加密算法
    跟浏览器尾部的密文进行比对
jwt认证
	三段信息
  (后期会讲 结合django一起使用) 
	
总结:
  	1.cookie就是保存在客户端浏览器上的信息
    2.session就是保存在服务端上的信息
    3.session是基于cookie工作的(其实大部分的保存用户状态的操作都需要使用到cookie)
    
=========================================================================================
cookie操作
# 虽然cookie是服务端告诉客户端浏览器需要保存内容
# 但是客户端浏览器可以选择拒绝保存 如果禁止了 那么 只要是需要记录用户状态的网站登陆功能都无法使用了

# 视图函数的返回值
return HttpResponse()
return render()
return redirect()


obj1 = HttpResponse()
# 操作cookie
return obj1

obj2 = render()
# 操作cookie
return obj2

obj3 = redirect()
# 操作cookie
return obj3
# 如果你想要操作cookie，你就不得不利用obj对象


"""
设置cookie
	obj.set_cookie(key,value)
获取cookie
	request.COOKIES.get(key)
在设置cookie的时候可以添加一个超时时间
	obj.set_cookie('username', 'jason666',max_age=3,expires=3)
	
	max_age
	expires
		两者都是设置超时时间的 并且都是以秒为单位
		需要注意的是 针对IE浏览器需要使用expires
主动删除cookie(注销功能)
	
	
"""
# 我们完成一个真正的登陆功能
# 校验用户是否登陆的装饰器
"""
用户如果在没有登陆的情况下想访问一个需要登陆的页面
那么先跳转到登陆页面 当用户输入正确的用户名和密码之后
应该跳转到用户之前想要访问的页面去 而不是直接写死
"""
def login_auth(func):
    def inner(request,*args,**kwargs):
        # print(request.path_info)
        # print(request.get_full_path())  # 能够获取到用户上一次想要访问的url
        target_url = request.get_full_path()
        if request.COOKIES.get('username'):
            return func(request,*args,**kwargs)
        else:
            return redirect('/login/?next=%s'%target_url)
    return inner

def login(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        if username == 'jason' and password == '123':

            # 获取用户上一次想要访问的url
            target_url = request.GET.get('next')  # 这个结果可能是None
            if target_url:
                obj = redirect(target_url)
            else:
                # 保存用户登陆状态
                obj = redirect('/home/')
            # 让浏览器记录cookie数据
            obj.set_cookie('username', 'jason666')
            """
            浏览器不单单会帮你存
            而且后面每次访问你的时候还会带着它过来
            """
            # 跳转到一个需要用户登陆之后才能看的页面
            return obj
    return render(request,'login.html')


@login_auth
def home(request):
    # 获取cookie信息 判断你有没有
    # if request.COOKIES.get('username') == 'jason666':
    #     return HttpResponse("我是home页面，只有登陆的用户才能进来哟~")
    # # 没有登陆应该跳转到登陆页面
    # return redirect('/login/')
    return HttpResponse("我是home页面，只有登陆的用户才能进来哟~")

=========================================================================================
session操作
"""
session数据是保存在服务端的(存？)，给客户端返回的是一个随机字符串
	sessionid:随机字符串
	
1.在默认情况下操作session的时候需要django默认的一张django_session表
	数据库迁移命令
		django会自己创建很多表	django_session就是其中的一张
		

django默认session的过期时间是14天
	但是你也可以人为的修改它
	

设置session	
request.session['key'] = value

获取session
request.session.get('key')

设置过期时间
request.session.set_expiry()
	括号内可以放四种类型的参数
		1.整数						多少秒
		2.日期对象			   到指定日期就失效
		3.0								一旦当前浏览器窗口关闭立刻失效
		4.不写						失效时间就取决于django内部全局session默认的失效时间

清除session	
	request.session.delete()  # 只删服务端的 客户端的不删
	request.session.flush()  # 浏览器和服务端都清空(推荐使用)


session是保存在服务端的 但是session的保存位置可以有多种选择
	1.MySQL
	2.文件
	3.redis
	4.memcache
	...
	

django_session表中的数据条数是取决于浏览器的
	同一个计算机上(IP地址)同一个浏览器只会有一条数据生效
	(当session过期的时候可能会出现多条数据对应一个浏览器，但是该现象不会持续很久，内部会自动识别过期的数据清除 你也可以通过代码清除)
	
	主要是为了节省服务端数据库资源
"""

request.session['hobby'] = 'girl'
    """
    内部发送了那些事
        1.django内部会自动帮你生成一个随机字符串
        2.django内部自动将随机字符串和对应的数据存储到django_session表中
            2.1先在内存中产生操作数据的缓存
            2.2在响应结果django中间件的时候才真正的操作数据库
        3.将产生的随机字符串返回给客户端浏览器保存
    """
request.session.get('hobby')
    """
    内部发送了那些事
        1.自动从浏览器请求中获取sessionid对应的随机字符串
        2.拿着该随机字符串去django_session表中查找对应的数据
        3.
            如果比对上了 则将对应的数据取出并以字典的形式封装到request.session中
            如果比对不上 则request.session.get()返回的是None
    """
  
  
# 利用session实现登陆验证

=========================================================================================
CBV添加装饰器
from django.views import View
from django.utils.decorators import method_decorator
"""
CBV中django不建议你直接给类的方法加装饰器
无论该装饰器能都正常给你 都不建议直接加
"""

# @method_decorator(login_auth,name='get')  # 方式2(可以添加多个针对不同的方法加不同的装饰器)
# @method_decorator(login_auth,name='post')
class MyLogin(View):
    @method_decorator(login_auth)  # 方式3:它会直接作用于当前类里面的所有的方法
    def dispatch(self, request, *args, **kwargs):
        return super().dispatch(request,*args,**kwargs)
    # @method_decorator(login_auth)  # 方式1:指名道姓
    def get(self,request):
        return HttpResponse("get请求")

    def post(self,request):
        return HttpResponse('post请求')

```

## Auth认证模块

```python
Auth模块
"""
其实我们在创建好一个django项目之后直接执行数据库迁移命令会自动生成很多表
	django_session
	auth_user
django在启动之后就可以直接访问admin路由，需要输入用户名和密码，数据参考的就是auth_user表,并且还必须是管理员用户才能进入

创建超级用户(管理员)
	python3 manage.py createsuperuser
	
依赖于auth_user表完成用户相关的所有功能
"""



方法总结
# 1.比对用户名和密码是否正确
user_obj = auth.authenticate(request,username=username,password=password)
# 括号内必须同时传入用户名和密码
print(user_obj)  # 用户对象  jason   数据不符合则返回None
print(user_obj.username)  # jason
print(user_obj.password)  # 密文

# 2.保存用户状态
auth.login(request,user_obj)  # 类似于request.session[key] = user_obj
# 主要执行了该方法 你就可以在任何地方通过request.user获取到当前登陆的用户对象

# 3.判断当前用户是否登陆
request.user.is_authenticated()

# 4.获取当前登陆用户
request.user

# 5.校验用户是否登陆装饰器
from django.contrib.auth.decorators import login_required
# 局部配置
@login_required(login_url='/login/') 
# 全局配置
LOGIN_URL = '/login/'
	1.如果局部和全局都有 该听谁的?
    局部 > 全局
	2.局部和全局哪个好呢?
    全局的好处在于无需重复写代码 但是跳转的页面却很单一
    局部的好处在于不同的视图函数在用户没有登陆的情况下可以跳转到不同的页面

# 6.比对原密码
request.user.check_password(old_password)

# 7.修改密码
request.user.set_password(new_password)  # 仅仅是在修改对象的属性
request.user.save()  # 这一步才是真正的操作数据库

# 8.注销
auth.logout(request) 

# 9.注册
# 操作auth_user表写入数据
User.objects.create(username=username,password=password)  # 写入数据  不能用create 密码没有加密处理
# 创建普通用户
User.objects.create_user(username=username,password=password)
# 创建超级用户(了解):使用代码创建超级用户 邮箱是必填的 而用命令创建则可以不填
User.objects.create_superuser(username=username,email='123@qq.com',password=password)


如何扩展auth_user表

from django.db import models
from django.contrib.auth.models import User,AbstractUser
# Create your models here.

# 第一种:一对一关系  不推荐
# class UserDetail(models.Model):
#     phone = models.BigIntegerField()
#     user = models.OneToOneField(to='User')


# 第二种:面向对象的继承
class UserInfo(AbstractUser):
    """
    如果继承了AbstractUser
    那么在执行数据库迁移命令的时候auth_user表就不会再创建出来了
    而UserInfo表中会出现auth_user所有的字段外加自己扩展的字段
    这么做的好处在于你能够直接点击你自己的表更加快速的完成操作及扩展
    
    前提:
        1.在继承之前没有执行过数据库迁移命令
            auth_user没有被创建，如果当前库已经创建了那么你就重新换一个库
        2.继承的类里面不要覆盖AbstractUser里面的字段名
            表里面有的字段都不要动，只扩展额外字段即可
        3.需要在配置文件中告诉django你要用UserInfo替代auth_user(******)
            AUTH_USER_MODEL = 'app01.UserInfo'
                                '应用名.表名'
    """
    phone = models.BigIntegerField()
    
    
"""
你如果自己写表替代了auth_user那么
auth模块的功能还是照常使用，参考的表页由原来的auth_user变成了UserInfo


我们bbs作业用户表就是用的上述方式
"""

```



## 项目：图书管理系统

```python
from django.shortcuts import render,redirect,HttpResponse
from app01 import models
# Create your views here.

def home(request):
    return render(request,'home.html')


def book_list(request):
    # 先查询出所有的书籍信息 传递给html页面
    book_queryset = models.Book.objects.all()
    return render(request,'book_list.html',locals())


def book_add(request):
    if request.method == 'POST':
        # 获取前端提交过来的所有数据
        title = request.POST.get("title")
        price = request.POST.get("price")
        publish_date = request.POST.get("publish_date")
        publish_id = request.POST.get("publish")
        authors_list = request.POST.getlist("authors")  # [1,2,3,4,]
        # 操作数据库存储数据
        # 书籍表
        book_obj = models.Book.objects.create(title=title,price=price,publish_date=publish_date,publish_id=publish_id)
        # 书籍与作者的关系表
        book_obj.authors.add(*authors_list)
        # 跳转到书籍的展示页面
        """
        redirect括号内可以直接写url
        其实也可以直接写别名
        
        但是如果你的别名需要额外给参数的话，那么就必须使用reverse解析了
        """
        return redirect('book_list')


    # 先获取当前系统中所有的出版社信息和作者信息
    publish_queryset = models.Publish.objects.all()
    author_queryset = models.Author.objects.all()
    return render(request,'book_add.html',locals())


def book_edit(request,edit_id):
    # 获取当前用户想要编辑的书籍对象 展示给用户看
    edit_obj = models.Book.objects.filter(pk=edit_id).first()
    if request.method == 'POST':
        title = request.POST.get("title")
        price = request.POST.get("price")
        publish_date = request.POST.get("publish_date")
        publish_id = request.POST.get("publish")
        authors_list = request.POST.getlist("authors")  # [1,2,3,4,]
        models.Book.objects.filter(pk=edit_id).update(title=title,
                                                      price=price,
                                                      publish_date=publish_date,
                                                      publish_id=publish_id
                                                      )
        # 该第三张关系表
        edit_obj.authors.set(authors_list)
        return redirect('book_list')

    publish_queryset = models.Publish.objects.all()
    author_queryset = models.Author.objects.all()
    return render(request,'book_edit.html',locals())


def book_delete(request,delete_id):
    # 简单粗暴 直接删除
    models.Book.objects.filter(pk=delete_id).delete()
    # 直接跳转到展示页
    return redirect('book_list')
```

## 项目：BBS博客系统






