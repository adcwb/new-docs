---
title: "json类型使用"
weight: 80
date: 2026-06-05
tags: ["MySQL", "JSON", "数据类型"]
---

## JSON类型简介

MySQL从5.7.8版本开始引入了JSON数据类型，用于存储和管理JSON格式的数据。JSON类型提供了自动验证、优化存储格式和高效访问的特性。

JSON类型的主要优势：

- 自动验证：确保存储的值是有效的JSON文档
- 优化存储：以二进制格式存储，快速读取
- 高效访问：提供专门的函数和操作符处理JSON数据



### 什么是JSON

JSON 是 JavaScript Object Notation（JavaScript 对象表示法）的缩写，是一个轻量级的，基于文本的，跨语言的数据交换格式。易于阅读和编写。

JSON 的基本数据类型如下：

- 数值：十进制数，不能有前导 0，可以为负数或小数，还可以为 e 或 E 表示的指数。
- 字符串：字符串必须用双引号括起来。
- 布尔值：true，false。
- 数组：一个由零或多个值组成的有序序列。每个值可以为任意类型。数组使用方括号`[]` 括起来，元素之间用逗号`,`分隔。譬如，[1, "abc", null, true, "10:27:06.000000", {"id": 1}]
- 对象：一个由零或者多个键值对组成的无序集合。其中键必须是字符串，值可以为任意类型。
  对象使用花括号`{}`括起来，键值对之间使用逗号`,`分隔，键与值之间用冒号`:`分隔。譬如，{"db": ["mysql", "oracle"], "id": 123, "info": {"age": 20}}
- 空值：null。



## 各版本JSON功能变化

| MySQL版本 | JSON功能改进                           |
| :-------- | :------------------------------------- |
| 5.7       | 引入JSON数据类型，基本JSON函数         |
| 8.0.0     | JSON聚合函数，JSON表函数，JSON合并函数 |
| 8.0.3     | JSON路径表达式中的`->>`操作符          |
| 8.0.4     | JSON_VALUE()函数，改进JSON比较         |
| 8.0.17    | 多值索引支持JSON数组                   |
| 8.0.21    | JSON_SCHEMA_VALIDATION()函数           |
| 8.0.27    | JSON_OVERLAPS()函数                    |



## 基本操作



### 创建JSON字段

```sql
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    attributes JSON,
    price DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```



### 插入JSON数据



对于 JSON 文档，KEY 名不能重复。

如果插入的值中存在重复 KEY，在 MySQL 8.0.3 之前，遵循 first duplicate key wins 原则，会保留第一个 KEY，后面的将被丢弃掉。

从 MySQL 8.0.3 开始，遵循的是 last duplicate key wins 原则，只会保留最后一个 KEY。



```sql
-- 使用JSON字符串
INSERT INTO products (name, attributes, price) 
VALUES ('Laptop', '{"color": "silver", "memory": "16GB", "storage": "512GB"}', 1299.99);

-- 使用JSON函数
INSERT INTO products (name, attributes, price)
VALUES ('Smartphone', JSON_OBJECT('color', 'black', 'memory', '8GB', 'storage', '256GB'), 899.99);
```



### 查询JSON数据

```sql
-- 查询整个JSON字段
SELECT id, name, attributes FROM products;

-- 提取特定属性
SELECT name, attributes->'$.color' AS color FROM products;

-- 使用JSON_EXTRACT函数
SELECT name, JSON_EXTRACT(attributes, '$.memory') AS memory FROM products;

-- 条件查询
SELECT name, price FROM products 
WHERE attributes->'$.color' = '"silver"';

-- 检查属性是否存在
SELECT name FROM products 
WHERE JSON_CONTAINS_PATH(attributes, 'one', '$.storage');
```



### 更新JSON数据

```sql
-- 完全替换JSON内容
UPDATE products SET attributes = '{"color": "red", "memory": "32GB"}' 
WHERE id = 1;

-- 修改特定属性
UPDATE products SET attributes = JSON_SET(attributes, '$.color', 'blue') 
WHERE id = 2;

-- 添加新属性
UPDATE products SET attributes = JSON_SET(attributes, '$.weight', '1.5kg') 
WHERE id = 1;

-- 删除属性
UPDATE products SET attributes = JSON_REMOVE(attributes, '$.weight') 
WHERE id = 1;
```



