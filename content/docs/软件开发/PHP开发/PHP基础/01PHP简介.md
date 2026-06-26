---
title: "PHP 简介与环境搭建"
weight: 1
date: 2026-06-16
tags: ["PHP", "入门", "环境"]
---

这篇介绍 PHP 是什么、能做什么、为什么选择它，以及在本地搭建 PHP 开发环境的方法。适合初次接触 PHP 的开发者快速建立整体认知。

## PHP 是什么

- PHP 是 "PHP: Hypertext Preprocessor" 的递归缩写
- PHP 是一种被广泛使用的开源服务器端脚本语言
- PHP 代码在服务器上执行，结果以纯文本（通常是 HTML）返回给浏览器
- PHP 文件后缀为 `.php`，可以包含文本、HTML、CSS 和 PHP 代码

## PHP 能做什么

- 生成动态页面内容
- 创建、读取、写入、删除服务器上的文件
- 接收并处理表单数据
- 发送和读取 Cookie
- 操作数据库（MySQL、PostgreSQL、SQLite 等）
- 限制用户访问网站中的特定页面
- 对数据进行加密
- 输出图像、PDF 等非 HTML 内容

## 为什么选择 PHP

- **跨平台**：运行于 Windows、Linux、macOS 等主流操作系统
- **兼容性强**：支持几乎所有主流 Web 服务器（Apache、Nginx、IIS）
- **数据库支持广泛**：原生支持 MySQL、PostgreSQL、SQLite 等
- **免费开源**：零成本获取和使用，社区庞大
- **易于上手**：语法简洁，学习曲线平缓，适合快速开发

## 环境搭建

有三种常见方式开始 PHP 开发：

1. **使用集成环境**（推荐新手）：如 XAMPP、Laragon、MAMP，一键安装 Apache + PHP + MySQL
2. **使用 Web 主机**：购买支持 PHP 的虚拟主机，上传 `.php` 文件即可运行
3. **手动安装**：分别安装 Web 服务器、PHP 解释器和数据库

{{< callout type="info" >}}
官方安装指南：[php.net/manual/zh/install.php](https://www.php.net/manual/zh/install.php)。建议新手从 Laragon（Windows）或 XAMPP（跨平台）开始，避免手动配置的繁琐。
{{< /callout >}}

## 一句话小结

PHP 是服务器端脚本语言，免费、跨平台、易上手，特别适合 Web 开发。环境搭建推荐从集成环境开始，把精力留给写代码本身。下一篇进入 [基本语法与输出](../02基本语法/)，开始写第一段 PHP 代码。
