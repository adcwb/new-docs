---
title: "ZooKeeper"
weight: 85
date: 2026-06-05
tags: ["ZooKeeper", "分布式协调", "中间件", "运维"]
---

ZooKeeper 是 Apache 基金会的开源分布式协调服务，提供配置管理、命名注册、分布式锁等功能，是 Kafka、HBase 等大数据组件的重要依赖。本文介绍单机启动与集群部署的操作步骤。

下载最新版本的 ZooKeeper：

```bash
$ wget https://mirror-hk.koddos.net/apache/zookeeper/zookeeper-3.6.1/apache-zookeeper-3.6.1-bin.tar.gz
```

解压：

```bash
$ tar zxvf apache-zookeeper-3.6.1-bin.tar.gz 
```

进入 zookeeper 目录，先启动一个单机的：

```bash
$ cp conf/zoo_sample.cfg conf/zoo.cfg 
$ ./bin/zkServer.sh start
```

查看状态：

```bash
$ ./bin/zkServer.sh status
```

然后停掉，准备部署 zk 集群：

```bash
$ ./bin/zkServer.sh stop
```

## 集群搭建

为每台服务器上的 zk 的配置文件添加以下配置：

```text
dataDir=/mnt/vde/zookeeper
server.1=172.20.20.162:2888:3888
server.2=172.20.20.179:2888:3888
server.3=172.20.20.145:2888:3888
```

上面的地址依次是 主机ip/服务间心跳连接端口/数据端口

分别在数据目录中新增名为 `myid` 文本文件,内容依次为 `0,1,2`,这是集群中每台 `Zookeeper`服务的唯一标识，不能重复，以第一台为例：

```bash
$ echo "0" > /mnt/vde/zookeeper/myid
```

在每台机器上分别启动：

```bash
./bin/zkServer.sh start
```

查看节点状态：

```bash
./bin/zkServer.sh status
```

这样就可以看到节点是 leader 还是 follower。