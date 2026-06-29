---
title: "Firewalld"
weight: 25
date: 2026-06-05
tags: ["Firewalld", "防火墙", "Linux", "安全"]
---

## 防火墙安全基本概述

*在CentOS7系统中集成了多款防火墙管理工具，默认启用的是firewalld(动态防火墙管理器)防火墙管理工具，Firewalld支持CLI(命令行）以及GUI（图形）的两种管理方式。
对于接触Linux较早的人员对Iptables比较的熟悉，但由于Iptables的规则比较的麻烦，并网络有一定要求，所以学习成本较高。但Firewalld的学习对网络并没有那么高的要求，相对Iptables来说要简单不少。就好比如(手动挡汽车 VS 自动挡汽车)，所以建议刚接触CentOS7系统的人员直接学习Firewalld*
![img](https://linux.oldxu.net/15230185799633.png)
***PS: 如果开启Firewalld防火墙，默认情况会阻止流量流入，但允许流量流出。\***
![img](https://linux.oldxu.net/15319190627314.jpg)

## 防火墙使用区域管理

*那么相较于传统的Iptables防火墙，firewalld支持动态更新，并加入了区域zone的概念。
简单来说，区域就是firewalld预先准备了几套防火墙策略集合（策略模板），用户可以根据不同的场景而选择不同的策略模板，从而实现防火墙策略之间的快速切换。*
![img](https://linux.oldxu.net/15602648594721.jpg?imageView2/0/q/75%7Cwatermark/2/text/d3d3Lnh1bGlhbmd3ZWkuY29t/font/5qW35L2T/fontsize/400/fill/I0Y4MEEwQQ==/dissolve/100/gravity/SouthEast/dx/25/dy/25%7Cimageslim)

***需要注意的是Firewalld中的区域与接口\***
*一个网卡仅能绑定一个区域。比如: eth0-->A区域
但一个区域可以绑定多个网卡。比如: B区域-->eth0、eth1、eth2
可以根据来源的地址设定不同的规则。比如：所有人能访问80端口，但只有公司的IP才允许访问22端口。*

| 区域     | 默认规则策略                                                 |
| :------- | :----------------------------------------------------------- |
| trusted  | 允许所有的数据包流入与流出                                   |
| home     | 拒绝流入的流量，除非与流出的流量相关；而如果流量与ssh、mdns、ipp-client、amba-client与dhcpv6-client服务相关，则允许流量 |
| internal | 等同于home区域                                               |
| work     | 拒绝流入的流量，除非与流出的流量数相关；而如果流量与ssh、ipp-client与dhcpv6-client服务相关，则允许流量 |
| public   | 拒绝流入的流量，除非与流出的流量相关；而如果流量与ssh、dhcpv6-client服务相关，则允许流量 |
| external | 拒绝流入的流量，除非与流出的流量相关；而如果流量与ssh服务相关，则允许流量 |
| dmz      | 拒绝流入的流量，除非与流出的流量相关；而如果流量与ssh服务相关，则允许流量 |
| block    | 拒绝流入的流量，除非与流出的流量相关                         |
| drop     | 拒绝流入的流量，除非与流出的流量相关                         |

## 防火墙基本指令参数

`firewall-cmd`命令分类列表

| 参数                          | 作用                                                 |
| :---------------------------- | :--------------------------------------------------- |
| **zone区域相关指令**          |                                                      |
| --get-default-zone            | 查询默认的区域名称                                   |
| --set-default-zone=<区域名称> | 设置默认的区域，使其永久生效                         |
| --get-active-zones            | 显示当前正在使用的区域与网卡名称                     |
| --get-zones                   | 显示总共可用的区域                                   |
| --new-zone=<zone>             | 新增区域                                             |
| **services服务相关指令**      |                                                      |
| --get-services                | 显示预先定义的服务                                   |
| --add-service=<服务名>        | 设置默认区域允许该服务的流量                         |
| --remove-service=<服务名>     | 设置默认区域不再允许该服务的流量                     |
| **Port端口相关指令**          |                                                      |
| --add-port=<端口号/协议>      | 设置默认区域允许该端口的流量                         |
| --remove-port=<端口号/协议>   | 设置默认区域不再允许该端口的流量                     |
| **Interface网卡相关指令**     |                                                      |
| --add-interface=<网卡名称>    | 将源自该网卡的所有流量都导向某个指定区域             |
| --change-interface=<网卡名称> | 将某个网卡与区域进行关联                             |
| **其他相关指令**              |                                                      |
| --list-all                    | 显示当前区域的网卡配置参数、资源、端口以及服务等信息 |
| --reload                      | 让“永久生效”的配置规则立即生效，并覆盖当前的配置规则 |

## 防火墙区域配置策略

*1.为了能正常使用firwalld服务和相关工具去管理防火墙，必须启动firwalld服务，同时关闭以前旧防火墙相关服务。需要注意firewalld的规则分两种状态:
runtime运行时: 修改规则马上生效，但如果重启服务则马上失效，测试建议。
permanent持久配置: 修改规则后需要reload重载服务才会生效，生产建议。*

```bash
#1.禁用旧版防火墙服务
[root@Firewalld ~]# systemctl mask iptables
[root@Firewalld ~]# systemctl mask ip6tables

#2.启动firewalld防火墙, 并加入开机自启动服务
[root@Firewalld ~]# systemctl start firewalld
[root@Firewalld ~]# systemctl enable firewalld
```

*2.firewalld启动后，我们需要知道使用的是什么区域，区域的规则明细又有哪些？*

```bash
#1.通过--get-default-zone获取当前默认使用的区域
[root@Firewalld ~]# firewall-cmd --get-default-zone 
public

#2.通过--list-all查看当前默认区域配置了哪些规则
[root@Firewalld ~]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0 eth1
  sources: 
  services: ssh dhcpv6-client
  ports: 
  protocols: 
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules:
```

*3.使用firewalld各个区域规则结合配置，调整默认public区域拒绝所有流量，但如果来源IP是10.0.0.0/24网段则允许。*

```bash
#1.临时移除默认区域的规则策略
[root@web01 ~]# firewall-cmd --remove-service=ssh --remove-service=dhcpv6-client
success

#2.添加来源是10.0.0.0/24网段，将其加入白名单(更精细化控制使用富规则)
[root@web01 ~]# firewall-cmd --add-source=10.0.0.0/24 --zone=trusted
success

#3.检查当前活动的区域
[root@web01 ~]# firewall-cmd --get-active-zone
public
  interfaces: eth0 eth1 #任何来源网段都走public默认区域规则(除了10网段)
trusted
  sources: 10.0.0.0/24  #来源是10网段则走trusted区域规则
```

*4.查询public区域是否允许请求SSH HTTPS协议的流量*

```bash
[root@Firewalld ~]# firewall-cmd --zone=public --query-service=ssh
yes
[root@Firewalld ~]# firewall-cmd --zone=public --query-service=https
no
```

*5.如果希望将临时的配置清空可以使用--reload参数。*

```bash
[root@web01 ~]# firewall-cmd --reload
```

## 防火墙端口访问策略

*使用firewalld允许客户请求的服务器的80/tcp端口，仅临时生效，如添加--permanent重启后则永久生效*

*1.临时添加允许放行单个端口*

```bash
[root@Firewalld ~]# firewall-cmd --add-port=80/tcp
```

*2.临时添加放行多个端口*

```bash
[root@Firewalld ~]# firewall-cmd --add-port={80/tcp,8080/tcp}
```

*3.永久添加多个端口,需要添加--permanent，并且需要重载firewalld*

```bash
[root@Firewalld ~]# firewall-cmd --add-port={80/tcp,8080/tcp} --permanet
[root@Firewalld ~]# firewall-cmd --reload
```

*4.通过--list-ports检查端口放行情况*

```bash
[root@Firewalld ~]# firewall-cmd --list-ports
80/tcp 8080/tcp
```

*5.移除临时添加的端口规则*

```bash
[root@Firewalld ~]# firewall-cmd --remove-port={80/tcp,8080/tcp}
```

## 防火墙服务访问策略

*使用firewalld允许客户请求服务器的http https协议，仅临时生效，如添加--permanent重启后则永久生效*

*1.临时添加允许放行单个端口*

```bash
[root@Firewalld ~]# firewall-cmd --add-service=http
```

*2.临时添加放行多个端口*

```bash
[root@Firewalld ~]# firewall-cmd --add-service={http,htps}
```

*3.永久添加多个端口,需要添加--permanent，并且需要重载firewalld*

```bash
[root@Firewalld ~]# firewall-cmd --add-service={http,htps} --permanet
[root@Firewalld ~]# firewall-cmd --reload
```

*4.通过--list-services检查端口放行情况*

```bash
[root@Firewalld ~]# firewall-cmd --list-services
http https
```

*5.移除临时添加的http https协议*

```bash
[root@Firewalld ~]# firewall-cmd --remove-port={http,htps}
```

*6.如何添加一个自定义端口，转其为对应的服务*

```bash
#1.拷贝相应的xml文件
[root@Firewalld ~]# cd /usr/lib/firewalld/services/
[root@Firewalld services]# cp http.xml zabbix-agent.xml

#2.修改端口为9000
[root@Firewalld services]# cat zabbix-agent.xml 
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>zabbix-agent</short>
  <description> zabbix-agent </description>
  <port protocol="tcp" port="10050"/>
</service>

#3.防火墙增加规则
[root@Firewalld ~]# firewall-cmd --permanent --add-service=zabbix-agent
[root@Firewalld ~]# firewall-cmd --list-services
ssh dhcpv6-client http https zabbix-agent

#4.安装php-fpm, 并监听9000端口
[root@Firewalld ~]# yum install zabbix-agent -y
[root@Firewalld ~]# systemctl start zabbix-agent

#5.测试验证
~ telnet  10.0.0.61 10050
Trying 10.0.0.61...
Connected to 10.0.0.61.
Escape character is '^]'.
```

## 防火墙端口转发策略

*端口转发是指传统的目标地址映射，实现外网访问内网资源，流量转发命令格式为：
firewall-cmd --permanent --zone=<区域> --add-forward-port=port=<源端口号>:proto=<协议>:toport=<目标端口号>:toaddr=<目标IP地址>*

*如果需要将当前的10.0.0.61:5555端口转发至后端172.16.1.9:22端口*

![img](https://linux.oldxu.net/15442353608554.jpg)

*1.开启masquerade，实现地址转换*

```bash
[root@Firewalld ~]# firewall-cmd --add-masquerade --permanent
```

*2.配置转发规则*

```bash
[root@Firewalld ~]# firewall-cmd --permanent --zone=public --add-forward-port=port=6666:proto=tcp:toport=22:toaddr=172.16.1.9
[root@Firewalld ~]# firewall-cmd --reload
```

## 防火墙富规则策略

*firewalld中的富规则表示更细致、更详细的防火墙策略配置，它可以针对系统服务、端口号、源地址和目标地址等诸多信息进行更有针对性的策略配置, 优先级在所有的防火墙策略中也是最高的。，下面为firewalld富规则帮助手册*

```bash
[root@Firewalld ~]# man firewall-cmd            # 帮助手册
[root@Firewalld ~]# man firewalld.richlanguage  # 获取富规则手册
    rule
        [source]
        [destination]
        service|port|protocol|icmp-block|masquerade|forward-port
        [log]
        [audit]
        [accept|reject|drop]

rule [family="ipv4|ipv6"]
source address="address[/mask]" [invert="True"]
service name="service name"
port port="port value" protocol="tcp|udp"
forward-port port="port value" protocol="tcp|udp" to-port="port value" to-addr="address"
accept | reject [type="reject type"] | drop


#富规则相关命令
--add-rich-rule='<RULE>'        #在指定的区添加一条富规则
--remove-rich-rule='<RULE>'     #在指定的区删除一条富规则
--query-rich-rule='<RULE>'      #找到规则返回0 ，找不到返回1
--list-rich-rules               #列出指定区里的所有富规则
```

*1.比如允许10.0.0.1主机能够访问http服务，允许172.16.1.0/24能访问10050端口*

```bash
[root@Firewalld ~]# firewall-cmd --add-rich-rule='rule family=ipv4 source address=10.0.0.1/32 service name=http  accept'
[root@Firewalld ~]# firewall-cmd --add-rich-rule='rule family=ipv4 source address=172.16.1.0/24 port port="10050" protocol="tcp" accept'
```

*2.默认public区域对外开放所有人能通过ssh服务连接，但拒绝172.16.1.0/24网段通过ssh连接服务器*

```bash
[root@Firewalld ~]# firewall-cmd --add-rich-rule='rule family=ipv4 source address=172.16.1.0/24 service name="ssh" drop'
```

*3.使用firewalld，允许所有人能访问http,https服务，但只有10.0.0.1主机可以访问ssh服务*

```bash
[root@Firewalld ~]# firewall-cmd --add-service={http,https}
success
[root@Firewalld ~]# firewall-cmd --add-rich-rule='rule family=ipv4 source address=10.0.0.1/32 service name=ssh accept'
success
```

*4.当用户来源IP地址是10.0.0.1主机，则将用户请求的5555端口转发至后端172.16.1.9的22端口*

```bash
[root@Firewalld ~]# firewall-cmd --add-masquerade
[root@Firewalld ~]# firewall-cmd --add-rich-rule='rule family=ipv4 source address=10.0.0.1/32 forward-port port="5555" protocol="tcp" to-port="22" to-addr="172.16.1.6"'
success
```

*5.查看设定的规则，如果没有添加--permanent参数则重启firewalld会失效。富规则按先后顺序匹配，按先匹配到的规则生效*

```bash
[root@Firewalld ~]# firewall-cmd --list-rich-rules
rule family="ipv4" source address="10.0.0.1/32" service name="http" accept
rule family="ipv4" source address="172.16.1.0/24" port port="10050" protocol="tcp" accept
rule family="ipv4" source address="172.16.1.0/24" service name="ssh" drop
rule family="ipv4" source address="10.0.0.1/32" service name="ssh" accept
rule family="ipv4" source address="10.0.0.1/32" forward-port port="5555" protocol="tcp" to-port="22" to-addr="172.16.1.6"
```

## 防火墙开启内部上网

*在指定的带有公网IP的实例上启动Firewalld防火墙的NAT地址转换，以此达到内部主机上网。*

![img](https://linux.oldxu.net/15442375496785.jpg)

*firewalld实现内部上网详细过程*
![img](https://linux.oldxu.net/15517748885644.jpg)

*1.`firewalld`防火墙开启masquerade, 实现地址转换*

```bash
[root@Firewalld ~]# firewall-cmd --add-masquerade --permanent
[root@Firewalld ~]# firewall-cmd --reload
```

*2.客户端将网关指向firewalld服务器，将所有网络请求交给firewalld*

```bash
[root@web03 ~]# cat /etc/sysconfig/network-scripts/ifcfg-eth1
GATEWAY=172.16.1.61
```

*3.客户端还需配置dns服务器*

```bash
[root@web03 ~]# cat /etc/resolv.conf
nameserver 223.5.5.5
```

*4.重启网络，使其配置生效*

```bash
[root@web03 ~]# nmcli connection reload
[root@web03 ~]# nmcli connection down eth1 && nmcli connection up eth1
```

*5.测试后端web的网络是否正常*

```bash
[root@web03 ~]# ping baidu.com
PING baidu.com (123.125.115.110) 56(84) bytes of data.
64 bytes from 123.125.115.110 (123.125.115.110): icmp_seq=1 ttl=127 time=9.08 ms
```