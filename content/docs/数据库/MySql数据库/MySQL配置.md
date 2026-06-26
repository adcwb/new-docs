---
title: "MySQL配置"
weight: 90
date: 2026-06-05
---

```ini
[mysqld]
# 基础设置
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid

# 二进制日志配置
server-id=1
log-bin=mysql-bin
binlog_format=ROW
binlog_row_image=MINIMAL
binlog_row_value_options=PARTIAL_JSON
expire_logs_days=7
max_binlog_size=500M

# 网络和数据包设置
max_allowed_packet=1G
max_connections=200
wait_timeout=600
interactive_timeout=600

# InnoDB 引擎优化
innodb_buffer_pool_size=12G
innodb_log_file_size=1G
innodb_log_buffer_size=64M
innodb_flush_log_at_trx_commit=1
innodb_flush_method=O_DIRECT
innodb_file_per_table=ON
innodb_buffer_pool_instances=8

# 其他优化
skip_name_resolve=ON
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
transaction_isolation=READ-COMMITTED
query_cache_type=0
query_cache_size=0
tmp_table_size=256M
max_heap_table_size=256M
```text





| 参数        | 含义                                                         |
| ----------- | ------------------------------------------------------------ |
| `datadir`   | 数据库的数据文件目录，默认路径 `/var/lib/mysql`。所有的 `.frm`、`.ibd`、`.ib_logfile` 文件均存储于此。 |
| `socket`    | 指定 Unix Socket 文件路径，供本地连接 MySQL 使用，适用于性能敏感场景。 |
| `log-error` | 错误日志输出文件路径。记录服务器启动、关闭、运行过程中的错误信息，便于排错。 |
| `pid-file`  | 存放进程 ID 的文件路径，MySQL 启动后会将主进程 PID 写入此文件。 |
| `server-id`                | 服务器唯一标识，主从复制必须设置不同的 `server-id`。         |
| `log-bin`                  | 启用二进制日志并指定日志文件前缀，用于主从同步、数据恢复、审计。 |
| `binlog_format`            | 设置 binlog 格式。`ROW` 表示记录每一行数据的变更，更精确。   |
| `binlog_row_image`         | `MINIMAL` 表示只记录变更字段，减少日志体积。                 |
| `binlog_row_value_options` | `PARTIAL_JSON` 是 8.0.21+ 的新功能，只记录被修改的 JSON 字段路径，优化 binlog 存储。 |
| `expire_logs_days`         | 二进制日志保留天数，过期自动清理。建议设置避免占满磁盘。     |
| `max_binlog_size`          | 单个 binlog 文件最大大小，超过后自动切换到新文件。           |
| `max_allowed_packet`  | 客户端/服务器能处理的最大数据包大小，防止传输大型 BLOB 或 JSON 时失败。默认 64MB，这里设置为 1G。 |
| `max_connections`     | 最大并发连接数。设置为 200，避免服务器过载。                 |
| `wait_timeout`        | 非交互连接的空闲超时时间（秒），超过后自动断开。             |
| `interactive_timeout` | 交互式连接（如 MySQL CLI）的超时设置。                       |
| `innodb_buffer_pool_size`        | InnoDB 缓冲池大小，决定了数据和索引缓存空间，建议设置为系统内存的 60~80%。 |
| `innodb_log_file_size`           | 每个 redo log 文件的大小，增大可减少 checkpoint 频率。       |
| `innodb_log_buffer_size`         | Redo log 缓冲区大小，事务较多时可适当增大。                  |
| `innodb_flush_log_at_trx_commit` | 设置为 1，表示每次提交事务时都将日志刷新到磁盘，最安全但影响性能。 |
| `innodb_flush_method=O_DIRECT`   | 避免双缓存（OS Cache + InnoDB Cache），提升写入效率。        |
| `innodb_file_per_table`          | 每个表使用独立的 `.ibd` 文件，便于表空间管理。               |
| `innodb_buffer_pool_instances`   | 缓冲池分区个数，提高并发性能，适用于多核机器。               |
| `skip_name_resolve`                      | 禁用 DNS 解析，避免连接延迟，要求用户权限中使用 IP 而非主机名。 |
| `character-set-server`                   | 设置服务器默认字符集为 `utf8mb4`，支持 Emoji。               |
| `collation-server`                       | 设置默认排序规则为 `utf8mb4_unicode_ci`，大小写不敏感，兼容性强。 |
| `transaction_isolation`                  | 设置事务隔离级别为 `READ-COMMITTED`，防止脏读，兼顾性能。    |
| `query_cache_type`                       | 禁用查询缓存（已废弃），防止性能问题。                       |
| `query_cache_size`                       | 查询缓存大小设为 0。                                         |
| `tmp_table_size` / `max_heap_table_size` | 控制内存临时表最大大小，超出将写入磁盘。                     |





