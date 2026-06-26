---
title: "inuflx"
weight: 60
date: 2026-06-05
---

## 简介

[InfluxDB](https://www.influxdata.com/)是一个开源分布式时序、事件和指标数据库。使用Go语言编写，无需外部依赖。其设计目标是实现分布式和水平伸缩扩展。



## 安装

```BASH
下载地址：
	https://portal.influxdata.com/downloads/


```text



## 术语

| influxDB名词 | 传统数据库概念 |
| :----------: | :------------: |
|   database   |     数据库     |
| measurement  |     数据表     |
|    point     |     数据行     |



### Point

InfluxDB中的point相当于传统数据库里的一行数据，由时间戳（time）、数据（field）、标签（tag）组成。

| Point属性 |                传统数据库概念                |
| :-------: | :------------------------------------------: |
|   time    |     每个数据记录时间，是数据库中的主索引     |
|   field   | 各种记录值（没有索引的属性），例如温度、湿度 |
|   tags    |       各种有索引的属性，例如地区、海拔       |

### Series

`Series`相当于是 InfluxDB 中一些数据的集合，在同一个 database 中，retention policy、measurement、tag sets 完全相同的数据同属于一个 series，同一个 series 的数据在物理上会按照时间顺序排列存储在一起。