### 删除JSON数据

```sql
-- 删除整个JSON字段值
UPDATE products SET attributes = NULL WHERE id = 1;

-- 删除包含特定JSON属性的记录
DELETE FROM products WHERE JSON_CONTAINS(attributes, '"red"', '$.color');
```



## 高级操作



### 批量操作

```sql
-- 批量插入JSON数据
INSERT INTO products (name, attributes, price) VALUES 
('Tablet', '{"color": "white", "memory": "4GB"}', 299.99),
('Monitor', '{"size": "27inch", "resolution": "4K"}', 499.99);

-- 批量更新JSON属性
UPDATE products 
SET attributes = JSON_SET(attributes, '$.discount', '10%')
WHERE price > 500;

-- 使用JSON_MERGE_PATCH批量合并更新
UPDATE products
SET attributes = JSON_MERGE_PATCH(attributes, '{"warranty": "2 years"}')
WHERE created_at > '2023-01-01';
```



### JSON路径表达式

MySQL支持JSON路径表达式来访问和修改JSON文档的特定部分：

```sql
-- 简写语法
SELECT attributes->'$.storage' FROM products;

-- 完整语法
SELECT JSON_EXTRACT(attributes, '$.memory') FROM products;

-- 数组访问
SELECT attributes->'$.features[0]' FROM products 
WHERE JSON_TYPE(attributes->'$.features') = 'ARRAY';

-- 通配符
SELECT attributes->'$.variants[*].price' FROM products;
```



### Partial Updates

MySQL 8.0+支持JSON字段的部分更新，比完全替换更高效：

```sql
-- 只更新color属性，其他保持不变
UPDATE products 
SET attributes = JSON_SET(attributes, '$.color', 'black')
WHERE id = 1;

-- 使用JSON_MERGE_PRESERVE合并更新
UPDATE products
SET attributes = JSON_MERGE_PRESERVE(attributes, '{"new_feature": true}')
WHERE id = 2;
```



### JSON索引

MySQL允许在JSON字段的特定路径上创建索引：

```sql
-- 创建虚拟列并建立索引
ALTER TABLE products 
ADD color VARCHAR(20) AS (attributes->>'$.color'),
ADD INDEX idx_color (color);

-- 直接在JSON路径上创建函数索引(MySQL 8.0+)
CREATE INDEX idx_memory ON products((attributes->>'$.memory'));

-- 多值索引(MySQL 8.0.17+)
CREATE INDEX idx_tags ON products((CAST(attributes->'$.tags' AS CHAR(255) ARRAY)));
```





## JSON函数使用



### 1.JSON创建函数

#### 1.1 JSON_ARRAY()

**作用**：创建JSON数组。
**语法**：`JSON_ARRAY(val1, val2, ...)`
**示例**：

```sql
SELECT JSON_ARRAY(1, 'MySQL', true, NOW());
-- 结果: [1, "MySQL", true, "2024-06-25 12:34:56.000000"]
```



#### 1.2 JSON_OBJECT()

**作用**：创建JSON对象。
**语法**：`JSON_OBJECT(key1, val1, key2, val2, ...)`
**示例**：

```sql
SELECT JSON_OBJECT('name', 'Alice', 'age', 28, 'active', true);
-- 结果: {"name": "Alice", "age": 28, "active": true}
```



#### 1.3 JSON_ARRAYAGG()

**作用**：将结果集聚合成一个JSON数组。
**语法**：`JSON_ARRAYAGG(expression)`
**示例**：

```sql
-- 假设表orders有列product，数据为('A'),('B'),('C')
SELECT JSON_ARRAYAGG(product) FROM orders;
-- 结果: ["A", "B", "C"]
```



#### 1.4 JSON_OBJECTAGG()

**作用**：将两个列的值聚合成一个JSON对象（键值对）。
**语法**：`JSON_OBJECTAGG(key_expr, value_expr)`
**示例**：

```sql
-- 假设表config有key和value列
SELECT JSON_OBJECTAGG(key, value) FROM config;
-- 结果: {"timeout": "30", "retries": "5"}
```

------



