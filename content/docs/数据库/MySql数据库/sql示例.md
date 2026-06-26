---
title: "sql示例"
weight: 60
date: 2026-06-05
---

## 统计所有数据库的大小信息

```mysql
SELECT 
    table_schema AS database_name,        -- 数据库名称
    COUNT(*) AS table_count,              -- 该数据库下的表数量
    SUM(data_length + index_length) / 1024 / 1024 AS total_size_mb, -- 数据库总大小(MB)
    SUM(data_length) / 1024 / 1024 AS data_size_mb,                   -- 数据部分大小(MB)
    SUM(index_length) / 1024 / 1024 AS index_size_mb                 -- 索引部分大小(MB)
FROM information_schema.tables          -- 从信息模式中的表视图获取数据
GROUP BY table_schema                   -- 按数据库名称分组
ORDER BY total_size_mb DESC;            -- 按总大小降序排列，最大的排在最前面
```sql

关键字段和概念解释：
| 字段/部分                         | 说明                                                         |
| :-------------------------------- | :----------------------------------------------------------- |
| `table_schema`                    | 表示**数据库的名称**。`GROUP BY table_schema`确保了每个数据库只返回一行统计结果。 |
| `COUNT(*)`                        | 计算每个数据库中有**多少张表**。                             |
| `data_length`                     | 表中**数据部分**的大小的近似值（单位为字节）。对于 InnoDB 表，这可能是一个估算值。 |
| `index_length`                    | 表中**索引部分**的大小（单位为字节）。                       |
| `SUM(data_length + index_length)` | 计算每个数据库所有表的**数据和索引的总和**。`SUM`是聚合函数，因为使用了 `GROUP BY`。 |
| `/ 1024 / 1024`                   | 将字节数转换为**兆字节 (MB)**。除以第一次1024得到KB，再除以第二次1024得到MB。 |
| `ORDER BY total_size_mb DESC`     | 让查询结果按照数据库的**总大小从大到小排序**，一眼就能找到占用空间最大的数据库。 |





## 查看特定数据库内所有表的详细信息

```mysql
SELECT 
    table_name,                          -- 表名称
    table_rows,                          -- 表行数的估计值
    (data_length + index_length) / 1024 / 1024 AS total_size_mb, -- 单表总大小(MB)
    data_length / 1024 / 1024 AS data_size_mb,                   -- 单表数据部分大小(MB)
    index_length / 1024 / 1024 AS index_size_mb,                 -- 单表索引部分大小(MB)
    engine                              -- 表的存储引擎（如 InnoDB、MyISAM）
FROM information_schema.tables          -- 从信息模式中的表视图获取数据
WHERE table_schema = 'opscenter'       -- 指定要查询的数据库名为 'opscenter'
ORDER BY total_size_mb DESC;            -- 按单表总大小降序排列，最大的表排在最前面
```

关键字段和概念解释：
| 字段/部分                          | 说明                                                         |
| :--------------------------------- | :----------------------------------------------------------- |
| `table_name`                       | 表的名称。                                                   |
| `table_rows`                       | 表中**行数的估计值**。对于 InnoDB 等事务性存储引擎，这个数字是近似值，可能与实际行数有差异。 |
| `data_length`, `index_length`      | 同上一个查询，但这里展示的是**单个表**的数据和索引大小。     |
| `engine`                           | 表的**存储引擎**，例如 `InnoDB`, `MyISAM`, `CSV`等。不同的引擎有不同的特性。 |
| `WHERE table_schema = 'opscenter'` | **过滤条件**，只查询属于 'opscenter' 这个数据库的表。您可以把 'opscenter' 替换成任何您想查看的数据库名。 |



## 查询当前实例所有连接信息

