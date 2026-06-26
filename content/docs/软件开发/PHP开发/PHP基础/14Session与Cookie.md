---
title: "Session 与 Cookie"
weight: 14
date: 2026-06-16
tags: ["PHP", "Session", "Cookie", "安全"]
---

这篇讲 PHP 中 Session 和 Cookie 的用法：如何保存用户状态、跨页面传递数据，以及安全配置的最佳实践。这是实现登录系统、购物车、用户偏好等功能的基础。

## Cookie 基础

Cookie 是存储在**客户端浏览器**中的一小段数据（通常不超过 4KB），每次请求时自动发送给服务器。

### 设置 Cookie

使用 `setcookie()` 函数——**必须在任何 HTML 输出之前调用**：

```php
<?php
// 基本用法
setcookie('username', 'php_dev', time() + 3600);  // 1 小时后过期

// 完整参数
setcookie(
    'username',       // 名称
    'php_dev',        // 值
    time() + 3600,    // 过期时间（Unix 时间戳）
    '/',              // 有效路径
    '',               // 有效域名
    true,             // Secure：仅 HTTPS
    true              // HttpOnly：JavaScript 无法访问
);
?>
```

### 读取和删除 Cookie

```php
<?php
// 读取
echo $_COOKIE['username'];  // php_dev

// 删除：设置过去的时间
setcookie('username', '', time() - 3600);
?>
```

## Session 基础

Session 的数据存储在**服务器端**，客户端只保存一个 Session ID（通常通过 Cookie 传递）。适合存储敏感信息（如用户登录状态）。

### Session 的基本操作

```php
<?php
// 1. 启动 Session——必须在任何输出之前
session_start();

// 2. 写入数据
$_SESSION['user_id'] = 123;
$_SESSION['username'] = 'php_dev';

// 3. 读取数据
echo $_SESSION['username'];  // php_dev

// 4. 修改数据
$_SESSION['username'] = 'new_name';

// 5. 删除单个键
unset($_SESSION['user_id']);

// 6. 销毁整个 Session
session_destroy();
?>
```

{{< callout type="warning" >}}
`session_start()` 必须在**任何 HTML 输出之前**调用，因为它需要设置 HTTP 头。和 `setcookie()` 一样，前面不能有任何 `echo`、`print` 或 HTML。
{{< /callout >}}

## Cookie vs Session 对比

| 特性 | Cookie | Session |
| --- | --- | --- |
| 数据存储位置 | 客户端浏览器 | 服务器端 |
| 安全性 | 低（用户可见、可篡改） | 高（用户只拿到 ID） |
| 容量 | 约 4KB | 仅受服务器内存限制 |
| 持久性 | 可设置长过期时间 | 默认关闭浏览器即失效 |
| 敏感数据 | **不应存储** | **适合存储** |

## 安全配置

### 安全的 Session 配置

PHP 7+ 支持在 `session_start()` 时直接传入安全选项：

```php
<?php
session_start([
    'name' => '__Secure-SessionId',     // 自定义 Session 名称
    'cookie_lifetime' => 0,            // 0 = 浏览器关闭时过期
    'cookie_path' => '/',              // Cookie 在整个网站可用
    'cookie_secure' => true,           // 仅通过 HTTPS 传输
    'cookie_httponly' => true,         // 禁止 JavaScript 访问
    'cookie_samesite' => 'Strict',     // 严格同站策略，防 CSRF
    'use_strict_mode' => true,         // 拒绝未初始化的 Session ID
]);
?>
```

### 安全的 Cookie 设置

```php
<?php
// 始终设置 HttpOnly 和 Secure 标志
setcookie('remember_token', $token, [
    'expires' => time() + 86400 * 30,
    'path' => '/',
    'secure' => true,          // HTTPS only
    'httponly' => true,        // 禁止 document.cookie 读取
    'samesite' => 'Strict',    // 防 CSRF
]);
?>
```

{{< callout type="warning" >}}
**安全三条铁律**：
1. 敏感数据用 Session，别用 Cookie
2. Session 和 Cookie 都设置 `HttpOnly` + `Secure` 标志
3. `SameSite=Strict` 能有效防御 CSRF 攻击
{{< /callout >}}

## 典型应用场景

**登录系统**：

```php
<?php
session_start();

// 登录——验证密码后
$_SESSION['user_id'] = $user['id'];
$_SESSION['logged_in'] = true;

// 检查登录状态
function isLoggedIn(): bool {
    return isset($_SESSION['logged_in']) && $_SESSION['logged_in'] === true;
}

// 登出
session_destroy();
?>
```

**"记住我"勾选框**——用 Cookie 存储长期有效的 token：

```php
<?php
// 勾选了"记住我"
if ($rememberMe) {
    $token = bin2hex(random_bytes(32));
    setcookie('remember_token', $token, time() + 86400 * 30, '/', '', true, true);
    // 同时将 token 的哈希存入数据库，下次自动登录时验证
}
?>
```

## 一句话小结

Cookie 存客户端，Session 存服务器。敏感数据放 Session，非敏感偏好放 Cookie。安全三要素：`HttpOnly` + `Secure` + `SameSite`。`session_start()` 和 `setcookie()` 必须在输出 HTML 之前调用。

---

> 至此 PHP 基础系列完结。掌握了 14 篇涵盖的内容，你已经具备了用 PHP 进行 Web 开发的扎实基础。接下来可以阅读 [PHP 与数据库](../../PHP数据库/01PDO与MySQLi/) 学习数据库操作，或 [PHP 框架](../../PHP框架/01Laravel入门/) 了解现代化 PHP 开发流程。
