---
title: "Laravel 入门"
weight: 1
date: 2026-06-16
tags: ["PHP", "Laravel", "框架"]
---

这篇介绍 Laravel 的核心特性、安装方式和基本概念，适合了解现代 PHP 框架开发的入门参考。Laravel 是目前 PHP 生态中最流行的全栈框架。

## Laravel 是什么

Laravel 是一个基于 MVC（Model-View-Controller）架构的 PHP 全栈框架，提供了一整套开箱即用的工具：

| 组件 | 说明 |
| --- | --- |
| **Artisan** | 命令行工具，自动生成代码、运行迁移、管理任务 |
| **Eloquent ORM** | 优雅的数据库操作，将数据表映射为 PHP 对象 |
| **Blade** | 轻量级模板引擎，支持布局、组件和条件渲染 |
| **路由系统** | 强大的 URL 路由，支持中间件、分组和资源路由 |
| **迁移系统** | 用代码管理数据库结构，版本可控 |
| **Laravel Mix/Vite** | 前端资源编译和打包 |

## 安装

前提：PHP 8.1+、Composer、Node.js（可选）。

```bash
composer create-project laravel/laravel my-app
cd my-app
php artisan serve   # 启动开发服务器，默认 http://localhost:8000
```

{{< callout type="info" >}}
`php artisan serve` 启动的是 PHP 内置开发服务器，仅适合本地开发。生产环境请使用 Nginx/Apache 作为 Web 服务器。
{{< /callout >}}

## 目录结构概览

| 目录 | 用途 |
| --- | --- |
| `app/Models/` | Eloquent 模型（数据层） |
| `app/Http/Controllers/` | 控制器（处理请求） |
| `routes/web.php` | Web 路由定义 |
| `resources/views/` | Blade 模板文件 |
| `database/migrations/` | 数据库迁移文件 |
| `config/` | 应用配置文件 |

## 路由与控制器

基本路由定义在 `routes/web.php`：

```php
<?php
// 简单路由——直接返回内容
Route::get('/', function () {
    return view('welcome');
});

// 指向控制器方法
Route::get('/users', [UserController::class, 'index']);
?>
```

控制器示例：

```php
<?php
namespace App\Http\Controllers;

use App\Models\User;

class UserController extends Controller
{
    public function index()
    {
        $users = User::all();
        return view('users.index', compact('users'));
    }
}
?>
```

## Eloquent ORM

Eloquent 让你用对象的方式操作数据库：

```php
<?php
// 查询所有用户
$users = User::all();

// 条件查询
$admin = User::where('role', 'admin')->first();

// 创建记录
User::create([
    'name' => '张三',
    'email' => 'zhangsan@example.com',
    'password' => bcrypt('secret'),
]);

// 关联查询
$posts = User::find(1)->posts;  // 获取用户的所有文章
?>
```

## Blade 模板

```blade
{{-- resources/views/users/index.blade.php --}}
@extends('layouts.app')

@section('content')
    <h1>用户列表</h1>
    @foreach ($users as $user)
        <p>{{ $user->name }} - {{ $user->email }}</p>
    @endforeach
@endsection
```

{{< callout type="tip" >}}
Laravel 有最好的中文文档之一：[learnku.com/docs/laravel](https://learnku.com/docs/laravel)。框架学习曲线比 ThinkPHP 略陡，但生态（包、教程、社区）更完善。
{{< /callout >}}

## 一句话小结

Laravel 是 PHP 最流行的全栈框架，核心是 MVC + Eloquent + Blade + Artisan。适合中大型项目和追求现代化开发流程的团队。下一篇了解国内更流行的 [ThinkPHP](../02ThinkPHP入门/)。