### 2. JSON查询函数

#### 2.1 JSON_EXTRACT()

**作用**：从JSON文档中提取值。
**语法**：`JSON_EXTRACT(json_doc, path[, path] ...)`
**示例**：

```sql
SET @json = '{"info": {"name": "Alice", "pets": ["Dog", "Cat"]}}';
SELECT JSON_EXTRACT(@json, '$.info.name'); -- "Alice"
SELECT JSON_EXTRACT(@json, '$.info.pets[0]'); -- "Dog"
```



#### 2.2 路径操作符 -> 和 ->>

- **->**：等同于`JSON_EXTRACT()`，返回带引号的字符串（如果是字符串）。
- **->>**：等同于`JSON_UNQUOTE(JSON_EXTRACT())`，返回去除引号的字符串。

```sql
SELECT profile->'$.name' FROM users; -- 结果: "Alice" (带引号)
SELECT profile->>'$.name' FROM users; -- 结果: Alice (无引号)
```



#### 2.3 JSON_CONTAINS()

**作用**：检查JSON文档中是否包含指定值。
**语法**：`JSON_CONTAINS(json_doc, val[, path])`
**示例**：

```sql
SET @json = '["a", "b", "c"]';
SELECT JSON_CONTAINS(@json, '"b"'); -- 1 (true)
SELECT JSON_CONTAINS(@json, '"d"'); -- 0 (false)
```



#### 2.4 JSON_SEARCH()

**作用**：按值查找并返回路径。
**语法**：`JSON_SEARCH(json_doc, 'one|all', search_str [, escape_char [, path] ...])`
**示例**：

```sql
SET @json = '{"info": {"name": "Alice", "phone": "123"}}';
SELECT JSON_SEARCH(@json, 'one', 'Alice'); -- "$.info.name"
SELECT JSON_SEARCH(@json, 'all', '%3%'); -- ["$.info.phone"] （使用LIKE模式）
```

------



### 3. JSON修改函数



#### 3.1 JSON_SET()

**作用**：替换现有值并添加新值。
**语法**：`JSON_SET(json_doc, path, val [, path, val] ...)`
**示例**：

```sql
SET @json = '{"name": "Alice", "age": 25}';
SELECT JSON_SET(@json, '$.age', 26, '$.country', 'USA');
-- 结果: {"age": 26, "name": "Alice", "country": "USA"}
```



#### 3.2 JSON_INSERT()

**作用**：.

仅在路径不存在时添加值。

如果指定的 path 是数组下标，且 json_doc 不是数组，该函数首先会将 json_doc 转化为数组，然后再插入新值

**语法**：`JSON_INSERT(json_doc, path, val [, path, val] ...)`
**示例**：

```sql
SET @json = '{"name": "Alice"}';
SELECT JSON_INSERT(@json, '$.name', 'Bob', '$.age', 26);
-- 结果: {"name": "Alice", "age": 26} （注意：$.name已存在，不更新）
```



#### 3.3 JSON_REPLACE()

**作用**：仅替换现有路径的值。
**语法**：`JSON_REPLACE(json_doc, path, val [, path, val] ...)`
**示例**：

```sql
SET @json = '{"name": "Alice", "age": 25}';
SELECT JSON_REPLACE(@json, '$.age', 26, '$.country', 'USA');
-- 结果: {"name": "Alice", "age": 26} （注意：country不存在，不添加）
```



#### 3.4 JSON_REMOVE()

**作用**：删除JSON文档中的指定路径。
**语法**：`JSON_REMOVE(json_doc, path [, path] ...)`
**示例**：

```sql
SET @json = '{"name": "Alice", "age": 25}';
SELECT JSON_REMOVE(@json, '$.age');
-- 结果: {"name": "Alice"}
```



#### 3.5 JSON_MERGE_PRESERVE() 和 JSON_MERGE_PATCH()

- **JSON_MERGE_PRESERVE()**：合并多个文档，保留重复键的值（将值合并为数组）。
- **JSON_MERGE_PATCH()**：合并多个文档，重复键则后者覆盖前者（类似深度合并）。

**示例**：

