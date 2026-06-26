---
title: "Flask Jinja2 模板"
weight: 2
date: 2026-06-23
tags: ["Python", "Flask", "Jinja2", "模板"]
---

## Jinja2模板引擎

Flask内置的模板语言，它的设计思想来源于 Django 的模板引擎，并扩展了其语法和一系列强大的功能。

渲染模版函数

- Flask提供的 **render_template** 函数封装了该模板引擎
- **render_template** 函数的第一个参数是模板的文件名，后面的参数都是键值对，表示模板中变量对应的真实值。

## 模板基本使用

1. 在flask应用对象创建的时候，设置或者保留template_folder参数，创建模板目录

   ```python
   app = Flask(__name__,template_folder='templates')
   ```

2. 在项目下创建 `templates` 文件夹，用于存放所有的模板文件，并在目录下创建一个模板html文件 `index.html`

   ```html
   <!DOCTYPE html>
   <html lang="en">
   <head>
       <meta charset="UTF-8">
       <title>Title</title>
   </head>
   <body>
       <h1>{{title}}</h1>
   </body>
   </html>
   ```

   

3. 在视图函数设置渲染模板并设置模板数据

   ```python
   from flask import Flask, render_template
   # 初始化
   app = Flask(import_name=__name__,template_folder='templates')
   
   # 配置终端脚本运行项目
         
   # 声明和加载配置
   class Config():
       DEBUG = True
   app.config.from_object(Config)
   
   # 编写路由视图
   @app.route(rule='/')
   def index():
       data={}
       data["title"] = "我的flask项目"
       return render_template("index.html",**data)
   
   if __name__ == '__main__':
       # 运行flask
       app.run(debug=True)
   ```

### 输出变量

```text
{{}} 来表示变量名，这种 {{}} 语法叫做 变量代码块
```

视图代码：

```python
@app.route("/")
def index():
    data={}
    data["title"] = "我的flask项目"
    return render_template("index.html",**data)
```

模板代码

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>{{title}}</title>
</head>
<body>
    <h1>{{title}}</h1>
</body>
</html>
```

Jinja2 模版中的变量代码块可以是任意 Python 类型或者对象，只要它能够被 Python 的 `__str__` 方法或者str()转换为一个字符串就可以，比如，可以通过下面的方式显示一个字典或者列表中的某个元素:

视图代码：

```python
from flask import Flask,render_template
from settings.dev import Config
"""创建flask应用"""
app = Flask(__name__,template_folder='templates')
"""加载配置"""
app.config.from_object(Config)

@app.route("/")
def index():
    data = {}
    data["title"] = "我的项目"
    data["data_list"] = ["a","b","c"]
    data["data_dict"] = {
        "name":"xiaoming",
        "id":100,
    }
    # return render_template("index.html",
    #                        title="我的flask项目",
    #                        data_list=data_list,
    #                        data_dict=data_dict
    #                        )
    return render_template("index.html",**data)
if __name__ == '__main__':
    app.run(debug=True)
```

模板代码：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>{{title}}</title>
</head>
<body>
    <div>{{title}}</div>
    <div>{{list}}</div>
    <div>{{list[0]}}</div>
    <div>{{list.0}}</div>
    <div>{{list[-1]}}</div>
    <div>{{dict}}</div>
    <div>{{dict['name']}}</div>
    <div>{{dict.name}}</div>
</body>
</html>
```

