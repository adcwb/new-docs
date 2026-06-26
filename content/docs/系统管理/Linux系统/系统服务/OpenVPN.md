---
title: "OpenVPN"
weight: 40
date: 2026-06-05
---

## 简介

```bash
此法用于多个客户端通过OpenVPN服务器实现内网访问
OpenVPN服务器操作系统CentOS-7.7
OpenVPN版本2.4.11
easy-rsa版本3.0.8
使用tap模式
客户端IP地址池10.8.0.0/24
多个客户端直接可以通过OpenVPN实现内网通信
```

## 内核调优：

```bash
# 修改系统参数：
cat > /etc/sysctl.d/99-net.conf <<EOF
# 二层的网桥在转发包时也会被iptables的FORWARD规则所过滤
net.bridge.bridge-nf-call-arptables=1
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
# 关闭严格校验数据包的反向路径，默认值1
net.ipv4.conf.default.rp_filter=0
net.ipv4.conf.all.rp_filter=0
# 设置 conntrack 的上限
net.netfilter.nf_conntrack_max=1048576
# 端口最大的监听队列的长度
net.core.somaxconn=21644
# TCP阻塞控制算法BBR，Linux内核版本4.9开始内置BBR算法
#net.ipv4.tcp_congestion_control=bbr
#net.core.default_qdisc=fq
# 打开ipv4数据包转发
net.ipv4.ip_forward=1
# TCP FastOpen
# 0:关闭 ; 1:作为客户端时使用 ; 2:作为服务器端时使用 ; 3:无论作为客户端还是服务器端都使用
net.ipv4.tcp_fastopen=3
EOF
    
# 修改limits参数：
cat > /etc/security/limits.d/99-centos.conf <<EOF
* - nproc 1048576
* - nofile 1048576
EOF
```





## 安装

```bash
安装epel源：
	yum -y install epel-* 

更新软件：
	yum makecache
	yum update -y

安装openvpn及easy-rsa
	yum -y install openvpn easy-rsa iptables-services	
	
参考文档：
	https://www.linuxprobe.com/centos7-config-openvpn-one.html
	https://www.linuxprobe.com/centos7-config-openvpn-two.html
```



## 证书配置：

```bash
复制文件：
	拷贝easy-rsa的文件到/etc/openvpn下
	cp -r /usr/share/easy-rsa/3.0.8 /etc/openvpn/easy-rsa
	cp /usr/share/doc/easy-rsa-3.0.8/vars.example /etc/openvpn/easy-rsa/vars

修改/etc/openvpn/easy-rsa/vars配置：
set_var EASYRSA_REQ_COUNTRY     "CN"
set_var EASYRSA_REQ_PROVINCE    "Guang Dong"
set_var EASYRSA_REQ_CITY        "Shen Zhen"
set_var EASYRSA_REQ_ORG         "kfidc"
set_var EASYRSA_REQ_EMAIL       "xx@kf-idc.com"
set_var EASYRSA_REQ_OU          "kf"
set_var EASYRSA_KEY_SIZE        4096
set_var EASYRSA_ALGO            rsa
set_var EASYRSA_CA_EXPIRE       365000
set_var EASYRSA_CERT_EXPIRE     3650
set_var EASYRSA_CERT_RENEW      180
set_var EASYRSA_CRL_DAYS        60
    
初始化PKI和CA
	切换目录：
		cd /etc/openvpn/easy-rsa
		
	创建PKI
    	./easyrsa init-pki
    	
    创建CA
    	./easyrsa build-ca nopass
    	
    创建服务器证书
        方式一：
            ./easyrsa build-server-full openvpn-server nopass	#自动签发公钥和私钥

        方式二：
            ./easyrsa gen-req openvpn-server nopass		# 创建服务器密钥
            ./easyrsa sign-req server openvpn-server	# 用CA证书签署密钥
    	
    创建客户端证书
    	方式一：
    		./easyrsa build-server-full openvpn-client nopass
           
		方式二：
			./easyrsa gen-req openvpn-client nopass		# 创建服务器密钥
            ./easyrsa sign-req client openvpn-client	# 用CA证书签署密钥
    	
    创建DH证书
		./easyrsa gen-dh		# 根据在顶部创建的vars配置文件生成密钥
		
	创建ta.key
		openvpn --genkey --secret /etc/openvpn/easy-rsa/ta.key
		
	生成CRL密钥：
		./easyrsa  gen-crl

	
拷贝证书
	mkdir -p /etc/openvpn/pki
    cp /etc/openvpn/easy-rsa/pki/ca.crt \
       /etc/openvpn/easy-rsa/pki/dh.pem \
       /etc/openvpn/easy-rsa/pki/issued/openvpn-server.crt \
       /etc/openvpn/easy-rsa/pki/private/openvpn-server.key \
       /etc/openvpn/pki/
    ln -sv /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/pki/crl.pem
    chown -R root:openvpn /etc/openvpn/pki
    
    
    复制ca证书，ta.key和server端证书及密钥到/etc/openvpn/server文件夹里
		cp -p /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn/server/
		cp -p /etc/openvpn/easy-rsa/pki/issued/openvpn-server.crt /etc/openvpn/server/
		cp -p /etc/openvpn/easy-rsa/pki/private/openvpn-server.key /etc/openvpn/server/
		cp -p /etc/openvpn/easy-rsa/ta.key /etc/openvpn/server/
		
	复制ca证书，ta.key和client端证书及密钥到/etc/openvpn/client文件夹里

		cp -p /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn/client/
		cp -p /etc/openvpn/easy-rsa/pki/issued/openvpn-client.crt /etc/openvpn/client/
		cp -p /etc/openvpn/easy-rsa/pki/private/openvpn-client.key /etc/openvpn/client/
		cp -p /etc/openvpn/easy-rsa/ta.key /etc/openvpn/client/
		
	复制dh.pem , crl.pem到/etc/openvpn/client文件夹里

		cp /etc/openvpn/easy-rsa/pki/dh.pem /etc/openvpn/server/
		cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/server/
		cp /etc/openvpn/easy-rsa/pki/dh.pem /etc/openvpn/client/
		cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/client/
    
```

