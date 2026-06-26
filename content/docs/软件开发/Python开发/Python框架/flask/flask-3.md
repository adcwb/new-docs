---
title: "Flask SQLAlchemy 数据库"
weight: 3
date: 2026-06-23
tags: ["Python", "Flask", "SQLAlchemy", "ORM", "数据库"]
---

## 数据库操作

### ORM

**ORM** 全拼`Object-Relation Mapping`，中文意为 **对象-关系映射**。主要实现模型对象到关系数据库数据的映射

优点 :

- 只需要面向对象编程, 不需要面向数据库编写代码.
  - 对数据库的操作都转化成对类属性和方法的操作.
  - 不用编写各种数据库的`sql语句`.
- 实现了数据模型与数据库的解耦, 屏蔽了不同数据库操作上的差异.
  - 不再需要关注当前项目使用的是哪种数据库。
  - 通过简单的配置就可以轻松更换数据库, 而不需要修改代码.

缺点 :

- 相比较直接使用SQL语句操作数据库,有性能损失.
- 根据对象的操作转换成SQL语句,根据查询的结果转化成对象, 在映射过程中有性能损失.



### Flask-SQLAlchemy

flask默认提供模型操作，但是并没有提供ORM，所以一般开发的时候我们会采用flask-SQLAlchemy模块来实现ORM操作。

SQLAlchemy是一个关系型数据库框架，它提供了高层的 ORM 和底层的原生数据库的操作。flask-sqlalchemy 是一个简化了 SQLAlchemy 操作的flask扩展。

