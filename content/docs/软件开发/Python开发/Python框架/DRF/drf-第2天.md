---
title: "drf-第2天"
weight: 3
date: 2026-06-23
---

restful就是一个接口开发的约定俗成的开发规范。不局限于django或者drf，即便我们不使用drf，其实也能实现符合restful规范的api接口。

同时，drf框架不是restful作者开发出来的！！！



## 7. 序列化器-Serializer

作用：

>1. 序列化,序列化器会<mark>把模型对象转换成字典</mark>,将来提供给视图经过response以后变成json字符串
>2. 反序列化,把客户端发送过来的数据,经过视图调用request以后变成python字典,序列化器可以<mark>把字典转成模型</mark>
>3. 反序列化,完成<mark>数据校验功能和操作数据库</mark>



## 7.1 定义序列化器

Django REST framework中的Serializer使用类来定义，须继承自rest_framework.serializers.Serializer。

接下来，为了方便演示序列化器的使用，我们另外创建一个新的子应用sers

```text
python manage.py startapp sers
```

先注册子应用到项目中，settings.py，代码：

```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    'rest_framework', # 把drf框架注册到django项目中

    'students', # 注册子应用
    'sers',
]
```



因为我们已有了一个数据库模型类students/Student，我们直接在接下来的演示中使用这个模型。

```python
class Student(models.Model):
    # 模型字段
    name = models.CharField(max_length=100,verbose_name="姓名")
    sex = models.BooleanField(default=1,verbose_name="性别")
    age = models.IntegerField(verbose_name="年龄")
    class_number = models.CharField(max_length=5,verbose_name="班级编号")
    description = models.TextField(max_length=1000,verbose_name="个性签名")

    class Meta:
        db_table="tb_student"
        verbose_name = "学生"
        verbose_name_plural = verbose_name
```



我们想为这个模型类提供一个序列化器，可以命名为`StudentSerializer`，

我们都会把序列化器代码保存到当前子应用下的serializers.py模块中，

可以定义如下：

```python
from rest_framework import serializers

# 声明序列化器，所有的序列化器都要直接或者间接继承于 Serializer
# 其中，ModelSerializer是Serializer的子类，ModelSerializer在Serializer的基础上进行了代码简化
class StudentSerializer(serializers.Serializer):
    """学生信息序列化器"""
    # 1. 需要进行数据转换的字段
    #  注意：
        # 1. 把需要提供给客户端的字段才写进来，或者需要客户端提供的字段才写进
        # 2. =号左边的字段一定要和模型里面的字段名对应
        # 3. 序列化器声明的字段并非一定要在数据库中的，也可以是模型声明的属性方法
        # 4. 字段选项，主要用在反序列化阶段验证数据
    id = serializers.IntegerField()
    name = serializers.CharField()
    age = serializers.IntegerField()
    sex = serializers.BooleanField()
    description = serializers.CharField()

    # 2. 如果序列化器集成的是ModelSerializer，则需要声明调用的模型信息

    # 3. 验证代码

    # 4. 编写添加和更新模型的代码
```

**注意：serializer不是只能为数据库模型类定义，也可以为非数据库模型类的数据定义。**serializer是独立于数据库之外的存在。



**常用字段类型**：

| 字段                    | 字段构造方式                                                 |
| ----------------------- | ------------------------------------------------------------ |
| **BooleanField**        | BooleanField()                                               |
| **NullBooleanField**    | NullBooleanField()                                           |
| **CharField**           | CharField(max_length=None, min_length=None, allow_blank=False, trim_whitespace=True) |
| **EmailField**          | EmailField(max_length=None, min_length=None, allow_blank=False) |
| **RegexField**          | RegexField(regex, max_length=None, min_length=None, allow_blank=False) |
| **SlugField**           | SlugField(max*length=50, min_length=None, allow_blank=False) 正则字段，验证正则模式 [a-zA-Z0-9*-]+ |
| **URLField**            | URLField(max_length=200, min_length=None, allow_blank=False) |
| **UUIDField**           | UUIDField(format='hex_verbose')  format:  1) `'hex_verbose'` 如`"5ce0e9a5-5ffa-654b-cee0-1238041fb31a"`  2） `'hex'` 如 `"5ce0e9a55ffa654bcee01238041fb31a"`  3）`'int'` - 如: `"123456789012312313134124512351145145114"`  4）`'urn'` 如: `"urn:uuid:5ce0e9a5-5ffa-654b-cee0-1238041fb31a"` |
| **IPAddressField**      | IPAddressField(protocol='both', unpack_ipv4=False, **options) |
| **IntegerField**        | IntegerField(max_value=None, min_value=None)                 |
| **FloatField**          | FloatField(max_value=None, min_value=None)                   |
| **DecimalField**        | DecimalField(max_digits, decimal_places, coerce_to_string=None, max_value=None, min_value=None) max_digits: 最多位数 decimal_palces: 小数点位置 |
| **DateTimeField**       | DateTimeField(format=api_settings.DATETIME_FORMAT, input_formats=None) |
| **DateField**           | DateField(format=api_settings.DATE_FORMAT, input_formats=None) |
| **TimeField**           | TimeField(format=api_settings.TIME_FORMAT, input_formats=None) |
| **DurationField**       | DurationField()                                              |
| **ChoiceField**         | ChoiceField(choices) choices与Django的用法相同               |
| **MultipleChoiceField** | MultipleChoiceField(choices)                                 |
| **FileField**           | FileField(max_length=None, allow_empty_file=False, use_url=UPLOADED_FILES_USE_URL) |
| **ImageField**          | ImageField(max_length=None, allow_empty_file=False, use_url=UPLOADED_FILES_USE_URL) |
| **ListField**           | ListField(child=, min_length=None, max_length=None)          |
| **DictField**           | DictField(child=)                                            |