## OpenVPN配置

```bash
创建日志目录：
	mkdir -p /var/log/openvpn
	chown -R openvpn:openvpn /var/log/openvpn

创建客户端配置目录
    mkdir -p /etc/openvpn/client/{config,user}
    chown -R root:openvpn /etc/openvpn/client/{config,user}
    
配置OpenVPN服务器端
	 cp -p /usr/share/doc/openvpn-2.4.11/sample/sample-config-files/server.conf /etc/openvpn/server/
    vim /etc/openvpn/server/server.conf
	# 路径根据实际情况修改，一般情况下服务启动失败都是因为证书的原因
	
	# 监听地址
    #local 0.0.0.0
    # 监听端口
    port 1194
    # 通信协议
    proto tcp
    # TUN模式还是TAP模式
    dev tap
    # 证书
    ca         /etc/openvpn/pki/ca.crt
    cert       /etc/openvpn/pki/openvpn-server.crt
    key        /etc/openvpn/pki/openvpn-server.key
    dh         /etc/openvpn/pki/dh.pem
    crl-verify /etc/openvpn/pki/crl.pem
    # 禁用OpenVPN自定义缓冲区大小，由操作系统控制
    sndbuf 0
    rcvbuf 0
    # TLS rules “client” | “server”
    #remote-cert-tls  "client"
    # TLS认证
    tls-auth /etc/openvpn/pki/ta.key 0
    # TLS最小版本
    #tls-version-min "1.2"
    # 重新协商数据交换的key，默认3600
    #reneg-sec 3600
    # 在此文件中维护客户端与虚拟IP地址之间的关联记录
    # 如果OpenVPN重启，重新连接的客户端可以被分配到先前分配的虚拟IP地址
    ifconfig-pool-persist /etc/openvpn/ipp.txt
    # 配置client配置文件
    client-config-dir /etc/openvpn/client/config
    # 该网段为 open VPN 虚拟网卡网段，不要和内网网段冲突即可。
    server 10.8.0.0 255.255.255.0
    # 配置网桥模式，需要在OpenVPN服务添加启动关闭脚本，将tap设备桥接到物理网口
    # 假定内网地址为192.168.0.0/24，内网网关是192.168.0.1
    # 分配192.168.0.200-250给VPN使用
    #server-bridge 192.168.0.1 255.255.255.0 192.168.0.200 192.168.0.250
    # 给客户端推送自定义路由
    #push "route 192.168.0.0 255.255.255.0"
    # 所有客户端的默认网关都将重定向到VPN
    push "redirect-gateway def1 bypass-dhcp"  
    # 向客户端推送DNS配置
    push "dhcp-option DNS 223.5.5.5"
    #push "dhcp-option DNS 223.6.6.6"
    # 允许客户端之间互相访问
    client-to-client
    # 限制最大客户端数量
    max-clients 100
    # 客户端连接时运行脚本
    #client-connect ovpns.script
    # 客户端断开连接时运行脚本
    #client-disconnect ovpns.script
    # 保持连接时间
    keepalive 20 120
    # 开启vpn压缩
    comp-lzo
    # 允许多人使用同一个证书连接VPN，不建议使用，注释状态
    duplicate-cn
    # 运行用户
    user openvpn
    #运行组
    group openvpn
    # 持久化选项可以尽量避免访问那些在重启之后由于用户权限降低而无法访问的某些资源
    persist-key
    persist-tun
    
    cipher AES-256-CBC
    compress lz4-v2
    push "compress lz4-v2"
    
    # 显示当前的连接状态
    status      /var/log/openvpn/openvpn-status.log
    # 日志路径，不指定文件路径时输出到控制台
    # log代表每次启动时清空日志文件
    # log        /var/log/openvpn/openvpn.log
    # log-append代表追加写入到日志文件
    log-append  /var/log/openvpn/openvpn.log
    # 日志级别
    verb 6
    # 忽略过多的重复信息，相同类别的信息只有前20条会输出到日志文件中
    mute 20
	explicit-exit-notify 1

```