SQLAlchemy: [sqlalchemy.org](https://www.sqlalchemy.org/)

中文文档: [osgeo.cn/sqlalchemy](https://www.osgeo.cn/sqlalchemy/index.html)



安装 flask-sqlalchemy【清华源】

```bash
pip install flask-sqlalchemy -i https://pypi.tuna.tsinghua.edu.cn/simple
```

如果连接的是 mysql 数据库，需要安装 mysqldb **驱动**

```bash
pip install flask-mysqldb -i https://pypi.tuna.tsinghua.edu.cn/simple
```



安装flask-mysqldb时，注意

```text
安装 flask-mysqldb的时候，python底层依赖于一个底层的模块 mysql-client模块
如果没有这个模块，则会报错如下：

Command "python setup.py egg_info" failed with error code 1 in /tmp/pip-install-21hysnd4/mysqlclient/
```

解决方案：

```bash
sudo apt-get install libmysqlclient-dev python3-dev

运行上面的安装命令如果再次报错如下：
   dpkg 被中断，您必须手工运行 ‘sudo dpkg --configure -a’ 解决此问题。

则根据提示执行命令以下命令，再次安装mysqlclient
	sudo dpkg --configure -a
	apt-get install libmysqlclient-dev python3-dev

解决了mysqlclient问题以后，重新安装 flask-mysqldb即可。
pip install flask-mysqldb -i https://pypi.tuna.tsinghua.edu.cn/simple
```



#### 数据库连接设置

- 在 Flask-SQLAlchemy 中，数据库使用URL指定，而且程序使用的数据库必须保存到Flask配置对象的 **SQLALCHEMY_DATABASE_URI** 键中

  config.py，配置文件代码：

```python
class Config(object):
    DEBUG = True
    SECRET_KEY = "*(%#4sxcz(^(#$#8423"
    # 数据库链接配置 = 数据库名称://登录账号:登录密码@数据库主机IP:数据库访问端口/数据库名称?charset=编码类型
    SQLALCHEMY_DATABASE_URI = "mysql://root:123@127.0.0.1:3306/students?charset=utf8mb4"
```

- 其他设置：

```python
# 动态追踪修改设置，如未设置只会提示警告
SQLALCHEMY_TRACK_MODIFICATIONS = True
#查询时会显示原始SQL语句
SQLALCHEMY_ECHO = True
```

- 配置完成需要去 MySQL 中创建项目所使用的数据库

```bash
$ mysql -uroot -p123
mysql > create database students charset=utf8mb4;
```

SQLAlchemy支持多种数据库连接操作，但是需要安装相对应的驱动程序，具体参考官方文档

[docs.sqlalchemy.org](https://docs.sqlalchemy.org/en/13/)



#### 常用的SQLAlchemy字段类型

| 模型字段类型名 | python中数据类型  | 说明                                                |
| :------------- | :---------------- | :-------------------------------------------------- |
| Integer        | int               | 普通整数，一般是32位                                |
| SmallInteger   | int               | 取值范围小的整数，一般是16位                        |
| BigInteger     | int或long         | 不限制精度的整数                                    |
| Float          | float             | 浮点数                                              |
| Numeric        | decimal.Decimal   | 普通数值，一般是32位                                |
| String         | str               | 变长字符串                                          |
| Text           | str               | 变长字符串，对较长或不限长度的字符串做了优化        |
| Unicode        | unicode           | 变长Unicode字符串                                   |
| UnicodeText    | unicode           | 变长Unicode字符串，对较长或不限长度的字符串做了优化 |
| Boolean        | bool              | 布尔值                                              |
| Date           | datetime.date     | 日期                                                |
| Time           | datetime.time     | 时间                                                |
| DateTime       | datetime.datetime | 日期和时间                                          |
| LargeBinary    | str               | 二进制文件内容                                      |



#### 常用的SQLAlchemy列约束选项

| 选项名      | 说明                                              |
| :---------- | :------------------------------------------------ |
| primary_key | 如果为True，代表表的主键                          |
| unique      | 如果为True，代表这列不允许出现重复的值            |
| index       | 如果为True，为这列创建索引，提高查询效率          |
| nullable    | 如果为True，允许有空值，如果为False，不允许有空值 |
| default     | 为这列定义默认值                                  |



### 数据库基本操作

- 在Flask-SQLAlchemy中，添加、修改、删除操作，均由数据库会话管理。
  - 会话用 db.session 表示。在准备把数据写入数据库前，要先将数据添加到会话中然后调用 db.commit() 方法提交会话。
- 在 Flask-SQLAlchemy 中，查询操作是通过 query 对象操作数据。
  - 最基本的查询是返回表中所有数据，可以通过过滤器进行更精确的数据库查询。

#### 定义模型类

我们后面会把模型创建到单独的文件中，但是现在我们先把模型类写在main.py文件中。

```python
from flask import Flask
# 初始化
app = Flask(import_name=__name__)

# 声明和加载配置
class Config():
    DEBUG = True
    # 数据库链接配置 = 数据库名称://登录账号:登录密码@数据库主机IP:数据库访问端口/数据库名称?charset=编码类型
    SQLALCHEMY_DATABASE_URI = "mysql://root:123@127.0.0.1:3306/students?charset=utf8"
    # 动态追踪修改设置，如未设置只会提示警告
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    # 显示原始SQL语句
    SQLALCHEMY_ECHO = True

app.config.from_object(Config)

# 初始化SQLAlchemy
from flask_sqlalchemy import SQLAlchemy
db = SQLAlchemy() # 初始化数据库操作对象
db.init_app(app)  # 初始化数据库链接

class Student(db.Model):
    # 表结构声明
    __tablename__ = "tb_student"

    # 字段声明
    id   = db.Column(db.Integer, primary_key=True, comment="主键")
    name = db.Column(db.String(64), index=True, comment="姓名")
    sex  = db.Column(db.Boolean, default=True, comment="性别")
    age  = db.Column(db.SmallInteger, nullable=True, comment="年龄")
    email = db.Column(db.String(128), unique=True, comment="邮箱地址")
    money = db.Column(db.Numeric(8,2), default=0, comment="钱包")

    # 自定义方法
    def __repr__(self):
        return 'Student:%s' % self.name

class Teacher(db.Model):
    # 表结构声明
    __tablename__ = 'tb_teacher'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(64), unique=True)
    option = db.Column(db.Enum("讲师","助教","班主任"), default="讲师")
    def __repr__(self):
        return 'Teacher:%s' % self.name

class Course(db.Model):
    # 定义表名
    __tablename__ = 'tb_course'
    # 定义字段对象
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(64), unique=True)
    price = db.Column(db.Numeric(6,2))
    # repr()方法类似于django的__str__，用于打印模型对象时显示的字符串信息
    def __repr__(self):
        return 'Course:%s'% self.name

@app.route(rule='/')
def index():
    return "ok"

if __name__ == '__main__':
    # 运行flask
    app.run(debug=True)
```



## 数据表操作

### 创建和删除表

创建表

```python
db.create_all()  # 注意，create_all()方法执行的时候，需要放在模型的后面
# 上面这段语句，后面我们需要转移代码到flask-script的自定义命令中。
# 执行了一次以后，需要注释掉。
```

删除表

```python
db.drop_all()
```

代码：

```python
from flask import Flask
# 初始化
app = Flask(import_name=__name__)

# 声明和加载配置
class Config():
    DEBUG = True
    # 数据库链接配置 = 数据库名称://登录账号:登录密码@数据库主机IP:数据库访问端口/数据库名称?charset=编码类型
    SQLALCHEMY_DATABASE_URI = "mysql://root:123@127.0.0.1:3306/students?charset=utf8"
    # 动态追踪修改设置，如未设置只会提示警告
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    # 显示原始SQL语句
    SQLALCHEMY_ECHO = True

app.config.from_object(Config)

# 初始化SQLAlchemy
from flask_sqlalchemy import SQLAlchemy
db = SQLAlchemy() # 初始化数据库操作对象
db.init_app(app)  # 初始化数据库链接

class Student(db.Model):
    # 表结构声明
    __tablename__ = "tb_student"

    # 字段声明
    id   = db.Column(db.Integer, primary_key=True, comment="主键")
    name = db.Column(db.String(64), index=True, comment="姓名")
    sex  = db.Column(db.Boolean, default=True, comment="性别")
    age  = db.Column(db.SmallInteger, nullable=True, comment="年龄")
    email = db.Column(db.String(128), unique=True, comment="邮箱地址")
    money = db.Column(db.Numeric(8,2), default=0, comment="钱包")

    # 自定义方法
    def __repr__(self):
        return 'Student:%s' % self.name

class Teacher(db.Model):
    # 表结构声明
    __tablename__ = 'tb_teacher'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(64), unique=True)
    option = db.Column(db.Enum("讲师","助教","班主任"), default="讲师")
    def __repr__(self):
        return 'Teacher:%s' % self.name

class Course(db.Model):
    # 定义表名
    __tablename__ = 'tb_course'
    # 定义字段对象
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(64), unique=True)
    price = db.Column(db.Numeric(6,2))
    # repr()方法类似于django的__str__，用于打印模型对象时显示的字符串信息
    def __repr__(self):
        return 'Course:%s'% self.name

@app.route(rule='/')
def index():
    return "ok"

if __name__ == '__main__':
    with app.app_context():
        # db.drop_all()   # 删除所有的数据表
        db.create_all() # 创建所有的数据表
    # 运行flask
    app.run(debug=True)
```



## 数据基本操作

添加一条数据

```python
student1 = Student(name="小明", sex=True, age=17, email="123456@qq.com", money=100)
db.session.add(student1)
db.session.commit()

#再次插入 一条数据
student2 = Student(name='小红', sex=False, age=13, email="16565666@qq.com", money=600)
db.session.add(student2)
db.session.commit()
```



一次插入多条数据

```python
st1 = Student(name='wang',email='wang@163.com',age=22)
st2 = Student(name='zhang',email='zhang@189.com',age=22)
st3 = Student(name='chen',email='chen@126.com',age=22)
st4 = Student(name='zhou',email='zhou@163.com',age=22)
st5 = Student(name='tang',email='tang@163.com',age=22)
st6 = Student(name='wu',email='wu@gmail.com',age=22)
st7 = Student(name='qian',email='qian@gmail.com',age=22)
st8 = Student(name='liu',email='liu@163.com',age=22)
st9 = Student(name='li',email='li@163.com',age=22)
st10 = Student(name='sun',email='sun@163.com',age=22)
db.session.add_all([st1,st2,st3,st4,st5,st6,st7,st8,st9,st10])
db.session.commit()
```



删除数据

```python
# 方法1
student = Student.query.first()
db.session.delete(student)
db.session.commit()

# 方法2【事务中使用，就是乐观锁】
ret = Student.query.filter(Student.name=='sun').delete()
db.session.commit()
```



更新数据

```python
# 方法1
student = Student.query.first()
student.name = 'dong'
db.session.commit()

# 方法2【事务中使用，就是乐观锁】
ret = Student.query.filter(Student.name == 'liu').update({'money': 1000})
db.session.commit()

# 方法3【批量操作, 实现类似django里面F函数的效果】
ret = Student.query.filter(Student.age == 22).update({Student.money: Student.money+'200'})
db.session.commit()


# 批量更新，一次操作，更新全部
db.session.bulk_update_mappings
class User(BaseModel):
	__tablename__ = "User"
    id = db.Column(db.String(50), comment="id")
    name = db.Column(db.String(50), comment="name")
    

db.session.bulk_update_mappings(
        User, # 当前映射类
        [*max_obj] # 列表里套的是字典打散
    )

db.session.commit()

```



### 数据基本查询

#### 常用的SQLAlchemy查询过滤器

| 过滤器      | 说明                                             |
| :---------- | :----------------------------------------------- |
| filter()    | 把过滤器添加到原查询上，返回一个新查询           |
| filter_by() | 把等值过滤器添加到原查询上，返回一个新查询       |
| limit()     | 使用指定的值限定原查询返回的结果                 |
| offset()    | 偏移原查询返回的结果，返回一个新查询             |
| order_by()  | 根据指定条件对原查询结果进行排序，返回一个新查询 |
| group_by()  | 根据指定条件对原查询结果进行分组，返回一个新查询 |



#### 常用的SQLAlchemy查询结果的方法

| 方法           | 说明                                                         |
| :------------- | :----------------------------------------------------------- |
| all()          | 以列表形式返回查询的所有结果                                 |
| first()        | 返回查询的第一个结果，如果未查到，返回None                   |
| first_or_404() | 返回查询的第一个结果，如果未查到，返回404                    |
| get()          | 返回指定主键对应的行，如不存在，返回None                     |
| get_or_404()   | 返回指定主键对应的行，如不存在，返回404                      |
| count()        | 返回查询结果的数量                                           |
| paginate()     | 返回一个Paginate分页器对象，它包含指定范围内的结果           |
| having         | 返回结果中符合条件的数据，必须跟在group by后面，其他地方无法使用。 |

 

get():参数为数字，表示根据主键查询数据，如果主键不存在返回None

```python
Student.query.get()
```



all()返回查询到的所有对象

```python
Student.query.all()
```



first()返回查询到的第一个对象【first获取一条数据,all获取多条数据】

```python
Student.query.first()
```



filter模糊查询，支持各种运算符和查询方法

返回名字结尾字符为g的所有数据。

```python
    # name姓名中以"g"结尾的学生
    ret = Student.query.filter(Student.name.endswith("g")).all()
    # name姓名中包含"u"的学生
    ret = Student.query.filter(Student.name.contains("u")).all()
    # name姓名中以"w"开头的学生
    ret = Student.query.filter(Student.name.startswith("w")).all()
    
    
    # 也可以使用filter进行精确查找，
    # 则需要指定条件格式为: 模型.字段 比较运算符 值。
    # 运算符可以是: ==表示相等,!=不相等，> 表示大于  < 表示小于，>=大于等于，<=小于等于
    # ret = Student.query.filter(Student.age==22).all()

    # 另一种写法的查询方式
    # db.session.query(Student) 相当于 Student.query
    # ret = db.session.query(Student).filter(Student.age==22).all()
    
```



filter_by精确查询，只支持字段的值是否相等这种条件

例如：返回名字等于wang的学生学生

```python
# name=wang的学生
ret = Student.query.filter_by(name="wang").first()
# age = 22的所有学生
ret = Student.query.filter_by(age=22).all()
```



练习

```python
查询所有男生数据
	# ret = Student.query.filter(Student.sex==True).all()
查询所有女生数据
	# ret = Student.query.filter(Student.sex==False).all()
查询id为4的学生[2种方式]
    # ret = Student.query.filter(Student.id==4).first()
    # ret = Student.query.get(4)
    # ret = Student.query.filter_by(id=4).first()    
查询年龄等于22的所有学生数据
	# ret = Student.query.filter_by(age=22).all()
查询name为liu的学生数据
    # ret = Student.query.filter(Student.name == "liu").all()
    # ret = Student.query.filter_by(name="liu").all()
```



#### 多条件查询

逻辑非，返回名字不等于wang的所有数据

```python
Student.query.filter(Student.name!='wang').all()
```



not_ 相当于取反

```python
from sqlalchemy import not_
Student.query.filter(not_(Student.name=='wang')).all()
```



逻辑与，需要导入and，返回and()条件满足的所有数据

```python
from sqlalchemy import and_
Student.query.filter(and_(Student.name!='wang',Student.email.endswith('163.com'))).all()
```



逻辑或，需要导入or_

```python
from sqlalchemy import or_
Student.query.filter(or_(Student.name!='wang',Student.email.endswith('163.com'))).all()
```



in_范围查询

```python
"""查询id为2, 3, 5, 7, 8这几个学生信息"""
student_list = Student.query.filter(Student.id.in_([2, 3, 5, 7, 8])).all()
print(student_list)
```



order_by 排序

```python
# 查询所有学生，并按年龄进行倒序排列
ret = Student.query.order_by(Student.age.desc()).all()

# 查询所有学生，并按年龄进行倒序排列，年龄相同，则按id进行降序排序.
ret = Student.query.order_by(Student.age.desc(),Student.id.desc()).all()

# 查询某个范围内的最大值
data = Hosts.query.filter(Hosts.id.in_([1])).order_by(Hosts.score.desc()).first()
```



count统计

```python
# 查询age>=19的男生的数量
    from sqlalchemy import and_
    # ret = Student.query.filter( and_(Student.age>=19,Student.sex==True) ).count()
    ret = Student.query.filter( Student.age>=19, Student.sex==True ).count()
```



对结果进行偏移量和数量的限制

```python
    # 查询年龄最大的3个学生
    ret1 = Student.query.order_by(Student.age.desc()).limit(3).all()

    # 查询年龄排第4到第7名的学生
    ret2 = Student.query.order_by(Student.age.desc(),Student.id.desc()).offset(4).limit(4).all()
    print(ret1,ret2)
```



```python
# 查询名字和邮箱都以 li 开头的所有数据[2种方式]
	ret = Student.query.filter(Student.name.startswith("li"),Student.email.startswith("li")).all()
# 查询age是 18 或者 `email` 以 `163.com` 结尾的所有学生
	Student.query.filter(or_(Student.age==18,Student.email.endswith("163.com"))).all()
# 查询id为 [1, 3, 5, 7, 9] 的学生列表
	student_list = Student.query.filter(Student.id.in_([1, 3, 5, 7, 9])).all()
print(student_list)
# 查询男生和女生的数量
	ret = Student.query.filter_by(sex=True).count()
    ret = Student.query.filter_by(sex=False).count()
```



分页器的使用：

run.py，代码：

```python
from flask import Flask,request,jsonify,render_template
from config import Config
from models import db,Student,Course,Teacher

# 初始化
app = Flask(import_name=__name__,template_folder='templates')
app.config.from_object(Config)
db.init_app(app)  # 初始化数据库链接

"""分页器使用"""
@app.route(rule="/list")
def list():
    pagination = Student.query.paginate(per_page=3)

    # 获取当前页面所有数据
    # print( pagination.items )
    # data = {
    #     "items": [],
    #     "pages": pagination.pages,
    #     "page": pagination.page,
    #     "has_prev": pagination.has_prev,
    #     "has_next": pagination.has_next,
    # }

    # for item in pagination.items:
    #     data["items"].append({
    #         "id": item.id,
    #         "sex": "男" if item.sex else "女",
    #         "age": item.age,
    #         "name": item.name,
    #     })
    #
    # if pagination.has_prev:
    #     print( pagination.prev() ) # 上一页数据的分页器对象
    #     print( pagination.prev().items ) # 上一页数据
    #
    # if pagination.has_next:
    #     print( pagination.next() ) # 下一页数据的分页器对象
    #     print( pagination.next().items ) # 下一页数据

    return render_template("list.html",pagination=pagination)

if __name__ == '__main__':
    # 运行flask
    app.run(debug=True)
```

list.html，代码：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Title</title>
    <style>
    .page a,.page span{
        padding: 2px 6px;
        color: #fff;
        background: #6666ff;
        text-decoration: none;
    }
    .page span{
        color: #fff;
        background: orange;
    }

    </style>
</head>
<body>
    <table border="1" align="center" width="600">
        <tr>
           <th>ID</th>
           <th>age</th>
           <th>name</th>
           <th>sex</th>
           <th>money</th>
        </tr>
        {% for student in pagination.items %}
        <tr>
           <td>{{ student.id }}</td>
           <td>{{ student.age }}</td>
           <td>{{ student.name }}</td>
           <td>{{ "男" if student.sex else "女" }}</td>
           <td>{{ student.money }}</td>
        </tr>
        {% endfor %}
        <tr align="center">
            <td colspan="5" class="page">
                {% if pagination.has_prev %}
                <a href="?page=1">首  页</a>
                <a href="?page={{ pagination.page-1 }}">上一页</a>
                <a href="?page={{ pagination.page-1 }}">{{ pagination.page-1 }}</a>
                {% endif %}
                <span>{{ pagination.page }}</span>
                {% if pagination.has_next %}
                <a href="?page={{ pagination.page+1 }}">{{ pagination.page+1 }}</a>
                <a href="?page={{ pagination.page+1 }}">下一页</a>
                <a href="?page={{ pagination.pages }}">尾  页</a>
                {% endif %}
            </td>
        </tr>
    </table>
</body>
</html>
```

分组查询和分组查询结果过滤

一般分组都会结合聚合函数来一起使用。SQLAlchemy中所有的聚合函数都在`func`模块中声明的。

`from sqlalchemy import func`

| 函数名     | 说明     |      |
| ---------- | -------- | ---- |
| func.count | 统计总数 |      |
| func.avg   | 平均值   |      |
| func.min   | 最小值   |      |
| func.max   | 最大值   |      |
| func.sum   | 和       |      |

代码：

```python
# 查询当前所有男生女生的数量
from sqlalchemy import func
    # ret = db.session.query(Student.sex,func.count(Student.id)).group_by(Student.sex).all()
    # 查询当前不同年龄的学生数量
    ret = db.session.query(Student.age,func.count(Student.id)).group_by(Student.age).having(Student.age>19).all()
    
    # 查询男生和女生中，年龄最小的是几岁？
    ret = db.session.query(Student.sex,func.min(Student.age)).group_by(Student.sex).all()
```

执行原生SQL语句

```python
# 读取多条数据
ret = db.session.execute("select * from tb_student").fetchall()
# 读取一条数据
ret = db.session.execute("select * from tb_student").fetchone()
# 添加/修改/删除
db.session.execute("UPDATE tb_student SET money=(tb_student.money + %s) WHERE tb_student.age = %s" % (200, 22))
    db.session.commit()
```



### 关联查询

#### 常用的SQLAlchemy关系选项

| 选项名         | 说明                                                         |
| :------------- | :----------------------------------------------------------- |
| backref        | 在关系的另一模型中添加反向引用,用于设置外键名称,在1查多的    |
| primary join   | 明确指定两个模型之间使用的连表条件                           |
| lazy           | 指定如何加载关联模型数据的方式。参数值:<br>select（立即加载，查询所有相关数据显示，相当于lazy=True）<br>subquery（立即加载，但使用子查询）<br>dynamic（不加载记录，但提供加载记录的查询对象） |
| uselist        | 如果为False，不使用列表，而使用标量值。<br>一对一关系中，需要设置relationship中的uselist=Flase，其他数据库操作一样。 |
| secondary      | 指定多对多关系中关系表的名字。<br>多对多关系中，需建立关系表，设置 secondary=关系表 |
| secondary join | 在SQLAlchemy中无法自行决定时，指定多对多关系中的二级连表条件 |



#### 模型之间的关联

##### 一对一

```python
class Student(db.Model):
    """个人信息主表"""
	....
    # 关联属性，这个不会被视作表字段，只是模型的属性。
    # 因为StudentInfo和Student是一对一的关系，所以uselist=False表示关联一个数据
    info = db.relationship("StudentInfo",uselist=False,backref="own")


class StudentInfo(db.Model):
    """个人信息附加表"""

    # 外键，
    # 如果是一对一，则外键放在附加表对应的模型中
    # 如果是一对多，则外键放在多的表对象的模型中
    uid = db.Column(db.Integer, db.ForeignKey(Student.id),comment="外键")
```

课堂代码：

run.py，代码：

```python
from flask import Flask,request,jsonify,render_template
from config import Config
from models2 import db,Student,Course,Teacher,StudentInfo

# 初始化
app = Flask(import_name=__name__,template_folder='templates')
app.config.from_object(Config)
db.init_app(app)  # 初始化数据库链接

@app.route(rule='/')
def index():
    """1对1模型操作"""
    # 获取数据[从主表读取数据，获取附加表数据]
    # student = Student.query.get(3)
    # print( student.info.address )
    # print( student.info.edu )

    # 获取数据[从附加表读取数据，获取主表数据]
    # student_info = StudentInfo.query.filter(StudentInfo.address=="北京市昌平区沙河地铁站对面").first()
    # print(student_info.own.name)

    # 添加数据[添加数据，把关联模型的数据也一并添加]
    # student = Student(name="liu", sex=True, age=22, email="33523@qq.com", money=100)
    # student.info = StudentInfo(address="深圳市宝安区创业2路103号", edu="本科")
    # db.session.add(student)
    # db.session.commit()

    # 修改数据[通过主表可以修改附加表的数据，也可以通过附加表模型直接修改主表的数据]
    # student = Student.query.get(4)
    # student.info.address = "广州市天河区天河东路103号"
    # db.session.commit()

    return "ok"

if __name__ == '__main__':
    # 运行flask
    app.run(debug=True)
```

models.py，代码：

```python
# 初始化SQLAlchemy
from flask_sqlalchemy import SQLAlchemy
db = SQLAlchemy() # 初始化数据库操作对象

class Student(db.Model):
    # 表名
    __tablename__ = "tb_student"
    # 字段
    id   = db.Column(db.Integer, primary_key=True, comment="主键")
    name = db.Column(db.String(64), index=True, comment="姓名")
    sex  = db.Column(db.Boolean, default=True, comment="性别")
    age  = db.Column(db.SmallInteger, nullable=True, comment="年龄")
    email = db.Column(db.String(128), unique=True, comment="邮箱地址")
    money = db.Column(db.Numeric(8,2), default=0, comment="钱包")
    # 关联属性，这个不会被视作表字段，只是模型的属性。
    # 因为StudentInfo和Student是一对一的关系，所以uselist=False表示关联一个数据
    info = db.relationship("StudentInfo",uselist=False,backref="own")
    # 自定义方法
    def __repr__(self):
        return 'Student:%s' % self.name

class StudentInfo(db.Model):
    # 表明
    __tablename__ = "tb_student_info"
    # 字段
    id = db.Column(db.Integer, primary_key=True, comment="主键")
    address = db.Column(db.String(299), comment="住址")
    edu = db.Column(db.Enum("高中以下","大专高技","本科","硕士","博士以上"))
    # uid = db.Column(db.Integer, db.ForeignKey("tb_student.id"),comment="外键")
    # 外键，
    # 如果是一对一，则外键放在附加表对应的模型中
    # 如果是一对多，则外键放在多的表对象的模型中
    uid = db.Column(db.Integer, db.ForeignKey(Student.id),comment="外键")

class Teacher(db.Model):
    # 表结构声明
    __tablename__ = 'tb_teacher'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(64), unique=True)
    option = db.Column(db.Enum("讲师","助教","班主任"), default="讲师")
    def __repr__(self):
        return 'Teacher:%s' % self.name

class Course(db.Model):
    # 定义表名
    __tablename__ = 'tb_course'
    # 定义字段对象
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(64), unique=True)
    price = db.Column(db.Numeric(6,2))
    # repr()方法类似于django的__str__，用于打印模型对象时显示的字符串信息
    def __repr__(self):
        return 'Course:%s'% self.name
```

config.py，代码：

```python
# 声明和加载配置
class Config():
    DEBUG = True
    # 数据库链接配置 = 数据库名称://登录账号:登录密码@数据库主机IP:数据库访问端口/数据库名称?charset=编码类型
    SQLALCHEMY_DATABASE_URI = "mysql://root:123@127.0.0.1:3306/students?charset=utf8"
    # 动态追踪修改设置，如未设置只会提示警告
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    # 显示原始SQL语句
    SQLALCHEMY_ECHO = True
    # 调整json数据转换中文的配置
    JSON_AS_ASCII=False
```

测试数据：

```sql
INSERT INTO students.tb_student (id, name, sex, age, email, money) VALUES (3, 'li', 1, 17, '333@qq.com', 300.00);
INSERT INTO students.tb_student (id, name, sex, age, email, money) VALUES (4, 'wang', 0, 15, '123@qq.com', 300.00);
INSERT INTO students.tb_student (id, name, sex, age, email, money) VALUES (5, 'zhao', 0, 17, '333@baidu.com', 300.00);
INSERT INTO students.tb_student (id, name, sex, age, email, money) VALUES (6, 'long', 0, 18, '333@163.com', 300.00);
INSERT INTO students.tb_student (id, name, sex, age, email, money) VALUES (7, 'zhang', 1, 21, '333@sina.com.cn', 300.00);
INSERT INTO students.tb_student (id, name, sex, age, email, money) VALUES (8, 'liu', 1, 22, '33523@qq.com', 100.00);

INSERT INTO students.tb_student_info (id, address, edu, uid) VALUES (1, '天津市静海区静海路2号', '本科', 3);
INSERT INTO students.tb_student_info (id, address, edu, uid) VALUES (2, '广州市天河区天河东路103号', '高中以下', 4);
INSERT INTO students.tb_student_info (id, address, edu, uid) VALUES (3, '天津市静海区静海路2号', '本科', 5);
INSERT INTO students.tb_student_info (id, address, edu, uid) VALUES (4, '北京市昌平区沙河地铁站对面', '本科', 6);
INSERT INTO students.tb_student_info (id, address, edu, uid) VALUES (5, '天津市静海区静海路2号', '本科', 7);
INSERT INTO students.tb_student_info (id, address, edu, uid) VALUES (6, '深圳市宝安区创业2路103号', '本科', 8);
```



##### 一对多

```python
class Teacher(db.Model):
	...
    # 关联属性，一的一方添加模型关联属性
    course = db.relationship("Course", uselist=True, backref="teacher",lazy='dynamic')
   
class Course(db.Model):
	...
    # 外键，多的一方模型中添加外间
    teacher_id = db.Column(db.Integer, db.ForeignKey(Teacher.id))
```

- 其中realtionship描述了Course和Teacher的关系。第一个参数为对应参照的类"Course"
- 第二个参数backref为类Teacher申明新属性的方法
- 第三个参数lazy决定了什么时候SQLALchemy从数据库中加载数据
  - lazy='subquery'，查询当前数据模型时，采用子查询(subquery)，把外键模型的属性也瞬间查询出来了。
  - lazy=True或lazy='select'，查询当前数据模型时，不会把外键模型的数据查询出来，只有操作到外键关联属性时，才进行连表查询数据[执行SQL]
  - lazy='dynamic'，查询当前数据模型时，不会把外键模型的数据查询出来，只有操作到外键关联属性并操作外键模型具体属性时，才进行连表查询数据[执行SQL]

课堂代码：

models2.py，代码：

```python
# 初始化SQLAlchemy
from flask_sqlalchemy import SQLAlchemy
db = SQLAlchemy() # 初始化数据库操作对象

class Student(db.Model):
    # 表名
    __tablename__ = "tb_student"
    # 字段
    id   = db.Column(db.Integer, primary_key=True, comment="主键")
    name = db.Column(db.String(64), index=True, comment="姓名")
    sex  = db.Column(db.Boolean, default=True, comment="性别")
    age  = db.Column(db.SmallInteger, nullable=True, comment="年龄")
    email = db.Column(db.String(128), unique=True, comment="邮箱地址")
    money = db.Column(db.Numeric(8,2), default=0, comment="钱包")
    # 关联属性，这个不会被视作表字段，只是模型的属性。
    # 因为StudentInfo和Student是一对一的关系，所以uselist=False表示关联一个数据
    info = db.relationship("StudentInfo",uselist=False,backref="own")
    # 自定义方法
    def __repr__(self):
        return 'Student:%s' % self.name

class StudentInfo(db.Model):
    # 表明
    __tablename__ = "tb_student_info"
    # 字段
    id = db.Column(db.Integer, primary_key=True, comment="主键")
    address = db.Column(db.String(299), comment="住址")
    edu = db.Column(db.Enum("高中以下","大专高技","本科","硕士","博士以上"))
    # uid = db.Column(db.Integer, db.ForeignKey("tb_student.id"),comment="外键")
    # 外键，
    # 如果是一对一，则外键放在附加表对应的模型中
    # 如果是一对多，则外键放在多的表对象的模型中
    uid = db.Column(db.Integer, db.ForeignKey(Student.id),comment="外键")

class Teacher(db.Model):
    # 表结构声明
    __tablename__ = 'tb_teacher'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(64), unique=True)
    option = db.Column(db.Enum("讲师","助教","班主任"), default="讲师")
    # 关联属性，一的一方添加模型关联属性
    course = db.relationship("Course", uselist=True, backref="teacher",lazy='dynamic')
    def __repr__(self):
        return 'Teacher:%s' % self.name