**选项参数：**

| 参数名称            | 作用                                                         |
| ------------------- | ------------------------------------------------------------ |
| **max_length**      | 最大长度[适用于字符串，列表，文件]                           |
| **min_lenght**      | 最小长度[适用于字符串，列表，文件]                           |
| **allow_blank**     | 是否允许数据的值为空，如果使用这个选项，则前端传递过来的数据必须有这个属性。 |
| **trim_whitespace** | 是否截断空白字符                                             |
| **max_value**       | 【数值】最小值                                               |
| **min_value**       | 【数值】最大值                                               |

通用参数：

| 参数名称           | 说明                                          |
| ------------------ | --------------------------------------------- |
| **read_only**      | 表明该字段仅用于序列化输出，默认False         |
| **write_only**     | 表明该字段仅用于反序列化输入，默认False       |
| **required**       | 表明该字段在反序列化时必须输入，默认True      |
| **default**        | 反序列化时使用的默认值                        |
| **allow_null**     | 表明该字段是否允许传入None，默认False         |
| **validators**     | 该字段使用的验证器                            |
| **error_messages** | 包含错误编号与错误信息的字典                  |
| **label**          | 用于HTML展示API页面时，显示的字段名称         |
| **help_text**      | 用于HTML展示API页面时，显示的字段帮助提示信息 |



## 7.2 创建Serializer对象

定义好Serializer类后，就可以创建Serializer对象了。

Serializer的构造方法为：

```python
Serializer(instance=None, data=empty, **kwarg)
```

说明：

1）用于序列化时，将模型类对象传入**instance**参数

2）用于反序列化时，将要被反序列化的数据传入**data**参数

3）除了instance和data参数外，在构造Serializer对象时，还可通过**context**参数额外添加数据，如

```python
serializer = StudentSerializer(student, context={'request': request},many=False)
```

**通过context参数附加的数据，可以通过Serializer对象的self.context属性获取。**



1. 使用序列化器的时候一定要注意，序列化器声明了以后，不会自动执行，需要我们在视图中进行调用才可以。
2. 序列化器无法直接接收客户端的请求数据，需要我们在视图中创建序列化器对象时把使用的数据传递过来。
3. 序列化器的字段声明类似于我们前面使用过的表单系统。
4. 开发restful api时，序列化器会帮我们把模型数据转换成字典.
5. drf提供的视图会帮我们把字典转换成json,或者把客户端发送过来的数据转换字典.