配置文件示例

```bash
[root@iZd7oawrdmsm8dagsrrr1xZ ~]# cat /etc/openvpn/server/server.conf |grep '^[^#|^;]'
port 1194
proto udp
dev tun
ca ca.crt
cert openvpn-server.crt
key openvpn-server.key  # This file should be kept secret
dh dh.pem
crl-verify crl.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 103.201.25.21"
push "dhcp-option DNS 114.114.114.114"
client-to-client
max-clients 100
duplicate-cn
keepalive 10 120
tls-auth ta.key 0 # This file is secret
cipher AES-256-CBC
compress lz4-v2
push "compress lz4-v2"
comp-lzo
user openvpn
group openvpn
persist-key
persist-tun
status  /var/log/openvpn/openvpn-status.log
log-append  /var/log/openvpn/openvpn.log
verb 6
mute 20
explicit-exit-notify 1
```



## 防火墙配置

```BASH
firewall-cmd --permanent --add-service=openvpn

firewall-cmd --permanent --add-interface=tun0	# vpn网卡名
firewall-cmd --permanent --add-masquerade
firewall-cmd --permanent --direct --passthrough ipv4 -t nat -A POSTROUTING -s  10.8.0.0/24 -o ens33 -j MASQUERADE	# IP地址为vpn网卡监听的网段，ens33指的是你上网的网卡名称
firewall-cmd --reload

```



## 服务启动

```bash
    systemctl enable openvpn-server@server
    systemctl start openvpn-server@server
    systemctl status openvpn-server@server
    netstat -tlunp | grep openvpn

```



## 客户端配置