class Course(db.Model):
    # 定义表名
    __tablename__ = 'tb_course'
    # 定义字段对象
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(64), unique=True)
    price = db.Column(db.Numeric(6,2))
    # 外键，多的一方模型中添加外间
    teacher_id = db.Column(db.Integer, db.ForeignKey(Teacher.id))
    # repr()方法类似于django的__str__，用于打印模型对象时显示的字符串信息
    def __repr__(self):
        return 'Course:%s'% self.name
```

run.py代码：

```python
from flask import Flask,request,jsonify,render_template
from config import Config
from models2 import db,Student,Course,Teacher,StudentInfo

# 初始化
app = Flask(import_name=__name__,template_folder='templates')
app.config.from_object(Config)
db.init_app(app)  # 初始化数据库链接

@app.route(rule='/more')
def more():
    """一对多/多对一模型操作"""
    # 从1的一方的模型中获取多的一方模型的数据
    # teacher = Teacher.query.get(1)
    # print(teacher)
    # # ret = teacher.course
    # for course in teacher.course:
    #     print(course.name,course.price)

    # 从多的一方获取1的一方数据
    # course = Course.query.get(1)
    # print(course.teacher)
    # print(course.teacher.name)

    # 添加数据
    # 从1的一方添加数据，同时给多的一方也添加
    # teacher = Teacher(name="蓝老师",option="讲师")
    # teacher.course = [Course(name="插画入门",price=199.00),Course(name="素描入门",price=129.00),]
    # db.session.add(teacher)
    # db.session.commit()

    return "ok"