```python
个人增加
	序列化器的声明在serializer.py文件中，格式类似于orm
    序列化器的创建在views.py文件中


# Create your views here.

from django.views import View
from django.http.response import JsonResponse
from .serializers import StudentSerializer
from students.models import Student
class StudentsView(View):
    def get1(self,request):
        """序列化器的声明和使用"""

        # 0. 从数据库中查询模型对象
        student = Student.objects.get(pk=1)
        print(student)
        # 1. 实例化序列化器对象
        # 参数:
        # 1） instance 模型对象, 一般来自于ORM
        # 2)  data     字典数据, 一般来自客户端
        # 3） context  字典, 可以把视图中的信息传参给序列化器[context 执行上下文]
        # 4)  many     布尔值，如果instance是多个对象，则必须声明many=True，否则序列化器会报错

        serializer = StudentSerializer(instance=student)

        print(serializer.data) # 转换后的字典数据

        return JsonResponse(serializer.data)

    def get2(self,request):
        """序列化单个数据"""
        # 1. 接受客户端的请求
        pk = request.GET.get("pk")
        print(pk)
        # 2. 操作数据
        student = Student.objects.get(pk=pk)

        # 3. 实例化序列化器对象
        serializer = StudentSerializer(instance=student)

        # 4. 返回结果
        return JsonResponse(serializer.data)

    def get(self,request):
        """序列化多个数据"""
        # 1. 操作数据
        student_list = Student.objects.all()

        # 2. 实例化序列化器对象
        # many=True的作用，就是告诉序列化器内部，当前instance的值是一个列表，所以需要循环
        serializer = StudentSerializer(instance=student_list, many=True)
        # 3. 返回结果
        # 通过data属性获取序列化器转换数据后的结果
        print(serializer.data)
        """打印效果
        [
            OrderedDict([('id', 1), ('name', '小明'), ('age', 17), ('sex', True), ('text', 100)]), 
            OrderedDict([('id', 2), ('name', '小明'), ('age', 17), ('sex', True), ('text', 100)]), 
            OrderedDict([('id', 3), ('name', '小明'), ('age', 17), ('sex', True), ('text', 100)]), 
            OrderedDict([('id', 4), ('name', '小明'), ('age', 17), ('sex', True), ('text', 100)]), 
            OrderedDict([('id', 5), ('name', '小明'), ('age', 17), ('sex', True), ('text', 100)]), 
            ....
        ]
        
        OrderedDict 是python的高级数据类型，叫有序字典
        from collections import OrderedDict
        因为python内置的基础类型的字典是无序的，所以这种无序字典无法不保证存储时的键值对顺序和提取时候的顺序一致
        有序字典和无序字典，除了声明不一样以外，对于成员的读取和操作是一样的。

        for item in serializer.data:
            # 获取有序字典的键值对
            print(item["name"])
        """

        # JsonResponse 只是支持返回字典，对于复杂的列表数据，需要设置参数safe=False
        return JsonResponse(serializer.data,safe=False)


```





## 7.3 序列化器的使用

序列化器的使用分两个阶段：

1. 在客户端请求时，使用序列化器可以完成对数据的反序列化。
2. 在服务器响应时，使用序列化器可以完成对数据的序列化。



### 7.3.1 序列化

#### 7.3.1.1 基本使用

1） 先查询出一个学生对象

视图中获取模型对象，代码：

```python
from students.models import Student

student = Student.objects.get(pk=3)
```

2） 构造序列化器对象

```python
from .serializers import StudentSerializer

serializer = StudentSerializer(instance=student)
```

3）获取序列化数据

通过data属性可以获取序列化后的数据

```python
serializer.data
# {'id': 4, 'name': '小张', 'age': 18, 'sex': True, 'description': '猴赛雷'}
```

完整视图代码：

```python
class Student2APIView(View):
    def get(self,request):
        """返回一个学生信息"""
        # 读取模型对象
        student = Student.objects.get(pk=1)
        # 实例化序列化器
        serializer = StudentSerializer(instance=student)
        print( serializer.data )
        """打印效果：
        {'id': 1, 'name': '张三', 'sex': True, 'age': 18}
        """
        return JsonResponse(serializer.data)
```



4）如果要被序列化的是包含多条数据的查询集QuerySet，可以通过添加**many=True**参数补充说明

```python

"""
目前我们先学习序列化器，所以我们还是使用原来django内置的视图类和路由。
使用序列化器对数据进行序列化器，一般用于返回数据给客户端。
"""
from django.views import View
from .serializers import StudentSerializer
from students.models import Student
from django.http.response import JsonResponse
class Student1APIView(View):
    def get(self,request):
        """返回所有学生给客户端"""
        """
        序列化器对象初始化有３个参数:
        1. instance，模型对象或者模型对象组成的列表，用于对数据进行序列化，把模型转换成字典
        2. data，字典，用于对数据进行反序列化，把数据进行验证和保存到数据库
        3. context，字典，用于把路由或者视图的自定义参数传递到序列化器里面使用
                 context将来作为序列化器对象的子属性
        4. many，当序列化器进行序列化时，如果模型有多个，则many必须为True
        """
        student_list = Student.objects.all()
        serializer = StudentSerializer(instance=student_list, many=True)

        print('student_list===>',student_list)
        print('serializer===>', serializer)
        print('转换的结果===>', serializer.data)
        """打印效果：
        [
            OrderedDict([('name', '张三'), ('sex', True), ('age', 18), ('class_null', '3011')]), 
            OrderedDict([('name', '张三'), ('sex', True), ('age', 18), ('class_null', '309')]), 
            OrderedDict([('name', '张三'), ('sex', True), ('age', 18), ('class_null', '309')]), 
            ....    
        ]
        
        说明：
        OrderedDict是python内置的高级数据类型，表示有序字典，因为普通数据类型中的字典是无序的.
        有序字典的成员读取方式，和无序字典一样
        导入路径：
        from collections import OrderedDict
        """

        # jsonResponse的第一个参数如果是列表则必须声明safe=False，否则报错如下：
        # In order to allow non-dict objects to be serialized set the safe parameter to False.
        return JsonResponse(serializer.data, safe=False)
```

