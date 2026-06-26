---
title: "SQL 进阶"
weight: 40
date: 2026-06-16
tags: ["PostgreSQL", "SQL", "窗口函数", "CTE"]
---

这篇讲 PostgreSQL 中比基础 CRUD 更强大的查询技巧：窗口函数、CTE（公共表表达式）、`DISTINCT ON` 等 PG 特有语法。

## 窗口函数

窗口函数在「结果集的某个窗口上」做计算，不像 `GROUP BY` 那样合并行，而是保留每一行：

```sql
-- 基本语法
SELECT
    department,
    employee,
    salary,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rank
FROM employees;
```

### 常用窗口函数

```sql
-- 准备测试数据
CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    salesperson VARCHAR(50),
    region VARCHAR(20),
    amount DECIMAL(10,2),
    sale_date DATE
);

INSERT INTO sales (salesperson, region, amount, sale_date) VALUES
    ('张三', '华北', 15000, '2024-01-15'),
    ('李四', '华北', 12000, '2024-01-20'),
    ('王五', '华东', 18000, '2024-01-10'),
    ('赵六', '华东', 14000, '2024-01-25'),
    ('张三', '华南', 20000, '2024-02-01'),
    ('李四', '华南', 11000, '2024-02-05');
```

```sql
-- ROW_NUMBER()：每行唯一序号
SELECT salesperson, amount,
       ROW_NUMBER() OVER (ORDER BY amount DESC) AS row_num
FROM sales;

-- RANK()：排名（有间隔——同值占位）
SELECT salesperson, amount,
       RANK() OVER (ORDER BY amount DESC) AS rank
FROM sales;

-- DENSE_RANK()：排名（无间隔——同值不占位）
SELECT salesperson, amount,
       DENSE_RANK() OVER (ORDER BY amount DESC) AS dense_rank
FROM sales;

-- SUM() + PARTITION BY：分区累计
SELECT salesperson, region, amount,
       SUM(amount) OVER (PARTITION BY region ORDER BY sale_date) AS running_total
FROM sales;

-- LAG/LEAD：前后行访问
SELECT salesperson, amount, sale_date,
       LAG(amount) OVER (ORDER BY sale_date) AS prev_amount,
       amount - LAG(amount) OVER (ORDER BY sale_date) AS diff
FROM sales;
```

## CTE（公共表表达式）

CTE 让你把复杂查询拆成可读的步骤，像一个临时视图：

```sql
-- 基础 CTE
WITH ranked_sales AS (
    SELECT
        salesperson,
        SUM(amount) AS total_sales,
        RANK() OVER (ORDER BY SUM(amount) DESC) AS rank
    FROM sales
    GROUP BY salesperson
)
SELECT * FROM ranked_sales WHERE rank <= 3;
```

```sql
-- 多个 CTE 串联（复杂查询拆为步骤）
WITH
    monthly AS (
        SELECT
            salesperson,
            DATE_TRUNC('month', sale_date) AS month,
            SUM(amount) AS monthly_sales
        FROM sales
        GROUP BY salesperson, DATE_TRUNC('month', sale_date)
    ),
    ranked AS (
        SELECT *,
               RANK() OVER (PARTITION BY month ORDER BY monthly_sales DESC) AS rank
        FROM monthly
    )
SELECT month, salesperson, monthly_sales
FROM ranked
WHERE rank = 1
ORDER BY month;
```

{{< callout type="tip" >}}
CTE + 窗口函数是 PG 数据分析的组合利器。一个业务需求（如「各月各区域的销售冠军」）用 CTE 拆解：先按月汇总 → 再排名 → 最后取第一名。SQL 的可读性远高于层层嵌套的子查询。
{{< /callout >}}

## DISTINCT ON

`DISTINCT ON` 是 PG 独有的语法，按指定列去重并保留每组的第一行：

```sql
-- 每个销售员最新的销售记录
SELECT DISTINCT ON (salesperson)
    salesperson,
    amount,
    sale_date
FROM sales
ORDER BY salesperson, sale_date DESC;
```

等价于用窗口函数写的：

```sql
SELECT salesperson, amount, sale_date
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY salesperson ORDER BY sale_date DESC) AS rn
    FROM sales
) sub
WHERE rn = 1;
```

`DISTINCT ON` 更简洁，但必须和 `ORDER BY` 配合——按相同列排序才能得到预期结果。

## 递归 CTE

处理树形结构（菜单、组织架构、文件目录）：

```sql
-- 建表
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    parent_id INT REFERENCES categories(id)
);

INSERT INTO categories (id, name, parent_id) VALUES
    (1, '电子产品', NULL),
    (2, '手机', 1),
    (3, '电脑', 1),
    (4, '苹果', 2),
    (5, '华为', 2),
    (6, '笔记本', 3);

-- 递归查询：从"电子产品"往下找所有子分类
WITH RECURSIVE tree AS (
    -- 基础情况：根节点
    SELECT id, name, parent_id, 0 AS level
    FROM categories
    WHERE parent_id IS NULL

    UNION ALL

    -- 递归情况：子节点
    SELECT c.id, c.name, c.parent_id, t.level + 1
    FROM categories c
    INNER JOIN tree t ON c.parent_id = t.id
)
SELECT REPEAT('  ', level) || name AS hierarchy
FROM tree;
```

输出：

```text
电子产品
  手机
    苹果
    华为
  电脑
    笔记本
```

## 聚合与 GROUP BY 进阶

```sql
-- GROUPING SETS：多维度汇总
SELECT
    COALESCE(region, '所有地区') AS region,
    COALESCE(salesperson, '所有销售') AS salesperson,
    SUM(amount) AS total
FROM sales
GROUP BY GROUPING SETS ((region), (salesperson), ())
ORDER BY region, salesperson;

-- FILTER 从句（PG 特有的条件聚合语法）
SELECT
    salesperson,
    SUM(amount) FILTER (WHERE region = '华北') AS north_sales,
    SUM(amount) FILTER (WHERE region = '华东') AS east_sales,
    SUM(amount) FILTER (WHERE region = '华南') AS south_sales
FROM sales
GROUP BY salesperson;
```

## 一句话小结

窗口函数让你在保留原行的情况下做排名和累计，CTE 把复杂查询拆成可读步骤，`DISTINCT ON` 是最简洁的去重方式，递归 CTE 处理树形数据。掌握这些，你的 SQL 就从「能查」跃升到「查得好」。下一篇讲 [索引与性能优化](../05索引与性能/)。
