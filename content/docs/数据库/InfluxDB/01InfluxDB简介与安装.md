---
title: "InfluxDB 简介与安装"
weight: 10
date: 2026-06-16
tags: ["InfluxDB", "时序数据库", "Docker", "入门"]
---

这篇介绍 InfluxDB 是什么、和传统关系型数据库有什么不同、以及用 Docker 快速启动的步骤。适合第一次接触时序数据库的开发者。

## 什么是时序数据库

传统数据库（MySQL、PostgreSQL）擅长处理**现状**——当前的用户、订单、库存。时序数据库专门处理**随时间变化**的数据——服务器 CPU 使用率、传感器温度、API 响应时间、股票价格。

InfluxDB 是时序数据库领域的代表——由 InfluxData 公司开发，Go 语言编写，开源、高性能、支持水平扩展。

## InfluxDB 的核心概念

拿传统数据库来类比：

| InfluxDB | 传统数据库 | 说明 |
| :---: | :---: | --- |
| database | 数据库 | 逻辑隔离 |
| measurement | 数据表 | 同一类数据的集合（如 `cpu_usage`） |
| point | 数据行 | 一条时序记录 |
| tag | 有索引的列 | 元数据（如 `host=server01`, `region=us-east`） |
| field | 无索引的列 | 实际数值（如 `usage=87.5`） |
| timestamp | 时间主索引 | 每条数据的生成时间，天然有序 |

**Series**：database + retention policy + measurement + tag set 相同的数据集合属于同一个 series。同一 series 的数据物理上按时间顺序连续存储——这就是时序查询极快的秘密。

```text
# 一个 point 的 Line Protocol 表示
cpu,host=server01,region=us-west usage=87.5,user=62.3 1705315200000000000
|--| |---------------| |-------------------| |------------------|
 |         |                   |                     |
measurement  tags              fields              timestamp
```

## Docker 快速安装

InfluxDB 2.x 是当前主流版本（注意 1.x 和 2.x 的 API 差异很大）：

```bash
# InfluxDB 2.x
docker run --name=influxdb2 \
  -p 8086:8086 \
  -v /data/influxdb/data:/var/lib/influxdb2 \
  -v /data/influxdb/config:/etc/influxdb2 \
  -e DOCKER_INFLUXDB_INIT_MODE=setup \
  -e DOCKER_INFLUXDB_INIT_USERNAME=admin \
  -e DOCKER_INFLUXDB_INIT_PASSWORD=YourPassword123 \
  -e DOCKER_INFLUXDB_INIT_ORG=my-org \
  -e DOCKER_INFLUXDB_INIT_BUCKET=my-bucket \
  -e DOCKER_INFLUXDB_INIT_RETENTION=30d \
  -d \
  influxdb:2
```

| 参数 | 说明 |
| --- | --- |
| `8086` | InfluxDB HTTP API 端口 |
| `INIT_USERNAME/PASSWORD` | 初始管理员账号 |
| `INIT_ORG` | 组织名称（2.x 的多租户概念） |
| `INIT_BUCKET` | 初始存储桶（类似 database） |
| `INIT_RETENTION` | 数据保留时间（`30d` = 30 天） |

启动后访问 `http://localhost:8086` 进入 Web UI。

{{< callout type="info" >}}
InfluxDB 2.x 把 1.x 的 database + retention policy 合并成了 **Bucket**。API 完全不同——如果你迁移旧项目，需要重写查询部分。如果新项目直接用 2.x，生态更成熟。
{{< /callout >}}

## 2.x 核心概念补充

- **Organization**：组织，一个 InfluxDB 实例可以有多个 org，数据和用户按 org 隔离
- **Bucket**：存储桶，数据存放的地方，有明确的 retention period
- **API Token**：认证方式，替代 1.x 的用户名/密码

## 命令行工具

InfluxDB 2.x 使用 `influx` CLI：

```bash
# 进入容器
docker exec -it influxdb2 bash

# 配置连接
influx config create --config-name default \
  --host-url http://localhost:8086 \
  --org my-org \
  --token your-api-token

# 写入测试数据
influx write \
  --bucket my-bucket \
  --precision s \
  'cpu,host=server01 usage=42.5'

# 查询
influx query 'from(bucket:"my-bucket") |> range(start: -1h)'
```

## 一句话小结

InfluxDB 专为时间序列数据设计：measurement 是表，tag 是索引列，field 是数值列，timestamp 是天然主键。Docker 一键启动，Web UI 开箱即用。下一篇讲 [数据写入](../02数据写入/)。