```bash
# 复制配置文件模板
	cp -p /usr/share/doc/openvpn-2.4.*/sample/sample-config-files/client.conf /etc/openvpn/client/
# 修改后的内容如下
[root@localhost client]# cat client.conf |grep '^[^#|^;]'
    client
    dev tun
    proto udp
    remote 192.168.43.138 1194
    resolv-retry infinite
    nobind
    persist-key
    persist-tun
    ca ca.crt
    cert openvpn-client.crt
    key openvpn-client.key
    remote-cert-tls server
    tls-auth ta.key 1
    cipher AES-256-CBC
    verb 6
    
# 更改client.conf文件名为client.ovpn
	mv /etc/openvpn/client/client.conf /etc/openvpn/client/client.ovpnmv client/client.conf client/client.ovpn
	
	
# 安装lrzsz工具，通过sz命令把 client.tar.gz传到客户机上面
[root@localhost openvpn]# yum -y install lrzsz
# 打包client文件夹
[root@localhost openvpn]# tar -zcvf client.tar.gz client/

# 注：若安装完成后客户端连接没有办法上网，可能是防火墙关闭导致流量无法转换


openvpn --daemon --cd /etc/openvpn/client/43.249.28.50/  --config client.ovpn --log-append /var/log/openvpn/43.249.28.50.log --auth-nocache && ifconfig

openvpn --daemon --cd /etc/openvpn/client/106.14.213.94/  --config client.ovpn --log-append /var/log/openvpn/106.14.213.94.log --auth-nocache && ifconfig

openvpn --daemon --cd /etc/openvpn/client/110.92.67.180/  --config client.ovpn --log-append /var/log/openvpn/110.92.67.180.log --auth-nocache && ifconfig

openvpn --daemon --cd /etc/openvpn/client/208.90.122.143/  --config client.ovpn --log-append /var/log/openvpn/208.90.122.143.log --auth-nocache && ifconfig

openvpn --daemon --cd /root/client/ --config client.ovpn --log-append /var/log/openvpn/110.92.67.180.log --auth-nocache 

	--daemon：后台运行
	--cd：切换路径
	--config： 指定配置文件
	--log-append：指定日志
	--auth-nocache：自动认证

```

参考模板

```bash
[root@iZd7oawrdmsm8dagsrrr1xZ client]# cat client.conf |grep '^[^#|^;]'
client
dev tun
proto udp
remote 8.208.83.52 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert openvpn-client.crt
key openvpn-client.key
remote-cert-tls server
tls-auth ta.key 1
cipher AES-256-CBC
comp-lzo
verb 6
mute 20
status client-status.log
```





## OpenVPN连接后无法ssh

```bash
    由于OpenVPN连接成功以后，默认所有的流量全部走vpn隧道了，所以会导致ssh连接失败
    可以使用ip route命令查询出默认网关信息，如：
        [root@server client]# ip route
        0.0.0.0/1 via 10.7.0.5 dev tun1 
        default via 172.19.111.253 dev eth0 
        10.7.0.0/24 via 10.7.0.5 dev tun1 
        10.7.0.5 dev tun1 proto kernel scope link src 10.7.0.6 
        10.8.0.0/24 via 10.8.0.2 dev tun0 
        10.8.0.2 dev tun0 proto kernel scope link src 10.8.0.1 
        116.7.99.162 via 172.19.111.253 dev eth0 
        128.0.0.0/1 via 10.7.0.5 dev tun1 
        169.254.0.0/16 dev eth0 scope link metric 1002 
        172.19.96.0/20 dev eth0 proto kernel scope link src 172.19.103.197 
        
	default via x.x.x.x dev eth0 x.x.x.x即默认网关
	然后将你本机的公网ip添加进路由，走默认网关
		route add -host 106.14.213.94  gw 43.249.28.33
		route add -host 208.90.122.143  gw 43.249.28.33
		
	
        route add -host 103.201.25.2 gw 172.19.111.253
        route add -host 116.7.99.162  gw 172.19.111.253
        route add -host 43.249.28.50  gw 172.19.111.253
        route add -host 208.90.122  gw 172.19.111.253
        
        route add -host 106.14.213.94  gw 208.90.122.129
        route add -host 43.249.28.50  gw 208.90.122.129
        
        
        route  -n

	查看本机IP：
		https://api.myip.la/cn?json

```





## OpenVPN负载均衡

```bash
方案一：
	两个相同的server，一个client配置文件
	两个相同ca，配置文件(local ip不同)的server
    在配置文件中配置两个参数和多个ip
    在拨号连接的时候client随机选择客户端，在VPNserver宕机的情况下自动重连其他机器
    
    修改客户端的配置文件
        remote server1.mydomain #负载均衡server
        remote server2.mydomain
        remote-random           #使用负载均衡
        resolv-retry            #重连时间
	
方案二：DNS轮询
	两个相同ca，配置文件(local ip不同)的server
    在配置文件中配置两个参数并将IP指向域名
    通过DNS轮询A记录实现负载均衡
    
    
```





## CentOS7内核升级

