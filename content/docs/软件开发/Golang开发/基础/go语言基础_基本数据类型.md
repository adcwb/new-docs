---
title: "基本数据类型"
weight: 30
date: 2026-06-05
tags: ["Go", "数据类型", "字符串", "整型"]
---

Go 的类型系统相对精简：基本类型包含整型、浮点型、复数、布尔值和字符串，其余容器类型（数组、切片、map、结构体、通道）各有专文。本文重点讲清楚各基本类型的宽度、零值、常用操作和陷阱。

## 整型

整型分为有符号和无符号两大类，按位宽细分：

| 类型 | 描述 |
| :--: | :-- |
| `uint8` | 无符号 8 位整型（0 ~ 255） |
| `uint16` | 无符号 16 位整型（0 ~ 65535） |
| `uint32` | 无符号 32 位整型（0 ~ 4 294 967 295） |
| `uint64` | 无符号 64 位整型（0 ~ 18 446 744 073 709 551 615） |
| `int8` | 有符号 8 位整型（-128 ~ 127） |
| `int16` | 有符号 16 位整型（-32 768 ~ 32 767） |
| `int32` | 有符号 32 位整型（-2 147 483 648 ~ 2 147 483 647） |
| `int64` | 有符号 64 位整型（-9 223 372 036 854 775 808 ~ 9 223 372 036 854 775 807） |

**平台相关类型：**

| 类型 | 描述 |
| :--: | :-- |
| `uint` | 在 32 位系统上等同 `uint32`，64 位上等同 `uint64` |
| `int` | 在 32 位系统上等同 `int32`，64 位上等同 `int64` |
| `uintptr` | 无符号整型，大小足以存放任意指针 |

{{< callout type="warning" >}}
使用 `int`/`uint` 时不能假定其宽度。涉及二进制文件传输、跨平台结构描述时，应使用固定宽度类型（`int32`、`int64` 等），避免平台差异导致数据错误。
{{< /callout >}}

### 数字字面量语法（Go 1.13+）

Go 1.13 引入了二进制/八进制字面量，以及用 `_` 分隔数字提升可读性：

```go
package main

import "fmt"

func main() {
    var a int = 10
    fmt.Printf("十进制: %d，二进制: %b\n", a, a)

    var b int = 0o77     // 八进制前缀 0o（旧写法 077 仍支持）
    fmt.Printf("八进制: %o\n", b)

    var c int = 0xff     // 十六进制
    fmt.Printf("十六进制: %x / %X\n", c, c)

    v := 0b00101101      // 二进制，等于十进制 45
    sep := 1_000_000     // 下划线分隔，等于 1000000
    fmt.Println(v, sep)
}
```

## 浮点型

Go 支持两种 IEEE 754 浮点类型：

- `float32`：最大约 3.4 × 10³⁸，精度约 7 位十进制有效数字
- `float64`：最大约 1.8 × 10³⁰⁸，精度约 15 位，**推荐优先使用**

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    fmt.Printf("float64 π: %f\n", math.Pi)
    fmt.Printf("保留两位:   %.2f\n", math.Pi)
    fmt.Printf("最大值:     %e\n", math.MaxFloat64)
}
```

## 复数

复数类型有实部和虚部，分别对应两种精度：

- `complex64`：实部和虚部各为 `float32`
- `complex128`：实部和虚部各为 `float64`

```go
package main

import "fmt"

