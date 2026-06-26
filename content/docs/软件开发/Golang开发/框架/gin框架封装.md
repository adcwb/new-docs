---
title: "Gin 框架封装"
weight: 10
date: 2026-06-05
tags: ["Go", "Gin", "Web框架", "中间件"]
---

## gin框架封装



### 项目初始化

```go
// gin框架安装
go get -u github.com/gin-gonic/gin

// 创建项目根目录
mkdir goDemo

// 初始化go.mod文件
go mod init

// 创建启动文件main.go，并写入以下内容
package main

import (
    "github.com/gin-gonic/gin"
    "net/http"
)

func main() {
    r := gin.Default()

    // 测试路由
    r.GET("/hello", func(c *gin.Context) {
        c.String(http.StatusOK, "hello gin")
    })

    // 启动服务器
    r.Run(":8080")
}

// 执行 go run main.go 启动应用
```



### 配置文件封装

配置文件是每个项目必不可少的部分，用来保存应用基本数据、数据库配置等信息，避免要修改一个配置项需要到处找的尴尬。这里我使用 [viper](https://link.juejin.cn?target=https%3A%2F%2Fgithub.com%2Fspf13%2Fviper) 作为配置管理方案，它支持 JSON、TOML、YAML、HCL、envfile、Java properties 等多种格式的配置文件，并且能够监听配置文件的修改，进行热重载，详细介绍大家可以去官方文档查看

```GO
// 安装
go get -u github.com/spf13/viper

// 创建settings文件夹，作为配置文件存放目录
mkdir settings


```



```bash

```



```bash

```

