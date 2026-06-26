---
title: "Prometheus"
weight: 120
date: 2026-06-05
---

## Prometheus监控体系建设


Prometheus(由go语言(golang)开发)是一套开源的监控&报警&时间序列数据库的组合。适合监控docker容器。因为kubernetes(俗称k8s)的流行带动了prometheus的发展。

### 核心组件

**Prometheus Server:**

Prometheus Server是Prometheus组件中的核心部分，负责实现对监控数据的获取，存储以及查询。 Prometheus Server可以通过静态配置管理监控目标，也可以配合使用Service Discovery的方式动态管理监控目标，并从这些监控目标中获取数据。其次Prometheus Server需要对采集到的监控数据进行存储，Prometheus Server本身就是一个时序数据库，将采集到的监控数据按照时间序列的方式存储在本地磁盘当中。最后Prometheus Server对外提供了自定义的PromQL语言，实现对数据的查询以及分析。 Prometheus Server内置的Express Browser UI，通过这个UI可以直接通过PromQL实现数据的查询以及可视化。 Prometheus Server的联邦集群能力可以使其从其他的Prometheus Server实例中获取数据，因此在大规模监控的情况下，可以通过联邦集群以及功能分区的方式对Prometheus Server进行扩展。

**Exporters:**

Exporter将监控数据采集的端点通过HTTP服务的形式暴露给Prometheus Server，Prometheus
Server通过访问该Exporter提供的Endpoint端点，即可获取到需要采集的监控数据。 一般来说可以将Exporter分为2类：
直接采集：这一类Exporter直接内置了对Prometheus监控的支持，比如cAdvisor，Kubernetes，Etcd，Gokit等，都直接内置了用于向Prometheus暴露监控数据的端点。
间接采集：间接采集，原有监控目标并不直接支持Prometheus，因此我们需要通过Prometheus提供的Client Library编写该监控目标的监控采集程序。例如： Mysql Exporter，JMX Exporter，Consul Exporter等。

**PushGateway:**

在Prometheus Server中支持基于PromQL创建告警规则，如果满足PromQL定义的规则，则会产生一条告警，而告警的后续处理流程则由AlertManager进行管理。在AlertManager中我们可以与邮件，Slack等等内置的通知方式进行集成，也可以通过Webhook自定义告警处理方式。

**Service Discovery:**

服务发现在Prometheus中是特别重要的一个部分，基于Pull模型的抓取方式，需要在Prometheus中配置大量的抓取节点信息才可以进行数据收集。有了服务发现后，用户通过服务发现和注册的工具对成百上千的节点进行服务注册，并最终将注册中心的地址配置在Prometheus的配置文件中，大大简化了配置文件的复杂程度，
也可以更好的管理各种服务。 在众多云平台中（AWS,OpenStack），Prometheus可以
通过平台自身的API直接自动发现运行于平台上的各种服务，并抓取他们的信息Kubernetes掌握并管理着所有的容器以及服务信息，那此时Prometheus只需要与Kubernetes打交道就可以找到所有需要监控的容器以及服务对象.

- Consul（官方推荐）等服务发现注册软件
- 通过DNS进行服务发现
- 通过静态配置文件（在服务节点规模不大的情况下）



**Prometheus UI**

Prometheus UI是Prometheus内置的一个可视化管理界面，通过Prometheus UI用户能够轻松的了解Prometheus当前的配置，监控任务运行状态等。 通过Graph面板，用户还能直接使用**PromQL**实时查询监控数据。访问ServerIP:9090/graph打开WEB页面，通过PromQL可以查询数据，可以进行基础的数据展示。

### 时间序列数据

**什么是序列数据**

**时间序列数据**(TimeSeries Data) : 按照时间顺序记录系统、设备状态变化的数据被称为时序数据。

应用的场景很多, 如：

