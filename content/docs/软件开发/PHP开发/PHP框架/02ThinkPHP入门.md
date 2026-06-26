---
title: "ThinkPHP 入门"
weight: 2
date: 2026-06-16
tags: ["PHP", "ThinkPHP", "框架"]
---

这篇介绍 ThinkPHP 的核心设计思路和快速上手方法。ThinkPHP 是国内使用最广泛的 PHP 框架之一，中文文档完善，适合快速开发。

## ThinkPHP 是什么

ThinkPHP 是一个国产开源 PHP 框架，以快速开发和实用性著称。当前主流版本是 ThinkPHP 6.x（长期支持）和 ThinkPHP 8.x。

核心特点：

- **MVC 架构**：清晰的分层设计
- **ORM**：内置强大的模型和关联操作
- **命令行工具**：快速生成代码、管理迁移
- **多应用模式**：一个项目可包含多个独立应用
- **丰富的扩展**：验证器、缓存、队列、消息通知等

## 安装

前提：PHP 8.0+、Composer。

```bash
composer create-project topthink/think my-app
cd my-app
php think run   # 启动开发服务器
```

{{< callout type="info" >}}
ThinkPHP 8.x 需要 PHP 8.0+。如果是维护老项目（ThinkPHP 5.x/3.x），注意 PHP 版本兼容性。
{{< /callout >}}

## 目录结构概览

| 目录 | 用途 |
| --- | --- |
| `app/controller/` | 控制器 |
| `app/model/` | 模型 |
| `app/middleware/` | 中间件 |
| `route/app.php` | 路由定义 |
| `view/` | 模板文件 |
| `config/` | 配置文件 |

## 路由与控制器

路由定义在 `route/app.php`：

```php
<?php
use think\facade\Route;

// 简单路由
Route::get('/', 'index/index');

// 资源路由
Route::resource('users', 'User');
?>
```

控制器示例：

```php
<?php
namespace app\controller;

use app\model\User;
use think\facade\View;

class UserController
{
    public function index()
    {
        $users = User::select();
        return View::fetch('index', ['users' => $users]);
    }
}
?>
```

## 模型操作

ThinkPHP 的 ORM 提供了流畅的查询方式：

```php
<?php
use app\model\User;

// 查询
$users = User::where('status', 1)->select();

// 创建
User::create([
    'name' => '张三',
    'email' => 'zhangsan@example.com',
]);

// 关联模型——User 模型的 posts 方法定义了 hasMany 关系
// $posts = User::find(1)->posts;
?>
```

{{< callout type="tip" >}}
ThinkPHP 的官方文档（[doc.thinkphp.cn](https://doc.thinkphp.cn)）对国内开发者非常友好。框架在中小企业、政府项目和快速原型开发中使用率很高。前一篇文章介绍了 [Laravel](../01Laravel入门/)，两者都是优秀的 PHP 框架，选择取决于团队习惯和项目需求。
{{< /callout >}}

## ThinkPHP vs Laravel

| 方面 | ThinkPHP | Laravel |
| --- | --- | --- |
| 学习曲线 | 平缓，上手快 | 略陡，概念更多 |
| 中文文档 | 原生中文，完善 | 翻译文档，有时滞 |
| 社区生态 | 国内活跃 | 全球最活跃 |
| 设计理念 | 实用、快速 | 优雅、规范 |
| 适用场景 | 国内项目、快速开发 | 国际化项目、大型应用 |

## 一句话小结

ThinkPHP 是国产 PHP 框架首选，上手快、中文文档好、在国内企业中使用广泛。与 Laravel 各有所长——选框架不如选懂框架。更多基础内容参见 [PHP 基础](../../PHP基础/01PHP简介/)。