if __name__ == '__main__':
    # 运行flask
    app.run(debug=True)
```

测试数据:

```sql
INSERT INTO students.tb_teacher (id, name, `option`) VALUES (1, '王老师', '讲师');
INSERT INTO students.tb_teacher (id, name, `option`) VALUES (2, '许老师', '讲师');
INSERT INTO students.tb_teacher (id, name, `option`) VALUES (3, '徐老师', '讲师');
INSERT INTO students.tb_teacher (id, name, `option`) VALUES (4, '张老师', '讲师');
INSERT INTO students.tb_teacher (id, name, `option`) VALUES (5, '留老师', '讲师');

INSERT INTO students.tb_course (id, name, price, teacher_id) VALUES (1, 'JAVA入门', 299.00, 1);
INSERT INTO students.tb_course (id, name, price, teacher_id) VALUES (2, 'Python入门', 399.00, 1);
INSERT INTO students.tb_course (id, name, price, teacher_id) VALUES (3, 'linux入门', 199.00, 2);
INSERT INTO students.tb_course (id, name, price, teacher_id) VALUES (4, 'django入门', 399.00, 3);
INSERT INTO students.tb_course (id, name, price, teacher_id) VALUES (5, 'flask入门', 299.00, 3);
INSERT INTO students.tb_course (id, name, price, teacher_id) VALUES (6, '数据分析入门', 199.00, 3);
INSERT INTO students.tb_course (id, name, price, teacher_id) VALUES (7, '爬虫入门', 299.00, 4);
INSERT INTO students.tb_course (id, name, price, teacher_id) VALUES (8, '前端入门', 199.00, 5);
INSERT INTO students.tb_course (id, name, price, teacher_id) VALUES (9, 'python项目', 199.00, 5);

