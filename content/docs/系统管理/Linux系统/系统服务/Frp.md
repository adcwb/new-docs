---
title: "Frp"
weight: 45
date: 2026-06-05
tags: ["Frp", "内网穿透", "反向代理", "运维"]
---

Frp 是一款高性能的内网穿透工具，支持 TCP/UDP/HTTP/HTTPS 协议转发，可将内网服务暴露到公网访问。本文介绍在 CentOS 上安装 frp 客户端（frpc）与服务端（frps）的完整步骤及 Systemd 服务配置。

## CentOS 安装frp

```bash
官方文档：
	https://gofrp.org/docs/
	
github地址：
	https://github.com/fatedier/frp
```



### 下载

```bash
wget https://github.com/fatedier/frp/releases/download/v0.36.2/frp_0.36.2_linux_amd64.tar.gz
```



### 解压

```bash
tar zxvf frp_0.36.2_linux_amd64.tar.gz
mv frp_0.36.2_linux_amd64 /usr/local/frp
ln -s /usr/local/frp/frpc /bin/frpc
ln -s /usr/local/frp/frps /bin/frps
mkdir /etc/frp
touch /etc/frp/{frpc.ini, frps.ini}

```



### 服务

```bash
vim /usr/lib/systemd/system/frp.service

[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=simple
ExecStart=/usr/local/frp/frps -c /usr/local/frp/frps.ini
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true
StandardOutput=syslog
StandardError=inherit

[Install]
WantedBy=multi-user.target


systemctl start frps
systemctl stop frps
systemctl restart frps
systemctl status frps

systemctl enable frps
systemctl disable frps
```

## 配置

```bash
# 服务端配置
[root@MyCloudServer frp]# cat frps.ini 
[common]
server_addr = 0.0.0.0
bind_port = 7000
log_file = /var/log/frps.log
log_level = trace
log_max_days = 7
disable_log_color = false
detailed_errors_to_client = true[common]
bind_port = 7000


# 客户端配置
[root@MyCloudServer frp]# cat frpc.ini 
[common]
server_addr = 127.0.0.1
server_port = 7000

[ssh]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = 6000

```

