```sql
SET @json1 = '{"name": "Alice", "hobbies": ["reading"]}';
SET @json2 = '{"age": 25, "hobbies": ["traveling"]}';

-- PRESERVE: 保留重复键的所有值
SELECT JSON_MERGE_PRESERVE(@json1, @json2);
-- 结果: {"age": 25, "name": "Alice", "hobbies": ["reading", "traveling"]}

-- PATCH: 后者覆盖前者
SELECT JSON_MERGE_PATCH(@json1, @json2);
-- 结果: {"name": "Alice", "age": 25, "hobbies": ["traveling"]}
```

------



### 4. JSON属性函数

#### 4.1 JSON_TYPE()

**作用**：返回JSON值的类型。
**语法**：`JSON_TYPE(json_val)`
**返回值**：OBJECT, ARRAY, STRING, INTEGER, BOOLEAN, NULL 等。
**示例**：

```sql
SELECT JSON_TYPE('{"name": "Alice"}'); -- OBJECT
SELECT JSON_TYPE('[1,2]'); -- ARRAY
SELECT JSON_TYPE('"hello"'); -- STRING
```



#### 4.2 JSON_VALID()

**作用**：验证字符串是否为有效JSON。
**语法**：`JSON_VALID(val)`
**示例**：

```sql
SELECT JSON_VALID('{"name": "Alice"}'); -- 1
SELECT JSON_VALID('{name: "Alice"}'); -- 0（键未加引号）
```



#### 4.3 JSON_LENGTH()

**作用**：返回JSON文档的长度（数组元素个数或对象成员个数）。
**语法**：`JSON_LENGTH(json_doc [, path])`
**示例**：

```sql
SET @json = '{"info": {"name": "Alice", "pets": ["Dog", "Cat"]}}';
SELECT JSON_LENGTH(@json); -- 1（顶层只有一个键info）
SELECT JSON_LENGTH(@json, '$.info.pets'); -- 2
```



#### 4.4 JSON_KEYS()

**作用**：返回对象中键的数组。
**语法**：`JSON_KEYS(json_doc [, path])`
**示例**：

```sql
SET @json = '{"name": "Alice", "age": 25}';
SELECT JSON_KEYS(@json); -- ["name", "age"]
```

------



### 5. JSON工具函数

#### 5.1 JSON_PRETTY()

**作用**：格式化JSON文档（美化输出）。
**语法**：`JSON_PRETTY(json_val)`
**示例**：

```sql
SELECT JSON_PRETTY('{"name": "Alice", "age": 25}');
/*
结果:
{
  "name": "Alice",
  "age": 25
}
*/
```



#### 5.2 JSON_STORAGE_SIZE()

**作用**：返回存储JSON文档的二进制表示所需的空间（字节）。
**语法**：`JSON_STORAGE_SIZE(json_val)`
**示例**：

```sql
SELECT JSON_STORAGE_SIZE('{"name": "Alice"}'); -- 大约20字节
```



#### 5.3 JSON_STORAGE_FREE()

**作用**：返回部分更新后释放的空间（仅适用于MySQL 8.0.17+，且启用Partial Updates）。
**语法**：`JSON_STORAGE_FREE(json_val)`
**示例**：

```sql
-- 假设profile列已启用部分更新
UPDATE users SET profile = JSON_SET(profile, '$.age', 30) WHERE id=1;
SELECT JSON_STORAGE_FREE(profile) FROM users WHERE id=1; -- 可能返回释放的字节数
```

------



### 6. JSON表函数 (JSON_TABLE)

**作用**：将JSON数据转换为关系表格式（类似虚拟表）。
**语法**：

```text
JSON_TABLE(
    expr,
    path COLUMNS (column_list)
) [AS] alias
```

**示例**：

```sql
SET @json = '[{"name":"Alice", "age":25}, {"name":"Bob", "age":30}]';

SELECT * FROM JSON_TABLE(
    @json,
    '$[*]' COLUMNS (
        name VARCHAR(20) PATH '$.name',
        age INT PATH '$.age'
    )
) AS jt;
/*
结果:
name    | age
--------|-----
Alice   | 25
Bob     | 30
*/
```

------



### 7. JSON Schema验证 (JSON_SCHEMA_VALID)