```



##### 多对多

```python
achievement = db.Table('tb_achievement',  
    db.Column('student_id', db.Integer, db.ForeignKey('tb_student.id')),  
    db.Column('course_id', db.Integer, db.ForeignKey('tb_course.id')),
)

class Course(db.Model):
    ...
	students = db.relationship('Student',secondary=achievement,  
                                    backref='courses',  
                                    lazy='dynamic')
class Student(db.Model):
    ...
```

>   多对多，也可以拆解成3个模型，其中tb_achievement作为单独模型存在。

- 查询老师授课的所有课程

```python
#查询讲师表id为1的老师
teacher = Teacher.query.get(1)
#查询当前老师的所有课程, 根据模型中关联关系来查询数据
print(teacher.courses)
```



- 查询课程所属讲师

```python
course = Course.query.get(2)

print(course)

# 根据外键只能查询到ID数值, SQLAlchemy不会帮我们把ID转换成模型
print( course.teacher_id )

# 要获取外键对应的模型数据,需要找到主键模型里面的  db.relationship 里面的 backref
print( course.teacher.name )
```



## 数据库迁移

- 在开发过程中，需要修改数据库模型，而且还要在修改之后更新数据库。最直接的方式就是删除旧表，但这样会丢失数据。
- 更好的解决办法是使用数据库迁移框架，它可以追踪数据库模式的变化，然后把变动应用到数据库中。
- 在Flask中可以使用Flask-Migrate扩展，来实现数据迁移。并且集成到Flask-Script中，所有操作通过命令就能完成。
- 为了导出数据库迁移命令，Flask-Migrate提供了一个MigrateCommand类，可以附加到flask-script的manager对象上。

首先要在虚拟环境中安装Flask-Migrate。

```bash
pip install flask-migrate
```

代码文件内容：

```python
from flask import Flask
from config import Config
from flask_migrate import Migrate,MigrateCommand
from flask_script import Manager,Command