```python
个人增加：

 def get2(self,request):
        """序列化单个数据"""
        # 1. 接受客户端的请求
        pk = request.GET.get("pk")
        print(pk)
        # 2. 操作数据
        student = Student.objects.get(pk=pk)

        # 3. 实例化序列化器对象
        serializer = StudentSerializer(instance=student)

        # 4. 返回结果
        return JsonResponse(serializer.data)

    
    
    
    
    def get(self,request):
        """序列化多个数据"""
        # 1. 操作数据
        student_list = Student.objects.all()

        # 2. 实例化序列化器对象
        # many=True的作用，就是告诉序列化器内部，当前instance的值是一个列表，所以需要循环
        serializer = StudentSerializer(instance=student_list, many=True)
        # 3. 返回结果
        # 通过data属性获取序列化器转换数据后的结果
        print(serializer.data)
        """打印效果
        [
            OrderedDict([('id', 1), ('name', '小明'), ('age', 17), ('sex', True), ('text', 100)]), 
            OrderedDict([('id', 2), ('name', '小明'), ('age', 17), ('sex', True), ('text', 100)]), 
            OrderedDict([('id', 3), ('name', '小明'), ('age', 17), ('sex', True), ('text', 100)]), 
            OrderedDict([('id', 4), ('name', '小明'), ('age', 17), ('sex', True), ('text', 100)]), 
            OrderedDict([('id', 5), ('name', '小明'), ('age', 17), ('sex', True), ('text', 100)]), 
            ....
        ]
        
        OrderedDict 是python的高级数据类型，叫有序字典
        from collections import OrderedDict
        因为python内置的基础类型的字典是无序的，所以这种无序字典无法不保证存储时的键值对顺序和提取时候的顺序一致
        有序字典和无序字典，除了声明不一样以外，对于成员的读取和操作是一样的。

        for item in serializer.data:
            # 获取有序字典的键值对
            print(item["name"])
        """

        # JsonResponse 只是支持返回字典，对于复杂的列表数据，需要设置参数safe=False
        return JsonResponse(serializer.data,safe=False)


	
```





### 7.3.2  反序列化

#### 7.3.2.1 数据验证

开发中，用户的数据都是不可信任的。

使用序列化器进行反序列化时，需要对数据进行验证后，才能获取验证成功的数据或保存成模型类对象。

在获取反序列化的客户端数据前，必须在视图中调用序列化对象的**is_valid()**方法，序列化器内部是在**is_valid**方法内部调用验证选项和验证方法进行验证，验证成功返回True，否则返回False。

验证失败，可以通过序列化器对象的**errors**属性获取错误信息，返回字典，包含了字段和字段的错误提示。如果是非字段错误，可以通过修改REST framework配置中的**NON_FIELD_ERRORS_KEY**来控制错误字典中的键名。

验证成功，可以通过序列化器对象的**validated_data**属性获取数据。

在定义序列化器时，指明每个字段的序列化类型和选项参数，本身就是一种验证行为。

为了方便演示，我们这里采用另一个图书模型来完成反序列化的学习。当然也创建一个新的子应用unsers。

```text
python manage.py startapp unsers
```

注册子应用，setting.py注册子应用，代码：

```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    'rest_framework', # 把drf框架注册到django项目中

    'students', # 注册子应用
    'sers',     # 演示序列化
    'unsers',     # 演示反序列化
]
```

注意：

```python
接下来的内容涉及到postman post提交数据，所以在此时我们没有学习到drf视图方法时，我i们把settings.py中的中间件的csrf关闭.

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    # 'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]
```



模型代码：

```python
from django.db import models

# Create your models here.
class BookInfo(models.Model):
    """图书信息"""
    title = models.CharField(max_length=20, verbose_name='标题')
    pub_date = models.DateField(verbose_name='发布日期')
    image = models.ImageField(verbose_name='图书封面')
    price = models.DecimalField(max_digits=8, decimal_places=2, verbose_name="价格")
    read = models.IntegerField(verbose_name='阅读量')
    comment = models.IntegerField(verbose_name='评论量')
    class Meta:
        # db_table = "表名"
        db_table = "tb_book_info"
        verbose_name = "图书"
        verbose_name_plural = verbose_name
```

