---
title: "切片 Slice"
weight: 70
date: 2026-06-05
tags: ["Go", "切片", "数据结构"]
---

数组的长度固定且属于类型的一部分，使用起来有诸多限制。切片（Slice）是 Go 在数组之上封装出的「可变长度序列」，是日常开发中最常用的数据结构之一。本文从数组的局限讲起，系统梳理切片的定义、底层结构、扩容策略与常用操作。

{{< callout type="info" >}}
下文示例为节省篇幅，大多省略了 `package main` 与 `import "fmt"`，仅保留 `func main()`。完整可运行版本见每节第一个示例。
{{< /callout >}}

## 为什么需要切片

数组的长度是类型的一部分，因此一个函数只能接收固定长度的数组：

```go
func arraySum(x [3]int) int {
    sum := 0
    for _, v := range x {
        sum += v
    }
    return sum
}
```

上面的 `arraySum` 只接受 `[3]int`，`[4]int`、`[5]int` 都无法传入。而且数组一旦声明，元素个数就不能再增减：

```go
a := [3]int{1, 2, 3}
// 无法再向 a 追加新元素
```

这些限制正是切片要解决的问题。

## 什么是切片

切片是一个拥有相同类型元素的**可变长度序列**，它基于数组做了一层封装，灵活且支持自动扩容。

切片是**引用类型**，其内部结构包含三个字段：底层数组的**指针**、切片的**长度（len）** 和**容量（cap）**。它常用于快速操作一块数据集合。

## 切片的定义

声明切片的基本语法如下，`T` 为元素类型：

```go
var name []T
```

下面是一个完整可运行的示例：

```go
package main

import "fmt"

func main() {
    var a []string              // 声明一个字符串切片（未初始化，为 nil）
    var b = []int{}             // 声明并初始化一个空整型切片
    var c = []bool{false, true} // 声明并初始化一个布尔切片

    fmt.Println(a)        // []
    fmt.Println(b)        // []
    fmt.Println(c)        // [false true]
    fmt.Println(a == nil) // true
    fmt.Println(b == nil) // false
    fmt.Println(c == nil) // false
}
```

{{< callout type="warning" >}}
切片是引用类型，**不支持** `==` 直接比较两个切片，唯一合法的比较是与 `nil` 比较。
{{< /callout >}}

## 长度和容量

切片拥有自己的长度和容量：用内置函数 `len()` 求长度，用 `cap()` 求容量。长度是当前元素个数，容量是底层数组从切片起点到末尾可容纳的元素个数。

## 切片表达式

切片表达式可以从字符串、数组、指向数组的指针或切片，构造出子串或子切片。它有两种形式：只指定 `low`、`high` 的**简单形式**，以及额外指定容量上限的**完整形式**。

### 简单切片表达式

`low` 和 `high` 表示一个索引范围（左闭右开）。下面从数组 `a` 中选出索引 `1 <= i < 3` 的元素组成切片，得到的切片 `长度 = high - low`，容量等于底层数组从 `low` 到末尾的长度：

```go
package main

import "fmt"

func main() {
    a := [5]int{1, 2, 3, 4, 5}
    s := a[1:3] // s := a[low:high]
    fmt.Printf("s:%v len(s):%v cap(s):%v\n", s, len(s), cap(s))
}
```

输出：

```text
s:[2 3] len(s):2 cap(s):4
```

为方便起见，索引可以省略：省略 `low` 默认为 0，省略 `high` 默认为操作数长度：

```go
a[2:] // 等同于 a[2:len(a)]
a[:3] // 等同于 a[0:3]
a[:]  // 等同于 a[0:len(a)]
```

{{< callout type="warning" >}}
对数组或字符串，索引需满足 `0 <= low <= high <= len(a)`，否则触发越界 panic。
对切片**再切片**时，`high` 的上限是**容量** `cap(a)` 而非长度——这一点容易被忽略。
{{< /callout >}}

```go
func main() {
    a := [5]int{1, 2, 3, 4, 5}
    s := a[1:3]
    fmt.Printf("s:%v len(s):%v cap(s):%v\n", s, len(s), cap(s))
    s2 := s[3:4] // 上限是 cap(s)=4 而不是 len(s)=2
    fmt.Printf("s2:%v len(s2):%v cap(s2):%v\n", s2, len(s2), cap(s2))
}
```

输出：

```text
s:[2 3] len(s):2 cap(s):4
s2:[5] len(s2):1 cap(s2):1
```

### 完整切片表达式

对数组、指向数组的指针或切片（**不能是字符串**）支持完整切片表达式：

```go
a[low : high : max]
```

它构造出与 `a[low:high]` 相同类型、长度和元素的切片，但把结果的容量设置为 `max - low`。完整形式中只有 `low` 可以省略（默认 0）：

