---
title: "CentOS环境安装"
weight: 5
date: 2026-06-23
---

Docker

```bash
# etcd安装
docker run -itd -p 2379:2379 -p 2380:2380 --env ALLOW_NONE_AUTHENTICATION=yes --env ETCD_ADVERTISE_CLIENT_URLS=http://etcd-server:2379 --name etcd bitnami/etcd:latest

# etcd安装
docker run -itd --name etcd \
  --user 1001:1001 \
  -v /data/etcd/data:/bitnami/etcd/data \
  -e ALLOW_NONE_AUTHENTICATION=no \
  -e ETCD_CLIENT_CERT_AUTH=false \
  -e ETCD_ROOT_PASSWORD=R0Lpe8u7sCXqKDOSzrWAhGgMcwv2iJ6F  \
  -e ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379" \
  -e ETCD_ADVERTISE_CLIENT_URLS="http://127.0.0.1:2379" \
  -p 2379:2379 -p 2380:2380 \
  bitnami/etcd:latest
  
  
# etcdkeeper
docker run -itd --name etcd-keeper -p 8000:8080 -e ETCD_SERVER=http://192.168.202.206:2379 evildecay/etcdkeeper


# MySQL
docker run -itd --name mysql -p 32577:3306 -e MYSQL_ROOT_PASSWORD=Kaka_2022 mysql:8.0.13 

	--lower_case_table_names=1: 忽略大小写


docker run -d \
  --name mysql-server \
  -e MYSQL_ROOT_PASSWORD=20240522W1m2.qx \
  -e MYSQL_DATABASE=xboard \
  -e MYSQL_USER=xboard \
  -e MYSQL_PASSWORD=Yoyo@89EsMu \
  -v /home/yunwei/mysql/data:/var/lib/mysql \
  -p 32577:3306 \
  mysql:latest
  
  
# Redis
docker run -itd --name redis -p 31641:6379 redis --requirepass "20221121W1m2.x"


docker run -itd --name mongodb \
-p 27017:27017 \
-v /data/mongodb/mongod.conf:/etc/mongod.conf \
-v /data/mongodb/data:/data/db \
-v /data/mongodb/logs:/var/log/mongodb \
-e MONGO_INITDB_ROOT_USERNAME=admin \
-e MONGO_INITDB_ROOT_PASSWORD="ROj4CN0hFWZ6Dp1dLQ2Hgxbfiy7YPotS"\
--restart=always  \
bitnami/mongodb:latest


docker run --name mongodb -p 27017:27017 -itd \
    -e MONGO_INITDB_ROOT_USERNAME=root \
    -e MONGO_INITDB_ROOT_PASSWORD="ROj4CN0hFWZ6Dp1dLQ2Hgxbfiy7YPotS" \
    mongo
    


# influxDB
docker run -itd -p 8086:8086 \
     --name influxdb2 \
     -v /data/influxdb2/data:/var/lib/influxdb2 \
     -v /data/influxdb2/config:/etc/influxdb2 \
     -e DOCKER_INFLUXDB_INIT_MODE=setup \
     -e DOCKER_INFLUXDB_INIT_USERNAME="admin" \
     -e DOCKER_INFLUXDB_INIT_PASSWORD="dy1FWlEsXWZIfk86MUxhY2BTKCNOfT0vaS4/YktKcjk=" \
     -e DOCKER_INFLUXDB_INIT_ADMIN_TOKEN="M3IvXz19OCZCdUFmSkdeSExDO3Q8YGJ6LDRSWk4+Iy4=" \
     -e DOCKER_INFLUXDB_INIT_ORG="Bsi" \
     -e DOCKER_INFLUXDB_INIT_BUCKET="opscenter" \
     influxdb:latest

```





```bash
wget https://www.python.org/ftp/python/3.6.15/Python-3.6.15.tgz
tar zxvf Python-3.6.15.tgz 
cd Python-3.6.15/
mkdir /usr/local/python3
./configure --prefix=/usr/local/python3.8 --enable-optimizations
make && make instal

```





