---
title: "DNS"
weight: 35
date: 2026-06-05
---

https://mp.weixin.qq.com/s/vwGlL7xNXszTr6mEKLXtZA

## 前言

### Address Records（A记录）

最常用的记录类型

```bash
www      IN    A      1.2.3.4
```



### Alias Records（CNAME记录）

常用于为一个已有的 A 记录创建别名。您不能创建一个CNAME记录指向另一个CNAME记录。

```text
mail     IN    CNAME  www
www      IN    A      1.2.3.4
```



### Mail Exchange Records（MX记录）

常用于定义邮件发往何处。必须指向一个 A 记录，不能是 CNAME。

```ini
IN    MX      mail.example.com.

[...]

mail    IN    A       1.2.3.4
```



### Name Server Records（NS记录）

常用于定义哪个服务器提供该区域的拷贝。它必须指向一个 A 记录，不能是 CNAME。

这是定义主、从服务器的地方。私密服务器被有意省略。

```ini
IN    NS     ns.example.com.

[...]

ns      IN    A      1.2.3.4
```





## BIND DNS使用

### 1、安装

#### Centos安装

```bash
# Centos安装
	yum -y install bind 

# 查看需要修改的配置文件所在路径
	rpm -qc bind                   # 查询bind软件配置文件所在路径
	/etc/named.conf                # 主配置文件
	/etc/named/rfc1912.zonrs       # 区域配置文件
	/var/named/named.localhost     # 区域数据配置文件
```

#### Ubuntu安装

```bash
# 安装bind9服务
$ sudo apt-get install bind9

# 安装相关工具
$ sudo apt-get install bind9-host dnsutils

# 安装文档(可选)
$ sudo apt-get install bind9-doc
```





### 2、配置

#### Centos配置

编辑主配置文件named.conf

```BASH
# vim /etc/named.conf
options {
  listen-on-v6 poet 53 { 192.168.184.10; };              #监听53端口，IP地址使用提供服务的本地IP，也可用any代表所有
# listen-on-v6 port 53 { : :1; };                      #ipv6行如不使用可以注释掉或者删除
  directory       "/var/named";                          #区域数据文件的默认存放位 置
  dump- file      "/var/ named/data/cache_ dump . db";   #域名缓存数据库文件的位置
  statistics-file "/var/named/data/named stats.txt";     #状态统计文件的位置
  memstatistics-file "/var/named/data/named_ mem_ stats. txt";    #内存统计文件的位置
  allow-query       { any; };                            #允许使用本DNS解析服务的网段，也可用any代表所有

```

编辑区域配置文件

```bash
im /etc/named. rfc1912. zone               #文件里有模版，可复制粘贴后修改
zone "80.168.192. in-addr.arpa" IN {        #反向解析的地址倒过来写，代表解析192.168.80段的地址
         type master;
         file "benet. com. zone. local";    #指定区域数据文件为benet.com.zone.local
         allow-update { none; } ;
```



#### Ubuntu配置

BIND9 配置文件被保存在`/etc/bind/`

主配置文件被保存在下列文件中

```text
/etc/bind/named.conf
/etc/bind/named.conf.options
/etc/bind/named.conf.local
```