**作用**：根据JSON Schema验证文档（MySQL 8.0.17+）。
**语法**：`JSON_SCHEMA_VALID(schema, document)`
**示例**：

```sql
SET @schema = '{
    "type": "object",
    "properties": {
        "name": {"type": "string"},
        "age": {"type": "integer"}
    },
    "required": ["name"]
}';

SET @valid_doc = '{"name": "Alice", "age": 25}';
SET @invalid_doc = '{"age": "twenty"}';

SELECT JSON_SCHEMA_VALID(@schema, @valid_doc);    -- 1（有效）
SELECT JSON_SCHEMA_VALID(@schema, @invalid_doc);  -- 0（无效）
```

------



MySQL提供丰富的JSON函数，从创建、查询、修改到验证和转换，覆盖了大多数JSON处理场景。合理利用这些函数可以高效处理半结构化数据。注意：

- 使用路径表达式`$`访问嵌套数据
- MySQL 8.0+ 新增函数（如`JSON_TABLE`, `JSON_SCHEMA_VALID`）大幅增强JSON处理能力
- 通过虚拟列对高频查询字段创建索引提升性能

> 在实际开发中，建议结合应用场景选择合适的函数，并针对性能关键路径进行基准测试。





## GORM实践



### 定义JSON字段

```go
package main

import (
    "gorm.io/gorm"
    "gorm.io/datatypes"
)

type User struct {
    gorm.Model
    Name       string
    Profile    datatypes.JSON  // 用户资料（JSON格式）
    Settings   datatypes.JSON  // 用户设置（JSON格式）
    Metadata   datatypes.JSON  // 元数据（JSON格式）
}

// 初始化数据库
func InitDB() (*gorm.DB, error) {
    dsn := "user:password@tcp(127.0.0.1:3306)/dbname?charset=utf8mb4&parseTime=True&loc=Local"
    db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
    if err != nil {
        return nil, err
    }
    
    // 自动迁移
    err = db.AutoMigrate(&User{})
    if err != nil {
        return nil, err
    }
    
    return db, nil
}
```



### CRUD操作

#### 创建记录

```go
// 创建用户
func CreateUser(db *gorm.DB, name string, profile, settings, metadata map[string]interface{}) (*User, error) {
    // 将map转换为JSON
    profileJSON, err := json.Marshal(profile)
    if err != nil {
        return nil, err
    }
    
    settingsJSON, err := json.Marshal(settings)
    if err != nil {
        return nil, err
    }
    
    metadataJSON, err := json.Marshal(metadata)
    if err != nil {
        return nil, err
    }
    
    user := &User{
        Name:     name,
        Profile:  datatypes.JSON(profileJSON),
        Settings: datatypes.JSON(settingsJSON),
        Metadata: datatypes.JSON(metadataJSON),
    }
    
    result := db.Create(user)
    if result.Error != nil {
        return nil, result.Error
    }
    
    return user, nil
}

// 使用示例
profile := map[string]interface{}{
    "age": 30,
    "gender": "male",
    "address": map[string]string{
        "city": "Beijing",
        "street": "Main St",
    },
}

settings := map[string]interface{}{
    "theme": "dark",
    "notifications": true,
    "preferences": []string{"sports", "music"},
}

metadata := map[string]interface{}{
    "created_by": "admin",
    "source": "web",
}

user, err := CreateUser(db, "John Doe", profile, settings, metadata)
```



#### 查询记录

