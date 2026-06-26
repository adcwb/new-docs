---
title: "InfluxDB文档"
weight: 70
date: 2026-06-05
---

## 简介

InfluxDB默认使用下面的网络端口：

- TCP端口`8086`用作InfluxDB的客户端和服务端的http api通信
- TCP端口`8088`给备份和恢复数据的RPC服务使用

另外，InfluxDB也提供了多个可能需要自定义端口的插件，所以的端口映射都可以通过配置文件修改，对于默认安装的InfluxDB，这个配置文件位于`/etc/influxdb/influxdb.conf`。

## 安装

### Debain & Ubuntu

Debian和Ubuntu用户可以直接用`apt-get`包管理来安装最新版本的InfluxDB。

对于Ubuntu用户，可以用下面的命令添加InfluxDB的仓库

```bash
curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/lsb-release
echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
```

Debian用户用下面的命令：

```bash
curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
source /etc/os-release
test $VERSION_ID = "7" && echo "deb https://repos.influxdata.com/debian wheezy stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
test $VERSION_ID = "8" && echo "deb https://repos.influxdata.com/debian jessie stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
```

然后安装、运行InfluxDB服务：

```bash
sudo apt-get update && sudo apt-get install influxdb
sudo service influxdb start
```

如果你的系统可以使用Systemd(比如Ubuntu 15.04+, Debian 8+），也可以这样启动：

```bash
sudo apt-get update && sudo apt-get install influxdb
sudo systemctl start influxdb
```

### RedHat & CentOS

RedHat和CentOS用户可以直接用`yum`包管理来安装最新版本的InfluxDB。

```text
cat <<EOF | sudo tee /etc/yum.repos.d/influxdb.repo
[influxdb]
name = InfluxDB Repository - RHEL \$releasever
baseurl = https://repos.influxdata.com/rhel/\$releasever/\$basearch/stable
enabled = 1
gpgcheck = 1
gpgkey = https://repos.influxdata.com/influxdb.key
EOF
```

一旦加到了`yum`源里面，就可以运行下面的命令来安装和启动InfluxDB服务：

```bash
sudo yum install influxdb
sudo service influxdb start
```

如果你的系统可以使用Systemd(比如CentOS 7+, RHEL 7+），也可以这样启动：

```bash
sudo yum install influxdb
sudo systemctl start influxdb
```

### MAC OS X

OS X 10.8或者更高版本的用户，可以使用Homebrew来安装InfluxDB; 一旦`brew`安装了，可以用下面的命令来安装InfluxDB：

```text
brew update
brew install influxdb
```

登陆后在用`launchd`开始运行InfluxDB之前，先跑：

```text
ln -sfv /usr/local/opt/influxdb/*.plist ~/Library/LaunchAgents
```

然后运行InfluxDB：

```text
launchctl load ~/Library/LaunchAgents/homebrew.mxcl.influxdb.plist
```

如果你不想用或是不需要launchctl，你可以直接在terminal里运行下面命令来启动InfluxDB：

```text
influxd -config /usr/local/etc/influxdb.conf
```



## 配置

安装好之后，每个配置文件都有了默认的配置，你可以通过命令`influxd config`来查看这些默认配置。

在配置文件`/etc/influxdb/influxdb.conf`之中的大部分配置都被注释掉了，所有这些被注释掉的配置都是由内部默认值决定的。配置文件里任意没有注释的配置都可以用来覆盖内部默认值，需要注意的是，本地配置文件不需要包括每一项配置。

有两种方法可以用自定义的配置文件来运行InfluxDB：

- 运行的时候通过可选参数`-config`来指定：

```text
influxd -config /etc/influxdb/influxdb.conf
```

- 设置环境变量`INFLUXDB_CONFIG_PATH`来指定，例如：

```text
echo $INFLUXDB_CONFIG_PATH
/etc/influxdb/influxdb.conf


influxd
```

其中`-config`的优先级高于环境变量。