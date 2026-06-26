---
title: "GORM 使用指南"
weight: 20
date: 2026-06-05
tags: ["Go", "GORM", "ORM", "数据库"]
---

## 关联关系

我们以图书管理系统为例，介绍GORM中的关联关系

在图书管理系统中，常见的实体包括：Author（作者）、Book（图书）、Publisher（出版社）、User（用户）、BorrowRecord（借阅记录）等

>下面我们分别详细说明并给出示例。
>
>注意：GORM中，外键默认使用主表的类型名（小写）加上ID构成，例如Publisher的默认外键是PublisherID。我们可以通过标签自定义。
>
>示例：图书管理系统模型定义
>
>我们将定义以下模型：
>
>- Publisher (出版社)
>- Author (作者)
>- Book (图书)
>- Tag (标签)
>- User (用户)
>- LibraryCard (借书卡，与用户一对一)
>- BorrowRecord (借阅记录，用户和图书之间多对多，但借阅记录需要记录额外信息如借出日期和归还日期，所以我们会通过中间表BorrowRecord来实现多对多)
>- Comment (评论，多态，可以评论图书或者期刊)
>
>注意：这里我们使用GORM标签来定义关联关系。
>
>

### Belongs To（属于）

表示一个模型属于另一个模型。例如，每本书属于一个出版社，那么Book模型中会有一个PublisherID字段作为外键。

- 定义：子模型从属于父模型，外键存储在子表中
- 适用场景：书籍属于特定出版社（外键在 books 表中）

```go
// Publisher 出版社表
type Publisher struct {
    ID   uint   `gorm:"primaryKey"`
    Name string `gorm:"unique"`
}

// 书籍表
type Book struct {
    ID           uint
    Title        string
    PublisherID  uint           // 外键字段（命名规则：父模型名+ID）
    Publisher    Publisher      `gorm:"foreignKey:PublisherID;references:ID"` // 显式声明关联
}


外键规则：
	1、默认外键命名：父结构体名 + ID（如 PublisherID）
	2、自定义：gorm:"foreignKey:CustomForeignKey"
	3、指向父表主键：references:ParentIDField


// 操作示例
// 查询书籍及其出版社
var book Book
db.Preload("Publisher").First(&book, 1)

// 创建关联
publisher := Publisher{Name: "人民文学出版社"}
db.Create(&Book{Title: "三国演义", Publisher: publisher})
```





### Has One（一对一）

表示一个模型拥有另一个模型。例如，一个用户有一个借书卡（LibraryCard），但借书卡只能属于一个用户。

- 定义：父模型拥有唯一的子模型，外键存储在子表中
- 适用场景：用户拥有唯一的借书卡

```go
// User 用户表
type User struct {
    ID       uint
    Name     string
    LibraryCard LibraryCard `gorm:"constraint:OnDelete:CASCADE;"` // 级联删除
}

// LibraryCard 借书卡
type LibraryCard struct {
    ID        uint
    CardNumber string `gorm:"unique"`
    UserID    uint    // 外键（命名规则相同）
}

```

>
>
>**区别 Belongs To**：
>
>- 方向性：从父模型角度声明
>- 控制权：父模型控制关联



### Has Many（一对多）

表示一个模型拥有多个另一个模型。例如，一个作者有多本书（Author has many Books）。

- 定义：父模型拥有多个子模型，外键在子表中
- 适用场景：一位作者拥有多本书籍

```go
// Author 作者表
type Author struct {
    ID    uint
    Name  string
    Books []Book `gorm:"foreignKey:AuthorID"` // 自定义外键
}

// Book 书籍表
type Book struct {
    ID       uint
    Title    string
    AuthorID uint // 外键
}

// 操作示例
// 查询作者及其所有书籍
author := Author{}
db.Preload("Books").First(&author, 1)

// 批量创建关联
author.Books = []Book{
    {Title: "围城"}, 
    {Title: "谈艺录"},
}
db.Create(&author)
```





### Many To Many（多对对）

表示两个模型可以相互拥有多个。例如，一本书可以有多个标签（Tag），一个标签也可以被多本书使用。
- 定义：通过中间表建立双向关联
- 适用场景：书籍属于多个分类，分类包含多本书

```go
// Book 书籍表
type Book struct {
    ID      uint
    Title   string
    Genres  []Genre `gorm:"many2many:book_genres;"` // 自定义连接表
}

// Genre 分类
type Genre struct {
    ID    uint
    Name  string
    Books []Book `gorm:"many2many:book_genres;"`
}

// 中间表表结构
type BookGenre struct {
    BookID  uint `gorm:"primaryKey"`
    GenreID uint `gorm:"primaryKey"`
    CreatedAt time.Time
}

// 操作示例
// 添加书籍到分类
db.Model(&book).Association("Genres").Append(&Genre{Name: "文学"})

// 查询某分类下所有书籍
var genres []Genre
db.Preload("Books").Where("name = ?", "科幻").Find(&genres)

```




### Polymorphism（多态）

允许一个模型同时属于多个其他模型。例如，评论（Comment）可以属于一本书（Book）或者一篇期刊（Journal），通过一个字段标识属于哪种类型。

- 定义：单个模型可关联多种父模型
- 适用场景：评论可以针对书籍或者作者

```go
// Comment 评论表
type Comment struct {
    ID             uint
    Content        string
    CommentableID  uint      // 多态ID
    CommentableType string   // 目标模型类型（book/author）
}

// Book 书籍表
type Book struct {
    ID       uint
    Title    string
    Comments []Comment `gorm:"polymorphic:Commentable;"` // 多态声明
}

// Author 作者表
type Author struct {
    ID       uint
    Name     string
    Comments []Comment `gorm:"polymorphic:Commentable;"`
}

// 操作示例
// 获取书籍的所有评论
var book Book
db.First(&book, 123)
db.Model(&book).Association("Comments").Find(&comments)
```





## 关联技巧

### 预加载优化

```go
// 避免 N+1 查询
db.Preload("Authors.Books.Genres").Find(&libraries)

// 条件预加载
db.Preload("Books", "rating > ?", 4.5).Find(&authors)
```



###  级联操作

```text
type Author struct {
    gorm.Model
    Books []Book `gorm:"constraint:OnDelete:SET NULL;"`
}
```



### 关联模式操作

```text
// 直接操作关联关系
db.Model(&author).Association("Books").Append(
    &Book{Title: "新书"}, 
    &Book{Title: "旧作"}
)

// 清空关联
db.Model(&book).Association("Genres").Clear()
```



### 连接表自定义属性

```text
db.SetupJoinTable(&Book{}, "Genres", &BookGenre{})
```





JSON类型支持

```bash
https://github.com/go-gorm/datatypes

```

