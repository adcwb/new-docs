---
title: "Trait 与泛型"
weight: 70
date: 2026-06-16
tags: ["Rust", "Trait", "泛型", "接口"]
---

这篇讲 Rust 中 trait 和泛型的配合使用。Trait 类似于 Go 的 interface 和 Java 的 interface 的结合体——但更强大，因为它支持默认实现和关联类型。泛型则让代码复用的同时保持类型安全。

## Trait：定义共享行为

Trait 告诉编译器：「实现了这个 trait 的类型，一定具备这些方法」。

### 定义 Trait

```rust
pub trait Summary {
    fn summarize(&self) -> String;  // 只有签名，没有实现（类似 Go interface）

    // 也可以提供默认实现
    fn default_summary(&self) -> String {
        String::from("(Read more...)")
    }
}
```

### 为类型实现 Trait

```rust
pub struct NewsArticle {
    pub headline: String,
    pub location: String,
    pub author: String,
    pub content: String,
}

impl Summary for NewsArticle {
    fn summarize(&self) -> String {
        format!("{}, by {} ({})", self.headline, self.author, self.location)
    }

    // default_summary 使用默认实现，无需重写
}

pub struct Tweet {
    pub username: String,
    pub content: String,
    pub reply: bool,
}

impl Summary for Tweet {
    fn summarize(&self) -> String {
        format!("{}: {}", self.username, self.content)
    }
}
```

{{< callout type="info" >}}
**孤儿规则**：要实现某个 trait 于某个类型，trait 或类型中至少有一个是在本 crate 中定义的。你不能为外部类型实现外部 trait——这防止了两个 crate 对同一类型的不同实现。
{{< /callout >}}

## Trait 作为参数

```rust
// 写法 1：impl Trait 语法糖
pub fn notify(item: &impl Summary) {
    println!("Breaking news! {}", item.summarize());
}

// 写法 2：trait bound——等价的长写法
pub fn notify<T: Summary>(item: &T) {
    println!("Breaking news! {}", item.summarize());
}

// 多个参数、多个 trait bound
pub fn notify_and_display<T: Summary + Display>(item: &T, other: &T) {
    // ...
}

// where 从句让复杂 bound 更可读
fn some_function<T, U>(t: &T, u: &U) -> i32
where
    T: Display + Clone,
    U: Clone + Debug,
{
    // ...
}
```

## 返回实现了 Trait 的类型

```rust
fn returns_summarizable() -> impl Summary {
    Tweet {
        username: String::from("horse_ebooks"),
        content: String::from("of course, as you probably already know, people"),
        reply: false,
    }
}
```

{{< callout type="warning" >}}
`impl Trait` 作为返回值时，函数只能返回**同一种具体类型**。如果需要返回不同类型（如有时返回 `NewsArticle`，有时返回 `Tweet`），需要用 `Box<dyn Trait>`（trait 对象）。
{{< /callout >}}

## 泛型

泛型让函数和结构体能处理多种类型而不损失类型安全：

```rust
// 泛型函数
fn largest<T: PartialOrd>(list: &[T]) -> &T {
    let mut largest = &list[0];
    for item in list {
        if item > largest {
            largest = item;
        }
    }
    largest
}

// 泛型结构体
struct Point<T> {
    x: T,
    y: T,
}

impl<T> Point<T> {
    fn x(&self) -> &T {
        &self.x
    }
}

// 对特定类型的方法
impl Point<f32> {
    fn distance_from_origin(&self) -> f32 {
        (self.x.powi(2) + self.y.powi(2)).sqrt()
    }
}

fn main() {
    let number_list = vec![34, 50, 25, 100, 65];
    let result = largest(&number_list);
    println!("最大的是 {result}");  // 100

    let p = Point { x: 5, y: 10 };
    println!("p.x = {}", p.x());
}
```

## 常用派生 Trait

通过 `#[derive]` 属性自动生成常见 trait 的实现：

```rust
#[derive(Debug, Clone, PartialEq, Eq, Hash, Default)]
struct MyStruct {
    field1: i32,
    field2: String,
}
// Debug:   可以用 {:?} 打印
// Clone:   .clone() 深度复制
// PartialEq / Eq:  可以用 == 比较
// Hash:    可以作为 HashMap 的 key
// Default: Default::default() 创建默认值
```

## Trait 与泛型的组合——标准库实例

标准库中泛型 + trait 的经典例子是 `HashMap<K, V>`。K 必须是可哈希的，V 是任意值——这在 Go 中对应 map 的类型约束：

```rust
use std::collections::HashMap;

fn main() {
    let mut scores = HashMap::new();
    scores.insert(String::from("Blue"), 10);
    scores.insert(String::from("Yellow"), 50);
}
```

## 一句话小结

Trait 定义共享行为（类似 Go interface），泛型让代码复用。`impl Trait` 语法糖简洁，trait bound 精确。`#[derive]` 自动生成常见 trait。「组合优于继承」——Rust 没有类继承，只有 trait + 组合。下一篇讲 [集合类型](../08集合类型/)。

## 练习

1. 定义一个 `Area` trait，有一个方法 `fn area(&self) -> f64`。为 `Circle` 和 `Rectangle` 结构体实现这个 trait。
2. 写一个泛型函数 `pair_equal<T: PartialEq>(a: T, b: T) -> bool`，返回两个值是否相等。

{{< details title="参考答案" >}}
```rust
use std::f64::consts::PI;

trait Area {
    fn area(&self) -> f64;
}

struct Circle {
    radius: f64,
}

impl Area for Circle {
    fn area(&self) -> f64 {
        PI * self.radius * self.radius
    }
}

struct Rectangle {
    width: f64,
    height: f64,
}

impl Area for Rectangle {
    fn area(&self) -> f64 {
        self.width * self.height
    }
}

fn pair_equal<T: PartialEq>(a: T, b: T) -> bool {
    a == b
}

fn main() {
    let c = Circle { radius: 5.0 };
    let r = Rectangle { width: 4.0, height: 6.0 };
    println!("圆面积: {:.2}, 矩形面积: {:.2}", c.area(), r.area());
    println!("相等吗？{}", pair_equal(42, 42));  // true
    println!("相等吗？{}", pair_equal("hello", "world"));  // false
}
```
{{< /details >}}