- 无人驾驶车辆运行中要记录的经度，纬度，速度，方向，旁边物体的距
    离等等。每时每刻都要将数据记录下来做分析。

  -  某一个地区的各车辆的行驶轨迹数据
  -  传统证券行业实时交易数据
  -  实时运维监控数据等



**时间序列数据特点**

>性能好:
>
>	关系型数据库对于大规模数据的处理性能糟糕。NOSQL可以比较好的处理大规模数据，让依然比不上时间序列数据库。
>
>存储成本低:
>
>	高效的压缩算法，节省存储空间，有效降低IO
>	Prometheus有着非常高效的时间序列数据存储方法，每个采样数据仅仅占用3.5byte左右空间，上百万条时间序列，30秒间隔，保留60天，大概花了200多G（来自官方数据)
>
>



**Prometheus的主要特征**

- 多维度数据模型
- 灵活的查询语言
- 不依赖分布式存储，单个服务器节点是自主的
- 以HTTP方式，通过pull模型拉去时间序列数据
- 也可以通过中间网关支持push模型
- 通过服务发现或者静态配置，来发现目标服务对象
- 支持多种多样的图表和界面展示



**Prometheus原理架构图**

![image-20220119173731215](https://raw.githubusercontent.com/adcwb/storages/master/image-20220119173731215.png)



### 环境准备

| 操作系统 |     IP地址     |    角色    | 配置  | 备注 |
| :------: | :------------: | :--------: | :---: | :--: |
| centos7  | 192.168.10.241 | prometheus | 8H16G |      |
| centos7  | 192.168.10.242 |  grafana   | 4H8G  |      |
| centos7  | 192.168.10.243 |   agent    | 4H8G  |      |



**主机名配置**

```bash
# 各自配置好主机名
hostnamectl set-hostname --static prometheus

# 三台都互相绑定IP与主机名
# vim /etc/hosts
192.168.10.241 prometheus
192.168.10.242 grafana
192.168.10.243 agent
```



**安全策略配置**

```bash
# systemctl stop firewalld
# systemctl disable firewalld
# iptables -F
# setenforce 0
```



**时间同步**

```bash
ntpdate ntp.aliyun.com
```



### 安装prometheus

从 https://prometheus.io/download/ 下载相应版本，安装到服务器上.

官网提供的是二进制版，解压就能用，不需要编译

![image-20220119174249794](https://raw.githubusercontent.com/adcwb/storages/master/image-20220119174249794.png)

```bash
wget https://github.com/prometheus/prometheus/releases/download/v2.32.1/prometheus-2.32.1.linux-amd64.tar.gz

tar zxvf prometheus-2.32.1.linux-amd64.tar.gz -C /usr/local/

mv /usr/local/prometheus-2.32.1.linux-amd64/ /usr/local/prometheus

```



**创建用户和数据存储目录**

```bash
useradd  -s /sbin/nologin -M prometheus
mkdir /usr/local/prometheus/data
chown -R prometheus:prometheus /usr/local/prometheus/
```



**创建systemd服务**

```bash
vim /usr/lib/systemd/system/prometheus.service

[Unit]
Description=Prometheus
Documentation=https://prometheus.io/
After=network.target

[Service]
Type=simple
User=prometheus
ExecStart=/usr/local/prometheus/prometheus --config.file=/usr/local/prometheus/prometheus.yml --storage.tsdb.path=/usr/local/prometheus/data
Restart=on-failure

[Install]
WantedBy=multi-user.target

# 启动服务
systemctl daemon-reload 
systemctl start prometheus
systemctl status prometheus
systemctl enable prometheus

```

启动后，通过浏览器访问http://服务器IP:9090就可以访问到prometheus的主界面

![image-20220119174702039](https://raw.githubusercontent.com/adcwb/storages/master/image-20220119174702039.png)

默认只监控了本机一台，点Status --> 点Targets --> 可以看到只监控了本机

![image-20220119174819753](https://raw.githubusercontent.com/adcwb/storages/master/image-20220119174819753.png)

**主机数据展示**

通过http://服务器IP:9090/metrics可以查看到监控的数据

![image-20220119174925373](https://raw.githubusercontent.com/adcwb/storages/master/image-20220119174925373.png)

**关键字查询**

在web主界面可以通过关键字查询监控项

![image-20220119175219735](https://raw.githubusercontent.com/adcwb/storages/master/image-20220119175219735.png)



### 安装Grafana

**什么是Grafana**

Grafana是一个开源的度量分析和可视化工具，可以通过将采集的数据分析，查询，然后进行可视化的展示,并能实现报警。

网址: https://grafana.com/

**特点**

- 可视化：快速和灵活的客户端图形具有多种选项。面板插件为许多不同的方式可视化指标和日志。
- 报警：可视化地为最重要的指标定义警报规则。Grafana将持续评估它们，并发送通知。
- 通知：警报更改状态时，它会发出通知。接收电子邮件通知。
- 动态仪表盘：使用模板变量创建动态和可重用的仪表板，这些模板变量作为下拉菜单出现在仪表板顶部。
- 混合数据源：在同一个图中混合不同的数据源!可以根据每个查询指定数据源。这甚至适用于自定义数据源。
- 注释：注释来自不同数据源图表。将鼠标悬停在事件上可以显示完整的事件元数据和标记。
- 过滤器：过滤器允许您动态创建新的键/值过滤器，这些过滤器将自动应用于使用该数据源的所有查询。



**安装Grafana**

在Grafana服务器上安装Grafana

下载地址:https://grafana.com/grafana/download

Grafana有企业版和开源版本，此处使用的是开源版本

Ubuntu and Debian

```bash
sudo apt-get install -y adduser libfontconfig1
wget https://dl.grafana.com/oss/release/grafana_8.3.4_amd64.deb
sudo dpkg -i grafana_8.3.4_amd64.deb
```



Red Hat, CentOS, RHEL, and Fedora(64 Bit)

```bash
wget https://dl.grafana.com/oss/release/grafana-8.3.4-1.x86_64.rpm
sudo yum install grafana-8.3.4-1.x86_64.rpm
```



**启动Grafana**

```BASH
systemctl start grafana-server.service
systemctl status grafana-server.service
systemctl enable grafana-server.service
```

通过浏览器访问 http:// grafana服务器IP:3000就到了登录界面,使用默认的admin用户,admin密码就可以登陆了

第一次登录的时候，会提示修改密码，若不想修改，也可以点击左下角的skip进行跳过

![image-20220119180434399](https://raw.githubusercontent.com/adcwb/storages/master/image-20220119180434399.png)



下面我们把prometheus服务器收集的数据做为数据源添加到grafana, 让grafana可以得到prometheus的数据。

添加数据源

![image-20220119180623678](https://raw.githubusercontent.com/adcwb/storages/master/image-20220119180623678.png)

选择数据源

![image-20220119180647222](https://raw.githubusercontent.com/adcwb/storages/master/image-20220119180647222.png)

此处填写对应的配置，然后保存即可

name为自定义数据源名称

Access选项保持默认即可

Timeout为超时时间

![image-20220119180802788](https://raw.githubusercontent.com/adcwb/storages/master/image-20220119180802788.png)

![image-20220119180953914](https://raw.githubusercontent.com/adcwb/storages/master/image-20220119180953914.png)

**查看创建好的数据源**

![image-20220119181056119](https://raw.githubusercontent.com/adcwb/storages/master/image-20220119181056119.png)



**然后为添加好的数据源做图形显示**

![image-20220120085831538](https://raw.githubusercontent.com/adcwb/storages/master/image-20220120085831538.png)

首次进入的时候，会提示让创建一个新的仪表盘

![image-20220120090834987](https://raw.githubusercontent.com/adcwb/storages/master/image-20220120090834987.png)

选择要监控的指标，然后保存即可

![image-20220120091226612](https://raw.githubusercontent.com/adcwb/storages/master/image-20220120091226612.png)



### 监控远程Linux主机

在需要被监控的Linux主机上面安装node_exporter

```bash
# 二进制安装
wget https://github.com/prometheus/node_exporter/releases/download/v1.2.2/node_exporter-1.2.2.linux-amd64.tar.gz

tar zxvf node_exporter-1.2.2.linux-amd64.tar.gz -C /usr/local/
mv /usr/local/node_exporter-1.2.2.linux-amd64/ /usr/local/node_exporter
nohup /usr/local/node_exporter/node_exporter >/dev/null 2>&1 &

# centos软件源安装
curl -Lo /etc/yum.repos.d/_copr_ibotty-prometheus-exporters.repo https://copr.fedorainfracloud.org/coprs/ibotty/prometheus-exporters/repo/epel-7/ibotty-prometheus-exporters-epel-7.repo

yum install node_exporter

# 启动node_exporter
systemctl start node_exporter.service
systemctl status node_exporter.service
systemctl enable node_exporter.service

# 启动服务的时候，要确保本地的9100端口没有被占用，有时候一些云平台默认会使用node_exporter作为数据来源，如zstack平台
```

通过浏览器访问http://被监控端IP:9100/metrics就可以查看到node_exporter在被监控端收集的监控信息

![image-20220120093620093](https://raw.githubusercontent.com/adcwb/storages/master/image-20220120093620093.png)



回到prometheus服务器的配置文件里添加被监控机器的配置段

![image-20220120094010608](https://raw.githubusercontent.com/adcwb/storages/master/image-20220120094010608.png)

```bash
vim /usr/local/prometheus/prometheus.yml
scrape_configs:

  - job_name: 'prometheus'
    static_configs:
    - targets: ['localhost:9090']
    
  - job_name: '名称随便填写'
    static_configs:
    - targets: ['ip地址:端口号']
```



改完配置文件后, 需要重启服务

```bash
systemctl restart prometheus.service
systemctl status prometheus.service
```

回到web管理界面 --> 点Status --> 点Targets --> 可以看到多了一台监控目标

![image-20220120094902867](https://raw.githubusercontent.com/adcwb/storages/master/image-20220120094902867.png)

### 监控主机的硬件信息

使用别人已经创建好的模板

主机基础监控模板(9276)

![image-20220120095419807](https://raw.githubusercontent.com/adcwb/storages/master/image-20220120095419807.png)

选择load，然后在下方选择数据来源，导入即可

![image-20220120095504734](https://raw.githubusercontent.com/adcwb/storages/master/image-20220120095504734.png)

**效果展示**

![image-20220120095621916](https://raw.githubusercontent.com/adcwb/storages/master/image-20220120095621916.png)



### 监控Nginx

需要自行编译的Nginx， 且要加载nginx-module-vts模块

下载该模块

```bash
git clone git://github.com/vozlt/nginx-module-vts.git
```

下载并编译Nginx

```bash
wget http://nginx.org/download/nginx-1.14.2.tar.gz
tar -zxvf nginx-1.14.2.tar.gz
cd nginx-1.14.2/
mkdir -p /usr/local/nginx
./configure --prefix=/usr/local/nginx --add-module=/root/nginx-module-vts/
make install
```

修改conf文件

```bash
http {
    vhost_traffic_status_zone;
    vhost_traffic_status_filter_by_host on;

...

server {

    ...

    location /status {
        vhost_traffic_status_display;
        vhost_traffic_status_display_format html;
    }
}

```

启动

```bash
cd /usr/local/nginx/sbin
./nginx
```

访问http://ip/status出现以下显示则表示nginx与nginx-vts-exporter安装成功

![image-20220120105031905](https://raw.githubusercontent.com/adcwb/storages/master/image-20220120105031905.png)

**安装nginx-vts-exporter**

下载地址：https://github.com/hnlq715/nginx-vts-exporter/releases

```bash
wget https://github.com/hnlq715/nginx-vts-exporter/releases/download/v0.10.3/nginx-vts-exporter-0.10.3.linux-amd64.tar.gz

tar zxvf nginx-vts-exporter-0.10.3.linux-amd64.tar.gz -C /usr/local/
mv /usr/local/nginx-vts-exporter-0.10.3.linux-amd64/ /usr/local/nginx-vts-exporter
nohup /usr/local/nginx-vts-exporter/nginx-vts-exporter  -nginx.scrape_uri http://192.168.10.243/status/format/json &
```

访问http://192.168.10.243:9913/metrics，若出现以下数据，则证明安装成功

![image-20220120105810535](https://raw.githubusercontent.com/adcwb/storages/master/image-20220120105810535.png)

**在Prometheus服务端配置**

```yaml
scrape_configs:

  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "192.168.10.243"
    static_configs:
      - targets: ["192.168.10.243:9100"]

  - job_name: 'nginx'
    static_configs:
      - targets: ['192.168.10.243:9913']

```

出现以下配置则证明成功

![image-20220120110124030](https://raw.githubusercontent.com/adcwb/storages/master/image-20220120110124030.png)

**配置Grafana**

此处使用Grafana的模板(2949)，直接导入即可

**效果展示**

![image-20220120110943725](https://raw.githubusercontent.com/adcwb/storages/master/image-20220120110943725.png)



### 监控MySQL

安装MySQL，此处不再具体展示安装，参考以下命令

```bash
wget -i -c http://dev.mysql.com/get/mysql57-community-release-el7-10.noarch.rpm
yum -y install mysql57-community-release-el7-10.noarch.rpm
yum -y install mysql-community-server
systemctl start mysqld.service && systemctl enable mysqld.service
systemctl status mysqld.service
grep "password" /var/log/mysqld.log
mysql -uroot -p
ALTER USER 'root'@'localhost' IDENTIFIED BY 'password';
grant all privileges on *.* to 'root'@'%' identified by 'password' with grant option;
flush privileges;
```



**安装MySQL的监控工具mysqld_exporter**

下载页面：https://prometheus.io/download/

```bash
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.13.0/mysqld_exporter-0.13.0.linux-amd64.tar.gz

tar zxvf mysqld_exporter-0.13.0.linux-amd64.tar.gz -C /usr/local/
mv /usr/local/mysqld_exporter-0.13.0.linux-amd64/ /usr/local/mysqld_exporter

```

配置监控

```bash
# 在MySQL中创建一个用户，提供给监控使用，此处由于是测试环境，我直接使用root
create user 'exporter'@'localhost'  IDENTIFIED BY 'eXpIHB666QWE!';
GRANT SELECT, PROCESS, SUPER, REPLICATION CLIENT, RELOAD ON *.* TO 'exporter'@'localhost';

# 创建一个配置文件
mkdir /etc/mysqld_exporter
vim /etc/mysqld_exporter/mysqld_exporter.cnf
[client]
user=exporter
password=eXpIHB666QWE!

# 启动mysqld_exporter
nohup /usr/local/mysqld_exporter/mysqld_exporter  --config.my-cnf=/etc/mysqld_exporter/mysqld_exporter.cnf &

```

浏览器输入：http://192.168.10.243:9104/metrics，可获得 MySQL 监控数据，如下图（部分数据）：

![image-20220120112311613](https://raw.githubusercontent.com/adcwb/storages/master/image-20220120112311613.png)

**在Prometheus服务端配置**

```yaml
scrape_configs:

  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "192.168.10.243"
    static_configs:
      - targets: ["192.168.10.243:9100"]

  - job_name: 'nginx'
    static_configs:
      - targets: ['192.168.10.243:9913']

  - job_name: 'mysqld'
    static_configs:
      - targets: ['192.168.10.243:9104']

```

![image-20220120112640354](https://raw.githubusercontent.com/adcwb/storages/master/image-20220120112640354.png)

**配置Grafana**

此处使用Grafana的模板(7362)，直接导入即可

**效果展示**

由于数据库是临时安装的，里面的数据量有限，所以可能有一些数据没有获取到，所以会显示No data，稍等一会儿他自己会更新的

![image-20220120114953597](https://raw.githubusercontent.com/adcwb/storages/master/image-20220120114953597.png)



### 监控MongoDB

由于时间原因，无法继续写该文档了，监控MongoDB使用的是mongodb_exporter

下载地址：https://github.com/percona/mongodb_exporter/releases

模板使用2583或者12079



### 监控Redis

由于时间原因，无法继续写该文档了，监控Redis使用的是redis_exporter

下载地址：https://github.com/oliver006/redis_exporter/releases

模板使用763





### 监控端口，http状态

```bash
# 监控端口，http状态，存活性使用
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.19.0/blackbox_exporter-0.19.0.linux-amd64.tar.gz

tar zxvf blackbox_exporter-0.19.0.linux-amd64.tar.gz -C /usr/local/
mv /usr/local/blackbox_exporter-0.19.0.linux-amd64 /usr/local/blackbox_exporter

vim /lib/systemd/system/blackbox_exporter.service
[Unit]
Description=blackbox_exporter
After=network.target

[Service]
User=root
Type=simple
ExecStart=/usr/local/blackbox_exporter/blackbox_exporter --config.file=/usr/local/blackbox_exporter/blackbox.yml
Restart=on-failure

[Install]
WantedBy=multi-user.target


systemctl daemon-reload 
systemctl start blackbox_exporter
systemctl stop blackbox_exporter
systemctl status blackbox_exporter
netstat -lnpt|grep 9115

```



### 监控主机存活性

```yaml
# ping 检测
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:

  # ping 检测
  - job_name: 'ping_status'
    metrics_path: /probe
    params:
      module: [icmp]
    static_configs:
      - targets: ['43.249.28.50']
        labels:
          instance: 'ping_status'
          group: 'icmp'
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - target_label: __address__
        replacement: 43.249.28.50:9115

```

### 监控docker资源使用率

CAdvisor为Google开源的一款用于监控和展示容器运行状态的可视化工具。CAdvior可直接运行在主机上，它不仅可以搜集到机器上所有运行的容器信息，还提供查询界面和http接口，方便如Prometheus等监控系统进行数据的获取。

```bash
# 下载镜像
$ docker pull google/cadvisor:latest

# 启动镜像
$ docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  --privileged=true \
  google/cadvisor:latest
  
  注解：该命令在容器中挂载了几个目录，ro代表只读，CAdvisor将从其中收集数据。rw代表可读写，此处指定/var/run目录，用于Docker套接字的挂载；--detach将以守护进程的方式运行；--name对生成的容器进行命名；在Ret Hat,CentOS, Fedora 等发行版上需要传递如下参数--privileged=true。
  
# 浏览器打开http://$ip:8080 ，可查看CAdvisor的web界面
```

**容器指标**

```bash
# 以下是比较常用到的一些容器指标：

#CPU指标
container_cpu_load_average_10s       #最近10秒容器的CPU平均负载情况
container_cpu_usage_seconds_total    #容器的CPU累积占用时间

# 内存指标
container_memory_max_usage_bytes     #容器的最大内存使用量（单位:字节）
container_memory_usage_bytes        #容器的当前内存使用量（单位：字节）
container_spec_memory_limit_bytes    #容器的可使用最大内存数量（单位：字节）

# 网络指标
container_network_receive_bytes_total   #容器网络累积接收字节数据总量（单位：字节）
container_network_transmit_bytes_total  #容器网络累积传输数据总量（单位：字节）

#存储指标
container_fs_usage_bytes    #容器中的文件系统存储使用量（单位：字节）
container_fs_limit_bytes    #容器中的文件系统存储总量（单位：字节）

```

**Prometheus集成**

```yaml
- job_name: 'docker'
    static_configs:
    - targets:
      -  '192.168.214.108:8080'
      labels:
        group: docker
```

**Grafana展示**

ID：193

### 告警配置

使用alertmanager组件发送告警信息给用户

下载地址：https://prometheus.io/download/

#### 邮件告警

```bash
# 发送邮件组件
wget https://github.com/prometheus/alertmanager/releases/download/v0.23.0/alertmanager-0.23.0.linux-amd64.tar.gz

tar zxvf alertmanager-0.23.0.linux-amd64.tar.gz -C /usr/local/
mv /usr/local/alertmanager-0.23.0.linux-amd64 /usr/local/alertmanager

vim /usr/lib/systemd/system/alertmanager.service
[Unit]
Description=alertmanager
Documentation=https://github.com/prometheus/alertmanager
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/alertmanager/alertmanager --config.file=/usr/local/alertmanager/alertmanager.yml --storage.path=/usr/local/alertmanager/data
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

修改alertmanager.yml

```yaml
global:
  resolve_timeout: 5m
  smtp_smarthost: 'smtp.example.com:465'
  smtp_from: 'devops'
  smtp_auth_username: 'devops@example.com'
  smtp_auth_password: 'password'
  smtp_require_tls: true

route:
  group_by: ['alertname']
  group_wait: 3s
  group_interval: 5s
  repeat_interval: 5m
  receiver: 'email'

receivers:
- name: 'email'
  email_configs:
  - to: 'test@example.com'
    send_resolved: true


inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
  
```

启动服务，然后访问http://192.168.10.241:9093/#/alerts可以看到

![image-20220120141058037](https://raw.githubusercontent.com/adcwb/storages/master/image-20220120141058037.png)

**修改prometheus.yml** 

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - '192.168.10.241:9093'
          
# 添加报警规则
rule_files:
  - "first_rules.yml"

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "192.168.10.243"
    static_configs:
      - targets: ["192.168.10.243:9100"]

  - job_name: 'nginx'
    static_configs:
      - targets: ['192.168.10.243:9913']

  - job_name: 'mysqld'
    static_configs:
      - targets: ['192.168.10.243:9104']

```

**first_rules.yml**

```yaml
groups:
- name: node
  rules:
  - alert: server_status
    expr: up{job="192.168.10.243"} == 0
    for: 15s
    annotations:
      summary: "机器{{ $labels.instance }} down"
      description: "Error：请立即查看!"

```

重新启动prometheus和alertmanagers，并关闭10.243的node_exporter，查看是否有邮件

![image-20220120151416507](https://raw.githubusercontent.com/adcwb/storages/master/image-20220120151416507.png)

#### 告警模板配置

修改alertmanager.yml

```yaml
global:
  resolve_timeout: 5m
  smtp_smarthost: 'smtp.example.com:465'
  smtp_from: 'devops'
  smtp_auth_username: 'devops@example.com'
  smtp_auth_password: 'password'
  smtp_require_tls: true
  
templates:
- '/usr/local/alertmanager/template/*.tmpl'

route:
  group_by: ['alertname']
  group_wait: 3s
  group_interval: 5s
  repeat_interval: 5m
  receiver: 'email'

receivers:
- name: 'email'
  email_configs:
  # 此处若是需要同时发送信息给多个收件人，用逗号隔开即可
  - to: 'test@example.com'
    send_resolved: true
    from: 'xxxx@qq.com
    html: '{{ template "email.to.html" .}}'
    headers: { Subject: '平台告警通知：'}

inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
  
```



#### 企业微信告警

由于无法注册应用，暂时无法演示

#### 钉钉告警



### 参考文档

Grafana监控系统之Prometheus+Grafana监控系统搭建	https://juejin.cn/post/6948241754030080037

监控系统变更到Prometheus https://www.zhihu.com/question/496373844/answer/2204322171 



**革命尚未成功，同志仍需努力！**

