注意：因为当前模型中， 设置到图片上传处理，所以我们需要安装`PIL`库

```bash
pip install Pillow
```

数据迁移

```bash
python manage.py makemigrations
python manage.py migrate
```



经过上面的准备工作，我们接下来就可以给图书信息增加图书的功能，那么我们需要对来自客户端的数据进行处理，例如，验证和保存到数据库中，此时，我们就可以使用序列化器的反序列化器，接下来，我们就可以参考之前定义学生信息的序列化器那样，定义一个图书的序列化器，当然，不同的是，接下来的序列化器主要用于反序列化器阶段，在unsers子应用，创建serializers.py，代码如下：

```python
from rest_framework import serializers

class BookInfoSerializer(serializers.Serializer):
    # 这里声明的字段用于进行反序列化器
    # 字段名 = serializers.字段类型(验证选项)
    title = serializers.CharField(max_length=20, label="标题", help_text="标题")
    # required=True 当前字段必填
    pub_date = serializers.DateField(required=True,label="发布日期", help_text="发布日期")
    image = serializers.ImageField(max_length=3*1024*1024, label="图书封面", help_text="图书封面")
    price = serializers.DecimalField(max_digits=8, decimal_places=2, required=True, label="价格", help_text="价格")
    read  = serializers.IntegerField(min_value=0, default=0, label="阅读量", help_text="阅读量")
    comment = serializers.IntegerField(min_value=0, default=0, label="评论量", help_text="评论量")

    # 关于继承数据库选项

    # 验证部分的代码

    # 数据库
```



通过构造序列化器对象，并将要反序列化的数据传递给data构造参数，进而进行验证

```python
# Create your views here.
from django.views import View
from django.http.response import HttpResponse
from .serializers import BookInfoSerializer
class BookInfoView(View):
    def get(self,request):
        """模拟客户端发送过来的数据"""
        data = {
            "title":"西厢记",
            "pub_date":"1980-10-10",
            "price": 19.80,
            "read": 100,
            "comment": -1,
        }

        # 对上面的数据进行反序列化器处理
        # 1. 初始化，填写data属性
        serializer = BookInfoSerializer(data=data)
        # 2. 调用序列化器提供的is_valid方法进行验证
        # raise_exception=True 表示终断程序，直接抛出错误
        ret = serializer.is_valid(raise_exception=True)
        print(ret) # is_valid的方法值就是验证结果，只会是True/False
        if ret:
            # 3.1 验证通过后，可以通过validated_data得到数据
            print("验证成功，ret=%s" % ret)
            print(serializer.validated_data)  # 验证处理后的数据
            """打印结果：
            OrderedDict([('title', '西厢记'), ('pub_date', datetime.date(1980, 10, 10)), ('price', Decimal('19.80')), ('read', 100), ('comment', 15)])
            """
        else:
            print("验证失败，ret=%s" % ret)
            # 3.1 验证没通过，可以通过
            print( serializer.errors )
            """打印结果：
            {'comment': [ErrorDetail(string='Ensure this value is greater than or equal to 0.', code='min_value')]}
            """
        return HttpResponse("ok")
```

is_valid()方法还可以在验证失败时抛出异常serializers.ValidationError，可以通过传递**raise_exception=True**参数开启，REST framework接收到此异常，会向前端返回HTTP 400 Bad Request响应。

```python
# Return a 400 response if the data was invalid.
serializer.is_valid(raise_exception=True)
```

如果觉得这些还不够，需要再补充定义验证行为，可以使用以下三种方法：

##### 1) validate_字段名

对`<field_name>`字段进行验证，如

```python
class BookInfoSerializer(serializers.Serializer):
    """图书数据序列化器"""
    ...

    # 单个字段的验证，方法名必须： validate_<字段名>(self,data)    # data 就是当前字段中客户端提交的数据
    # validate_price 会被is_valid调用
    def validate_price(self, data):
        """"""
        if data < 0:
            raise serializers.ValidationError("对不起，价格不能低于0元")
        # 验证通过以后，必须要返回验证的结果数据，否则序列化器的validated_data无法得到当前字段的结果
        return data
```

把前面的例子的price改为-19.80，运行就可以测试了。



##### 2) validate

在序列化器中需要同时对多个字段进行比较验证时，可以定义validate方法来验证，如

```python
class BookInfoSerializer(serializers.Serializer):
    """图书数据序列化器"""
    ...

    # 多个字段的验证，必须方法名叫 "validate"
    # data 表示客户端发送过来的所有数据，字典格式
    def validate(self, data):
        # 判断图书的阅读量不能低于评论量
        read = data.get("read")
        comment = data.get("comment")
        if read < comment:
            raise serializers.ValidationError("对不起，阅读量不能低于评论量")

        return data
```