```bash
一、升级前操作
	1. 查看当前内核版本
		uname -r
		
	2.安装ELRepo源
		(1) 导入公共秘钥
			rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org	
			
        (2) 安装 ELRepo 的 YUM 源
			rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm 
            
二、安装内核
	1. 通过 YUM 安装
		yum --disablerepo=\* --enablerepo=elrepo-kernel repolist	# 载入元数据
		yum --disablerepo=\* --enablerepo=elrepo-kernel list kernel*	# 查看可用包
		yum remove kernel-tools-libs.x86_64 kernel-tools.x86_64  -y	# 删除旧版本工具包
        yum --enablerepo=elrepo-kernel install kernel-ml-devel kernel-ml kernel-ml-tools
        默认安装 mainline 版本（主线版本）。
        lt  ：long term support，长期支持版本；
		ml：mainline，主线版本；
        
	2. 查看已安装的内核版本
		rpm -qa kernel*
	

    3. 查找新安装的内核完整名称
   		cat /boot/grub2/grub.cfg | grep menuentry
   		
   		
三、内核切换
	0. 前实际启动顺序
		grub2-editenv list
		
    1. 更改默认内核
        命令2选1：
        (1) grub2-set-default 0
        	默认启动顺序应该为1，升级后内核是往前面插入，为0。
			grub2-set-default 0
			
        (2) grub2-set-default '新内核‘
        	grub2-set-default 'CentOS Linux (5.4.120-1.el7.elrepo.x86_64) 7 (Core)'
        	
    2. 查看默认启动内核是否更换成功
    	grub2-editenv list
    	
四、激活内核
    1. 重启系统
    	reboot

    2. 查看内核版本
    	uname -r

```

## IPSec VPN

```bash
参考文件：
	https://github.com/hwdsl2/setup-ipsec-vpn
```





## FRRouting安装

```bash
官方文档：
	http://docs.frrouting.org/projects/dev-guide/en/latest/building-frr-for-centos7.html
	
安装依赖包：
	yum -y install git autoconf automake libtool make \
  readline-devel texinfo net-snmp-devel groff pkgconfig \
  json-c-devel pam-devel bison flex pytest c-ares-devel \
  python-devel systemd-devel python-sphinx libcap-devel \
  elfutils-libelf-devel

yum源安装：
	# add RPM repository on CentOS 7
	FRRVER="frr-stable"
	curl -O https://rpm.frrouting.org/repo/$FRRVER-repo-1-0.el7.noarch.rpm
    yum -y install ./$FRRVER*
    
    # install FRR
    yum -y install frr frr-pythontools
	
源码编译安装：
	添加frr组和用户
		sudo groupadd -g 92 frr
        sudo groupadd -r -g 85 frrvty
        sudo useradd -u 92 -g 92 -M -r -G frrvty -s /sbin/nologin \
          -c "FRR FRRouting suite" -d /var/run/frr frr
         
	下载源代码，对其进行配置和编译
        git clone https://github.com/frrouting/frr.git frr
        cd frr
        ./bootstrap.sh
        ./configure \
            --bindir=/usr/bin \
            --sbindir=/usr/lib/frr \
            --sysconfdir=/etc/frr \
            --libdir=/usr/lib/frr \
            --libexecdir=/usr/lib/frr \
            --localstatedir=/var/run/frr \
            --with-moduledir=/usr/lib/frr/modules \
            --enable-snmp=agentx \
            --enable-multipath=64 \
            --enable-user=frr \
            --enable-group=frr \
            --enable-vty-group=frrvty \
            --enable-systemd=yes \
            --disable-exampledir \
            --disable-ldpd \
            --enable-fpm \
            --with-pkg-git-version \
            --with-pkg-extra-version=-MyOwnFRRVersion \
            SPHINXBUILD=/usr/bin/sphinx-build
        make
        make check
        sudo make install
        
	创建空的FRR配置文件
		sudo mkdir /var/log/frr
        sudo mkdir /etc/frr
        sudo touch /etc/frr/zebra.conf
        sudo touch /etc/frr/bgpd.conf
        sudo touch /etc/frr/ospfd.conf
        sudo touch /etc/frr/ospf6d.conf
        sudo touch /etc/frr/isisd.conf
        sudo touch /etc/frr/ripd.conf
        sudo touch /etc/frr/ripngd.conf
        sudo touch /etc/frr/pimd.conf
        sudo touch /etc/frr/nhrpd.conf
        sudo touch /etc/frr/eigrpd.conf
        sudo touch /etc/frr/babeld.conf
        sudo chown -R frr:frr /etc/frr/
        sudo touch /etc/frr/vtysh.conf
        sudo chown frr:frrvty /etc/frr/vtysh.conf
        sudo chmod 640 /etc/frr/*.conf
        
	安装守护程序配置文件
		sudo install -p -m 644 tools/etc/frr/daemons /etc/frr/
		sudo chown frr:frr /etc/frr/daemons
		
	启用ip转发：
		vim /etc/sysctl.d/90-routing-sysctl.conf
			net.ipv4.conf.all.forwarding=1
			net.ipv6.conf.all.forwarding=1
		sysctl -p /etc/sysctl.d/90-routing-sysctl.conf
		
	安装frr服务
		sudo install -p -m 644 tools/frr.service /usr/lib/systemd/system/frr.service
		
	注册系统文件
		sudo systemctl preset frr.service
		
	启动
		sudo systemctl enable frr
		sudo systemctl start frr
	
			
```



