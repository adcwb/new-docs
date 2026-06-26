---
title: "PostgreSQL 简介"
weight: 10
date: 2026-06-16
tags: ["PostgreSQL", "数据库", "入门"]
---

这篇介绍 PostgreSQL 是什么、和 MySQL 有什么不同、为什么越来越多的项目从 MySQL 迁到 PG。读完你会对 PG 的定位和优势有清晰认知。

## PostgreSQL 是什么

PostgreSQL（简称 PG）是一个功能强大的开源对象-关系型数据库系统。经过 30 多年的活跃开发，它在可靠性、功能稳健性和性能方面赢得了极高的声誉。

PG 的核心特点：

- **ACID 完全兼容**：完整的事务支持，比 MySQL 的默认引擎更早实现
- **丰富的数据类型**：原生支持 JSON/JSONB、数组、范围类型、UUID、地理空间（PostGIS）
- **强大的扩展能力**：支持自定义函数（PL/pgSQL、PL/Python、PL/Perl 等十多种语言）、自定义类型、自定义索引
- **并发控制**：使用 MVCC（多版本并发控制），读写互不阻塞
- **标准合规**：对 SQL 标准的支持程度在所有开源数据库中最高

## PostgreSQL vs MySQL

| 方面 | PostgreSQL | MySQL |
| --- | --- | --- |
| SQL 标准支持 | 最完整 | 较宽松（宽松模式） |
| JSON 支持 | JSONB（二进制存储+索引） | JSON（5.7+，8.0 后增强） |
| 窗口函数 | 最早支持，功能最全 | 8.0+ 支持 |
| 全文搜索 | 内置强大 | 基本支持 |
| 地理空间 | PostGIS（行业标准） | 基本空间索引 |
| 复制/集群 | 流复制、逻辑复制 | 主从复制、Group Replication |
| 扩展生态 | 极丰富（FDW、Citus、TimescaleDB） | 较少 |
| 运维复杂度 | 稍高 | 较低 |
| 适用场景 | 复杂查询、数据分析、GIS | Web 应用、简单 CRUD、高并发读 |

{{< callout type="info" >}}
简单粗暴的选择指南：如果你在做数据仓库、GIS、复杂业务逻辑 —— 选 PG。如果做传统 CRUD Web 应用，MySQL 和 PG 都行，团队熟悉哪个用哪个。
{{< /callout >}}

## 为什么越来越多项目迁移到 PG

- **JSONB 是杀手特性**：既享受 NoSQL 的灵活性，又有关系型的事务保障
- **横向扩展方案成熟**：Citus（分布式 PG）、TimescaleDB（时序数据）都是基于 PG 扩展
- **ORM 支持完善**：Django、Prisma、TypeORM、GORM 对 PG 的支持都是第一梯队
- **许可证友好**：PostgreSQL License（类似 MIT），比 MySQL 的 GPL 更宽松

## Docker 快速启动

```bash
docker run --name=pgsql \
  -v /data/postgresql/data:/var/lib/postgresql/data \
  -v /data/postgresql/conf:/etc/postgresql \
  -v /data/postgresql/logs:/var/log/postgresql \
  -e POSTGRES_PASSWORD=YourPassword \
  -e TZ=Asia/Shanghai \
  -p 5432:5432 \
  -d \
  postgres:16
```

| 参数 | 说明 |
| --- | --- |
| `-v /data/postgresql/data:/var/lib/postgresql/data` | 数据持久化 |
| `-v /data/postgresql/conf:/etc/postgresql` | 配置文件挂载 |
| `-e POSTGRES_PASSWORD=密码` | 设置 postgres 超级用户密码 |
| `-p 5432:5432` | 端口映射 |
| `postgres:16` | 指定版本（推荐 16.x，当前最新稳定版） |

## 一句话小结

PostgreSQL 是功能最全的开源关系型数据库：SQL 标准兼容度最高、数据类型最丰富、扩展性最强。如果新项目没有历史包袱，PG 是比 MySQL 更值得考虑的选择。下一篇进入 [基本操作](../02基本操作/)。