app = Flask(__name__,template_folder='templates')
app.config.from_object(Config)

manage = Manager(app)

"""模型的创建"""
from flask_sqlalchemy import SQLAlchemy
db = SQLAlchemy(app)



#第一个参数是Flask的实例，第二个参数是Sqlalchemy数据库实例
migrate = Migrate(app,db)

#manager是Flask-Script的实例，这条语句在flask-Script中添加一个db命令
manage.add_command('db',MigrateCommand)

# 多对多的关系
# 关系表的声明方式
achieve = db.Table('tb_achievement',
    db.Column('student_id', db.Integer, db.ForeignKey('tb_student.id')),
    db.Column('course_id', db.Integer, db.ForeignKey('tb_course.id'))
)


class Course(db.Model):
    # 定义表名
    __tablename__ = 'tb_course'
    # 定义字段对象
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(64), unique=True)
    price = db.Column(db.Numeric(6,2))
    teacher_id = db.Column(db.Integer, db.ForeignKey('tb_teacher.id'))
    students = db.relationship('Student', secondary=achieve, backref='courses', lazy='subquery')
    # repr()方法类似于django的__str__，用于打印模型对象时显示的字符串信息
    def __repr__(self):
        return 'Course:%s'% self.name

class Student(db.Model):
    __tablename__ = 'tb_student'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(64), unique=True)
    email = db.Column(db.String(64),unique=True)
    age = db.Column(db.SmallInteger,nullable=False)
    sex = db.Column(db.Boolean,default=1)

    def __repr__(self):
        return 'Student:%s' % self.name