func main() {
    var c1 complex64  = 1 + 2i
    var c2 complex128 = 2 + 3i

    fmt.Println(c1)       // (1+2i)
    fmt.Println(c2)       // (2+3i)
    fmt.Println(real(c2)) // 2
    fmt.Println(imag(c2)) // 3
}
```

{{< callout type="info" >}}
Go 不允许在函数外部进行涉及变量的运算语句，常量表达式除外。
{{< /callout >}}

## 布尔值

`bool` 类型只有 `true` 和 `false` 两个值，零值为 `false`。

- Go **不允许**将整型强制转换为布尔型（不像 C 中 `0` 等于 `false`）。
- 布尔值不能参与数值运算，也不能与其他类型互转。

```go
var isOk bool = true
fmt.Println(isOk)  // true
```

## 字符串

Go 字符串是以 UTF-8 编码的不可变字节序列，用**双引号**（可解析转义）或**反引号**（原始字符串，不解析转义）表示：

```go
s1 := "Hello\nWorld"   // 包含换行符
s2 := `Hello\nWorld`   // 原样输出，\n 不转义
```

**常用转义符：**

| 转义符 | 含义 |
| :----: | :-- |
| `\r` | 回车（返回行首） |
| `\n` | 换行 |
| `\t` | 制表符 |
| `\'` | 单引号 |
| `\"` | 双引号 |
| `\\` | 反斜杠 |

### 字符串的常用操作

| 方法 | 说明 |
| :-- | :-- |
| `len(str)` | 字节数（非字符数） |
| `str1 + str2` 或 `fmt.Sprintf` | 拼接 |
| `strings.Split` | 按分隔符切割 |
| `strings.Contains` | 判断是否包含子串 |
| `strings.HasPrefix` / `strings.HasSuffix` | 前缀 / 后缀判断 |
| `strings.Index` / `strings.LastIndex` | 子串第一次 / 最后一次出现位置 |
| `strings.Join(a []string, sep)` | 拼接切片为字符串 |

```go
package main

import (
    "fmt"
    "strings"
)

func main() {
    s := "alexdsb"
    fmt.Println(len(s))                          // 7（字节数）
    fmt.Println(strings.Contains(s, "sb"))       // true
    fmt.Println(strings.HasPrefix(s, "alex"))    // true
    fmt.Println(strings.Split(s, "x"))           // [ale dsb]

    langs := []string{"Python", "PHP", "Go"}
    fmt.Println(strings.Join(langs, " / "))      // Python / PHP / Go
}
```

### 引号对比

| 引号 | 用途 |
| :--: | :-- |
| 双引号 `"` | 普通字符串，支持转义 |
| 反引号 `` ` `` | 原始字符串，支持多行，不支持转义 |
| 单引号 `'` | **不能**用于字符串，只用于单个 `rune`（如 `'中'`） |

## byte 和 rune 类型

Go 的字符有两种表示：

- `byte`（`uint8` 别名）：表示 ASCII 字符，一个字节
- `rune`（`int32` 别名）：表示 Unicode 码点，处理中文等多字节字符时使用

```go
package main

import "fmt"

func main() {
    s := "hello沙河"

    // 按字节遍历（中文会被拆开）
    for i := 0; i < len(s); i++ {
        fmt.Printf("%v(%c) ", s[i], s[i])
    }
    fmt.Println()

    // 按 rune 遍历（正确处理中文）
    for _, r := range s {
        fmt.Printf("%v(%c) ", r, r)
    }
    fmt.Println()
}
```

输出：

```bash
104(h) 101(e) 108(l) 108(l) 111(o) 230(æ) 178(²) 153() 230(æ) 178(²) 179(³)
104(h) 101(e) 108(l) 108(l) 111(o) 27801(沙) 27827(河)
```

UTF-8 下一个中文汉字占 3～4 个字节，按字节遍历会乱码，需按 `rune` 遍历。

### 字符串修改

字符串本身不可修改，需先转为 `[]byte` 或 `[]rune`，修改后再转回：

```go
func main() {
    s1 := "big"
    b := []byte(s1)
    b[0] = 'p'
    fmt.Println(string(b))   // pig

    s2 := "白萝卜"
    r := []rune(s2)
    r[0] = '红'
    fmt.Println(string(r))   // 红萝卜
}
```

## 类型转换

Go 只有**显式**类型转换，没有隐式转换。语法：`T(表达式)`

```go
func main() {
    var a, b = 3, 4
    var c int
    // math.Sqrt 要求 float64，需显式转换
    c = int(math.Sqrt(float64(a*a + b*b)))
    fmt.Println(c)   // 5
}
```