环境变量设置

```bash
# mongodb
export PATH=/usr/local/mongodb/bin:$PATH

# java
export JAVA_HOME=/usr/local/java/jdk1.8.0_311
export JRE_HOME=${JAVA_HOME}/jre
export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
export PATH=${JAVA_HOME}/bin:$PATH

# python3
export PATH=$PATH:$HOME/bin
export PATH=$PATH:/usr/local/python3/bin

# nodejs
export NODE_HOME=/usr/local/nodejs
export PATH=$NODE_HOME/bin:$PATH
export NODE_PATH=$NODE_HOME/lib/node_modules:$PATH

# golang
export GOROOT=/usr/local/golang
export GOPATH=/usr/local/golang/gocode
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# virtualenvs
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/local/python3/bin/python3
source /usr/local/python3/bin/virtualenvwrapper.sh
```



内核升级

## 一、背景

在 CentOS 使用过程中，高版本的应用环境可能需要更高版本的内核才能支持，所以难免需要升级内核，所以以下将介绍**yum和rpm两种升级内核方式**。

关于内核种类:

- `kernel-ml`——kernel-ml 中的ml是英文【 mainline stable 】的缩写，elrepo-kernel中罗列出来的是最新的稳定主线版本。
- `kernel-lt`——kernel-lt 中的lt是英文【 long term support 】的缩写，elrepo-kernel中罗列出来的长期支持版本。ML 与 LT 两种内核类型版本可以共存，但每种类型内核只能存在一个版本。

## 二、在线 yum 安装

### 1）查看当前内核版本信息

```bash
uname -a
# 仅查看版本信息
uname -r
#  通过绝对路径查看查看版本信息及相关内容
cat /proc/version
#  通过绝对路径查看查看版本信息
cat /etc/redhat-release
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/3440a455083b4bc19ceccf5abd87c437.png)

### 2）导入仓库源

```bash
# 1、更新yum源仓库
yum -y update
# 2、导入ELRepo仓库的公共密钥
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
# 3、安装ELRepo仓库的yum源
yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
# 4、查询可用内核版本
yum --disablerepo="*" --enablerepo="elrepo-kernel" list available
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/9e05c46dc50f4db3a243316d6950baca.png)

### 3）选择 ML 或 LT 版本安装

```bash
# 安装 最新版ML 版本
# yum --enablerepo=elrepo-kernel install  kernel-ml-devel kernel-ml -y
# 安装 最新版LT 版本
# yum --enablerepo=elrepo-kernel install kernel-lt-devel kernel-lt -y

# 不带版本号就安装最新版本，这里我们安装 LT 5.4.225-1.el7.elrepo版本
# 安装 LT 版本，K8S全部选这个
yum --enablerepo=elrepo-kernel install kernel-lt-devel-5.4.225-1.el7.elrepo.x86_64 kernel-lt-5.4.225-1.el7.elrepo.x86_64 -y
```

安装完成后需要设置 grub2，即内核默认启动项

### 4）设置启动

> 内核安装好后，需要设置为默认启动选项并重启后才会生效。

查看系统上的所有可用内核

```bash
sudo awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/ba1f5d133d7e4f56b834553ed4eaebcc.png)
刚刚安装的内核即0 : `CentOS Linux (5.4.225-1.el7.elrepo.x86_64) 7 (Core)`
我们需要把grub2默认设置为0
可以通过 `grub2-set-default 0` 命令或编辑 `/etc/default/grub` 文件来设置

**方法1：通过 grub2-set-default 0 命令设置**

```bash
grub2-set-default 0
```

**方法2：编辑 /etc/default/grub 文件**

```bash
# 将GRUB_DEFAULT设置为0，如下
vim /etc/default/grub
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/2682d952883b4d788ed9f9b1f2c0879c.png)

