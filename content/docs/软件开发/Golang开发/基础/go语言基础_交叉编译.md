---
title: "交叉编译"
weight: 180
date: 2026-06-05
tags: ["Go", "交叉编译", "CGO", "构建"]
---

Go 原生支持交叉编译——在任意平台上为其他平台构建可执行文件，只需设置 `GOOS`、`GOARCH` 两个环境变量，无需工具链切换。

## Golang 在 三大平台下如何交叉编译

- GOOS：目标平台的操作系统（部分不常见的没有列出）
  - darwin  
  - freebsd
  - openbsd
  - linux
  - windows
  - ios
  - android
  - aix
- GOARCH：目标平台的体系架构（）
  - 386
  - amd64
  - arm
- 交叉编译不支持 CGO 所以要禁用它



```bash
# 查看支持的平台

go tool dist list

# 终极打包工具
https://github.com/upx/upx
```





### Windows设置

```bash
# 设置为Mac平台
SET CGO_ENABLED=0
SET GOOS=darwin
SET GOARCH=amd64
go build main.go

# 设置为Linux系统
SET CGO_ENABLED=0
SET GOOS=linux
SET GOARCH=amd64
go build main.go

# 编译为Mips
SET GOOS=linux
SET GOARCH=mipsle
SET GOMIPS=softfloat
SET CGO_ENABLED=0
go build -trimpath -ldflags="-s -w"  main.go
upx -9 main


# 调整至windows
SET GOOS=windows
SET GOARCH=amd64

```



### Linux设置

```bash
# 编译为Mac平台
CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 go build main.go

# 编译为windows系统
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build main.go

#编译为Mips系统
GOOS=linux
GOARCH=mipsle
GOMIPS=softfloat
CGO_ENABLED=0

go build -trimpath -ldflags="-s -w"  main.go



```



### Mac设置

```bash
# 设置为Linux平台
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build main.go

# 设置为windows系统
CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build main.go
```



### Mips

```bash

linux/mips
linux/mips64
linux/mips64le
linux/mipsle


GOOS=linux GOARCH=mips GOMIPS=softfloat go build -o main.go
```