```go
// 根据ID获取用户
func GetUserByID(db *gorm.DB, id uint) (*User, error) {
    var user User
    result := db.First(&user, id)
    if result.Error != nil {
        return nil, result.Error
    }
    return &user, nil
}

// 获取所有用户
func GetAllUsers(db *gorm.DB) ([]User, error) {
    var users []User
    result := db.Find(&users)
    if result.Error != nil {
        return nil, result.Error
    }
    return users, nil
}


// 查询设置中使用深色主题的用户
func GetUsersWithDarkTheme(db *gorm.DB) ([]User, error) {
    var users []User
    result := db.Where(
        datatypes.JSONQuery("settings").Equals("dark", "theme"),
    ).Find(&users)
    
    if result.Error != nil {
        return nil, result.Error
    }
    return users, nil
}

// 查询资料中城市为北京的用戶
func GetUsersInBeijing(db *gorm.DB) ([]User, error) {
    var users []User
    result := db.Where(
        datatypes.JSONQuery("profile").Equals("Beijing", "address", "city"),
    ).Find(&users)
    
    if result.Error != nil {
        return nil, result.Error
    }
    return users, nil
}

// 查询有通知设置的用户
func GetUsersWithNotifications(db *gorm.DB) ([]User, error) {
    var users []User
    result := db.Where(
        datatypes.JSONQuery("settings").HasKey("notifications"),
    ).Find(&users)
    
    if result.Error != nil {
        return nil, result.Error
    }
    return users, nil
}

// 组合查询示例
func GetActiveUsersInBeijing(db *gorm.DB) ([]User, error) {
    var users []User
    result := db.Where(
        datatypes.JSONQuery("profile").Equals("Beijing", "address", "city"),
    ).Where(
        datatypes.JSONQuery("settings").Equals(true, "notifications"),
    ).Find(&users)
    
    if result.Error != nil {
        return nil, result.Error
    }
    return users, nil
}
```



#### 更新记录

```go
// 更新整个JSON字段
func UpdateUserProfile(db *gorm.DB, id uint, newProfile map[string]interface{}) error {
    profileJSON, err := json.Marshal(newProfile)
    if err != nil {
        return err
    }
    
    result := db.Model(&User{}).Where("id = ?", id).Update("profile", datatypes.JSON(profileJSON))
    return result.Error
}


// 更新JSON字段中的特定属性
func UpdateUserTheme(db *gorm.DB, id uint, theme string) error {
    result := db.Model(&User{}).
        Where("id = ?", id).
        Update("settings", datatypes.JSONSet("settings").
            Set("$.theme", theme),
        )
    return result.Error
}

// 更新嵌套JSON属性
func UpdateUserCity(db *gorm.DB, id uint, city string) error {
    result := db.Model(&User{}).
        Where("id = ?", id).
        Update("profile", datatypes.JSONSet("profile").
            Set("$.address.city", city),
        )
    return result.Error
}

// 向JSON数组添加元素
func AddUserPreference(db *gorm.DB, id uint, preference string) error {
    result := db.Model(&User{}).
        Where("id = ?", id).
        Update("settings", datatypes.JSONSet("settings").
            ArrayAppend("$.preferences", preference),
        )
    return result.Error
}

// 从JSON数组中移除元素
func RemoveUserPreference(db *gorm.DB, id uint, preference string) error {
    result := db.Model(&User{}).
        Where("id = ?", id).
        Update("settings", datatypes.JSONSet("settings").
            ArrayRemove("$.preferences", preference),
        )
    return result.Error
}
```



#### 删除记录

```go
// 删除用户
func DeleteUser(db *gorm.DB, id uint) error {
    result := db.Delete(&User{}, id)
    return result.Error
}

// 根据条件删除用户
func DeleteUsersWithInactiveStatus(db *gorm.DB) error {
    result := db.Where(
        datatypes.JSONQuery("settings").Equals(false, "active"),
    ).Delete(&User{})
    
    return result.Error
}
```





### 复杂查询示例



查询特定年龄段且使用深色主题的用户

```go

func GetUsersByAgeAndTheme(db *gorm.DB, minAge, maxAge int, theme string) ([]User, error) {
    var users []User
    result := db.Where(
        datatypes.JSONQuery("profile").Gte(minAge, "age"),
    ).Where(
        datatypes.JSONQuery("profile").Lte(maxAge, "age"),
    ).Where(
        datatypes.JSONQuery("settings").Equals(theme, "theme"),
    ).Find(&users)
    
    if result.Error != nil {
        return nil, result.Error
    }
    return users, nil
}
```



查询有特定偏好的用户

```go

func GetUsersWithPreference(db *gorm.DB, preference string) ([]User, error) {
    var users []User
    result := db.Where(
        datatypes.JSONQuery("settings").ArrayContains(preference, "preferences"),
    ).Find(&users)
    
    if result.Error != nil {
        return nil, result.Error
    }
    return users, nil
}
```



多条件组合查询