class Teacher(db.Model):
    __tablename__ = 'tb_teacher'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(64), unique=True)
    # 课程与老师之间的多对一关联
    courses = db.relationship('Course', backref='teacher', lazy='subquery')

    def __repr__(self):
        return 'Teacher:%s' % self.name


@app.route("/")
def index():
    return "ok"

if __name__ == '__main__':
    manage.run()
```

### 创建迁移版本仓库

```bash
#这个命令会创建migrations文件夹，所有迁移文件都放在里面。
python main.py db init
```

### 创建迁移版本

- 自动创建迁移版本有两个函数
  - upgrade()：函数把迁移中的改动应用到数据库中。
  - downgrade()：函数则将改动删除。
- 自动创建的迁移脚本会根据模型定义和数据库当前状态的差异，生成upgrade()和downgrade()函数的内容。
- 对比不一定完全正确，有可能会遗漏一些细节，需要进行检查

```bash
python main.py db migrate -m 'initial migration'

# 这里等同于django里面的 makemigrations，生成迁移版本文件
```

### 升级版本库的版本

```bash
python main.py db upgrade 
```

### 降级版本库的版本

```text
python main.py db downgrade
```



### 版本库的历史管理

可以根据history命令找到版本号,然后传给downgrade命令:

```bash
python manage.py db history

输出格式：<base> ->  版本号 (head), initial migration
```

回滚到指定版本

```bash
python manage.py db downgrade # 默认返回上一个版本
python manage.py db downgrade 版本号   # 返回到指定版本号对应的版本
```



数据迁移的步骤：

```text
1. 初始化数据迁移的目录
python manage.py db init

2. 数据库的数据迁移版本初始化
python manage.py db migrate -m 'initial migration'

3. 升级版本[创建表/创建字段/修改字段]
python manage.py db upgrade 

4. 降级版本[删除表/删除字段/恢复字段]
python manage.py db downgrade
```



#### 模块推荐

文档: https://faker.readthedocs.io/en/master/locales/zh_CN.html

批量生成测试数据: https://github.com/joke2k/faker





## flask-session

允许设置session到指定存储的空间中, 文档: 

安装命令: https://pythonhosted.org/Flask-Session/

```bash
pip install flask-Session
```

使用session之前,必须配置一下配置项:

```python
SECRET_KEY = "*(%#4sxcz(^(#$#8423" # session秘钥
```



### redis保存session的基本配置

配置文件信息：

```python
import redis
class Config(object):
    DEBUG = True
    SECRET_KEY = "*(%#4sxcz(^(#$#8423"
    # 数据库链接配置:
    #数据类型://登录账号:登录密码@数据库主机IP:数据库访问端口/数据库名称
    SQLALCHEMY_DATABASE_URI = "mysql://root:123@127.0.0.1:3306/flask_students"
    # 设置mysql的错误跟踪信息显示
    SQLALCHEMY_TRACK_MODIFICATIONS = True
    # 打印每次模型操作对应的SQL语句
    SQLALCHEMY_ECHO = True
    # 把session保存到redis中
    # session存储方式为redis
    SESSION_TYPE="redis"
    # 如果设置session的生命周期是否是会话期, 为True，则关闭浏览器session就失效
    SESSION_PERMANENT = False
    # 是否对发送到浏览器上session的cookie值进行加密
    SESSION_USE_SIGNER = False
    # 保存到redis的session数的名称前缀
    SESSION_KEY_PREFIX = "session:"
    # session保存数据到redis时启用的链接对象
    SESSION_REDIS = redis.Redis(host='127.0.0.1', port='6379')  # 用于连接redis的配置
```

主文件信息main.py，代码:

```python
from flask import Flask
from config import Config
from flask_session import Session
from flask import session
app = Flask(__name__,template_folder='templates')
app.config.from_object(Config)

Session(app)

@app.route("/")
def index():
    return "ok"

@app.route("/set_session")
def set_session():
    """设置session"""
    session["username"] = "小明"
    return "ok"

if __name__ == '__main__':
    app.run()
```



### SQLAlchemy存储session的基本配置

需要手动创建session表，在项目第一次启动的时候，使用`db.create_all()`来完成创建。

```python
db = SQLAlchemy(app)

app.config['SESSION_TYPE'] = 'sqlalchemy'  # session类型为sqlalchemy
app.config['SESSION_SQLALCHEMY'] = db # SQLAlchemy对象
app.config['SESSION_SQLALCHEMY_TABLE'] = 'session' # session要保存的表名称
app.config['SESSION_PERMANENT'] = True  # 如果设置为True，则关闭浏览器session就失效。
app.config['SESSION_USE_SIGNER'] = False  # 是否对发送到浏览器上session的cookie值进行加密
app.config['SESSION_KEY_PREFIX'] = 'session:'  # 保存到session中的值的前缀

Session(app)
```





## 蓝图 Blueprint

### 模块化

随着flask程序越来越复杂,我们需要对程序进行模块化的处理,之前学习过python的模块化管理,于是针对一个简单的flask程序进行模块化处理



简单来说，Blueprint 是一个存储视图方法的容器，这些操作在这个Blueprint 被注册到一个应用之后就可以被调用，Flask 可以通过Blueprint来组织URL以及处理请求。

Flask使用Blueprint让应用实现模块化，在Flask中，Blueprint具有如下属性：

- 一个项目可以具有多个Blueprint
- 可以将一个Blueprint注册到任何一个未使用的URL下比如 “/”、“/sample”或者子域名
- 在一个应用中，一个模块可以注册多次
- Blueprint可以单独具有自己的模板、静态文件或者其它的通用操作方法，它并不是必须要实现应用的视图和函数的
- 在一个应用初始化时，就应该要注册需要使用的Blueprint

但是一个Blueprint并不是一个完整的应用，它不能独立于应用运行，而必须要注册到某一个应用中。



Blueprint对象用起来和一个应用/Flask对象差不多，最大的区别在于一个 蓝图对象没有办法独立运行，必须将它注册到一个应用对象上才能生效

使用蓝图可以分为四个步骤

1. 创建一个蓝图的包,例如**users**,并在``__init__.py``文件中创建蓝图对象

```python
users=Blueprint('users',__name__)
```

1. 在这个蓝图目录下, 创建views.py文件,保存当前蓝图使用的视图函数

```python
@admin.route('/')
def home():
    return 'user.home'
