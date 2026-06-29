---
title: "RESTful 与 DRF 入门"
weight: 10
date: 2026-06-29
tags: ["Python", "Django", "DRF", "REST", "API"]
---

Django REST framework（DRF）是构建在 Django 之上的 Web API 开发框架，专为前后端分离架构设计。本文从 RESTful 设计规范讲起，介绍 DRF 的核心特性、安装配置，并通过一个完整的五步示例带你快速上手。

## 前后端分离与 RESTful

### 两种 Web 应用模式

传统的前后端不分离模式中，服务端直接返回渲染好的 HTML 页面，前后端耦合紧密，难以复用接口。

前后端分离模式中，后端只提供数据（JSON/XML），前端框架（React、Vue 等）或移动客户端负责渲染。双方通过 API 接口解耦，使得同一套后端接口可同时服务 Web、iOS、Android、小程序等多端。

### RESTful 设计规范

REST（Representational State Transfer）由 Roy Fielding 在 2000 年的博士论文中提出，是目前最主流的 API 接口设计风格。其核心思想是：**把后端所有数据视为资源，用 URL 声明资源位置，用 HTTP 方法声明对资源的操作**。

**URL 命名规则**

- URL 中只出现名词（复数），不出现动词。
- 使用 `/` 分隔资源层级，末尾不加 `/`。
- 禁止写 `/getStudents`、`/deleteOrder` 这类含动词的路径。

```text
# 正确
GET  /api/students          # 获取学生列表
POST /api/students          # 创建学生
GET  /api/students/5        # 获取 id=5 的学生
PUT  /api/students/5        # 整体更新
PATCH /api/students/5       # 部分更新
DELETE /api/students/5      # 删除
```

**HTTP 方法对应语义**

| 方法   | 对应操作 | 说明                       |
| :----- | :------- | :------------------------- |
| GET    | 查询     | 幂等；不修改服务器状态     |
| POST   | 创建     | 非幂等；返回 201           |
| PUT    | 整体更新 | 幂等；需提供完整资源       |
| PATCH  | 部分更新 | 幂等；只提交变化字段       |
| DELETE | 删除     | 幂等；返回 204 No Content  |

**常用状态码**

| 状态码 | 含义                                    |
| :----- | :-------------------------------------- |
| 200    | OK — 请求成功                           |
| 201    | Created — 资源创建成功                  |
| 204    | No Content — 删除成功，无响应体         |
| 400    | Bad Request — 请求参数有误              |
| 401    | Unauthorized — 未认证                   |
| 403    | Forbidden — 已认证但无权限              |
| 404    | Not Found — 资源不存在                  |
| 500    | Internal Server Error — 服务端错误      |

**版本管理**

推荐将 API 版本号放入 URL：

```text
/api/v1/students/
/api/v2/students/
```

**错误响应格式**

错误时统一返回 JSON，以 `detail` 或 `error` 作为错误键名：

```json
{
    "detail": "Authentication credentials were not provided."
}
```

## Django REST framework 简介

DRF 是建立在 Django 之上的专业 REST API 框架，主要特性：

- **序列化器**（Serializer）：将模型对象与 JSON 互相转换，并内置数据校验。
- **类视图体系**：从 `APIView` → `GenericAPIView` → `Mixin` → `ViewSet`，逐级简化代码。
- **认证 & 权限 & 限流**：内置 Session、Token 认证，以及细粒度权限控制和访问频率限制。
- **过滤 & 排序 & 分页**：与 `django-filter` 无缝集成。
- **可视化 API 文档**：浏览器访问接口时自动渲染可交互的文档页面。

官方文档：<https://www.django-rest-framework.org/>

## 安装与配置

**环境要求**：Python 3.8+，Django 3.2+

```bash
pip install djangorestframework
```

在 `settings.py` 的 `INSTALLED_APPS` 中注册：

```python
INSTALLED_APPS = [
    ...
    'rest_framework',
]
```

可选的全局配置（放在 `settings.py` 中）：

```python
REST_FRAMEWORK = {
    'DEFAULT_RENDERER_CLASSES': [
        'rest_framework.renderers.JSONRenderer',
        'rest_framework.renderers.BrowsableAPIRenderer',  # 开发时可视化界面
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',  # 默认放开，生产环境按需收紧
    ],
}
```

## 五步快速上手

下面用一个学生管理接口演示 DRF 最简洁的开发路径，五步完成全量 CRUD。

{{< steps >}}

### 定义模型

在 `students/models.py` 中：

```python
from django.db import models

class Student(models.Model):
    name        = models.CharField(max_length=100, verbose_name="姓名")
    sex         = models.BooleanField(default=True, verbose_name="性别")
    age         = models.IntegerField(verbose_name="年龄")
    class_null  = models.CharField(max_length=5, verbose_name="班级编号")
    description = models.TextField(max_length=1000, verbose_name="个性签名")

    class Meta:
        db_table = "tb_student"
        verbose_name = "学生"
        verbose_name_plural = verbose_name
```

执行数据迁移：

```bash
python manage.py makemigrations
python manage.py migrate
```

### 创建序列化器

在 `students/serializers.py` 中：

```python
from rest_framework import serializers
from .models import Student

class StudentModelSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Student
        fields = "__all__"
```

### 编写视图

在 `students/views.py` 中：

```python
from rest_framework.viewsets import ModelViewSet
from .models import Student
from .serializers import StudentModelSerializer

class StudentViewSet(ModelViewSet):
    queryset         = Student.objects.all()
    serializer_class = StudentModelSerializer
```

`ModelViewSet` 自动提供列表、创建、详情、更新、删除五个接口，无需手写任何 HTTP 方法。

### 配置路由

在 `students/urls.py` 中：

```python
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register('students', views.StudentViewSet)

urlpatterns = router.urls
```

在项目总路由 `urls.py` 中引入：

```python
from django.urls import path, include

urlpatterns = [
    path('api/', include('students.urls')),
]
```

### 启动测试

```bash
python manage.py runserver
```

访问 `http://127.0.0.1:8000/api/students/`，DRF 会渲染可交互的 API 文档页面。自动生成的接口：

| 路径                          | 方法           | 功能     |
| :---------------------------- | :------------- | :------- |
| `/api/students/`              | GET            | 获取列表 |
| `/api/students/`              | POST           | 创建     |
| `/api/students/{id}/`         | GET            | 获取详情 |
| `/api/students/{id}/`         | PUT / PATCH    | 更新     |
| `/api/students/{id}/`         | DELETE         | 删除     |

{{< /steps >}}

## 序列化与反序列化概念

API 开发中最核心的转换过程：

**序列化**：将服务端的模型对象转换为 JSON 字符串，返回给前端。

```text
Student 对象  →  序列化器  →  Python 字典  →  JSON 字符串  →  HTTP 响应
```

**反序列化**：将前端提交的 JSON 数据校验、转换为模型对象，保存到数据库。

```text
HTTP 请求  →  JSON 字符串  →  Python 字典  →  序列化器校验  →  模型对象  →  数据库
```

序列化器（`Serializer` / `ModelSerializer`）同时承担这两个方向的工作，详见[序列化器](../02-序列化器/)。