## FRRouting组网

```bash
    vim /etc/frr/daemons
    启用ospfd,设为on
    systemctl enable frr.service
    systemctl start frr.service
    netstat -anp | grep ospfd
    
    echo "net.ipv4.conf.all.forwarding=1">>/etc/sysctl.conf
    echo "net.ipv6.conf.all.forwarding=1">>/etc/sysctl.conf
    sysctl -p
    
    [root@localhost ~]# vtysh
    
    Hello, this is FRRouting (version 7.5.1).
    Copyright 1996-2005 Kunihiro Ishiguro, et al.

    localhost.localdomain# configure terminal 
    localhost.localdomain(config)# router ospf
    localhost.localdomain(config-router)# network 10.7.0.0/24 area 0
    localhost.localdomain(config-router)# network 10.8.0.0/24 area 0
    localhost.localdomain(config-router)# network 10.9.0.0/24 area 0
    localhost.localdomain(config-router)# do write file
    Note: this version of vtysh never writes vtysh.conf
    Building Configuration...
    Configuration saved to /etc/frr/zebra.conf
    Configuration saved to /etc/frr/ospfd.conf
    Configuration saved to /etc/frr/staticd.conf
    localhost.localdomain(config-router)# 
    
    systemctl restart frr
    
    show running-config		# 查看当前frr配置信息
    show interface brief 	# 查看当前设备所有接口信息
    show ip route			# 查看路由表
    

    

    
```

## CentOS7安装docker

```bash
# 安装yum工具类
	yum install -y yum-utils device-mapper-persistent-data lvm2

# 启动docker源
	yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 安装docker
	yum install docker-ce

# 配置镜像加速器
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json <<-'EOF'
    {
      "registry-mirrors": ["https://gziwmbaz.mirror.aliyuncs.com"]
    }
    EOF
    sudo systemctl daemon-reload
    sudo systemctl restart docker
```



## CentOS7安装MySql

```bash
# 下载安装包
	wget -i -c http://dev.mysql.com/get/mysql57-community-release-el7-10.noarch.rpm
	
# 运行安装包
	yum -y install mysql57-community-release-el7-10.noarch.rpm
	
# 安装数据库
	yum -y install mysql-community-server
	
# 启动服务
	systemctl start mysqld.service
	
# 使用默认密码进入数据库
	grep "password" /var/log/mysqld.log
	mysql -uroot -p

# 修改密码，注意密码复杂度要求
	ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';

# 授权远程访问
	grant all privileges on *.* to 'root'@'%' identified by '123456' with grant option;
	
# 刷新权限
	flush privileges;
	
# MySQL默认源在国外，如果在国内连接的话，可能会特别慢，这个时候可以去官网下载别人打包好的tar包，解压安装即可
	wget https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.34-1.el7.x86_64.rpm-bundle.tar
	tar xvf mysql-5.7.34-1.el7.x86_64.rpm-bundle.tar
	yum -y install ./mysql-community-*
	systemctl start mysqld.service

	


```



