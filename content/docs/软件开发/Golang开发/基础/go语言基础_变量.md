---
title: "安装与变量"
weight: 20
date: 2026-06-05
tags: ["Go", "安装", "变量", "常量"]
---

本文覆盖 Go 开发环境搭建和变量 / 常量的核心语法。安装完成后运行第一个程序验证环境，然后深入理解 `var`、`:=`、`const`、`iota` 的使用规则。

## 安装 Go

从官网或镜像站下载对应平台的安装包：

- 官网：[golang.org/dl/](https://golang.org/dl/)
- 国内镜像：[golang.google.cn/dl/](https://golang.google.cn/dl/)

### Linux

```bash
# 下载并解压（以 1.22 为例，请替换为当前最新版本）
wget https://golang.org/dl/go1.22.0.linux-amd64.tar.gz
rm -rf /usr/local/go
tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz

# 写入 /etc/profile 使开机生效
export PATH=$PATH:/usr/local/go/bin

# 验证
go version
```

### Windows

下载 `.msi` 安装包双击安装，默认勾选「添加到 PATH」。

Go 1.8+ 会自动设置 `GOPATH` 默认值，无需手动配置。国内推荐设置代理：

```bash
go env -w GOPROXY=https://goproxy.cn,direct
```

### macOS

```bash
# Homebrew
brew install go

# 或下载 .pkg 安装包，默认安装到 /usr/local/go
```

## 第一个 Go 程序

新建 `main.go` 并运行：

```go
package main  // 声明 main 包，表示可执行程序

import "fmt"  // 导入内置 fmt 包

func main() {           // 程序入口
    fmt.Println("Hello World!")
}
```

```bash
go run main.go   # 直接运行
go build         # 编译为可执行文件
```

## 项目目录结构

模块模式（Go 1.11+）下不再强制要求代码放在 `$GOPATH/src` 内。推荐结构：

```text
myproject/
├── go.mod          # 模块定义
├── go.sum          # 依赖校验
├── main.go         # 入口
├── internal/       # 私有包
└── pkg/            # 可导出包
```

## 标识符与关键字

**标识符**由字母、数字和下划线组成，只能以字母或下划线开头，例如 `abc`、`_tmp`、`a123`。

Go 共有 **25 个关键字**，不可用作标识符：

```text
break    default     func    interface  select
case     defer       go      map        struct
chan     else        goto    package    switch
const    fallthrough if      range      type
continue for        import  return     var
```

另有 **37 个预声明标识符**（内置类型、函数、常量），建议不要遮蔽（shadow）它们：

```text
常量:  true  false  iota  nil
类型:  int  int8  int16  int32  int64  uint  uint8  uint16  uint32  uint64
       uintptr  float32  float64  complex128  complex64  bool  byte  rune  string  error
函数:  make  len  cap  new  append  copy  close  delete
       complex  real  imag  panic  recover
```

## 变量

### 声明方式

Go 变量必须先声明后使用，同一作用域内不允许重复声明。

**标准声明**：

```go
var name string
var age  int
var isOk bool
```

**批量声明**：

```go
var (
    a string
    b int
    c bool
    d float32
)
```

### 变量初始化

声明时若不赋值，Go 会自动初始化为**零值**（整型 `0`、浮点 `0.0`、字符串 `""`、布尔 `false`、指针/切片/map/通道/函数 `nil`）：

```go
var name string = "Alice"
var age  int    = 18

// 类型推导（省略类型，编译器自动推断）
var name = "Alice"
var age  = 18
```

### 短变量声明（`:=`）

函数内部可用更简洁的 `:=` 同时声明和初始化，**只能在函数体内使用**：

```go
func main() {
    hi := "hello"   // 等价于 var hi = "hello"
    fmt.Println(hi)
}
```

{{< callout type="warning" >}}
短变量声明语句中**至少要有一个新变量**，否则应使用普通赋值 `=`。函数外使用 `:=` 会导致编译错误。
{{< /callout >}}

### 匿名变量（`_`）

多返回值时，用 `_` 忽略不需要的值，匿名变量不占命名空间、不分配内存：

```go
func foo() (int, string) {
    return 10, "Alice"
}

func main() {
    x, _ := foo()   // 只取第一个返回值
    _, y := foo()   // 只取第二个返回值
    fmt.Println(x, y)
}
```

## 常量

常量用 `const` 声明，定义后值不可改变：

```go
const pi = 3.14159
const e  = 2.71828

// 批量声明
const (
    StatusOK    = 200
    StatusNotFound = 404
)
```

`const` 块中，若省略值则表示与上一行相同：

```go
const (
    n1 = 100
    n2       // 100
    n3       // 100
)
```

## iota —— 常量计数器

`iota` 是 Go 内置的常量计数器，每遇到一个 `const` 关键字就重置为 0，`const` 块中每新增一行（不论是否使用 `iota`）自动加 1。

```go
const (
    a1 = iota  // 0
    a2 = iota  // 1
    a3 = 6     // 6（自定义值）
    a4         // 6（同上一行）
    a5 = iota  // 4（iota 计数已到第 5 行）
)
```

常见用法：

```go
// 跳过某些值
const (
    n1 = iota  // 0
    n2         // 1
    _          // 跳过 2
    n4         // 3
)

// 定义数量级（KB / MB / GB …）
const (
    _  = iota
    KB = 1 << (10 * iota)   // 1024
    MB = 1 << (10 * iota)   // 1048576
    GB = 1 << (10 * iota)
    TB = 1 << (10 * iota)
    PB = 1 << (10 * iota)
)

// 多个 iota 定义在同一行
const (
    a, b = iota + 1, iota + 2   // 1, 2
    c, d                         // 2, 3
    e, f                         // 3, 4
)
```
