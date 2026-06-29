---
title: "RabbitMQ"
weight: 90
date: 2026-06-05
tags: ["RabbitMQ", "消息队列", "中间件", "运维"]
---

## RabbitMQ安装

### 简介

```bash
# 下载地址
	https://www.rabbitmq.com/download.html


```





### docker安装

```bash
# for RabbitMQ 3.9, the latest series
docker run -it --rm --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.9-management

# for RabbitMQ 3.8,
# 3.8.x support timeline: https://www.rabbitmq.com/versions.html
docker run -it --rm --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3.8-management
```



### Centos7安装

```bash
# 设置证书
## primary RabbitMQ signing key
rpm --import https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc
## modern Erlang repository
rpm --import https://packagecloud.io/rabbitmq/erlang/gpgkey
## RabbitMQ server repository
rpm --import https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey
```



yum源配置

```bash
# In /etc/yum.repos.d/rabbitmq.repo

##
## Zero dependency Erlang
##

[rabbitmq_erlang]
name=rabbitmq_erlang
baseurl=https://packagecloud.io/rabbitmq/erlang/el/7/$basearch
repo_gpgcheck=1
gpgcheck=1
enabled=1
# PackageCloud's repository key and RabbitMQ package signing key
gpgkey=https://packagecloud.io/rabbitmq/erlang/gpgkey
       https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300

[rabbitmq_erlang-source]
name=rabbitmq_erlang-source
baseurl=https://packagecloud.io/rabbitmq/erlang/el/7/SRPMS
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/rabbitmq/erlang/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300

##
## RabbitMQ server
##

[rabbitmq_server]
name=rabbitmq_server
baseurl=https://packagecloud.io/rabbitmq/rabbitmq-server/el/7/$basearch
repo_gpgcheck=1
gpgcheck=1
enabled=1
# PackageCloud's repository key and RabbitMQ package signing key
gpgkey=https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey
       https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300

[rabbitmq_server-source]
name=rabbitmq_server-source
baseurl=https://packagecloud.io/rabbitmq/rabbitmq-server/el/7/SRPMS
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
```



安装

```bash
yum update -y

## install these dependencies from standard OS repositories
yum install socat logrotate -y
yum install erlang rabbitmq-server -y

```





### ubuntu安装

```bash
# 启用https传输
sudo apt-get install apt-transport-https

# 添加存储库秘钥
## Team RabbitMQ's main signing key
curl -1sLf "https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA" | sudo gpg --dearmor | sudo tee /usr/share/keyrings/com.rabbitmq.team.gpg > /dev/null

## Launchpad PPA that provides modern Erlang releases
curl -1sLf "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xf77f1eda57ebb1cc" | sudo gpg --dearmor | sudo tee /usr/share/keyrings/net.launchpad.ppa.rabbitmq.erlang.gpg > /dev/null

## PackageCloud RabbitMQ repository
curl -1sLf "https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey" | sudo gpg --dearmor | sudo tee /usr/share/keyrings/io.packagecloud.rabbitmq.gpg > /dev/null


# 添加软件源
# Source repository definition example.

## Provides modern Erlang/OTP releases
##
## "bionic" as distribution name should work for any reasonably recent Ubuntu or Debian release.
## See the release to distribution mapping table in RabbitMQ doc guides to learn more.
deb [signed-by=/usr/share/keyrings/net.launchpad.ppa.rabbitmq.erlang.gpg] http://ppa.launchpad.net/rabbitmq/rabbitmq-erlang/ubuntu bionic main
deb-src [signed-by=/usr/share/keyrings/net.launchpad.ppa.rabbitmq.erlang.gpg] http://ppa.launchpad.net/rabbitmq/rabbitmq-erlang/ubuntu bionic main

## Provides RabbitMQ
##
## "bionic" as distribution name should work for any reasonably recent Ubuntu or Debian release.
## See the release to distribution mapping table in RabbitMQ doc guides to learn more.
deb [signed-by=/usr/share/keyrings/io.packagecloud.rabbitmq.gpg] https://packagecloud.io/rabbitmq/rabbitmq-server/ubuntu/ bionic main
deb-src [signed-by=/usr/share/keyrings/io.packagecloud.rabbitmq.gpg] https://packagecloud.io/rabbitmq/rabbitmq-server/ubuntu/ bionic main



```



## RabbitMQ使用

```bash
# 启动web页面
	rabbitmq-plugins enable rabbitmq_management

# 关闭插件
	rabbitmq-plugins disable rabbitmq_management

# 添加用户
	rabbitmqctl add_user admin qwer1234
	
# 删除用户
	rabbitmqctl delete_user admin
	
# 修改密码
	rabbitmqctl change_password admin qwer1234
	
# 给用户添加角色
	rabbitmqctl set_user_tags admin administrator
	management
	monitoring
	policymaker
	administrator
	
# 给用户添加权限
	rabbitmqctl set_permissions -p "/" admin ".*" ".*" ".*"
	
	rabbitmqctl set_permissions [-p vhostpath] {user} {conf} {write} {read}
	-p vhostpath ：用于指定一个资源的命名空间，例如 –p / 表示根路径命名空间
	user：用于指定要为哪个用户授权填写用户名
	conf:一个正则表达式match哪些配置资源能够被该用户配置。
	write:一个正则表达式match哪些配置资源能够被该用户读。
	read:一个正则表达式match哪些配置资源能够被该用户访问。

# 查看权限
	# 查看指定命名空间下的所有用户权限
		rabbitmqctl  list_permissions
	# 查看指定命名空间下的所有用户权限
		rabbitmqctl  list_permissions /abc

# 查看用户权限
	rabbitmqctl  list_user_permissions admin

# 清除用户权限
	rabbitmqctl  clear_permissions admin
	
```



## RabbitMQ 命名空间

 		vhost是RabbitMQ中的一个命名空间，可以限制消息的存放位置利用这个命名空间可以进行权限的控制有点类似Windows中的文件夹一样，在不同的文件夹中存放不同的文件。

```bash
# 添加vhost:
	rabbitmqctl add vhost {name}
	
# 删除vhost：
	rabbitmqctl delete vhost {name}
	

```