```

1. 在**users/__init__.py**中引入views.py中所有的视图函数

```python
from flask import Blueprint
# 等同于原来在 manage.py里面的 app = Flask()
users=Blueprint('users',__name__)

from .views import *
```



1. 在主应用main.py文件中的app对象上注册这个**users**蓝图对象

```python
from users import users
app.register_blueprint(users,url_prefix='/users')
```

当这个应用启动后,通过/users/可以访问到蓝图中定义的视图函数



### 运行机制

- 蓝图是保存了一组将来可以在应用对象上执行的操作，注册路由就是一种操作
- 当在app对象上调用 route 装饰器注册路由时,这个操作将修改对象的url_map路由表
- 然而，蓝图对象根本没有路由表，当我们在蓝图对象上调用route装饰器注册路由时,它只是在内部的一个延迟操作记录列表defered_functions中添加了一个项
- 当执行app对象的 register_blueprint() 方法时，应用对象将从蓝图对象的 defered_functions 列表中取出每一项，并以自身作为参数执行该匿名函数，即调用应用对象的 add_url_rule() 方法，这将真正的修改应用对象的usr_map路由表



### 蓝图的url前缀

- 当我们在应用对象上注册一个蓝图时，可以指定一个url_prefix关键字参数（这个参数默认是/）


- 在应用最终的路由表 url_map中，在蓝图上注册的路由URL自动被加上了这个前缀，这个可以保证在多个蓝图中使用相同的URL规则而不会最终引起冲突，只要在注册蓝图时将不同的蓝图挂接到不同的自路径即可
- url_for在使用时，如果要生成一个蓝图里面的视图对应的路由地址，则需要声明当前蓝图名称+视图名称

```python
url_for('users.home') # /users/home
```



### 注册蓝图中的静态文件的相关路由

和应用对象不同，蓝图对象创建时不会默认注册静态目录的路由。需要我们在 创建时指定 static_folder 参数。

下面的示例将蓝图所在目录下的static_users目录设置为静态目录

```python
# users/__init__.py，代码：
user_blu = Blueprint("users",__name__,static_folder='static_users')

# 启动文件 main.py，代码：
from users import user_blu
app.register_blueprint(user_blu,url_prefix='/users')
```

现在就可以使用/admin/static_admin/ 访问static_admin目录下的静态文件了 定制静态目录URL规则 ：可以在创建蓝图对象时使用 static_url_path 来改变静态目录的路由。


下面的示例将为 static_admin 文件夹的路由设置为 /lib

```python
admin = Blueprint("admin",__name__,static_folder='static_admin',static_url_path='/lib')
app.register_blueprint(admin,url_prefix='/admin')
```



### 设置蓝图中模版的目录

蓝图对象默认的模板目录为系统的模版目录，可以在创建蓝图对象时使用 template_folder 关键字参数设置模板目录

创建蓝图中的模板目录template_users :


```python
admin = Blueprint('admin',__name__,template_folder='templates_users')
```


注:如果在 templates 中存在和 templates_users 有同名模板文件时, 则系统会优先使用 templates 中的文件



## 调整session配置

分析SQLAlachemy的构造方式可以发现，初始化并非一定要传递app应用对象到内部，事实上它提供了init_app方法给我们后续调用。而 init_app 方法是flask框架要求任何的第三方组件都要实现这个方法。

init_app方法内部就是要第三方组件开发者编写一些使用当前组建的默认配置项以及把当前组件设置成一个对象，加载到app对象内部extensions字典才能让开发者在flask框架内部配置和使用当前组件。

我们可以利用这种组件开发机制，那么把配置代码抽离出去。

配置文件中：

```python
import redis
from flask_sqlalchemy import SQLAlchemy
# 创建db对象
db = SQLAlchemy()
class Config(object):
    DEBUG = True
    SECRET_KEY = "*(%#4sxcz(^(#$#8423"
    # 数据库链接配置:
    #数据类型://登录账号:登录密码@数据库主机IP:数据库访问端口/数据库名称
    SQLALCHEMY_DATABASE_URI = "mysql://root:123@127.0.0.1:3306/flask_students"
    # 设置mysql的错误跟踪信息显示
    SQLALCHEMY_TRACK_MODIFICATIONS = True
    # 打印每次模型操作对应的SQL语句
    SQLALCHEMY_ECHO = True

    """把session保存到redis中"""
    # session存储方式为redis
    # SESSION_TYPE="redis"
    # # 如果设置session的生命周期是否是会话期, 为True，则关闭浏览器session就失效
    # SESSION_PERMANENT = False
    # # 是否对发送到浏览器上session的cookie值进行加密
    # SESSION_USE_SIGNER = False
    # # 保存到redis的session数的名称前缀
    # SESSION_KEY_PREFIX = "session:"
    # # session保存数据到redis时启用的链接对象
    # SESSION_REDIS = redis.Redis(host='127.0.0.1', port='6379')  # 用于连接redis的配置

    SESSION_TYPE= 'sqlalchemy'  # session的存储方式为sqlalchemy
    SESSION_SQLALCHEMY= db  # SQLAlchemy对象
    SESSION_SQLALCHEMY_TABLE= 'sessions'  # session要保存的表名称
    SESSION_PERMANENT= True  # 如果设置为True，则关闭浏览器session就失效。
    SESSION_USE_SIGNER= False  # 是否对发送到浏览器上session的cookie值进行加密
    SESSION_KEY_PREFIX= 'session:'  # 保存到session中的值的前缀
```

启动文件main.py，代码：

```python
from flask import Flask
from config import Config,db
from flask_session import Session

from flask import session

app = Flask(__name__,template_folder='templates')
app.config.from_object(Config)

# 把app加载到db对象中
db.init_app(app)

Session(app)

@app.route("/")
def index():
    return "ok"

@app.route("/set_session")
def set_session():
    """设置session"""
    session["username"] = "小明"
    return "ok"

if __name__ == '__main__':
    # db.create_all()
    print( app.url_map )
    app.run()
```


