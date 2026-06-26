---
title: "常用标准库"
weight: 160
date: 2026-06-05
tags: ["Go", "标准库", "fmt", "strings", "time"]
---

## fmt.Printf使用

fmt包实现了类似C语言printf和scanf的格式化I/O。主要分为向外输出内容和获取输入内容两大部分。



### Print

`Print`系列函数会将内容输出到系统的标准输出，区别在于`Print`函数直接输出内容，`Printf`函数支持格式化输出字符串，`Println`函数会在输出内容的结尾添加一个换行符。



```go
func main() {
	name := "张三"
	fmt.Print("在终端打印该信息~") 			// 不会换行
	fmt.Printf("我是：%s\n", name)		   // 格式化输出
	fmt.Println("在终端打印单独一行显示")    // 尾部自动加换行
	fmt.Print("在终端打印该信息~")
}

/* 
输出信息

在终端打印该信息~我是：张三
在终端打印单独一行显示
在终端打印该信息~

*/
```



### 占位符

```go
// 普通占位符
%v        相应值的默认格式				fmt.Printf("%v\n", data)     //格式化输出结构
%+v	      类似%v，但输出结构体时会添加字段名
%#v       相应值的Go语法表示			fmt.Printf("%#v\n", data) 
%T        相应值的类型的Go语法表示		  fmt.Printf("%T\n", data) 
%%        字面上的百分号，并非值的占位符   fmt.Printf("%%") 

// 布尔占位符
%t        单词 true 或 false。         fmt.Printf("%t", true)

// 整数占位符
%b        二进制表示
%c        相应Unicode码点所表示的字符
%d        十进制表示
%o        八进制表示
%q        单引号围绕的字符字面值，由Go语法安全地转义
%x        十六进制表示，字母形式为小写 a-f
%X        十六进制表示，字母形式为大写 A-F
%U        Unicode格式：U+1234，等同于 "U+%04X"

// 浮点数和复数的组成部分（实部和虚部）
%b        无小数部分的，指数为二的幂的科学计数法，如-123456p-78
%e        科学计数法，例如 -1234.456e+78 
%E        科学计数法，例如 -1234.456E+78  
%f        有小数点而无指数，例如 123.456 
%F	      等价于%f
%g        根据情况选择 %e 或 %f 以产生更紧凑的（无末尾的0）输出
%G        根据情况选择 %E 或 %f 以产生更紧凑的（无末尾的0）输出   

// 字符串与字节切片
%s        输出字符串表示（string类型或[]byte) 
%q        双引号围绕的字符串，由Go语法安全地转义

// 指针
%p        十六进制表示，前缀 0x      

// 宽度标识符
宽度通过一个紧跟在百分号后面的十进制数指定，如果未指定宽度，则表示值时除必需之外不作填充。精度通过（可选的）宽度后跟点号后跟的十进制数指定。如果未指定精度，会使用默认精度；如果点号后没有跟数字，表示精度为0。举例如下：

%f        默认宽度，默认精度
%9f       宽度9，默认精度
%.2f      默认宽度，精度2
%9.2f     宽度9，精度2
%9.f      宽度9，精度0

n := 12.34
fmt.Printf("%f\n", n)
fmt.Printf("%9f\n", n)
fmt.Printf("%.2f\n", n)
fmt.Printf("%9.2f\n", n)
fmt.Printf("%9.f\n", n)

12.340000
12.340000
12.34
    12.34
       12


// 其他占位符标记
0        填充前导的0而非空格；对于数字，这会将填充移到正负号之后
' '      （空格）为数值中省略的正负号留出空白（% d）；
+        总打印数值的正负号；对于%q（%+q）保证只输出ASCII编码的字符。
-        在右侧而非左侧填充空格（左对齐该区域）
```





## Fprint

`Fprint`系列函数会将内容输出到一个`io.Writer`接口类型的变量`w`中，我们通常用这个函数往文件中写入内容。

```go
// 向标准输出写入内容
fmt.Fprintln(os.Stdout, "向标准输出写入内容")
fileObj, err := os.OpenFile("./xx.txt", os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0644)
if err != nil {
	fmt.Println("打开文件出错，err:", err)
	return
}
name := "沙河小王子"
// 向打开的文件句柄中写入内容
fmt.Fprintf(fileObj, "往文件中写如信息：%s", name)
```

注意，只要满足`io.Writer`接口的类型都支持写入。



## Sprint

`Sprint`系列函数会把传入的数据生成并返回一个字符串。

```go
s1 := fmt.Sprint("沙河小王子")
name := "沙河小王子"
age := 18
s2 := fmt.Sprintf("name:%s,age:%d", name, age)
s3 := fmt.Sprintln("沙河小王子")
fmt.Println(s1, s2, s3)
```



## Errorf

`Errorf`函数根据format参数生成格式化字符串并返回一个包含该字符串的错误。

```go
func Errorf(format string, a ...interface{}) error
```

通常使用这种方式来自定义错误类型，例如：

```go
err := fmt.Errorf("这是一个错误")
```