```go
func main() {
    a := [5]int{1, 2, 3, 4, 5}
    t := a[1:3:5]
    fmt.Printf("t:%v len(t):%v cap(t):%v\n", t, len(t), cap(t))
}
```

输出：

```text
t:[2 3] len(t):2 cap(t):4
```

完整切片表达式需满足 `0 <= low <= high <= max <= cap(a)`。

## 用 make() 构造切片

基于数组创建切片需要先有数组。若要直接动态创建切片，使用内置的 `make()`：

```go
make([]T, size, cap)
```

其中 `T` 是元素类型，`size` 是初始长度，`cap` 是容量（可省略，默认等于 `size`）：

```go
func main() {
    a := make([]int, 2, 10)
    fmt.Println(a)      // [0 0]
    fmt.Println(len(a)) // 2
    fmt.Println(cap(a)) // 10
}
```

底层已分配 10 个元素的空间，但当前只使用了 2 个，因此 `len` 为 2、`cap` 为 10。

## 切片的本质

切片本质上是对底层数组的封装，包含三个信息：**底层数组指针、长度（len）、容量（cap）**。

以 `a := [8]int{0, 1, 2, 3, 4, 5, 6, 7}` 为例，切片 `s1 := a[:5]` 的结构如下：

![切片 s1 := a[:5] 的底层结构示意图](https://raw.githubusercontent.com/adcwb/storages/master/image-20210924144532691.png)

切片 `s2 := a[3:6]` 的结构如下：

![切片 s2 := a[3:6] 的底层结构示意图](https://raw.githubusercontent.com/adcwb/storages/master/image-20210924144606772.png)

## 切片的比较

切片之间不能用 `==` 比较，唯一合法的比较是与 `nil` 比较。`nil` 切片没有底层数组，长度和容量都为 0；但反过来，长度和容量都为 0 的切片**不一定**是 `nil`：

```go
var s1 []int         // len=0; cap=0; s1 == nil  ✔ 是 nil
s2 := []int{}        // len=0; cap=0; s2 != nil  ✘ 不是 nil
s3 := make([]int, 0) // len=0; cap=0; s3 != nil  ✘ 不是 nil
```

{{< callout type="info" >}}
判断切片是否为空，始终用 `len(s) == 0`，不要用 `s == nil`。
{{< /callout >}}

## 赋值拷贝：共享底层数组

切片直接赋值时，两个变量共享同一个底层数组，对其中一个的修改会影响另一个：

```go
func main() {
    s1 := make([]int, 3) // [0 0 0]
    s2 := s1             // s1、s2 共用底层数组
    s2[0] = 100
    fmt.Println(s1) // [100 0 0]
    fmt.Println(s2) // [100 0 0]
}
```

## 遍历

切片的遍历方式与数组一致，支持索引遍历和 `for range` 遍历：

```go
func main() {
    s := []int{1, 3, 5}

    for i := 0; i < len(s); i++ {
        fmt.Println(i, s[i])
    }

    for index, value := range s {
        fmt.Println(index, value)
    }
}
```

## 添加元素：append()

内置函数 `append()` 可为切片动态添加元素，可一次追加一个、多个，或用 `...` 展开另一个切片：

```go
func main() {
    var s []int
    s = append(s, 1)       // [1]
    s = append(s, 2, 3, 4) // [1 2 3 4]
    s2 := []int{5, 6, 7}
    s = append(s, s2...)   // [1 2 3 4 5 6 7]
    fmt.Println(s)
}
```

{{< callout type="info" >}}
通过 `var s []int` 声明的 nil 切片可以直接用于 `append()`，无需先初始化。不必写成 `s := []int{}` 再追加。
{{< /callout >}}

由于底层数组容量不足时切片会自动「扩容」并更换底层数组，**必须用原变量接收 `append()` 的返回值**。下面观察扩容过程中容量与底层数组地址（`ptr`）的变化：

```go
func main() {
    var numSlice []int
    for i := 0; i < 10; i++ {
        numSlice = append(numSlice, i)
        fmt.Printf("%v  len:%d  cap:%d  ptr:%p\n", numSlice, len(numSlice), cap(numSlice), numSlice)
    }
}
```

输出（地址值每次运行会变）：

```text
[0]                    len:1  cap:1  ptr:0xc0000a8000
[0 1]                  len:2  cap:2  ptr:0xc0000a8040
[0 1 2]                len:3  cap:4  ptr:0xc0000b2020
[0 1 2 3]              len:4  cap:4  ptr:0xc0000b2020
[0 1 2 3 4]            len:5  cap:8  ptr:0xc0000b6000
...
[0 1 2 3 4 5 6 7 8]    len:9  cap:16 ptr:0xc0000b8000
[0 1 2 3 4 5 6 7 8 9]  len:10 cap:16 ptr:0xc0000b8000
```

可以看到：`append()` 把元素追加到末尾并返回切片；容量按 1→2→4→8→16 翻倍增长，每次扩容后底层数组地址（`ptr`）发生变化，说明底层数组被替换了。

## 扩容策略

切片的扩容逻辑位于运行时源码 `$GOROOT/src/runtime/slice.go` 的 `growslice` 函数中。其核心思路是：

- 如果新申请容量大于旧容量的 2 倍，直接使用新申请的容量；
- 否则，若切片较小，则容量翻倍；
- 若切片较大，则每次约增长 1.25 倍，直到满足需求。

{{< callout type="warning" >}}
**版本差异（容易踩坑）：** 早期资料常说「长度 < 1024 时翻倍，≥ 1024 时按 1.25 倍增长」。但自 **Go 1.18** 起，这个阈值由 1024 改为了 **256**，且大切片采用了更平滑的增长公式：

```go
newcap += (newcap + 3*256) / 4
```

因此具体扩容倍数请以你使用的 Go 版本源码为准，不要把某个数字当成永恒规则。此外，最终容量还会按元素类型做内存对齐，实际 `cap` 可能略大于按公式算出的值。
{{< /callout >}}

## 用 copy() 复制切片

先看一个问题——直接赋值得到的是引用，并非拷贝：

```go
func main() {
    a := []int{1, 2, 3, 4, 5}
    b := a // b 与 a 指向同一底层数组
    b[0] = 1000
    fmt.Println(a) // [1000 2 3 4 5]
    fmt.Println(b) // [1000 2 3 4 5]
}
```

要得到独立的副本，使用内置的 `copy()`，它把源切片的数据复制到目标切片：

```go
copy(destSlice, srcSlice)
```

```go
func main() {
    a := []int{1, 2, 3, 4, 5}
    c := make([]int, 5) // 目标切片需有足够长度
    copy(c, a)          // 将 a 的元素复制到 c
    c[0] = 1000
    fmt.Println(a) // [1 2 3 4 5]    a 不受影响
    fmt.Println(c) // [1000 2 3 4 5]
}
```

{{< callout type="warning" >}}
`copy` 复制的元素个数为 `min(len(dest), len(src))`。若目标切片长度不足，会被「截断」而非自动扩容。
{{< /callout >}}

## 删除元素

Go 没有删除切片元素的专用函数，可借助切片表达式与 `append()` 实现。删除索引为 `index` 的元素：

```go
func main() {
    a := []int{30, 31, 32, 33, 34, 35, 36, 37}
    index := 2
    a = append(a[:index], a[index+1:]...) // 删除索引 2 的元素
    fmt.Println(a) // [30 31 33 34 35 36 37]
}
```

通用写法即：`a = append(a[:index], a[index+1:]...)`。

## 切片 vs 数组

| 对比项 | 数组 | 切片 |
| --- | --- | --- |
| 长度 | 固定，是类型的一部分 | 可变，不在类型字面量中 |
| 类型 | 值类型 | 引用类型 |
| 传参 | 值拷贝，长度必须匹配 | 传递引用（指针+len+cap） |
| 扩容 | 不支持 | `append` 时自动扩容 |

一个形象的比喻：底层数组像一排固定的格子，切片则像一个**只能向右移动的窗口**——通过这个窗口你只能看到底层数组中连续的一段元素。当 `append` 导致窗口容纳不下时，Go 会另开一个更大的底层数组，把原有元素和新元素一并拷贝过去，原切片并不会被改变。

## 练习

**1. 写出下面代码的输出结果：**

```go
func main() {
    var a = make([]string, 5, 10)
    for i := 0; i < 10; i++ {
        a = append(a, fmt.Sprintf("%v", i))
    }
    fmt.Println(a)
}
```

{{< details title="参考答案" >}}
输出为：

```text
[     0 1 2 3 4 5 6 7 8 9]
```

`make([]string, 5, 10)` 已经创建了 **5 个**零值元素（空字符串 `""`），`append` 再从第 6 位开始追加 `"0"`~`"9"`。因此前 5 个是空串（打印时表现为连续空格），后 10 个才是数字字符。注意元素之间是空格分隔，不是逗号。
{{< /details >}}

**2. 使用标准库 `sort` 对数组 `[...]int{3, 7, 8, 9, 1}` 排序：**

```go
package main

import (
    "fmt"
    "sort"
)

func main() {
    a := [...]int{3, 7, 8, 9, 1}
    sort.Ints(a[:]) // sort.Ints 接收切片，用 a[:] 把数组转为切片
    fmt.Println(a)  // [1 3 7 8 9]
}
```
