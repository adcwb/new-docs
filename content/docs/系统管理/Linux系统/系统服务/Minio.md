---
title: "Minio"
weight: 80
date: 2026-06-05
---

Minio

下载

```bash
wget http://dl.minio.org.cn/server/minio/release/linux-amd64/minio
chmod +x minio
cp minio /usr/bin

```



创建用户和组

```bash
# 创建minio组
groupadd  -g  2021  minio

# 创建minio用户 /sbin/nologin禁止用户登录
useradd  -r  -M  -u  2021  -g 2021  -c "Minio User"  -s /sbin/nologin  minio

```



创建配置文件

```bash
# 设置数据存储目录，需要事先创建
MINIO_VOLUMES="/minio/data"
# 设置端口访问路径
MINIO_OPTS="--address :9000"
# 用户名
MINIO_ROOT_USER=UENdGjWLQVePo7x4
# 密码
MINIO_ROOT_PASSWORD=7kxgnSZbOJcjMXRBp3Isl2mhGEeLDY1v

```



单机启动

```bash
# 服务脚本

[Unit]
#名称
Description=MinIO 
Documentation=https://docs.min.io
Wants=network-online.target
After=network-online.target
#运行文件地址,也就是下载的二进制执行文件
AssertFileIsExecutable=/usr/local/src/minio/minio/bin/minio

[Service]
# User and group
User=minio
Group=minio
#指定配置文件
EnvironmentFile=/minio/conf/minio.conf
#按照配置文件方式指定运行
ExecStart=/bin/minio server $MINIO_OPTS $MINIO_VOLUMES
# 让systemd始终重新启动此服务:always,手动启动装置:on-failure
Restart=on-failure
# Specifies the maximum file descriptor number that can be opened by this process
# 指定此进程可以打开的最大文件描述符编号
LimitNOFILE=65536
# Disable timeout logic and wait until process is stopped
# 禁用超时逻辑并等待进程停止
TimeoutStopSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
```





集群启动

```bash
# 启动脚本 每台机器同样的配置
#!/bin/bash

export MINIO_ROOT_USER=UENdGjWLQVePo7x4
export MINIO_ROOT_PASSWORD=7kxgnSZbOJcjMXRBp3Isl2mhGEeLDY1v

/bin/minio server http://192.168.10.241/minio/data \
                  http://192.168.10.242/minio/data \
                  http://192.168.10.243/minio/data \
                  http://192.168.10.244/minio/data \
                  http://192.168.10.245/minio/data \
                  http://192.168.10.246/minio/data --console-address ":10000"


# 系统服务
[root@master1 ~]# cat /etc/systemd/system/minio.service
[Unit]
Description=Minio service
Documentation=https://docs.minio.io/

[Service]
# User and group
User=minio
Group=minio
ExecStart=/minio/conf/runing.sh
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target


# nginx代理
[root@master1 conf.d]# cat minio.conf 
upstream minio_servers {
    ip_hash;
    server 192.168.10.241:10000;
    server 192.168.10.242:10000;
    server 192.168.10.243:10000;
    server 192.168.10.244:10000;
    server 192.168.10.245:10000;
    server 192.168.10.246:10000;
}

server {
    listen 80;


    location / {
        proxy_set_header Host $host;
        proxy_pass       http://minio_servers;
        proxy_redirect  off;
    }
}

```



权限管理

```bash
# 下载客户端工具
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod a+x mc
cp mc /usr/bin

# 创建client目录
mkdir -p /minio/client/
chown -R minio:minio  /minio/client/

# 第一次使用mc，会自动生成相关的默认配置文件
[root@master1 ~]# mc
mc: Configuration written to `/root/.mc/config.json`. Please update your access credentials.
mc: Successfully created `/root/.mc/share`.
mc: Initialized share uploads `/root/.mc/share/uploads.json` file.
mc: Initialized share downloads `/root/.mc/share/downloads.json` file.

```



创建策略

```json
{
  "Version": "2012-10-17",       
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [ 
		"s3:ListAllMyBuckets",
		"s3:ListBucket",
		"s3:GetBucketLocation",
		"s3:GetObject",
		"s3:PutObject",
		"s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::front/*"
      ]
    }
  ]
}
```