Go1.13版本为`fmt.Errorf`函数新加了一个`%w`占位符用来生成一个可以包裹Error的Wrapping Error。

```go
e := errors.New("原始错误e")
w := fmt.Errorf("Wrap了一个错误%w", e)
```



## 获取用户输入

Go语言`fmt`包下有`fmt.Scan`、`fmt.Scanf`、`fmt.Scanln`三个函数，可以在程序运行过程中从标准输入获取用户的输入。

### fmt.Scan

函数定签名如下：

```go
func Scan(a ...interface{}) (n int, err error)
```

- Scan从标准输入扫描文本，读取由空白符分隔的值保存到传递给本函数的参数中，换行符视为空白符。
- 本函数返回成功扫描的数据个数和遇到的任何错误。如果读取的数据个数比提供的参数少，会返回一个错误报告原因。

具体代码示例如下：

```go
func main() {
	var (
		name    string
		age     int
		married bool
	)
	fmt.Scan(&name, &age, &married)
	fmt.Printf("扫描结果 name:%s age:%d married:%t \n", name, age, married)
}
```

将上面的代码编译后在终端执行，在终端依次输入`小王子`、`28`和`false`使用空格分隔。

```bash
$ ./scan_demo 
小王子 28 false
扫描结果 name:小王子 age:28 married:false 
```

`fmt.Scan`从标准输入中扫描用户输入的数据，将以空白符分隔的数据分别存入指定的参数。



### fmt.Scanf

函数签名如下：

```go
func Scanf(format string, a ...interface{}) (n int, err error)
```

- Scanf从标准输入扫描文本，根据format参数指定的格式去读取由空白符分隔的值保存到传递给本函数的参数中。
- 本函数返回成功扫描的数据个数和遇到的任何错误。

代码示例如下：

```go
func main() {
	var (
		name    string
		age     int
		married bool
	)
	fmt.Scanf("1:%s 2:%d 3:%t", &name, &age, &married)
	fmt.Printf("扫描结果 name:%s age:%d married:%t \n", name, age, married)
}
```

将上面的代码编译后在终端执行，在终端按照指定的格式依次输入`小王子`、`28`和`false`。

```bash
$ ./scan_demo 
1:小王子 2:28 3:false
扫描结果 name:小王子 age:28 married:false 
```

`fmt.Scanf`不同于`fmt.Scan`简单的以空格作为输入数据的分隔符，`fmt.Scanf`为输入数据指定了具体的输入内容格式，只有按照格式输入数据才会被扫描并存入对应变量。

例如，我们还是按照上个示例中以空格分隔的方式输入，`fmt.Scanf`就不能正确扫描到输入的数据。

```bash
$ ./scan_demo 
小王子 28 false
扫描结果 name: age:0 married:false 
```



### fmt.Scanln

函数签名如下：

```go
func Scanln(a ...interface{}) (n int, err error)
```

- Scanln类似Scan，它在遇到换行时才停止扫描。最后一个数据后面必须有换行或者到达结束位置。
- 本函数返回成功扫描的数据个数和遇到的任何错误。

具体代码示例如下：

```go
func main() {
	var (
		name    string
		age     int
		married bool
	)
	fmt.Scanln(&name, &age, &married)
	fmt.Printf("扫描结果 name:%s age:%d married:%t \n", name, age, married)
}
```

将上面的代码编译后在终端执行，在终端依次输入`小王子`、`28`和`false`使用空格分隔。

```bash
$ ./scan_demo 
小王子 28 false
扫描结果 name:小王子 age:28 married:false 
```

`fmt.Scanln`遇到回车就结束扫描了，这个比较常用。



### bufio.NewReader

有时候我们想完整获取输入的内容，而输入的内容可能包含空格，这种情况下可以使用`bufio`包来实现。示例代码如下：

```go
func bufioDemo() {
	reader := bufio.NewReader(os.Stdin) // 从标准输入生成读对象
	fmt.Print("请输入内容：")
	text, _ := reader.ReadString('\n') // 读到换行
	text = strings.TrimSpace(text)
	fmt.Printf("%#v\n", text)
}
```



### Fscan系列

这几个函数功能分别类似于`fmt.Scan`、`fmt.Scanf`、`fmt.Scanln`三个函数，只不过它们不是从标准输入中读取数据而是从`io.Reader`中读取数据。

```go
func Fscan(r io.Reader, a ...interface{}) (n int, err error)
func Fscanln(r io.Reader, a ...interface{}) (n int, err error)
func Fscanf(r io.Reader, format string, a ...interface{}) (n int, err error)
```



### Sscan系列

这几个函数功能分别类似于`fmt.Scan`、`fmt.Scanf`、`fmt.Scanln`三个函数，只不过它们不是从标准输入中读取数据而是从指定字符串中读取数据。

```go
func Sscan(str string, a ...interface{}) (n int, err error)
func Sscanln(str string, a ...interface{}) (n int, err error)
func Sscanf(str string, format string, a ...interface{}) (n int, err error)
```