运行之前的例子，把read改为1，comment改为100，访问测试。



##### 3) validators验证器

验证器类似于验证方法，但是验证方法只属于当前序列化器，如果有多个序列化器共用同样的验证功能，则可以把验证代码分离到序列化器外部，作为一个普通函数，由validators加载到序列化器中使用。

在字段中添加validators选项参数，也可以补充验证行为，如

```python
from rest_framework import serializers

# 可以把验证函数进行多次使用，提供不用的字段或者不同的序列化器里面使用
def about_django(data):
    if "django" in data:
        raise serializers.ValidationError("对不起，图书标题不能出现关键字django")
    # 返回验证以后的数据
    return data

class BookInfoSerializer(serializers.Serializer):
    # 这里声明的字段用于进行反序列化器
    # 字段名 = serializers.字段类型(验证选项)
    title = serializers.CharField(max_length=20,validators=[about_django], label="标题", help_text="标题")
    # required=True 当前字段必填
    pub_date = serializers.DateField(required=True, label="发布日期", help_text="发布日期")
    # max_length 文件的大小
    # allow_null=True 允许传递的image数据为None
    image = serializers.ImageField(required=False, allow_null=True, max_length=3*1024*1024, label="图书封面", help_text="图书封面")
    price = serializers.DecimalField(max_digits=8, decimal_places=2, required=True, label="价格", help_text="价格")
    # min_value 数值大小
    # default 设置默认值
    read  = serializers.IntegerField(min_value=0, default=0, label="阅读量", help_text="阅读量")
    comment = serializers.IntegerField(min_value=0, default=0, label="评论量", help_text="评论量")

```

把前面的例子修改成title=“西厢记django版本”，然后运行测试

视图代码：

```python
# Create your views here.
from django.views import View
from django.http.response import HttpResponse
from .serializers import BookInfoSerializer
class BookInfoView(View):
    def get(self,request):
        """模拟客户端发送过来的数据"""
        data = {
            "title":"西厢记django版本",
            "pub_date":"1980-10-10",
            "price": 19.80,
            "read": 10000,
            "comment": 100,
        }

        # 对上面的数据进行反序列化器处理
        # 1. 初始化，填写data属性
        serializer = BookInfoSerializer(data=data)
        # 2. 调用序列化器提供的is_valid方法进行验证
        # raise_exception=True 表示终断程序，直接抛出错误
        ret = serializer.is_valid(raise_exception=True)
        print(ret) # is_valid的方法值就是验证结果，只会是True/False
        if ret:
            # 3.1 验证通过后，可以通过validated_data得到数据
            print("验证成功，ret=%s" % ret)
            print(serializer.validated_data)  # 验证处理后的数据
            """打印结果：
            OrderedDict([('title', '西厢记'), ('pub_date', datetime.date(1980, 10, 10)), ('price', Decimal('19.80')), ('read', 100), ('comment', 15)])
            """
        else:
            print("验证失败，ret=%s" % ret)
            # 3.1 验证没通过，可以通过
            print( serializer.errors )
            """打印结果：
            {'comment': [ErrorDetail(string='Ensure this value is greater than or equal to 0.', code='min_value')]}
            """
        return HttpResponse("ok")
```

```text
is_valid实际上内部执行了三种不同的验证方式：
1. 先执行了字段内置的验证选项
2. 在执行了validators自定义选项
3. 最后执行了validate自定义验证方法[包含了validate_<字段>, validate]
```



#### 7.3.2.2  数据保存

通过序列化器来完成数据的更新或者添加，把视图中对于模型中的操作代码移出视图中，放入到序列化器。

前面的验证数据成功后,我们可以使用序列化器来完成数据反序列化的过程.这个过程可以把数据转成模型类对象.

可以通过实现create()和update()两个方法来实现。

