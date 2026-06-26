---
title: "PDO 与 MySQLi"
weight: 1
date: 2026-06-16
tags: ["PHP", "数据库", "PDO", "MySQLi"]
---

这篇讲 PHP 连接 MySQL 数据库的两种主流方式——PDO 和 MySQLi——的选择依据、连接方法和基本查询操作。

## PDO vs MySQLi

PHP 提供了两种操作 MySQL 的扩展，各有特点：

| 特性 | PDO | MySQLi |
| --- | :---: | :---: |
| 数据库支持 | 12 种数据库（MySQL、PostgreSQL、SQLite 等） | 仅 MySQL |
| API 风格 | 纯面向对象 | 面向过程 + 面向对象双模式 |
| 命名参数 | 支持（`:name`） | 不支持（仅 `?`） |
| 未缓冲查询 | 支持 | 支持 |
| 推荐场景 | 需要跨数据库兼容 | 只用 MySQL 的老项目 |

{{< callout type="tip" >}}
**推荐 PDO**。它支持更多数据库类型，命名参数让预处理语句更可读，且换数据库只需改 DSN，无需重写代码。
{{< /callout >}}

## PDO 连接

```php
<?php
$dsn = 'mysql:host=localhost;dbname=test;charset=utf8mb4';
$user = 'root';
$pass = '';

try {
    $pdo = new PDO($dsn, $user, $pass, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,   // 异常模式
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,  // 默认关联数组
        PDO::ATTR_EMULATE_PREPARES => false,            // 使用真正的预处理语句
    ]);
} catch (PDOException $e) {
    die('数据库连接失败：' . $e->getMessage());
}
?>
```sql

## PDO 查询

### 简单查询

```php
<?php
// 无参数的查询
$stmt = $pdo->query('SELECT id, name FROM users');
$users = $stmt->fetchAll();

foreach ($users as $user) {
    echo $user['name'] . '<br>';
}
?>
```

### 预处理语句（防 SQL 注入）

```php
<?php
// 使用命名参数（推荐）
$stmt = $pdo->prepare('SELECT * FROM users WHERE email = :email');
$stmt->execute(['email' => 'user@example.com']);
$user = $stmt->fetch();

// 插入数据
$stmt = $pdo->prepare('INSERT INTO users (name, email) VALUES (:name, :email)');
$stmt->execute([
    'name' => '张三',
    'email' => 'zhangsan@example.com',
]);
echo '最后插入 ID：' . $pdo->lastInsertId();
?>
```sql

### 获取结果的不同方式

```php
<?php
$stmt = $pdo->query('SELECT * FROM users');

$row = $stmt->fetch();       // 单行（关联数组）
$rows = $stmt->fetchAll();   // 所有行（二维数组）
$col = $stmt->fetchColumn(); // 单列值
$obj = $stmt->fetchObject(); // 单行（对象）
?>
```

## MySQLi 连接与查询

MySQLi 提供面向过程和面向对象两种写法：

```php
<?php
// 面向对象风格
$mysqli = new mysqli('localhost', 'root', '', 'test');

if ($mysqli->connect_error) {
    die('连接失败：' . $mysqli->connect_error);
}

// 预处理语句
$stmt = $mysqli->prepare('SELECT name, email FROM users WHERE id = ?');
$stmt->bind_param('i', $id);  // 'i' = integer
$id = 1;
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();
?>
```text

## 一句话小结

PDO 是 PHP 数据库操作的推荐选择——跨数据库、命名参数、异常模式三大优势。无论用哪种方式，**始终使用预处理语句**——它是防御 SQL 注入的第一道防线。下一篇讲 [数据库安全与最佳实践](../02数据库查询最佳实践/)。
