---
title: "Go 1.25 Windows 编译兼容问题"
weight: 40
date: 2026-06-05
tags: ["Go", "Windows", "编译", "兼容性"]
---

## 前言

在某些 Windows 版本，Go 1.25.x 编译出来的 exe 运行报错：此应用无法在你的电脑上运行

在 Go 1.25.x 的 Windows 版本中，使用了**DWARF v5 调试信息格式**，编译生成部分 Windows 加载器或安全系统无法识别的 PE 结构，从而导致 “此应用无法在你的电脑上运行”。



## 原理解释

从 Go 1.25 开始，官方默认启用了 dwarf5，Go 在生成可执行文件时会使用 **DWARF v5 调试信息格式**。



### DWARF 是什么？

DWARF 是一种标准的 **调试信息格式**，用于在二进制文件中存储：

- 源代码行号；
- 变量名和类型；
- 函数符号；
- 栈帧和调试符号表。

Go 在编译时把这些信息写进 `.debug_*` 段（sections）里， 运行时并不会读取这些调试段。



**DWARF v5 和 v4 的区别：**

| 对比项         | DWARF v4           | DWARF v5               |
| -------------- | ------------------ | ---------------------- |
| 引入时间       | Go ≤ 1.24 默认     | Go ≥ 1.25 默认         |
| 文件体积       | 略大               | 更紧凑（结构优化）     |
| 调试信息格式   | 较旧格式，兼容性好 | 新格式，支持更多元数据 |
| 调试器支持     | GDB/Delve 都支持   | 需新版 GDB/Delve       |
| 对运行性能影响 | 无                 | 无                     |



**DWARF v5 改善的是调试体验，而非运行性能。**

然而：

- Windows PE 格式对 DWARF 的支持很有限；
- 某些 Windows 版本（包括部分 Windows 11 + SmartScreen / Core Isolation 启用的环境），对包含 DWARF v5 section 的 EXE 文件直接拒绝加载；
- 因此，外部链接器（external linker）生成的带 DWARF v5 的可执行文件就无法运行；
- 而内部链接器（internal linker）或关闭 DWARF v5 后 (也就是退回到DWARF v4版本) 则正常。



## 解决方法

当你执行：

```bash
set GOEXPERIMENT=nodwarf5
go build
```

或者在环境中永久设置（推荐）：

```bash
go env -w GOEXPERIMENT=nodwarf5
```

这会告诉 Go：

> 不要使用 DWARF v5，而回退到 DWARF v4 调试信息格式。

于是编译产物恢复兼容性，编译生成的 `.exe` 文件可以被正常加载执行。



## 对比

| 项目         | Go 1.24.8 | Go 1.25.2 (默认)                       | Go 1.25.2 + nodwarf5 |
| ------------ | --------- | -------------------------------------- | -------------------- |
| 调试信息格式 | DWARF v4  | DWARF v5                               | DWARF v4             |
| 构建兼容性   | ✅ 稳定    | ❌ 可能导致“此应用无法在你的电脑上运行” | ✅ 稳定               |
| 链接方式     | 内部      | 外部                                   | 外部或内部都可       |
| 推荐用途     | 全面兼容  | 实验性                                 | 推荐默认设置         |

------

> **Go 1.25.x 实验性功能**:
>
> - **`greenteagc`**：一个新的垃圾回收器，旨在降低高并发、小对象频繁分配服务中的GC开销。
> - **`jsonv2`**：`encoding/json`包的新实现，能够提供更快的解码速度。
> - **`nodwarf5`**：如果需要与外部调试工具兼容，可以使用此选项禁用DWARFv5调试信息，回退到v4版本。
>
> 启用它们的示例：`GOEXPERIMENT=greenteagc,jsonv2 go build .`