```python
from rest_framework import serializers

# 可以把验证函数进行多次使用，提供不用的字段或者不同的序列化器里面使用
def about_django(data):
    if "django" in data:
        raise serializers.ValidationError("对不起，图书标题不能出现关键字django")
    # 返回验证以后的数据
    return data

class BookInfoSerializer(serializers.Serializer):
    # 这里声明的字段用于进行反序列化器
    # 字段名 = serializers.字段类型(验证选项)
    title = serializers.CharField(max_length=20,validators=[about_django], label="标题", help_text="标题")
    # required=True 当前字段必填
    pub_date = serializers.DateField(required=True, label="发布日期", help_text="发布日期")
    # max_length 文件的大小
    # allow_null=True 允许传递的image数据为None
    image = serializers.ImageField(required=False, allow_null=True, max_length=3*1024*1024, label="图书封面", help_text="图书封面")
    price = serializers.DecimalField(max_digits=8, decimal_places=2, required=True, label="价格", help_text="价格")
    # min_value 数值大小
    # default 设置默认值
    read  = serializers.IntegerField(min_value=0, default=0, label="阅读量", help_text="阅读量")
    comment = serializers.IntegerField(min_value=0, default=0, label="评论量", help_text="评论量")

    # 关于继承数据库选项

    # 自定义验证的代码
    # 单个字段的验证，方法名必须： validate_<字段名>(self,data)    # data 就是当前字段中客户端提交的数据
    # validate_price 会被is_valid调用
    def validate_price(self, data):
        """"""
        if data < 0:
            raise serializers.ValidationError("对不起，价格不能低于0元")
        # 验证通过以后，必须要返回验证的结果数据，否则序列化器的validated_data无法得到当前字段的结果
        return data

    # 多个字段的验证，必须方法名叫 "validate"
    # data 表示客户端发送过来的所有数据，字典格式
    def validate(self, data):
        # 判断图书的阅读量不能低于评论量
        read = data.get("read")
        comment = data.get("comment")
        if read < comment:
            raise serializers.ValidationError("对不起，阅读量不能低于评论量")

        return data

    # 数据库操作
    def create(self, validated_data): # 这里会在调用时，由序列化器补充验证成功以后的数据进来
        """完成添加操作"""
        print(validated_data) # 字典
        # 导入模型
        from .models import BookInfo
        # 添加数据
        book = BookInfo.objects.create(
            title=validated_data.get("title"),
            price=validated_data.get("price"),
            pub_date=validated_data.get("pub_date"),
            read=validated_data.get("read"),
            comment=validated_data.get("comment"),
        )

        return book

    # instance就是要修改的模型，系统会自动从对象初始化时的instance提取过来
    # validated_data 就是经过验证以后的客户端提交的数据
    def update(self, instance, validated_data):
        """更新操作"""
        instance.title = validated_data.get('title')
        instance.pub_date = validated_data.get('pub_date')
        instance.comment = validated_data.get('comment')
        instance.price = validated_data.get('price')
        instance.read = validated_data.get('read')
        instance.save()

        return instance

```

![image-20201021201302179](drf-第2天.assets/image-20201021201302179.png)

视图代码：

```python
# Create your views here.
from django.views import View
from django.http.response import HttpResponse
from .serializers import BookInfoSerializer
class BookInfoView(View):
    # ...
    def get(self,request):
        """保存数据[更新]"""
        # 客户端提交数据过来
        id = 2
        data = { # 模拟客户端发送过来的数据
            "title": "东游记",
            "pub_date": "1998-10-01",
            "price": 19.98,
            "read": 330,
            "comment": 100,
        }
        from .models import BookInfo
        book = BookInfo.objects.get(pk=id)

        # 使用序列化器验证数据[如果是更新操作，需要传入2个参数，分别是instance和data]
        serializer = BookInfoSerializer(instance=book,data=data)
        serializer.is_valid()
        book = serializer.save() # 此时，我们必须在序列化器中预先声明update方法
        """
        serailzier对象调用的save方法是什么？怎么做到自动调用update和create?
        1. 这里的save不是数据库ORM模型对象的save，是BaseSerializer定义的。
        2. save方法中根据实例化serializer时是否传入instance参数来判断执行update还是create的
           当传入instance时，则instance.save调用的就是update方法
           没有传入instance，则instance.save调用的就是create方法
        3. serializer.save使用前提是必须在序列化器中声明create或者update方法，否则报错！！！
        """
        print(book)
        """打印结果：
        BookInfo object (2)
        """
        return HttpResponse("ok")
```

在序列化器实现了create和update两个方法后，在反序列化数据的时候，就可以通过save()方法返回一个数据对象实例了

```python
book = serializer.save()
```



如果创建序列化器对象的时候，没有传递instance实例，则调用save()方法的时候，create()被调用，相反，如果传递了instance实例，则调用save()方法的时候，update()被调用。

```python
serailzier对象调用的save方法是什么？怎么做到自动调用update和create?
1. 这里的save不是数据库ORM模型对象的save，是BaseSerializer定义的。
2. save方法中根据实例化serializer时是否传入instance参数来判断执行update还是create的
当传入instance时，则instance.save调用的就是update方法
没有传入instance，则instance.save调用的就是create方法
3. serializer.save使用前提是必须在序列化器中声明create或者update方法，否则报错！！！
```

BaseSerializer中定义的save方法源码：

![1582086563954](assets/1582086563954.png)



#### 7.3.2.3 附加参数说明