>
>
>show processlist 是显示用户正在运行的线程，需要注意的是，除了 root 用户能看到所有正在运行的线程外，其他用户都只能看到自己正在运行的线程，看不到其它用户正在运行的线程。除非单独个这个用户赋予了PROCESS 权限。
>
>root用户，可以看到全部线程运行情况
>
>普通的activiti用户只能看到自己的
>
>单独给activiti用户授PROCESS权限，（授权后需要退出重新登录）
>
>show processlist 显示的信息都是来自MySQL系统库 information_schema 中的 processlist 表。所以使用下面的查询语句可以获得相同的结果：
>
>select * from information_schema.processlist
>
>了解这些基本信息后，下面我们看看查询出来的结果都是什么意思。
>
>Id: 就是这个线程的唯一标识，当我们发现这个线程有问题的时候，可以通过 kill 命令，加上这个Id值将这个线程杀掉。前面我们说了show processlist 显示的信息时来自information_schema.processlist 表，所以这个Id就是这个表的主键。
>
>User: 就是指启动这个线程的用户。
>
>Host: 记录了发送请求的客户端的 IP 和 端口号。通过这些信息在排查问题的时候，我们可以定位到是哪个客户端的哪个进程发送的请求。
>
>DB: 当前执行的命令是在哪一个数据库上。如果没有指定数据库，则该值为 NULL 。
>
>Command: 是指此刻该线程正在执行的命令。这个很复杂，下面单独解释
>
>Time: 表示该线程处于当前状态的时间。
>
>State: 线程的状态，和 Command 对应，下面单独解释。
>
>Info: 一般记录的是线程执行的语句。默认只显示前100个字符，也就是你看到的语句可能是截断了的，要看全部信息，需要使用 show full processlist。
>
>下面我们单独看一下 Command 的值：
>
>Binlog Dump: 主节点正在将二进制日志 ，同步到从节点
>
>Change User: 正在执行一个 change-user 的操作
>
>Close Stmt: 正在关闭一个Prepared Statement 对象
>
>Connect: 一个从节点连上了主节点
>
>Connect Out: 一个从节点正在连主节点
>
>Create DB: 正在执行一个create-database 的操作
>
>Daemon: 服务器内部线程，而不是来自客户端的链接
>
>Debug: 线程正在生成调试信息
>
>Delayed Insert: 该线程是一个延迟插入的处理程序
>
>Drop DB: 正在执行一个 drop-database 的操作
>
>Execute: 正在执行一个 Prepared Statement
>
>Fetch: 正在从Prepared Statement 中获取执行结果
>
>Field List: 正在获取表的列信息
>
>Init DB: 该线程正在选取一个默认的数据库
>
>Kill : 正在执行 kill 语句，杀死指定线程
>
>Long Data: 正在从Prepared Statement 中检索 long data
>
>Ping: 正在处理 server-ping 的请求
>
>Prepare: 该线程正在准备一个 Prepared Statement
>
>ProcessList: 该线程正在生成服务器线程相关信息
>
>Query: 该线程正在执行一个语句
>
>Quit: 该线程正在退出
>
>Refresh：该线程正在刷表，日志或缓存；或者在重置状态变量，或者在复制服务器信息
>
>Register Slave： 正在注册从节点
>
>Reset Stmt: 正在重置 prepared statement
>
>Set Option: 正在设置或重置客户端的 statement-execution 选项
>
>Shutdown: 正在关闭服务器
>
>Sleep: 正在等待客户端向它发送执行语句
>
>Statistics: 该线程正在生成 server-status 信息
>
>Table Dump: 正在发送表的内容到从服务器
>
>Time: Unused

```mysql
-- 查询线程及相关信息 ID 为此线程ID，Time为线程运行时间，Info为此线程SQL
SHOW FULL PROCESSLIST;

-- 按客户端 IP 分组，看哪个客户端的链接数最多
 SELECT
  client_ip,
  count( client_ip ) AS client_num 
FROM
  ( SELECT substring_index( HOST, ':', 1 ) AS client_ip FROM information_schema.PROCESSLIST ) AS connect_info 
GROUP BY
  client_ip 
ORDER BY
  client_num DESC;


-- 查看正在执行的线程，并按 Time 倒排序，看看有没有执行时间特别长的线程
SELECT
  * 
FROM
  information_schema.PROCESSLIST 
WHERE
  Command != 'Sleep' 
ORDER BY
  TIME DESC;


-- 找出所有执行时间超过 5 分钟的线程，拼凑出 kill 语句，方便后面查杀 （此处 5分钟 可根据自己的需要调整SQL标红处）
-- concat是MySQL中拼接函数
SELECT
  concat( 'kill ', id, ';' ) 
FROM
  information_schema.PROCESSLIST 
WHERE
  Command != 'Sleep' 
  AND TIME > 300 
ORDER BY
  TIME DESC;
```text



