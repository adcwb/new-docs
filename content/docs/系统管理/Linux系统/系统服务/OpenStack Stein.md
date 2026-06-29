---
title: "OpenStack Stein"
weight: 165
date: 2026-06-05
tags: ["OpenStack", "云计算", "虚拟化", "运维"]
---

## OpenStack安装

- 身份服务
- 图像服务
- 安置服务
- 计算服务
- 网络服务

我们建议您在安装最小部署服务后还安装以下组件：

- 仪表板
- 块存储服务



## 简介

```bash
# 版本：
	OpenStack Train版
```



## 环境准备

|   节点   |       IP地址       | 主机名  | 配置 |   备注    |
| :------: | :----------------: | :-----: | :--: | :-------: |
| 控制节点 |   192.168.10.241   | master  | 4H4G | centos7.9 |
| 网络节点 |   192.168.10.242   | network | 4H4G | centos7.9 |
| 存储节点 |   192.168.10.243   | storage | 4H4G | centos7.9 |
| 计算节点 | 192.168.10.244~246 |  node   | 8H8G | centos7.9 |

安装前通用配置

```bash
# 关闭防火墙
	systemctl stop firewalld

# 永久关闭selinux策略
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# 临时关闭selinux策略
	setenforce 0

# 时间同步

# hosts文件配置
    192.168.10.241 master
    192.168.10.242 master2
    192.168.10.243 master3
    192.168.10.244 node1
    192.168.10.245 node2
    192.168.10.246 node3

# 配置ssh互信

# /etc/profile 将密码声明为环境变量
    export ADMIN_PASS=BMIGHYSFvRfVX542LmCpQsjqtD6bonTg
    export CINDER_DBPASS=Ls8rM2lZo@bSCg6td6PrWaNQB5CktOb9
    export CINDER_PASS=BMIGHYSFvRfVX542LmCpQsjqtD6bonTg
    export DASH_DBPASS=BMIGHYSFvRfVX542LmCpQsjqtD6bonTg
    export DEMO_PASS=BMIGHYSFvRfVX542LmCpQsjqtD6bonTg
    export GLANCE_DBPASS=Ls8rM2lZo@bSCg6td6PrWaNQB5CktOb9
    export GLANCE_PASS=BMIGHYSFvRfVX542LmCpQsjqtD6bonTg
    export KEYSTONE_DBPASS=Ls8rM2lZo@bSCg6td6PrWaNQB5CktOb9
    export METADATA_SECRET=BMIGHYSFvRfVX542LmCpQsjqtD6bonTg
    export NEUTRON_DBPASS=Ls8rM2lZo@bSCg6td6PrWaNQB5CktOb9
    export NEUTRON_PASS=BMIGHYSFvRfVX542LmCpQsjqtD6bonTg
    export NOVA_DBPASS=Ls8rM2lZo@bSCg6td6PrWaNQB5CktOb9
    export NOVA_PASS=BMIGHYSFvRfVX542LmCpQsjqtD6bonTg
    export PLACEMENT_PASS=BMIGHYSFvRfVX542LmCpQsjqtD6bonTg
    export RABBIT_PASS=BMIGHYSFvRfVX542LmCpQsjqtD6bonTg
```



参考：https://docs.openstack.org/install-guide/



## yum 库

本次安装**Stein** 这个版本，这一步在所有节点上安装。

安装 yum 库：

```bash
$ yum install centos-release-openstack-stein -y

# rdo源官方建议安装，但是安装后会造成openstack版本不对的情况，谨慎使用此源
$ yum install https://rdoproject.org/repos/rdo-release.rpm -y
$ yum upgrade -y
$ yum install python-openstackclient -y #客户端安装
```

我这里关闭了 SELiunx，如果打开了，还需要执行：

```bash
$ yum install openstack-selinux
```

## 组件图

架构图如下，组件挺多的，每个都需要单独安装：