```go

func ComplexQuery(db *gorm.DB) ([]User, error) {
    var users []User
    result := db.Where(
        datatypes.JSONQuery("profile").HasKey("address"),
    ).Where(
        datatypes.JSONQuery("settings").Equals(true, "notifications"),
    ).Where(
        "name LIKE ?", "J%",
    ).Order("created_at DESC").
    Limit(10).
    Find(&users)
    
    if result.Error != nil {
        return nil, result.Error
    }
    return users, nil
}
```



通过构建查询获取JSON中指定字段的值

```go
// 获取用户主题设置
func GetUserTheme(db *gorm.DB, id uint) (string, error) {
    var theme string
    err := db.Model(&User{}).
        Select("JSON_EXTRACT(settings, '$.theme')").
        Where("id = ?", id).
        Scan(&theme).Error
    
    return theme, err
}

// 获取用户城市信息
func GetUserCity(db *gorm.DB, id uint) (string, error) {
    var city string
    err := db.Model(&User{}).
        Select("JSON_EXTRACT(profile, '$.address.city')").
        Where("id = ?", id).
        Scan(&city).Error
    
    return city, err
}
```



JSON字段转换

```go

// 将JSON字段转换为map
func GetUserProfileAsMap(user *User) (map[string]interface{}, error) {
    var profile map[string]interface{}
    err := json.Unmarshal(user.Profile, &profile)
    return profile, err
}

// 将JSON字段转换为结构体
type UserProfile struct {
    Age     int               `json:"age"`
    Gender  string            `json:"gender"`
    Address map[string]string `json:"address"`
}

func GetUserProfileAsStruct(user *User) (*UserProfile, error) {
    var profile UserProfile
    err := json.Unmarshal(user.Profile, &profile)
    return &profile, err
}
```



使用Select减少数据传输

```go
func GetUserNamesWithDarkTheme(db *gorm.DB) ([]string, error) {
    var names []string
    err := db.Model(&User{}).
        Select("name").
        Where(datatypes.JSONQuery("settings").Equals("dark", "theme")).
        Pluck("name", &names).Error
    return names, err
}
```





### 事务操作

```go

// 使用事务更新多个JSON字段
func UpdateUserWithTransaction(db *gorm.DB, id uint, updates map[string]interface{}) error {
    tx := db.Begin()
    defer func() {
        if r := recover(); r != nil {
            tx.Rollback()
        }
    }()
    
    if err := tx.Error; err != nil {
        return err
    }
    
    // 更新profile
    if profile, ok := updates["profile"]; ok {
        profileJSON, err := json.Marshal(profile)
        if err != nil {
            tx.Rollback()
            return err
        }
        
        if err := tx.Model(&User{}).Where("id = ?", id).
            Update("profile", datatypes.JSON(profileJSON)).Error; err != nil {
            tx.Rollback()
            return err
        }
    }
    
    // 更新settings
    if settings, ok := updates["settings"]; ok {
        settingsJSON, err := json.Marshal(settings)
        if err != nil {
            tx.Rollback()
            return err
        }
        
        if err := tx.Model(&User{}).Where("id = ?", id).
            Update("settings", datatypes.JSON(settingsJSON)).Error; err != nil {
            tx.Rollback()
            return err
        }
    }
    
    return tx.Commit().Error
}
```



### 批量操作

```go
func BatchUpdateUserThemes(db *gorm.DB, ids []uint, theme string) error {
    return db.Model(&User{}).
        Where("id IN ?", ids).
        Update("settings", datatypes.JSONSet("settings").
            Set("$.theme", theme),
        ).Error
}
```text





```go
// 查询特定JSON属性
var colors []string
db.Model(&Product{}).Where("JSON_EXTRACT(attributes, '$.color') = ?", `"black"`).Pluck("attributes->'$.color'", &colors)

// 使用GORM的JSON查询
db.Where("attributes->'$.color' = ?", `"black"`).Find(&products)

// 检查JSON属性是否存在
db.Where("JSON_CONTAINS_PATH(attributes, 'one', '$.ports')").Find(&products)

// 查询JSON数组包含特定值的记录
db.Where("JSON_CONTAINS(attributes->'$.ports', ?)", `"USB-C"`).Find(&products)
```



### 索引示例