### 5）生成 grub 配置文件

GRUB2 的配置文件通常为 /boot/grub2/grub.cfg，虽然此文件很灵活，但是我们并**不需要手写所有内容**。可以通过程序自动生成，或是直接修改生成之后的文件。通常情况下简单配置文件 `/etc/default/grub` ，然后用程序 `grub-mkconfig` 来产生文件 `grub.cfg`。

```bash
grub2-mkconfig -o /boot/grub2/grub.cfg
```

### 6）重启

```bash
# 重启(默认30秒)
reboot
# 立即重启
reboot -h now
```

### 7）验证是否升级成功

```bash
uname -a
# 仅查看版本信息
uname -r
#  通过绝对路径查看查看版本信息及相关内容
cat /proc/version
#  通过绝对路径查看查看版本信息
cat /etc/redhat-release
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/ccabd581796a4015a695e2f1dc8931cc.png)

### 8）删除旧内核（可选）

查看系统中的全部内核

```bash
rpm -qa | grep kernel
# yum remove kernel-版本
yum remove kernel-3.10.0-1160.el7.x86_64 kernel-3.10.0-1160.71.1.el7.x86_64 kernel-tools-3.10.0-1160.71.1.el7.x86_64 kernel-tools-libs-3.10.0-1160.71.1.el7.x86_64
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/6d51796fd922453bb65085e48f31af84.png)

## 三、离线rpm安装

查找 kernel rpm 历史版本：http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/

### 1）下载内核 RPM

```bash
wget http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-lt-devel-5.4.225-1.el7.elrepo.x86_64.rpm
wget http://mirrors.coreix.net/elrepo-archive-archive/kernel/el7/x86_64/RPMS/kernel-lt-5.4.225-1.el7.elrepo.x86_64.rpm
```

### 2）安装内核

```bash
rpm -ivh kernel-lt-5.4.225-1.el7.elrepo.x86_64.rpm
rpm -ivh kernel-lt-devel-5.4.225-1.el7.elrepo.x86_64.rpm
```

### 3）确认已安装内核版本

```bash
rpm -qa | grep kernel
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/1afb3f5b47504416b11ba6a4708f6674.png)

### 4）设置启动

查看系统上的所有可用内核

```bash
sudo awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/c3c61e9dee524f73b2f4d5599b32f4a9.png)

```bash
grub2-set-default 0
```

### 5）生成 grub 配置文件

GRUB2 的配置文件通常为 `/boot/grub2/grub.cfg`，虽然此文件很灵活，但是我们并**不需要手写所有内容**。可以通过程序自动生成，或是直接修改生成之后的文件。通常情况下简单配置文件 `/etc/default/grub` ，然后用程序 `grub-mkconfig` 来产生文件 `grub.cfg`。

```bash
grub2-mkconfig -o /boot/grub2/grub.cfg
```

### 6）重启

```bash
# 重启(默认30秒)
reboot
# 立即重启
reboot -h now
```

### 7）验证是否升级成功

```bash
uname -a
# 仅查看版本信息
uname -r
#  通过绝对路径查看查看版本信息及相关内容
cat /proc/version
#  通过绝对路径查看查看版本信息
cat /etc/redhat-release
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/b9af5467035c4a009e1631792765e2b0.png)

### 8）删除旧内核（可选）

查看系统中的全部内核

```bash
rpm -qa | grep kernel
# yum remove kernel-版本
yum remove kernel-3.10.0-1160.el7.x86_64 kernel-3.10.0-1160.71.1.el7.x86_64 kernel-tools-3.10.0-1160.71.1.el7.x86_64 kernel-tools-libs-3.10.0-1160.71.1.el7.x86_64
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/6d51796fd922453bb65085e48f31af84.png)

Centos7 内核升级（5.4.225）升级就到这里了，有疑问的小伙伴欢迎给我留言，后续更新【云原生+大数据】相关的文章，请小伙伴耐心等待~