1） 在对序列化器进行save()保存时，可以额外传递数据，这些数据可以在create()和update()中的validated_data参数获取到

```python
# 可以传递任意参数到数据保存方法中
# 例如：request.user 是django中记录当前登录用户的模型对象
serializer.save(owner=request.user)
```

2）默认序列化器必须传递所有必填字段[required=True]，否则会抛出验证异常。但是我们可以使用partial参数来允许部分字段更新

```python
# Update `BookInfo` with partial data
# partial=True 设置序列化器只是针对客户端提交的字段进行验证，没有提交的字段，即便有验证选项或方法也不进行验证。
serializer = BookInfoSerializer(book, data=data, partial=True)
```





### 7.3.3 模型类序列化器

如果我们想要使用序列化器对应的是Django的模型类，DRF为我们提供了ModelSerializer模型类序列化器来帮助我们快速创建一个Serializer类。

ModelSerializer与常规的Serializer相同，但提供了：

- 基于模型类自动生成一系列序列化器字段
- 基于模型类自动为Serializer生成validators，比如unique_together
- 包含默认的create()和update()的实现

#### 7.3.3.1 定义

比如我们创建一个BookInfoSerializer

```python
class BookInfoSerializer(serializers.ModelSerializer):
    """图书数据序列化器"""
    class Meta:
        model = BookInfo
        fields = '__all__'
```

- model 指明参照哪个模型类
- fields 指明为模型类的哪些字段生成

我们可以在python manage.py shell中查看自动生成的BookInfoSerializer的具体实现

```python
>>> from booktest.serializers import BookInfoSerializer
>>> serializer = BookInfoSerializer()
>>> serializer
BookInfoSerializer():
    id = IntegerField(label='ID', read_only=True)
    btitle = CharField(label='名称', max_length=20)
    bpub_date = DateField(allow_null=True, label='发布日期', required=False)
    bread = IntegerField(label='阅读量', max_value=2147483647, min_value=-2147483648, required=False)
    bcomment = IntegerField(label='评论量', max_value=2147483647, min_value=-2147483648, required=False)
    image = ImageField(allow_null=True, label='图片', max_length=100, required=False)
```

#### 7.3.3.2 指定字段

1) 使用**fields**来明确字段，`__all__`表名包含所有字段，也可以写明具体哪些字段，如

```python
class BookInfoSerializer(serializers.ModelSerializer):
    """图书数据序列化器"""
    class Meta:
        model = BookInfo
        fields = ('id', 'btitle', 'bpub_date')
```

2) 使用**exclude**可以明确排除掉哪些字段

```python
class BookInfoSerializer(serializers.ModelSerializer):
    """图书数据序列化器"""
    class Meta:
        model = BookInfo
        exclude = ('image',)
```

3) 显示指明字段，如：

```python
class HeroInfoSerializer(serializers.ModelSerializer):
    hbook = BookInfoSerializer()

    class Meta:
        model = HeroInfo
        fields = ('id', 'hname', 'hgender', 'hcomment', 'hbook')
```

4) 指明只读字段

可以通过**read_only_fields**指明只读字段，即仅用于序列化输出的字段

```python
class BookInfoSerializer(serializers.ModelSerializer):
    """图书数据序列化器"""
    class Meta:
        model = BookInfo
        fields = ('id', 'title', 'pub_date'， 'read', 'comment')
        read_only_fields = ('id', 'read', 'comment')
```



#### 7.3.3.3 添加额外参数

我们可以使用**extra_kwargs**参数为ModelSerializer添加或修改原有的选项参数

```python
class BookInfoSerializer(serializers.ModelSerializer):
    """图书数据序列化器"""
    class Meta:
        model = BookInfo
        fields = ('id', 'btitle', 'bpub_date', 'bread', 'bcomment')
        extra_kwargs = {
            'bread': {'min_value': 0, 'required': True},
            'bcomment': {'min_value': 0, 'required': True},
        }

# BookInfoSerializer():
#    id = IntegerField(label='ID', read_only=True)
#    btitle = CharField(label='名称', max_length=20)
#    bpub_date = DateField(allow_null=True, label='发布日期', required=False)
#    bread = IntegerField(label='阅读量', max_value=2147483647, min_value=0, required=True)
#    bcomment = IntegerField(label='评论量', max_value=2147483647, min_value=0, required=True)
```





```python
ModelSerializer在保存空数据的时候能保存上？
```



## 作业

```text
在django项目中实现5个基本的学生信息的API接口，返回json格式数据提供给客户端。
  1. 使用今天所学的序列化器对数据进行处理。
  2. 使用基本序列化器。
  3. [选做题]，预习ModelSerilzer模型序列化器，然后基于模型序列化器来实现5个api接口
```