```go
// 迁移时添加索引
db.Migrator().CreateIndex(&User{}, "profile_age_idx", "JSON_EXTRACT(profile, '$.age')")
db.Migrator().CreateIndex(&User{}, "settings_theme_idx", "JSON_EXTRACT(settings, '$.theme')")
```





### 注意事项

1. **性能考虑**：频繁更新的JSON字段可能影响性能，考虑规范化设计
2. **索引使用**：为经常查询的JSON属性创建虚拟列索引
3. **NULL处理**：GORM中注意处理JSON字段为NULL的情况
4. **版本兼容**：确保使用的JSON函数与MySQL版本兼容
5. **数据验证**：应用层应验证JSON数据，尽管MySQL会验证JSON有效性

通过合理使用MySQL的JSON类型和GORM的支持，可以在关系型数据库中高效地处理半结构化数据，同时保持数据的完整性和查询性能。







### datatypes.JSON

核心结构体：`type JSON json.RawMessage`

`JSON` 类型是基于 `json.RawMessage` 的别名类型，用于表示 JSON 数据。



#### 实现方法

**数据库交互接口：**

```go
// 实现 driver.Valuer 接口，用于将值存入数据库
func (j JSON) Value() (driver.Value, error) {
    if len(j) == 0 {
        return nil, nil
    }
    return string(j), nil
}

// 实现 sql.Scanner 接口，用于从数据库读取值
func (j *JSON) Scan(value interface{}) error {
    // 处理各种输入类型的转换
}
```



**JSON 序列化接口：**

```go
// 实现 json.Marshaler 接口
func (j JSON) MarshalJSON() ([]byte, error)

// 实现 json.Unmarshaler 接口
func (j *JSON) UnmarshalJSON(b []byte) error
```



**GORM 集成接口**：

```go
// 定义 GORM 数据类型
func (JSON) GormDataType() string {
    return "json"
}

// 数据库特定的数据类型
func (JSON) GormDBDataType(db *gorm.DB, field *schema.Field) string
```



#### JSON 查询表达式

```go
type JSONQueryExpression struct {
    column      string
    keys        []string
    hasKeys     bool
    equals      bool
    likes       bool
    equalsValue interface{}
    extract     bool
    path        string
}


// 提供链式 API 构建 JSON 查询条件：
// 基本用法
JSONQuery("column").HasKey("field")
JSONQuery("column").Equals(value, "path.to.field")
JSONQuery("column").Likes(value, "path.to.field")
JSONQuery("column").Extract("path.to.field")
```

实现原理：`Build` 方法根据不同的数据库方言生成相应的 SQL

```go
func (jsonQuery *JSONQueryExpression) Build(builder clause.Builder) {
    switch stmt.Dialector.Name() {
    case "mysql", "sqlite":
        // 生成 MySQL/SQLite 的 JSON_EXTRACT 语法
    case "postgres":
        // 生成 PostgreSQL 的 json_extract_path_text 语法
    }
}
```



#### JSON 更新表达式

```go
type JSONSetExpression struct {
    column     string
    path2value map[string]interface{}
    mutex      sync.RWMutex
}
```text

提供链式 API 构建 JSON 更新操作：

```go
JSONSet("column").Set("path.to.field", value)
```

实现原理：`Build` 方法根据数据库方言生成不同的更新 SQL：

```go
func (jsonSet *JSONSetExpression) Build(builder clause.Builder) {
    switch stmt.Dialector.Name() {
    case "mysql":
        // 使用 JSON_SET 函数
    case "sqlite":
        // 使用 JSON_SET 函数
    case "postgres":
        // 使用 JSONB_SET 函数
    }
}
```text



#### JSON 数组操作

```go
type JSONArrayExpression struct {
    contains    bool
    in          bool
    column      string
    keys        []string
    equalsValue interface{}
}
```

提供数组操作：

```text
JSONArrayQuery("column").Contains(value)  // 检查数组是否包含元素
JSONArrayQuery("column").In(values)       // 检查元素是否在数组中
```



#### 其他实用功能

1. **JSONOverlapsExpression**：
   - 用于检查两个 JSON 文档是否有重叠（仅 MySQL 支持）
2. **columnExpression**：
   - 简单的列名表达式，用于构建查询