![image-20211111113700805](https://raw.githubusercontent.com/adcwb/storages/master/image-20211111113700805.png)

全部 service 地址：https://www.openstack.org/software/project-navigator/openstack-components#openstack-services

参考：https://www.cnblogs.com/klb561/p/8660264.html

从左上角开始装。

### 控制节点架构

控制节点包括以下服务

- 管理支持服务
- 基础管理服务
- 扩展管理服务

管理支持服务包含MySQL与Qpid两个服务

- MySQL：数据库作为基础/扩展服务产生的数据存放的地方
- Qpid：消息代理(也称消息中间件)为其他各种服务之间提供了统一的消息通信服务

基础管理服务包含Keystone，Glance，Nova，Neutron，Horizon五个服务

- Keystone：认证管理服务，提供了其余所有组件的认证信息/令牌的管理，创建，修改等等，使用MySQL作为统一的数据库
- Glance：镜像管理服务，提供了对虚拟机部署的时候所能提供的镜像的管理，包含镜像的导入，格式，以及制作相应的模板
- Nova：计算管理服务，提供了对计算节点的Nova的管理，使用Nova-API进行通信
- Neutron：网络管理服务，提供了对网络节点的网络拓扑管理，同时提供Neutron在Horizon的管理面板
- Horizon：控制台服务，提供了以Web的形式对所有节点的所有服务的管理，通常把该服务称为DashBoard

扩展管理服务包含Cinder，Swift，Trove，Heat，Centimeter五个服务

- Cinder：提供管理存储节点的Cinder相关，同时提供Cinder在Horizon中的管理面板
- Swift：提供管理存储节点的Swift相关，同时提供Swift在Horizon中的管理面板
- Trove：提供管理数据库节点的Trove相关，同时提供Trove在Horizon中的管理面板
- Heat：提供了基于模板来实现云环境中资源的初始化，依赖关系处理，部署等基本操作，也可以解决自动收缩,负载均衡等高级特性。
- Centimeter：提供对物理资源以及虚拟资源的监控，并记录这些数据，对该数据进行分析，在一定条件下触发相应动作

控制节点一般来说只需要一个网络端口用于通信/管理各个节点。



### 网络节点架构

网络节点仅包含Neutron服务

- Neutron：负责管理私有网段与公有网段的通信，以及管理虚拟机网络之间的通信/拓扑，管理虚拟机之上的防火等等



### 计算节点架构

计算节点包含Nova，Neutron，Telemeter三个服务

基础服务

- Nova：提供虚拟机的创建，运行，迁移，快照等各种围绕虚拟机的服务，并提供API与控制节点对接，由控制节点下发任务
- Neutron：提供计算节点与网络节点之间的通信服务

扩展服务

- Telmeter：提供计算节点的监控代理，将虚拟机的情况反馈给控制节点，是Centimeter的代理服务



### 存储节点架构

存储节点包含Cinder，Swift等服务

- Cinder：块存储服务，提供相应的块存储，简单来说，就是虚拟出一块磁盘，可以挂载到相应的虚拟机之上，不受文件系统等因素影响，对虚拟机来说，这个操作就像是新加了一块硬盘，可以完成对磁盘的任何操作，包括挂载，卸载，格式化，转换文件系统等等操作，大多应用于虚拟机空间不足的情况下的空间扩容等等
- Swift：对象存储服务，提供相应的对象存储，简单来说，就是虚拟出一块磁盘空间，可以在这个空间当中存放文件，也仅仅只能存放文件，不能进行格式化，转换文件系统，大多应用于云磁盘/文件



## 架构图

参考：https://docs.openstack.org/install-guide/get-started-conceptual-architecture.html

![image-20211111113738788](https://raw.githubusercontent.com/adcwb/storages/master/image-20211111113738788.png)

参考：https://docs.openstack.org/install-guide/get-started-logical-architecture.html

![image-20211111113811538](https://raw.githubusercontent.com/adcwb/storages/master/image-20211111113811538.png)





## 准备

一共就三台机器，生产中建议每台机器都是 24 核心 CPU、48 G内存、两块 200 G 的盘。

准备三台机器上安装 Ceph、一台机器当作控制节点，一台当作计算节点。

下面先安装一些基础服务，包括数据库、消息中间件、Etcd 等，再安装 OpenStack 的一些 Service。



## 安装基础服务

参考：https://docs.openstack.org/install-guide/environment.html

下面的组件全部在 master 上安装和设置。



### 密码设置

要提前设置一些密码，后续都通过环境变量的方式提供，生成随机密码可以使用以下命令：

```bash
$ openssl rand -hex 10
```

在 `/etc/profile` 中设置环境变量：

```bash
export ADMIN_PASS=bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
export CINDER_DBPASS=bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
export CINDER_PASS=bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
export DASH_DBPASS=bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
export DEMO_PASS=bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
export GLANCE_DBPASS=bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
export GLANCE_PASS=bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
export KEYSTONE_DBPASS=bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
export METADATA_SECRET=bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
export NEUTRON_DBPASS=bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
export NEUTRON_PASS=bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
export NOVA_DBPASS=bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
export NOVA_PASS=bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
export PLACEMENT_PASS=bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
export RABBIT_PASS=bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
```

使之生效：

```bash
$ source /etc/profile
```



### 安装 MySQL

安装一个单节点的 mysql，在 master 上安装，安装教程：

下载安装包(mysql 5.7+)

```bash
$ wget -i -c http://dev.mysql.com/get/mysql57-community-release-el7-10.noarch.rpm
```

运行安装包

```bash
$ yum -y install mysql57-community-release-el7-10.noarch.rpm
```

安装数据库

```bash
$ yum -y install mysql-community-server
```

启动服务

```shell
$ systemctl start mysqld.service && systemctl enable mysqld.service
$ systemctl status mysqld.service
```

使用默认密码进入数据库

```bash
grep "password" /var/log/mysqld.log
mysql -uroot -p
```

修改密码，注意密码复杂度要求

```mysql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj';
```

授权远程访问

```mysql
grant all privileges on *.* to 'root'@'%' identified by 'bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj' with grant option;
```

额外添加一个参数，调大最大连接数：

```bash
max_connections=300
```

查看最大连接数：

```mysql
mysql> show variables like '%max_connections%';
```

查看当前连接数：

```mysql
mysql> show status like 'Threads%';
```

Threads_connected 是当前连接数，Threads_running 是并发数。



### 安装 RabbitMQ

RabbitMQ 是一个由 Erlang 语言开发的 AMQP 的开源实现。是一个老牌的消息中间件。

```bash
$ yum install rabbitmq-server -y
```

启动 RabbitMQ：

```bash
$ systemctl enable rabbitmq-server.service
$ systemctl start rabbitmq-server.service
```

添加用户：

```bash
$ rabbitmqctl add_user openstack $RABBIT_PASS
```

为 openstack 用户添加配置、读、写权限：

```bash
$ rabbitmqctl set_permissions openstack ".*" ".*" ".*"
```



### 安装 Memcached

*memcached*是一套分布式的高速缓存系統。安装：

```bash
$ yum install memcached python-memcached -y
```

修改 `/etc/sysconfig/memcached` 配置文件，以允许外部访问，将 `OPTIONS="-l 127.0.0.1,::1"` 改为 ：

```bash
OPTIONS=""
```

启动：

```bash
$ systemctl enable memcached.service
$ systemctl start memcached.service
```



### 安装 etcd

```bash
$ yum install etcd -y
```

修改配置文件 `/etc/etcd/etcd.conf` 如下：

```bash
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="http://192.168.10.241:2380"
ETCD_LISTEN_CLIENT_URLS="http://192.168.10.241:2379"
ETCD_NAME="controller"

ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.10.241:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.10.241:2379"
ETCD_INITIAL_CLUSTER="controller=http://192.168.10.241:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-01"
ETCD_INITIAL_CLUSTER_STATE="new"
```

启动：

```bash
$ systemctl enable etcd
$ systemctl start etcd
```



## 安装 OpenStack Service

最小安装参考：https://docs.openstack.org/install-guide/openstack-services.html#minimal-deployment-for-train

需要安装 Keystone、Glance、Placement、Nova、Neutron 和 Horizon、Cinder



## 安装 Keystone

在 master 上安装 Keystone

创建 mysql 用户及库（mysql 8.0）：

```mysql
mysql> CREATE DATABASE keystone;
mysql> CREATE USER keystone IDENTIFIED BY 'bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj';
mysql> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%';
mysql> FLUSH PRIVILEGES;
```

在 master 上安装 keystone ：

```bash
$ yum install openstack-keystone httpd mod_wsgi -y

# 此处会提示缺少一个包，找到对应的包下载安装即可
wget https://cbs.centos.org/kojifiles/packages/qpid-proton/0.22.0/1.el7/aarch64/qpid-proton-c-0.22.0-1.el7.aarch64.rpm

```

修改配置文件 `/etc/keystone/keystone.conf` 如下：

```ini
[database]
connection = mysql+pymysql://keystone:bapG6ZF%40li3vDw7wZKUXQhfKfhf8DHDri0Kj@master/keystone

[token]
provider = fernet
```

由于我设置的密码中有特殊字符，所以需要urlencode，@ 进行 urlencode 之后就是 %40 。

填充服务数据库：

```bash
$ su -s /bin/sh -c "keystone-manage db_sync" keystone
```

初始化Fernet密钥存储库:

```bash
$ keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
$ keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
```

启动 keystone 服务：

```bash
$ keystone-manage bootstrap --bootstrap-password $ADMIN_PASS \
  --bootstrap-admin-url http://master:5000/v3/ \
  --bootstrap-internal-url http://master:5000/v3/ \
  --bootstrap-public-url http://master:5000/v3/ \
  --bootstrap-region-id RegionOne
```

配置 httpd 服务器，修改 `/etc/httpd/conf/httpd.conf` 配置文件：

```bash
ServerName master
```

创建软连接：

```bash
$ ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/
```

启动 httpd 服务：

```bash
$ systemctl enable httpd.service
$ systemctl start httpd.service
```

在 /etc/profile 中配置环境变量，在三台机器上都要配置：

```bash
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://master:5000/v3
```

使之生效：

```bash
$ source /etc/profile
```

------

创建默认 domain：

```bash
$ openstack domain create --description "An Example Domain" example
```

创建 service 项目：

```bash
$ openstack project create --domain default --description "Service Project" service
```

创建`myproject` project :

```bash
$ openstack project create --domain default --description "Demo Project" myproject
```

创建 **myuser** 用户：

```bash
$ openstack user create --domain default --password-prompt myuser
```

需要设置密码，我这里设置的bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj



创建 **myrole** 权限：

```bash
$ openstack role create myrole
```

把 myrole 权限加入到 myproject 和 myuser 中：

```bash
$ openstack role add --project myproject --user myuser myrole
```

------

验证：

```bash
$ unset OS_AUTH_URL OS_PASSWORD
$ openstack --os-auth-url http://controller:5000/v3 \
  --os-project-domain-name Default --os-user-domain-name Default \
  --os-project-name admin --os-username admin token issue
```

输入 admin 用户的密码。

再验证 myproject：

```bash
$ openstack --os-auth-url http://master:5000/v3 \
  --os-project-domain-name Default --os-user-domain-name Default \
  --os-project-name myproject --os-username myuser token issue
```

输入密码，我这里是 bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj

------

创建 **admin-openrc** 文件：

```bash
export ADMIN_PASS=bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://master:5000/v3
export OS_IDENTITY_API_VERSION=3
```

创建 **demo-openrc** 文件：

```bash
export ADMIN_PASS=bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=myproject
export OS_USERNAME=myuser
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=http://master:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
```

使之生效：

```bash
$ . admin-openrc
```

请求认证token：

```bash
$ openstack token issue
```



## 安装 Glance

Glance 是镜像服务。在 master 上安装 Glance。

创建 mysql 用户及库：

```mysql
mysql> CREATE DATABASE glance;
mysql> CREATE USER glance IDENTIFIED BY 'bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj';
mysql> GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%';
mysql> FLUSH PRIVILEGES;
```

创建 **glance** 用户：

```bash
$ openstack user create --domain default --password-prompt glance
```

密码为上面的 GLANCE_PASS ，即 bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj

为 glance 用户添加 admin 权限：

```bash
$ openstack role add --project service --user glance admin
```

创建 glance service ：

```bash
$ openstack service create --name glance --description "OpenStack Image" image
```

创建 Image service API endpoints:

```bash
$ openstack endpoint create --region RegionOne image public http://master:9292
$ openstack endpoint create --region RegionOne image internal http://master:9292
$ openstack endpoint create --region RegionOne image admin http://master:9292
```

安装 glance 组件：

```bash
$ yum install openstack-glance -y 
```

修改 `/etc/glance/glance-api.conf` 文件：

```bash
[database]
connection = mysql+pymysql://glance:bapG6ZF%40li3vDw7wZKUXQhfKfhf8DHDri0Kj@master/glance

[keystone_authtoken]
www_authenticate_uri  = http://master:5000
auth_url = http://master:5000
memcached_servers = master:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj

[paste_deploy]
flavor = keystone

[glance_store]
stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images/
```

初始化数据库：

```bash
$ su -s /bin/sh -c "glance-manage db_sync" glance
```

启动 Glance 服务：

```bash
$ systemctl enable openstack-glance-api.service
$ systemctl start openstack-glance-api.service
```

## 安装 Placement

在 master 上安装 Placement

创建 mysql 库和用户：

```mysql
mysql> CREATE DATABASE placement;
mysql> CREATE USER placement IDENTIFIED BY 'bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj';
mysql> GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%';
mysql> FLUSH PRIVILEGES;
```

创建用户：

```bash
$ openstack user create --domain default --password-prompt placement
```

密码是上面的 PLACEMENT_PASS ，即 bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj

添加 placement service ：

```bash
$ openstack role add --project service --user placement admin
```

创建Placement API entry：

```bash
$ openstack service create --name placement --description "Placement API" placement
```

创建 Placement API service endpoints :

```bash
$ openstack endpoint create --region RegionOne placement public http://master:8778
$ openstack endpoint create --region RegionOne placement internal http://master:8778
$ openstack endpoint create --region RegionOne placement admin http://master:8778
```

安装 Placement 组件：

```bash
$ yum install openstack-placement-api -y
```

修改 `/etc/placement/placement.conf` 文件：

```bash
[placement_database]
connection = mysql+pymysql://placement:bapG6ZF%40li3vDw7wZKUXQhfKfhf8DHDri0Kj@master/placement

[api]
auth_strategy = keystone

[keystone_authtoken]
auth_url = http://master:5000/v3
memcached_servers = master:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = placement
password = bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
```

初始化数据库：

```bash
$ su -s /bin/sh -c "placement-manage db sync" placement
```

重启 httpd 服务：

```bash
$ systemctl restart httpd
```

验证：

```shell
[root@master ~]# placement-status upgrade check
+----------------------------------+
| Upgrade Check Results            |
+----------------------------------+
| Check: Missing Root Provider IDs |
| Result: Success                  |
| Details: None                    |
+----------------------------------+
| Check: Incomplete Consumers      |
| Result: Success                  |
| Details: None                    |
+----------------------------------+

[root@master ~]# pip install osc-placement
Collecting osc-placement
  Downloading https://files.pythonhosted.org/packages/c8/17/dcd47e4b96a200903f8e746b6f43a086b0506b283814ad2f4e43bb2cf501/osc-placement-3.1.1.tar.gz (56kB)
  Running setup.py install for osc-placement ... done
Successfully installed osc-placement-3.1.1
You are using pip version 8.1.2, however version 21.3.1 is available.
You should consider upgrading via the 'pip install --upgrade pip' command.

[root@master ~]# openstack --os-placement-api-version 1.2 resource class list --sort-column name
Expecting value: line 1 column 1 (char 0)

$ openstack --os-placement-api-version 1.6 trait list --sort-column name
```

这里出现一个错误，如果不解决，后续也有问题，错误：

```bash
Expecting value: line 1 column 1 (char 0)
```

解决方案，在 `/etc/httpd/conf.d/00-placement-api.conf` 中的 `<VirtualHost *:8778>` 内部加入以下代码：

```html
  <Directory /usr/bin>
    <IfVersion >= 2.4>
      Require all granted
    </IfVersion>
    <IfVersion < 2.4>
      Order allow,deny
      Allow from all
    </IfVersion>
  </Directory>
```

重启 httpd：

```bash
$ systemctl restart httpd
```

再次验证：

```bash
[root@master ~]# openstack --os-placement-api-version 1.2 resource class list --sort-column name
+----------------------------+
| name                       |
+----------------------------+
| DISK_GB                    |
| FPGA                       |
| IPV4_ADDRESS               |
| MEMORY_MB                  |
| MEM_ENCRYPTION_CONTEXT     |
| NET_BW_EGR_KILOBIT_PER_SEC |
| NET_BW_IGR_KILOBIT_PER_SEC |
| NUMA_CORE                  |
| NUMA_MEMORY_MB             |
| NUMA_SOCKET                |
| NUMA_THREAD                |
| PCI_DEVICE                 |
| PCPU                       |
| PGPU                       |
| SRIOV_NET_VF               |
| VCPU                       |
| VGPU                       |
| VGPU_DISPLAY_HEAD          |
+----------------------------+

[root@master ~]# openstack --os-placement-api-version 1.6 trait list --sort-column name
+---------------------------------------+
| name                                  |
+---------------------------------------+
| COMPUTE_DEVICE_TAGGING                |
| COMPUTE_GRAPHICS_MODEL_CIRRUS         |
......
| HW_NUMA_ROOT                          |
| MISC_SHARES_VIA_AGGREGATE             |
| STORAGE_DISK_HDD                      |
| STORAGE_DISK_SSD                      |
+---------------------------------------+

```



## 安装 Nova

需要先安装 Nova 控制节点，再安装 Nova 计算节点



### 安装 Nova 控制节点

在 master 上安装 Nova 控制节点。

创建 mysql 用户和库：

```mysql
mysql> CREATE DATABASE nova_api;
mysql> CREATE DATABASE nova;
mysql> CREATE DATABASE nova_cell0;
mysql> CREATE USER nova IDENTIFIED BY 'bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj';
mysql> GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%';
mysql> GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%';
mysql> GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%';
mysql> FLUSH PRIVILEGES;
```

创建 nova 用户：

```bash
[root@master ~]# openstack user create --domain default --password-prompt nova
User Password:
Repeat User Password:
+---------------------+----------------------------------+
| Field               | Value                            |
+---------------------+----------------------------------+
| domain_id           | default                          |
| enabled             | True                             |
| id                  | 86fbc5f194ae4de28964831e9f04e45d |
| name                | nova                             |
| options             | {}                               |
| password_expires_at | None                             |
+---------------------+----------------------------------+

```

密码是 NOVA_PASS ，即 bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj 。

为 nova 添加 admin 权限：

```bash
$ openstack role add --project service --user nova admin
```

创建 `nova` service entity：

```bash
openstack service create --name nova --description "OpenStack Compute" compute
```

创建 Compute API service endpoints：

```bash
$ openstack endpoint create --region RegionOne compute public http://master:8774/v2.1
$ openstack endpoint create --region RegionOne compute internal http://master:8774/v2.1
$ openstack endpoint create --region RegionOne compute admin http://master:8774/v2.1
```

安装 nova：

```bash
$ yum install openstack-nova-api openstack-nova-conductor openstack-nova-novncproxy openstack-nova-scheduler -y
```

修改 `/etc/nova/nova.conf` 文件：

```bash
[DEFAULT]
enabled_apis=osapi_compute,metadata
block_device_allocate_retries=300
block_device_allocate_retries_interval=3
transport_url=rabbit://openstack:bapG6ZF%40li3vDw7wZKUXQhfKfhf8DHDri0Kj@master:5672/
my_ip=192.168.10.241
use_neutron = true
firewall_driver = nova.virt.firewall.NoopFirewallDriver

[api_database]
connection = mysql+pymysql://nova:bapG6ZF%40li3vDw7wZKUXQhfKfhf8DHDri0Kj@master/nova_api

[database]
connection = mysql+pymysql://nova:bapG6ZF%40li3vDw7wZKUXQhfKfhf8DHDri0Kj@master/nova



[api]
auth_strategy = keystone

[keystone_authtoken]
www_authenticate_uri = http://master:5000/
auth_url = http://master:5000/
memcached_servers = master:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = nova
password = bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj



[vnc]
enabled = true
server_listen = $my_ip
server_proxyclient_address = $my_ip

[glance]
api_servers=http://master:9292

[oslo_concurrency]
lock_path = /var/lib/nova/tmp

[placement]
region_name = RegionOne
project_domain_name = Default
project_name = service
auth_type = password
user_domain_name = Default
auth_url = http://master:5000/v3
username = placement
password = bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
```

初始化数据库：

```bash
$ su -s /bin/sh -c "nova-manage api_db sync" nova
```

注册 **cell0** 数据库：

```bash
$ su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
```

注册 cell1 数据库：

```bash
[root@master ~]# su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
04ccfb8a-47ba-48f7-aa27-e4c8b5b68896

```

填充 nove 数据库：

```bash
$ su -s /bin/sh -c "nova-manage db sync" nova
```

验证 cell0 和 cell1 是否被注册了：

```bash
[root@master ~]# su -s /bin/sh -c "nova-manage cell_v2 list_cells" nova
+-------+--------------------------------------+---------------------------------------+----------------------------------------------+----------+
|  名称 |                 UUID                 |             Transport URL             |                  数据库连接                  | Disabled |
+-------+--------------------------------------+---------------------------------------+----------------------------------------------+----------+
| cell0 | 00000000-0000-0000-0000-000000000000 |                 none:/                | mysql+pymysql://nova:****@master/nova_cell0 |  False   |
| cell1 | 04ccfb8a-47ba-48f7-aa27-e4c8b5b68896 | rabbit://openstack:****@master:5672/ |    mysql+pymysql://nova:****@master/nova    |  False   |
+-------+--------------------------------------+---------------------------------------+----------------------------------------------+----------+

```

启动 nova：

```bash
$ systemctl enable \
    openstack-nova-api.service \
    openstack-nova-scheduler.service \
    openstack-nova-conductor.service \
    openstack-nova-novncproxy.service
$ systemctl start \
    openstack-nova-api.service \
    openstack-nova-scheduler.service \
    openstack-nova-conductor.service \
    openstack-nova-novncproxy.service
```

检查更新：

```bash
[root@master ~]# nova-status upgrade check
+--------------------------------------------------------------------+
| Upgrade Check Results                                              |
+--------------------------------------------------------------------+
| Check: Cells v2                                                    |
| Result: Success                                                    |
| Details: No host mappings or compute nodes were found. Remember to |
|   run command 'nova-manage cell_v2 discover_hosts' when new        |
|   compute hosts are deployed.                                      |
+--------------------------------------------------------------------+
| Check: Placement API                                               |
| Result: Success                                                    |
| Details: None                                                      |
+--------------------------------------------------------------------+
| Check: Ironic Flavor Migration                                     |
| Result: Success                                                    |
| Details: None                                                      |
+--------------------------------------------------------------------+
| Check: Cinder API                                                  |
| Result: Success                                                    |
| Details: None                                                      |
+--------------------------------------------------------------------+

```

### 安装 Nova 计算节点

在 node1 上安装：

```bash
$ yum install openstack-nova-compute
```

修改 `/etc/nova/nova.conf` 文件：

```bash
[DEFAULT]
enabled_apis = osapi_compute,metadata
block_device_allocate_retries=300
block_device_allocate_retries_interval=3
transport_url=rabbit://openstack:bapG6ZF%40li3vDw7wZKUXQhfKfhf8DHDri0Kj@master
my_ip=192.168.10.244
use_neutron = true
firewall_driver = nova.virt.firewall.NoopFirewallDriver

[api]
auth_strategy = keystone

[keystone_authtoken]
www_authenticate_uri = http://master:5000/
auth_url = http://master:5000/
memcached_servers = master:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = nova
password = bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj




[vnc]
enabled = true
server_listen = 0.0.0.0
server_proxyclient_address = $my_ip
novncproxy_base_url = http://master:6080/vnc_auto.html

[glance]
api_servers=http://master:9292

[api_database]
connection = mysql+pymysql://nova:bapG6ZF%40li3vDw7wZKUXQhfKfhf8DHDri0Kj@master/nova_api

[oslo_concurrency]
lock_path = /var/lib/nova/tmp

[placement]
region_name = RegionOne
project_domain_name = Default
project_name = service
auth_type = password
user_domain_name = Default
auth_url = http://master:5000/v3
username = placement
password = bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
```

执行：

```bash
$ egrep -c '(vmx|svm)' /proc/cpuinfo
```

如果返回了 0 ，还需要配置：

```bash
[libvirt]
virt_type=qemu
```

启动 Nova 计算节点：

```bash
$ systemctl enable libvirtd.service openstack-nova-compute.service
$ systemctl start libvirtd.service openstack-nova-compute.service
```

查看有哪些计算节点：

```bash
[root@node1 ~]# openstack compute service list --service nova-compute
+----+--------------+-------+------+---------+-------+------------+
| ID | Binary       | Host  | Zone | Status  | State | Updated At |
+----+--------------+-------+------+---------+-------+------------+
|  8 | nova-compute | node1 | nova | enabled | up    | None       |
+----+--------------+-------+------+---------+-------+------------+

```

输入密码：bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj

发现计算节点：

```bash
[root@node1 ~]# su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova
Found 2 cell mappings.
Skipping cell0 since it does not contain hosts.
Getting computes from cell 'cell1': 04ccfb8a-47ba-48f7-aa27-e4c8b5b68896
Checking host mapping for compute host 'node1': 2bfe08ff-4a95-4ff0-b143-a42307f89cef
Creating host mapping for compute host 'node1': 2bfe08ff-4a95-4ff0-b143-a42307f89cef
Found 1 unmapped computes in cell: 04ccfb8a-47ba-48f7-aa27-e4c8b5b68896

```

每次加入新节点后，都要执行 `nova-manage cell_v2 discover_hosts` 命令。

------

### 验证 Nova 安装

```bash
[root@node1 ~]# openstack catalog list
+-----------+-----------+--------------------------------------+
| Name      | Type      | Endpoints                            |
+-----------+-----------+--------------------------------------+
| placement | placement | RegionOne                            |
|           |           |   internal: http://master:8778      |
|           |           | RegionOne                            |
|           |           |   public: http://master:8778        |
|           |           | RegionOne                            |
|           |           |   admin: http://master:8778         |
|           |           |                                      |
| keystone  | identity  | RegionOne                            |
|           |           |   internal: http://master:5000/v3/  |
|           |           | RegionOne                            |
|           |           |   public: http://master:5000/v3/    |
|           |           | RegionOne                            |
|           |           |   admin: http://master:5000/v3/     |
|           |           |                                      |
| glance    | image     | RegionOne                            |
|           |           |   public: http://master:9292        |
|           |           | RegionOne                            |
|           |           |   internal: http://master:9292      |
|           |           | RegionOne                            |
|           |           |   admin: http://master:9292         |
|           |           |                                      |
| nova      | compute   | RegionOne                            |
|           |           |   public: http://master:8774/v2.1   |
|           |           | RegionOne                            |
|           |           |   internal: http://master:8774/v2.1 |
|           |           | RegionOne                            |
|           |           |   admin: http://master:8774/v2.1    |
|           |           |                                      |
+-----------+-----------+--------------------------------------+

[root@master ~]# openstack image list

[root@master ~]# nova-status upgrade check
+--------------------------------+
| Upgrade Check Results          |
+--------------------------------+
| Check: Cells v2                |
| Result: Success                |
| Details: None                  |
+--------------------------------+
| Check: Placement API           |
| Result: Success                |
| Details: None                  |
+--------------------------------+
| Check: Ironic Flavor Migration |
| Result: Success                |
| Details: None                  |
+--------------------------------+
| Check: Cinder API              |
| Result: Success                |
| Details: None                  |
+--------------------------------+

```



## 安装 Neutron

Neutron 提供网络服务。Neutron 也分控制节点和计算节点。



### 安装 Neutron 控制节点

在master节点安装，创建 mysql 库和用户：

```mysql
mysql> CREATE DATABASE neutron;
mysql> CREATE USER neutron IDENTIFIED BY 'bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj';
mysql> GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%';
mysql> FLUSH PRIVILEGES;
```

创建 **neutron** 用户：

```bash
[root@master ~]# openstack user create --domain default --password-prompt neutron
User Password:
Repeat User Password:
+---------------------+----------------------------------+
| Field               | Value                            |
+---------------------+----------------------------------+
| domain_id           | default                          |
| enabled             | True                             |
| id                  | cd1c353d9db74176997e0e66cad80867 |
| name                | neutron                          |
| options             | {}                               |
| password_expires_at | None                             |
+---------------------+----------------------------------+

```

使用 NEUTRON_PASS 为密码，即 bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj。

为 neutron 用户添加 admin 权限：

```bash
$ openstack role add --project service --user neutron admin
```

创建 `neutron` service entity：

```bash
$ openstack service create --name neutron --description "OpenStack Networking" network
```

创建 Networking service API endpoints：

```bash
$ openstack endpoint create --region RegionOne network public http://master:9696
$ openstack endpoint create --region RegionOne network internal http://master:9696
$ openstack endpoint create --region RegionOne network admin http://master:9696
```

------

这里配置网络有两种选项，下面来部署比较简单的 选项一：

```bash
$ yum install openstack-neutron openstack-neutron-ml2 openstack-neutron-linuxbridge ebtables -y
```

修改 `/etc/neutron/neutron.conf` 文件：

```bash
[database]
connection = mysql+pymysql://neutron:bapG6ZF%40li3vDw7wZKUXQhfKfhf8DHDri0Kj@master/neutron

[DEFAULT]
core_plugin = ml2
service_plugins =
notify_nova_on_port_status_changes = true
notify_nova_on_port_data_changes = true
transport_url=rabbit://openstack:bapG6ZF%40li3vDw7wZKUXQhfKfhf8DHDri0Kj@master
auth_strategy = keystone

[keystone_authtoken]
www_authenticate_uri = http://master:5000
auth_url = http://master:5000
memcached_servers = master:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = neutron
password = bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj


[nova]
auth_url = http://master:5000
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = nova
password = bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj

[oslo_concurrency]
lock_path = /var/lib/neutron/tmp
```

修改 `/etc/neutron/plugins/ml2/ml2_conf.ini` 文件，添加以下内容：

```bash
[ml2]
type_drivers = flat,vlan
tenant_network_types =
mechanism_drivers = linuxbridge
extension_drivers = port_security

[ml2_type_flat]
flat_networks = provider

[securitygroup]
enable_ipset = true
```

修改 `/etc/neutron/plugins/ml2/linuxbridge_agent.ini` 文件，添加以下内容：

```bash
# ens192需要修改成本地网卡名称
[linux_bridge]
physical_interface_mappings = provider:ens192

[vxlan]
enable_vxlan = false

[securitygroup]
enable_security_group = true
firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
```

修改 `/etc/neutron/dhcp_agent.ini` 文件，加入以下配置：

```bash
interface_driver = linuxbridge
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
enable_isolated_metadata = true
```

------

修改 `/etc/neutron/metadata_agent.ini` 文件，加入以下内容：

```bash
[DEFAULT]
nova_metadata_host = controller
metadata_proxy_shared_secret = bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
```

修改 `/etc/nova/nova.conf` ，加入以下内容：

```bash
[neutron]
auth_url = http://master:5000
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = neutron
password = bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
service_metadata_proxy = true
metadata_proxy_shared_secret = bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
```

启动 Neutron：

```bash
$ ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
$ su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf \
  --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
$ systemctl restart openstack-nova-api.service
$ systemctl enable neutron-server.service \
  neutron-linuxbridge-agent.service neutron-dhcp-agent.service \
  neutron-metadata-agent.service
$ systemctl start neutron-server.service \
  neutron-linuxbridge-agent.service neutron-dhcp-agent.service \
  neutron-metadata-agent.service
```

创建网络：

```bash
$ openstack network create  --share --external \
  --provider-physical-network provider \
  --provider-network-type flat provider
```

创建子网：

```bash
$ openstack subnet create --network provider \
  --allocation-pool start=10.10.0.2,end=10.10.255.254 \
  --dns-nameserver 10.10.0.1 --gateway 10.10.0.1 \
  --subnet-range 10.10.0.0/16 provider
```

---



### 安装 Neutron 计算节点

在 master2 上安装 Neutron 计算节点。

```bash
$ yum install openstack-neutron-linuxbridge ebtables ipset -y
```

修改 `/etc/neutron/neutron.conf` 文件:

```bash
[DEFAULT]
transport_url=rabbit://openstack:bapG6ZF@%40i3vDw7wZKUXQhfKfhf8DHDri0Kj@master
auth_strategy = keystone

[keystone_authtoken]
www_authenticate_uri = http://master:5000
auth_url = http://master:5000
memcached_servers = master:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = neutron
password = bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj

[oslo_concurrency]
lock_path = /var/lib/neutron/tmp
```

修改 `/etc/neutron/plugins/ml2/linuxbridge_agent.ini` 文件：

```bash
# 此处网卡名称要修改为对应的本地网卡名称
[linux_bridge]
physical_interface_mappings = provider:ens192

[vxlan]
enable_vxlan = false

[securitygroup]
enable_security_group = true
firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
```

修改 `/etc/nova/nova.conf` 文件：

```bash
# 所有的Nova计算节点都要添加

[neutron]
url = http://master:9696
auth_url = http://master:5000
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = neutron
password = bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj
```

重启计算服务：

```bash
$ systemctl restart openstack-nova-compute.service
```

启动网络计算服务：

```bash
$ systemctl enable neutron-linuxbridge-agent.service
$ systemctl start neutron-linuxbridge-agent.service
```

验证：

```bash
$ openstack extension list --network
```

输入密码：BMIGHYSFvRfVX542LmCpQsjqtD6bonTg

查看网络节点列表：

```bash
$ openstack network agent list
```



## 安装 CInder

Cinder 分为 控制节点、储存节点、备份节点



### 安装 Cinder 控制节点

添加 mysql 库和 用户：

```text
mysql> CREATE DATABASE cinder;
mysql> CREATE USER cinder IDENTIFIED BY 'bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj';
mysql> GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%';
mysql> FLUSH PRIVILEGES;
```

创建 cinder 用户：

```bash
[root@master ~]# openstack user create --domain default --password-prompt cinder
User Password:
Repeat User Password:
+---------------------+----------------------------------+
| Field               | Value                            |
+---------------------+----------------------------------+
| domain_id           | default                          |
| enabled             | True                             |
| id                  | d91869c22e6445d09decbb0cad3f6904 |
| name                | cinder                           |
| options             | {}                               |
| password_expires_at | None                             |
+---------------------+----------------------------------+

```

密码是 CINDER_PASS，即 bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj。

为 cinder 用户绑定 admin 权限：

```bash
$ openstack role add --project service --user cinder admin
```

创建 `cinderv2` and `cinderv3` service entities：

```bash
[root@master ~]# openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | OpenStack Block Storage          |
| enabled     | True                             |
| id          | 6a823ff56cb34770a505992bb337d9f2 |
| name        | cinderv2                         |
| type        | volumev2                         |
+-------------+----------------------------------+
[root@master ~]# openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | OpenStack Block Storage          |
| enabled     | True                             |
| id          | 656bbae4b9c4405aad9b6a72d5c79016 |
| name        | cinderv3                         |
| type        | volumev3                         |
+-------------+----------------------------------+

```

创建 Block Storage service API endpoints：

```bash
$ openstack endpoint create --region RegionOne \
  volumev2 public http://master:8776/v2/%\(project_id\)s
$ openstack endpoint create --region RegionOne \
  volumev2 internal http://master:8776/v2/%\(project_id\)s
$ openstack endpoint create --region RegionOne \
  volumev2 admin http://master:8776/v2/%\(project_id\)s

$ openstack endpoint create --region RegionOne \
  volumev3 public http://master:8776/v3/%\(project_id\)s
$ openstack endpoint create --region RegionOne \
  volumev3 internal http://master:8776/v3/%\(project_id\)s
$ openstack endpoint create --region RegionOne \
  volumev3 admin http://master:8776/v3/%\(project_id\)s
```

安装 cinder：

```bash
$ yum install openstack-cinder -y
```

修改 `/etc/cinder/cinder.conf` 文件：

```bash
[database]
connection = mysql+pymysql://cinder:bapG6ZF%40li3vDw7wZKUXQhfKfhf8DHDri0Kj@master/cinder

[DEFAULT]
transport_url=rabbit://openstack:bapG6ZF%40li3vDw7wZKUXQhfKfhf8DHDri0Kj@master:5672/
auth_strategy = keystone
my_ip = 192.168.10.241

[keystone_authtoken]
www_authenticate_uri = http://master:5000
auth_url = http://master:5000
memcached_servers = master:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = cinder
password = bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj

[oslo_concurrency]
lock_path = /var/lib/cinder/tmp
```

初始化数据库：

```bash
$ su -s /bin/sh -c "cinder-manage db sync" cinder
```

配置计算节点使用块储存，在 全部节点 上修改 `/etc/nova/nova.conf` :

```bash
[cinder]
os_region_name = RegionOne
```

重启 nova-api :

```bash
$ systemctl restart openstack-nova-api.service
```

启动块储存控制节点的服务：

```bash
$ systemctl enable openstack-cinder-api.service openstack-cinder-scheduler.service
$ systemctl start openstack-cinder-api.service openstack-cinder-scheduler.service
```



### 安装 Cinder 储存节点

在 master3中安装

```bash
$ yum install lvm2 device-mapper-persistent-data
```

启动 lvm：

```bash
$ systemctl enable lvm2-lvmetad.service
$ systemctl start lvm2-lvmetad.service
```

准备几块磁盘，创建pv：

```bash
$ pvcreate /dev/sdb
$ pvcreate /dev/sdc
```

创建 vg：

```bash
$ vgcreate cinder-volumes /dev/sdb /dev/sdc
```

在 `/etc/lvm/lvm.conf` 中 的 devices 块中添加：

```bash
filter = [ "a/sdb/", "a/sdc/" "r/.*/"]
```

安装 Cinder 储存组件：

```bash
$ yum install openstack-cinder targetcli python-keystone -y
```

修改 `/etc/cinder/cinder.conf` ：

```bash
[database]
connection = mysql+pymysql://cinder:bapG6ZF%40li3vDw7wZKUXQhfKfhf8DHDri0Kj@master/cinder

[DEFAULT]
transport_url=rabbit://openstack:bapG6ZF%40li3vDw7wZKUXQhfKfhf8DHDri0Kj@master
auth_strategy = keystone
my_ip = 192.168.10.243
enabled_backends = lvm
glance_api_servers = http://master:9292

[keystone_authtoken]
www_authenticate_uri = http://master:5000
auth_url = http://master:5000
memcached_servers = master:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = cinder
password = bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj

[lvm]
volume_driver = cinder.volume.drivers.lvm.LVMVolumeDriver
volume_group = cinder-volumes
target_protocol = iscsi
target_helper = lioadm

[oslo_concurrency]
lock_path = /var/lib/cinder/tmp
```

启动 Cinder 储存节点：

```bash
$ systemctl enable openstack-cinder-volume.service target.service
$ systemctl start openstack-cinder-volume.service target.service
```

验证：

```bash
$ openstack volume service list
```

输入密码 bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj



## 安装 Horizon

Horizon就是 Openstack 的 Dashboard。

在 master 上安装：

```bash
$ yum install openstack-dashboard -y
```

修改 `/etc/openstack-dashboard/local_settings` 文件：

```python
OPENSTACK_HOST = "master"
ALLOWED_HOSTS = ['*']
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
CACHES = {
    'default': {
         'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
         'LOCATION': 'master:11211',
    }
}

TIME_ZONE = "Asia/Shanghai"

OPENSTACK_NEUTRON_NETWORK = {
    'enable_auto_allocated_network': False,
    'enable_distributed_router': False,
    'enable_fip_topology_check': True,
    'enable_ha_router': False,
    'enable_ipv6': True,
    'enable_quotas': False,
    'enable_rbac_policy': True,
    'enable_router': True,
    'enable_lb': False,
    'enable_firewall': False,
    'enable_vpn': False,
    'default_dns_nameservers': [],
    'supported_provider_types': ['*'],
    'segmentation_id_range': {},
    'extra_provider_types': {},
    'supported_vnic_types': ['*'],
    'physical_networks': [],

}


OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True
OPENSTACK_API_VERSIONS = {
    "identity": 3,
    "image": 2,
    "volume": 3,
}
OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "Default"
OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"

WEBROOT = "/dashboard/"
```

在 `/etc/httpd/conf.d/openstack-dashboard.conf` 中添加：

```nginx
WSGIApplicationGroup %{GLOBAL}
```

重启 httpd 和 缓存服务：

```bash
$ systemctl restart httpd.service memcached.service
```

测试访问：http://master/dashboard

域填写 default，用户名为 admin,密码为 bapG6ZF@li3vDw7wZKUXQhfKfhf8DHDri0Kj

在界面上创建一个镜像，镜像需要特殊定制的。然后查看镜像列表：

```bash
$ glance image-list
```

然后在 管理员 -> 实例类型中创建一个实例类型。

最后在 项目 -> 计算 -> 实例中创建实例。

我这里可以创建完成！



## 错误

### 错误1

在创建实例时，报错说卷创建错误：

```text
Volume 0e4150db-567 f-4ae0-a947-8fc7a0d624f0 did not finish being created even after we waited 150 seconds or 61 attempts. And its status is downloading.
```

解决方法：在 nova 的控制和计算节点的 `/etc/nova/nova.conf` 中添加以下配置：

```text
block_device_allocate_retries=300
block_device_allocate_retries_interval=3
```

然后重启 Nova 相关的服务，在控制节点：

```bash
$ systemctl restart \
      openstack-nova-api.service \
      openstack-nova-scheduler.service \
      openstack-nova-conductor.service \
      openstack-nova-novncproxy.service
```

在计算节点：

```bash
$ systemctl restart libvirtd.service openstack-nova-compute.service
```



## 总结

跟着官方的教程走，可以手动安装一个集群，中间会有一两个小错误，在网上都可以找到解决方案。