使用 {# #} 进行注释，注释的内容不会在html中被渲染出来

```text
{# {{ name }} #}
```

## 模板中特有的变量和函数

你可以在自己的模板中访问一些 Flask 默认内置的函数和对象

### config

你可以从模板中直接访问Flask当前的config对象:

```python
{{config.SQLALCHEMY_DATABASE_URI}}
sqlite:///database.db
```

### request

就是flask中代表当前请求的request对象：

```python
{{request.url}}
http://127.0.0.1
```

### session

为Flask的session对象，显示session数据

```python
{{session.new}}
True
```

### g变量

在视图函数中设置g变量的 name 属性的值，然后在模板中直接可以取出

```python
{{ g.name }}
```

### url_for()

url_for会根据传入的路由器函数名,返回该路由对应的URL,在模板中始终使用url_for()就可以安全的修改路由绑定的URL,则不比担心模板中渲染出错的链接:

```python
{{url_for('home')}}
```

如果我们定义的路由URL是带有参数的,则可以把它们作为关键字参数传入url_for(),Flask会把他们填充进最终生成的URL中:

```python
{{ url_for('index', post_id=1)}}
/1
```

课堂代码：

主程序 run.py：

```python
from flask import Flask, render_template
# 初始化
app = Flask(import_name=__name__,template_folder='templates')

# 配置终端脚本运行项目

# 声明和加载配置
class Config():
    DEBUG = True
    SECRET_KEY = "abc"
app.config.from_object(Config)

# 编写路由视图
@app.route(rule='/')
def index():
    data={}
    data["title"] = "我的项目"
    data["list"] = ["a","b","c"]
    data["dict"] = {
        "name":"xiaoming",
        "id":100,
    }
    return render_template("index.html",**data)

from flask import session
@app.route("/session/set")
def set_session():
    session["name"] = "root"
    return "ok"

if __name__ == '__main__':
    # 运行flask
    app.run(debug=True)
```

模板 templates/index.html：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>{{title}}</title>
</head>
<body>
    <div>{{title}}</div>
    <div>{{list}}</div>
    <div>{{list[0]}}</div>
    <div>{{list.0}}</div>
    <div>{{list[-1]}}</div>
    <div>{{dict}}</div>
    <div>{{dict['name']}}</div>
    {# flask模板引擎的注释 #}
    {# <div>{{dict.name}}</div> #}
    <div>{{config}}</div>
    <div>{{config.DEBUG}}</div>
    <div>name={{request.args.name}}</div>
    <div>session.name={{session.name}}</div>
    <div>{{config.PREFERRED_URL_SCHEME}}://{{request.headers.Host}}{{url_for("set_session")}}</div>
</body>
</html>
```

pycharm中设置当前项目的模板语言：

files/settings/languages & frameworks/python template languages。

设置下拉框为jinja2，保存

## 流程控制

主要包含两个：

```text
- if/elif /else / endif
- for / endfor
```

### if语句

Jinja2 语法中的if语句跟 Python 中的 if 语句相似,后面的布尔值或返回布尔值的表达式将决定代码中的哪个流程会被执行.

用 {**%%**} 定义的**控制代码块**，可以实现一些语言层次的功能，比如循环或者if语句

视图代码：

```python
from flask import Flask,render_template,request
from settings.dev import Config
"""创建flask应用"""
app = Flask(__name__,template_folder='templates')
"""加载配置"""
app.config.from_object(Config)

@app.route("/list")
def list_page():
    data = {}
    data["book_list"] = [
        {"id":1,"price":78.50,"title":"javascript入门"},
        {"id":2,"price":78.50,"title":"python入门"},
        {"id":3,"price":78.50,"title":"django项目实战"}
    ]
    data["name"] = int( request.args.get("name") )
    return render_template("list.html",**data)

if __name__ == '__main__':
    app.run(debug=True)
```

list.html，模板代码：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
    <table border="1" align="center" width="680">
        <tr>
            <th>id</th>
            <th>标题</th>
            <th>价格</th>
        </tr>
        {# for循环 #}
        {% for book in book_list %}
        <tr>
            <td>{{ book.id }}</td>
            <td>{{ book.title }}</td>
            <td>{{ book.price }}</td>
        </tr>
        {% endfor %}
    </table>

    {# 判断一个参数是否是奇数 #}
    {% if name % 2 == 0 %}
        偶数<br>
    {% else %}
        奇数<br>
    {% endif %}
</body>
</html>
```

flask中也有过滤器，并且也可以被用在 if 语句或者for语句中:

视图代码：

```python
from flask import Flask,render_template,request
from settings.dev import Config
"""创建flask应用"""
app = Flask(__name__,template_folder='templates')
"""加载配置"""
app.config.from_object(Config)

@app.route("/")
def index():
    data = {}
    data["title"] = "我的项目"
    data["data_list"] = ["a","b","c"]
    data["data_dict"] = {
        "name":"xiaoming",
        "id":100,
    }
    # return render_template("index.html",
    #                        title="我的flask项目",
    #                        data_list=data_list,
    #                        data_dict=data_dict
    #                        )
    return render_template("index.html",**data)

@app.route("/list")
def list_page():
    data = {}
    data["book_list"] = [
        {"id":1,"price":78.50,"title":"javascript入门"},
        {"id":2,"price":78.50,"title":"python入门"},
        {"id":3,"price":78.50,"title":"django项目实战"}
    ]
    data["name"] = int( request.args.get("name") )
    return render_template("list.html",**data)

@app.route("/filter")
def filter():
    data = {}
    data["text"] = "hello flask"
    data["img_url"] = '<img width="300px" src="https://github.githubassets.com/images/modules/site/heroes/octocat-paper.svg">'
    return render_template("fitler.html",**data)

if __name__ == '__main__':
    app.run(debug=True)
```

filter.html，模板代码：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
    <p>{{ text }}</p>
    <p>{{ text|upper }}</p>
    <p>{{ text|length }}</p>
    <p>{{ img_url }}</p>
    <p>{{ img_url|safe }}</p>
    {% if request.args.get("name")| int % 2 == 0 %}
    <p>偶数</p>
    {% else %}
    <p>奇数</p>
    {% endif %}
</body>
</html>
```

### 循环语句

- 我们可以在 Jinja2 中使用循环来迭代任何列表或者生成器函数

```python
{% for post in posts %}
    <div>
        <h1>{{ post.title }}</h1>
        <p>{{ post.text | safe }}</p>
    </div>
{% endfor %}
```

- 循环和if语句可以组合使用，以模拟 Python 循环中的 continue 功能，下面这个循环将只会渲染post.text不为None的那些post：

```python
{% for post in posts if post.text %}
    <div>
        <h1>{{ post.title }}</h1>
        <p>{{ post.text | safe }}</p>
    </div>
{% endfor %}
```

- 在一个 for 循环块中你可以访问这些特殊的变量:

| 变量           | 描述                                           |
| :------------- | :--------------------------------------------- |
| loop.index     | 当前循环迭代的次数（从 1 开始）                |
| loop.index0    | 当前循环迭代的次数（从 0 开始）                |
| loop.revindex  | 到循环结束需要迭代的次数（从 1 开始）          |
| loop.revindex0 | 到循环结束需要迭代的次数（从 0 开始）          |
| loop.first     | 如果是第一次迭代，为 True 。                   |
| loop.last      | 如果是最后一次迭代，为 True 。                 |
| loop.length    | 序列中的项目数。                               |
| loop.cycle     | 在一串序列间期取值的辅助函数。见下面示例程序。 |

- 在循环内部,你可以使用一个叫做loop的特殊变量来获得关于for循环的一些信息
  - 比如：要是我们想知道当前被迭代的元素序号，并模拟Python中的enumerate函数做的事情，则可以使用loop变量的index属性,例如:

```python
{% for post in posts%}
{{loop.index}}, {{post.title}}
{% endfor %}
```

- 会输出这样的结果

```python
1, Post title
2, Second Post
```

- cycle函数会在每次循环的时候,返回其参数中的下一个元素,可以拿上面的例子来说明:

```python
{% for post in posts%}
	{{loop.cycle('odd','even')}} {{post.title}}
{% endfor %}
```

- 会输出这样的结果：

```python
odd Post Title
even Second Post
```

#### 课堂代码

视图代码：

```python
from flask import Flask, render_template
# 初始化
app = Flask(import_name=__name__,template_folder='templates')

# 配置终端脚本运行项目

# 声明和加载配置
class Config():
    DEBUG = True
    SECRET_KEY = "abc"
app.config.from_object(Config)

# 编写路由视图
@app.route(rule='/')
def index():
    data={}
    data["title"] = "我的项目"
    data["book_list"] = [
        {"id":10,"price":78.50,"title":"javascript入门"},
        {"id":21,"price":78.50,"title":"python入门"},
        {"id":33,"price":78.50,"title":"django项目实战"},
        {"id":34,"price":78.50,"title":"django项目实战"},
        {"id":33,"price":78.50,"title":"django项目实战"},
    ]
    return render_template("index.html",**data)

if __name__ == '__main__':
    # 运行flask
    app.run(debug=True)
```

continue.html，模板代码：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>{{title}}</title>
</head>
<body>
<p>判断</p>
<!--{% if request.args.name %}-->
<!--    <p>欢迎回来，{{request.args.name}}</p>-->
<!--{% endif %}-->

<!--{% if request.args.name %}-->
<!--    <p>欢迎回来，{{request.args.name}}</p>-->
<!--{% else %}-->
<!--    <p>对不起，您尚未登录</p>-->
<!--{% endif %}-->

<!--{% if request.args.name=="root" %}-->
<!--    <p>欢迎回来，您是当前网站的超级管理员～</p>-->
<!--{% elif request.args.name %}-->
<!--    <p>尊敬的用户{{request.args.name}}，欢迎回来</p>-->
<!--{% else %}-->
<!--    <p>对不起，您尚未登录</p>-->
<!--{% endif %}-->

<p>循环</p>
<table border="1" align="center" width="600">
    <tr>
        <th>序号</th>
        <th>ID</th>
        <th>price</th>
        <th>title</th>
    </tr>
    {% for book in book_list %}
        {% if loop.index %2 == 0 %}
            <tr bgcolor="#add8e6">
        {% else %}
            <tr>
        {% endif %}
            <td>{{ loop.index }}</td>
            <td>{{ book.id }}</td>
            <td>{{ book.price }}</td>
            <td>{{ book.title }}</td>
    </tr>
    {% endfor %}
</table>

</body>
</html>
```

## 过滤器

过滤器的本质就是函数。有时候我们不仅仅只是需要输出变量的值，我们还需要修改变量的显示，甚至格式化、运算等等，而在模板中是不能直接调用 Python 中的某些方法，那么这就用到了过滤器。

使用方式：

- 过滤器的使用方式为：变量名 | 过滤器。

```python
{{variable | filter_name(args1,args2,....)}}
```

- 如果没有任何参数传给过滤器,则可以把括号省略掉

```python
{{variable | filter_name }}
```

- 如：``，这个过滤器的作用：把变量variable 的值的首字母转换为大写，其他字母转换为小写

在 jinja2 中，过滤器是可以支持链式调用的，示例如下：

```python
{{ "hello world" | reverse | upper }}
```

### 常见的内建过滤器

#### 字符串操作

- safe：禁用转义

```python
<p>{{ '<em>hello</em>' | safe }}</p>
```

- capitalize：把变量值的首字母转成大写，其余字母转小写

```python
<p>{{ 'hello' | capitalize }}</p>
```

- lower：把值转成小写

```python
<p>{{ 'HELLO' | lower }}</p>
```

- upper：把值转成大写

```python
<p>{{ 'hello' | upper }}</p>
```

- title：把值中的每个单词的首字母都转成大写

```python
<p>{{ 'hello' | title }}</p>
```

- reverse：字符串反转

```python
<p>{{ 'olleh' | reverse }}</p>
```

- format：格式化输出

```python
<p>{{ '%s is %d' | format('name',17) }}</p>
```

- striptags：渲染之前把值中所有的HTML标签都删掉

    >   如果内容中，存在大小于号的情况，则不要使用这个过滤器，容易误删内容。

```python
<p>{{ '<em>hello</em>' | striptags }}</p>
<p>{{ "如果x<y，z>x，那么x和z之间是否相等？" | striptags }}</p>
```

- truncate: 字符串截断

```python
<p>{{ 'hello every one' | truncate(9)}}</p>
```

#### 列表操作

- first：取第一个元素

```python
<p>{{ [1,2,3,4,5,6] | first }}</p>
```

- last：取最后一个元素

```python
<p>{{ [1,2,3,4,5,6] | last }}</p>
```

- length：获取列表长度

```python
<p>{{ [1,2,3,4,5,6] | length }}</p>
```

- sum：列表求和

```python
<p>{{ [1,2,3,4,5,6] | sum }}</p>
```

- sort：列表排序

```text
<p>{{ [6,2,3,1,5,4] | sort }}</p>
```

#### 语句块过滤

```pyhton
{% filter upper %}
    #一大堆文字#
{% endfilter %}
```

### 自定义过滤器

过滤器的本质是函数。当模板内置的过滤器不能满足需求，可以自定义过滤器。自定义过滤器有两种实现方式：

- 一种是通过Flask应用对象的 **add_template_filter** 方法
- 通过装饰器来实现自定义过滤器

**重要：自定义的过滤器名称如果和内置的过滤器重名，会覆盖内置的过滤器。**

需求：添加列表反转的过滤器

方式一

通过调用应用程序实例的 add_template_filter 方法实现自定义过滤器。该方法第一个参数是函数名，第二个参数是自定义的过滤器名称：

```python
# 自定义过滤器
def do_list_reverse(old_list):
    # 因为字典/列表是属于复合类型的数据，所以改动数据的结构，也会应该能影响到原来的变量
    # 通过list新建一个列表进行操作，就不会影响到原来的数据
    new_list = list(old_list)
    new_list.reverse()
    return new_list

# 注册过滤器
app.add_template_filter(do_list_reverse, "lrev")
```

方式二

用装饰器来实现自定义过滤器。装饰器传入的参数是自定义的过滤器名称。

```python
@app.template_filter('lrev')
def do_list_reverse(old_list):
    # 因为字典/列表是属于复合类型的数据，所以改动数据的结构，也会应该能影响到原来的变量
    # 通过list新建一个列表进行操作，就不会影响到原来的数据
    new_list = list(old_list)
    new_list.reverse()
    return new_list
```

- 主程序中创建和注册过滤器

```python
from flask import Flask, render_template
# 初始化
app = Flask(import_name=__name__,template_folder='templates')

# 配置终端脚本运行项目

# 声明和加载配置
class Config():
    DEBUG = True
app.config.from_object(Config)

# 自定义过滤器
def do_list_reverse(old_list):
    # 因为字典/列表是属于复合类型的数据，所以改动数据的结构，也会应该能影响到原来的变量
    # 通过list新建一个列表进行操作，就不会影响到原来的数据
    new_list = list(old_list)
    new_list.reverse()
    return new_list
# 注册过滤器
app.add_template_filter(do_list_reverse, "lrev")

@app.route(rule='/')
def index():
    data={}
    data["user_list"] = ["xiaoming","小黑白","小红"]
    return render_template("index.html",**data)

if __name__ == '__main__':
    # 运行flask
    app.run(debug=True)
```

- html调用过滤器

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>title</title>
</head>
<body>
    <p>{{ user_list }}</p>
    <p>{{ user_list | lrev }}</p>
    <p>{{ user_list }}</p>
</body>
</html>
```

- 运行结果

```text
['xiaoming', '小黑白', '小红']

['小红', '小黑白', 'xiaoming']

['xiaoming', '小黑白', '小红']
```

#### 案例：给手机进行部分屏蔽

```python
from flask import Flask,render_template,request
from settings.dev import Config
"""创建flask应用"""
app = Flask(__name__,template_folder='templates')
"""加载配置"""
app.config.from_object(Config)

@app.template_filter("mobile")
def do_mobile(data,string):
    return data[:3]+string+data[7:]

@app.route("/")
def index():
    data = {}
    data["user_list"] = [
        {"id":1,"name":"张三","mobile":"13112345678"},
        {"id":2,"name":"张三","mobile":"13112345678"},
        {"id":3,"name":"张三","mobile":"13112345678"},
        {"id":4,"name":"张三","mobile":"13112345678"},
    ]
    return render_template("index2.html",**data)

if __name__ == '__main__':
    app.run(debug=True)
```

index2.html，模板代码：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
<table border="1" align="center" width="680">
    <tr>
        <th>ID</th>
        <th>姓名</th>
        <th>手机</th>
    </tr>
    {% for user in user_list %}
    <tr>
        <td>{{ user.id }}</td>
        <td>{{ user.name }}</td>
        <td>{{ user.mobile | mobile(string="****") }}</td>
    </tr>
    {% endfor %}

</table>
</body>
</html>
```

效果：

## 模板继承

在模板中，可能会遇到以下情况：

- 多个模板具有完全相同的顶部和底部内容
- 多个模板中具有相同的模板代码内容，但是内容中部分值不一样
- 多个模板中具有完全相同的 html 代码块内容

像遇到这种情况，可以使用 JinJa2 模板中的 **继承** 来进行实现

模板继承是为了重用模板中的公共内容。一般Web开发中，继承主要使用在网站的顶部菜单、底部。这些内容可以定义在父模板中，子模板直接继承，而不需要重复书写。

- 标签定义的内容

```python
{% block top %} {% endblock %}
```

- 相当于在父模板中挖个坑，当子模板继承父模板时，可以进行填充。
- 子模板使用 extends 指令声明这个模板继承自哪个模板
- 父模板中定义的块在子模板中被重新定义，在子模板中调用父模板的内容可以使用super()

父模板代码：

base.html

```python
{% block top %}
  顶部菜单
{% endblock top %}

{% block content %}
{% endblock content %}

{% block bottom %}
  底部
{% endblock bottom %}
```

子模板代码：

- extends指令声明这个模板继承自哪

```python
{% extends 'base.html' %}
{% block content %}
 需要填充的内容
{% endblock content %}
```

模板继承使用时注意点：

1. 不支持多继承

2. 为了便于阅读，在子模板中使用extends时，尽量写在模板的第一行。

3. 不能在一个模板文件中定义多个相同名字的block标签。

4. 当在页面中使用多个block标签时，建议给结束标签起个名字，当多个block嵌套时，阅读性更好。

   

## 在 Flask 项目中解决 CSRF 攻击

```bash
pip install flask_wtf
```

在 Flask 中， Flask-wtf 扩展有一套完善的 csrf 防护体系，对于我们开发者来说，使用起来非常简单

1. 设置应用程序的 secret_key，用于加密生成的 csrf_token 的值

```python
# 1. session加密的时候已经配置过了.如果没有在配置项中设置,则如下:
app.secret_key = "#此处可以写随机字符串#"

# 2. 也可以写在配置类中。
class Config(object):
    DEBUG = True
    SECRET_KEY = "dsad32DASSLD*13%^32"
    
"""加载配置"""
app.config.from_object(Config)
```

2. 导入 flask_wtf.csrf 中的 CSRFProtect 类，进行初始化，并在初始化的时候关联 app

```python
from flask.ext.wtf import CSRFProtect
CSRFProtect(app)
```

1. 在表单中使用 CSRF 令牌:

```html
<form method="post" action="/">
    <input type="hidden" name="csrf_token" value="{{ csrf_token() }}" />
</form>
```

视图代码;

```python
from flask import Flask,render_template
from settings.dev import Config
from flask_wtf.csrf import CSRFProtect
# from flask.ext.wtf import CSRFProtect  # 低版本的flask直接可以引入
"""创建flask应用"""
app = Flask(__name__,template_folder='templates')
"""加载配置"""
app.config.from_object(Config)

"""初始化csrf防范机制"""
CSRFProtect(app)

@app.route("/login",methods=["get"])
def loginform():
    return render_template("login.html")

@app.route("/dologin",methods=["post"])
def login():
    return "ok"

if __name__ == '__main__':
    app.run(debug=True)
```

模板代码：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
</head>
<body>
    <form action="{{ url_for('login') }}" method="post">
        <input type="hidden" name="csrf_token" value="{{ csrf_token() }}">
        <input type="submit" value="登录">
    </form>
</body>
</html>
```


