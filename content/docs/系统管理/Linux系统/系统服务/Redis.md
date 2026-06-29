---
title: "Redis"
weight: 60
date: 2026-06-05
tags: ["Redis", "缓存", "NoSQL", "运维"]
---

Redis 是一款基于内存的高性能键值数据库，广泛用于缓存、会话管理、消息队列等场景。本文介绍通过源码编译安装 Redis、配置持久化与集群参数的完整流程。




## 源码编译安装redis

```bash
wget https://download.redis.io/releases/redis-6.2.6.tar.gz
tar xzf redis-6.2.6.tar.gz
cd redis-6.2.6
make
安装到指定目录/usr/local/redis
make  PREFIX=/usr/local/redis install

redis-benchmark  性能测试工具
redis-check-aof  日志文件检测工(比如断电造成日志损坏,可以检测并修复)
redis-check-dump  快照文件检测工具,效果类上
redis-cli  客户端
redis-server 服务端

```



### 服务端配置文件

```bash
[root@master2 ~]# cat /etc/redis/redis.conf | grep -v ^# | grep -v "^$"
# redis进程是否以守护进程的方式运行，yes为是，no为否(不以守护进程的方式运行会占用一个终端)。
daemonize no
# 指定redis进程的PID文件存放位置
pidfile /var/run/redis.pid
# redis进程的端口号
port 6379
#是否开启保护模式，默认开启。要是配置里没有指定bind和密码。开启该参数后，redis只会本地进行访问，拒绝外部访问。要是开启了密码和bind，可以开启。否则最好关闭设置为no。
protected-mode yes
# 绑定的主机地址
bind 127.0.0.1
# 客户端闲置多长时间后关闭连接，默认此参数为0即关闭此功能
timeout 300
# redis日志级别，可用的级别有debug.verbose.notice.warning
loglevel verbose
# log文件输出位置，如果进程以守护进程的方式运行，此处又将输出文件设置为stdout的话，就会将日志信息输出到/dev/null里面去了
logfile stdout   # 本次实验使用logfile   /var/log/redis_6379.log  
# 设置数据库的数量，默认为0可以使用select <dbid>命令在连接上指定数据库id
databases 16
# 指定在多少时间内刷新次数达到多少的时候会将数据同步到数据文件
save <seconds> <changes>
# 指定存储至本地数据库时是否压缩文件，默认为yes即启用存储
rdbcompression yes
# 指定本地数据库文件名
dbfilename dump.db
# 指定本地数据存放位置
dir ./     # dir /var/lib/redis/6379
# 指定当本机为slave服务时，设置master服务的IP地址及端口，在redis启动的时候他会自动跟master进行数据同步
replicaof <masterip> <masterport>
# 当master设置了密码保护时，slave服务连接master的密码
masterauth <master-password>
# 设置redis连接密码，如果配置了连接密码，客户端在连接redis是需要通过AUTH<password>命令提供密码，默认关闭
requirepass footbared
# 设置同一时间最大客户连接数，默认无限制。redis可以同时连接的客户端数为redis程序可以打开的最大文件描述符，如果设置 maxclients 0，表示不作限制。当客户端连接数到达限制时，Redis会关闭新的连接并向客户端返回 max number of clients reached 错误信息
maxclients 128
# 指定Redis最大内存限制，Redis在启动时会把数据加载到内存中，达到最大内存后，Redis会先尝试清除已到期或即将到期的Key。当此方法处理后，仍然到达最大内存设置，将无法再进行写入操作，但仍然可以进行读取操作。Redis新的vm机制，会把Key存放内存，Value会存放在swap区
maxmemory<bytes>
# 指定是否在每次更新操作后进行日志记录，Redis在默认情况下是异步的把数据写入磁盘，如果不开启，可能会在断电时导致一段时间内的数据丢失。因为redis本身同步数据文件是按上面save条件来同步的，所以有的数据会在一段时间内只存在于内存中。默认为no。
appendonly no  # 开启AOF持久化功能  appendonly yes 
# 指定跟新日志文件名默认为appendonly.aof
appendfilename appendonly.aof
# 指定更新日志的条件，有三个可选参数 - no：表示等操作系统进行数据缓存同步到磁盘(快)，always：表示每次更新操作后手动调用fsync()将数据写到磁盘(慢，安全)， everysec：表示每秒同步一次(折衷，默认值)；
appendfsync everysec
```





### 配置systemd服务

```bash
[root@localhost utils]# cat /usr/lib/systemd/system/redis.service 
[Unit]
Description=Redis data structure server
Documentation=https://redis.io/documentation
After=syslog.target network.target

[Service]
Type=simple
PIDFile=/var/run/redis.pid
ExecStart=/usr/local/redis/bin/redis-server /etc/redis/redis.conf
ExecReload=/bin/kill -USR2 $MAINPID
ExecStop=/bin/kill -SIGINT $MAINPID

[Install]
WantedBy=multi-user.target

```



### 启动Redis

```bash
systemctl daemon-reload 
systemctl restart redis
systemctl status redis

echo  "export PATH=/usr/local/redis/bin:$PATH" >> /etc/profile
source /etc/profile
```



## 主从配置

### master配置

```bash
# vim /etc/redis/6379.conf
bind 0.0.0.0                         # 修改bind 项，0.0.0.0监听所有网段
port：6379                           # 工作端口
protected-mode：no                   # 关闭保护模式
daemonize yes                       # 开启守护进程
logfile /var/log/redis_6379.log     # 指定日志文件目录
dir /var/lib/redis/6379             # 指定本地数据存放位置
appendonly yes                      # 开启AOF持久化功能
requirepass：pwdtest@2021           # 设置 redis 连接密码
masterauth：pwdtest@2021            # 设置slave 服务连接 master 的密码

/etc/init.d/redis_6379 restart  # 重启redis
```



### slave配置

```bash
# vim /etc/redis/6379.conf
bind 0.0.0.0                         # 修改bind 项，0.0.0.0监听所有网卡
port：6379                           # 工作端口
protected-mode：no                   # 关闭保护模式
daemonize yes                       # 开启守护进程
logfile /var/log/redis_6379.log     # 指定日志文件目录
dir /var/lib/redis/6379             # 指定本地数据存放位置
appendonly yes                      # 开启AOF持久化功能
requirepass：pwdtest@2021           # 设置 redis 连接密码
masterauth：pwdtest@2021            # 设置slave 服务连接 master 的密码
replicaof 10.0.0.11 6379            # 指定要同步的Master节点IP和端口

# /etc/init.d/redis_6379 restart  # 重启redis
```



### 验证集群

```bash
[root@master1 data]# redis-cli  info replication  
# Replication
role:master
connected_slaves:5
slave0:ip=192.168.10.243,port=6379,state=online,offset=541,lag=1
slave1:ip=192.168.10.244,port=6379,state=online,offset=541,lag=1
slave2:ip=192.168.10.246,port=6379,state=online,offset=541,lag=1
slave3:ip=192.168.10.245,port=6379,state=online,offset=541,lag=1
slave4:ip=192.168.10.242,port=6379,state=online,offset=541,lag=1
master_failover_state:no-failover
master_replid:75f254ae48b4582ab685cb37bc344f8399c25ad5
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:541
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:541

```



### 常用命令

```bash
# 命令格式：
redis-cli -h yourIp -p yourPort -a youpassword//启动redis客户端，并连接服务器 redis默认端口6379

# 在登录的时候的时候输入密码
redis-cli -h 10.0.0.10 -p 6379 -a foobaa

keys * # 输出服务器中的所有key

# 不重启设置redis密码
redis 127.0.0.1:6379> config set requirepass foo123  # 重启密码失效

# 查询密码:
redis 127.0.0.1:6379> config get requirepass
 (error) ERR operation not permitted

# 验证密码:
redis 127.0.0.1:6379> auth foo123
ok

# 获取密码：
redis 127.0.0.1:6379> config get requirepass
   1) "requirepass"
   2) "foo123"
   
# 主服务器登陆redis
[root@localhost redis-6.2.1]# redis-cli -h 10.0.0.11 -p 6379 -a pwdtest@2021
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
10.0.0.11:6379> keys *
(empty array)
# 此时主服务器数据是空的

# 主服务器写入测试数据

10.0.0.11:6379> set name lisi
OK

# 从服务器登陆redis
# redis-cli -h 10.0.0.12 -p 6379 -a pwdtest@2021
# redis-cli -h 10.0.0.13 -p 6379 -a pwdtest@2021
[root@haproxy-master redis-6.2.1]# redis-cli -h 10.0.0.12 -p 6379 -a pwdtest@2021
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
10.0.0.12:6379> get name
"lisi"
# 从服务器已经同步

```





## 哨兵模式

### 简介



- Sentinel(哨兵) 进程是用于**监控 Redis 集群中 Master 主服务器工作的状态**

- 在 Master 主服务器发生故障的时候，可以实现 Master 和 Slave 服务器的切换，保证系统的高可用（High Availability）

- 哨兵机制被集成在 Redis2.6+ 的版本中，到了2.8版本后就稳定下来了。



### 哨兵的作用

- 监控(Monitoring)：哨兵(sentinel) 会不断地检查你的 Master 和 Slave 是否运作正常。

- 提醒(Notification)：当被监控的某个Redis节点出现问题时, 哨兵(sentinel) 可以通过 API 向管理员或者其他应用程序发送通知。（使用较少）

- 自动故障迁移(Automatic failover)：当一个 Master 不能正常工作时，哨兵(sentinel) 会开始一次自动故障迁移操作。具体操作如下：

  - 它会将失效 Master 的其中一个 Slave 升级为新的 Master, 并让失效 Master 的其他Slave 改为复制新的 Master。

  - 当客户端试图连接失效的 Master 时，集群也会向客户端返回新 Master 的地址，使得集群可以使用现在的 Master 替换失效 Master。

  - Master 和 Slave 服务器切换后，Master 的 redis.conf、Slave 的 redis.conf 和sentinel.conf 的配置文件的内容都会发生相应的改变，即 Master 主服务器的 redis.conf 配置文件中会多一行 slaveof 的配置，sentinel.conf 的监控目标会随之调换。



### 哨兵的工作方式

1、每个 Sentinel（哨兵）进程以**每秒钟一次**的频率向整个集群中的 **Master 主服务器，Slave 从服务器以及其他 Sentinel（哨兵）进程**发送一个 PING 命令。（此处我们还没有讲到集群，下一章节就会讲到，这一点并不影响我们模拟哨兵机制）

2、如果一个实例（instance）距离最后一次有效回复 PING 命令的时间超过 down-after-milliseconds 选项所指定的值， 则这个实例会被 Sentinel（哨兵）进程标记为**主观下线**（**SDOWN**）。

3、 如果一个 Master 主服务器被标记为主观下线（SDOWN），则正在监视这个 Master 主服务器的**所有 Sentinel（哨兵）**进程要以每秒一次的频率**确认 Master 主服务器**的确**进入了主观下线状态**。

4、 当**有足够数量的 Sentinel（哨兵）**进程（大于等于配置文件指定的值）在指定的时间范围内确认 Master 主服务器进入了主观下线状态（SDOWN）， 则 Master 主服务器会被标记为**客观下线（ODOWN）**。

5、 在一般情况下， 每个 Sentinel（哨兵）进程会以每 10 秒一次的频率向集群中的所有Master 主服务器、Slave 从服务器发送 INFO 命令。

6、 当 Master 主服务器被 Sentinel（哨兵）进程标记为**客观下线（ODOWN）**时，Sentinel（哨兵）进程向下线的 Master 主服务器的所有 Slave 从服务器发送 INFO 命令的频率会从 10 秒一次改为每秒一次。

7、 若没有足够数量的 Sentinel（哨兵）进程同意 Master 主服务器下线， Master 主服务器的客观下线状态就会被移除。若 Master 主服务器重新向 Sentinel（哨兵）进程发送 PING 命令返回有效回复，Master 主服务器的主观下线状态就会被移除。



### 哨兵的Leader选举

一般情况下当哨兵发现主节点sdown之后 该哨兵节点会成为领导者负责处理主从节点的切换工作：

1.  哨兵A发现Redis主节点失联；
2. 哨兵A报出sdown，并通知其他哨兵，发送指令sentinel is-master-down-by-address-port给其余哨兵节点；
3. 其余哨兵接收到哨兵A的指令后尝试连接Redis主节点，发现主节点确实失联；
4. 哨兵返回信息给哨兵A，当超过半数的哨兵认为主节点下线后，状态会变成odown；
5. 最先发现主节点下线的哨兵A会成为哨兵领导者负责这次的主从节点的切换工作；
6. 哨兵的选举机制是以各哨兵节点接收到发送*sentinel is-master-down-by-address-port*指令的哨兵id 投票，票数最高的哨兵id会成为本次故障转移工作的哨兵Leader；

### **故障转移**

当哨兵发现主节点下线之后经过上面的哨兵选举机制，选举出本次故障转移工作的哨兵节点完成本次主从节点切换的工作：

1. 哨兵Leader 根据一定规则从各个从节点中选择出一个节点升级为主节点；
2. 其余从节点修改对应的主节点为新的主节点；
3. 当原主节点恢复启动的时候，变为新的主节点的从节点



哨兵Leader选择新的主节点遵循下面几个规则：

**健康度**：从节点响应时间快；

**完整性**：从节点消费主节点的offset偏移量尽可能的高 ()；

**稳定性**：若仍有多个从节点，则根据从节点的创建时间选择最有资历的节点升级为主节点；



在哨兵模式下主从节点总是会变更，因此在Java或Python中访问哨兵模式下的Redis时可以使用对应的哨兵接口连接：

```bash
#Java
JedisSentinelPool

#Python
from redis.sentinel import SentinelConnectionPool
```



### 配置参数详解

```bash
# 哨兵sentinel实例运行的端口，默认26379  
port 26379
# 哨兵sentinel的工作目录
dir ./
# 是否开启保护模式，默认开启。
protected-mode:no
# 是否设置为后台启动。
daemonize:yes

# 哨兵sentinel的日志文件
logfile:./sentinel.log

# 哨兵sentinel监控的redis主节点的 
## ip：主机ip地址
## port：哨兵端口号
## master-name：可以自己命名的主节点名字（只能由字母A-z、数字0-9 、这三个字符".-_"组成。）
## quorum：当这些quorum个数sentinel哨兵认为master主节点失联 那么这时 客观上认为主节点失联了  
# sentinel monitor <master-name> <ip> <redis-port> <quorum>  
sentinel monitor mymaster 127.0.0.1 6379 2

# 当在Redis实例中开启了requirepass，所有连接Redis实例的客户端都要提供密码。
# sentinel auth-pass <master-name> <password>  
sentinel auth-pass mymaster 123456  

# 指定主节点应答哨兵sentinel的最大时间间隔，超过这个时间，哨兵主观上认为主节点下线，默认30秒  
# sentinel down-after-milliseconds <master-name> <milliseconds>
sentinel down-after-milliseconds mymaster 30000  

# 指定了在发生failover主备切换时，最多可以有多少个slave同时对新的master进行同步。这个数字越小，完成failover所需的时间就越长；反之，但是如果这个数字越大，就意味着越多的slave因为replication而不可用。可以通过将这个值设为1，来保证每次只有一个slave，处于不能处理命令请求的状态。
# sentinel parallel-syncs <master-name> <numslaves>
sentinel parallel-syncs mymaster 1  

# 故障转移的超时时间failover-timeout，默认三分钟，可以用在以下这些方面：
## 1. 同一个sentinel对同一个master两次failover之间的间隔时间。  
## 2. 当一个slave从一个错误的master那里同步数据时开始，直到slave被纠正为从正确的master那里同步数据时结束。  
## 3. 当想要取消一个正在进行的failover时所需要的时间。
## 4.当进行failover时，配置所有slaves指向新的master所需的最大时间。不过，即使过了这个超时，slaves依然会被正确配置为指向master，但是就不按parallel-syncs所配置的规则来同步数据了
# sentinel failover-timeout <master-name> <milliseconds>  
sentinel failover-timeout mymaster 180000

# 当sentinel有任何警告级别的事件发生时（比如说redis实例的主观失效和客观失效等等），将会去调用这个脚本。一个脚本的最大执行时间为60s，如果超过这个时间，脚本将会被一个SIGKILL信号终止，之后重新执行。
# 对于脚本的运行结果有以下规则：  
## 1. 若脚本执行后返回1，那么该脚本稍后将会被再次执行，重复次数目前默认为10。
## 2. 若脚本执行后返回2，或者比2更高的一个返回值，脚本将不会重复执行。  
## 3. 如果脚本在执行过程中由于收到系统中断信号被终止了，则同返回值为1时的行为相同。
# sentinel notification-script <master-name> <script-path>  
sentinel notification-script mymaster /var/redis/notify.sh

# 这个脚本应该是通用的，能被多次调用，不是针对性的。
# sentinel client-reconfig-script <master-name> <script-path>
sentinel client-reconfig-script mymaster /var/redis/reconfig.sh
```





配置文件

```bash
# vim /etc/redis/sentinel.conf         
# 最好复制一份到/etc/redis/sentinel.conf与redis主配置文件一起，方便管理

pidfile /var/run/redis-sentinel.pid             #运行时PID文件
protected-mode no                               # 关闭保护模式
port 26379                                      # Redis哨兵默认的监听端口
daemonize yes                                   # 指定sentinel为后台启动
logfile "/data/redis/logs/sentinel.log"                 # 指定日志存放路径
dir "/var/lib/redis/6379"                       # 指定数据库存放路径

#监控的节点名字可以自定义，后边的2代表的：如果有俩个哨兵判断这个主节点挂了那这个主节点就挂了，通常设置为哨兵个数一半加一
# 指定该哨兵节点监控10.0.0.11:6379这个主节点，该主节点的名称是mymaster，最后的2的含义与主节点的故障判定有关：至少需要2个哨兵节点同意，才能判定主节点故障并进行故障转移
sentinel monitor mymaster 192.168.10.241 6379 2    

# 当在Redis实例中开启了requirepass，这里就需要提供密码。
sentinel auth-pass mymaster pwdtest@2021


#哨兵连接主节点多长时间没有响应就代表主节点挂了，单位毫秒。默认30000毫秒，30秒。
sentinel down-after-milliseconds mymaster 30000 

#在故障转移时，最多有多少从节点对新的主节点进行同步。这个值越小完成故障转移的时间就越长，这个值越大就意味着越多的从节点因为同步数据而暂时阻塞不可用
# 主备切换时，最多有多少个slave同时对新的master进行同步，这里设置为默认的1。
sentinel parallel-syncs mymaster 1

# 故障转移的超时时间，这里设置为三分钟180000（180秒）
sentinel failover-timeout mymaster 180000   

#禁止使用SENTINEL SET设置notification-script和client-reconfig-script
sentinel deny-scripts-reconfig yes
```



启动哨兵

```bash
# 配置启动文件

[root@master1 ~]# cat /usr/lib/systemd/system/redis-sentinel.service
[Unit]
Description=Redis
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/redis/bin/redis-sentinel /etc/redis/sentinel.conf
ExecStop=/usr/local/redis/bin/redis-cli shutdown
Restart=always
PrivateTmp=true

[Install]
WantedBy=multi-user.target

[root@master1 ~]# systemctl daemon-reload 
[root@master1 ~]# systemctl start redis-sentinel.service 
[root@master1 ~]# systemctl status redis-sentinel.service 

```



验证哨兵模式

```bash
# 监测哨兵日志
[root@master1 ~]# tail -f /data/redis/logs/sentinel.log 
10564:X 04 Nov 2021 09:17:14.198 * Increased maximum number of open files to 10032 (it was originally set to 1024).
10564:X 04 Nov 2021 09:17:14.198 * monotonic clock: POSIX clock_gettime
10564:X 04 Nov 2021 09:17:14.199 * Running mode=sentinel, port=26379.
10564:X 04 Nov 2021 09:17:14.200 # Sentinel ID is 8548986daa72ed4772b331c3e5c40e2b3254dc18
10564:X 04 Nov 2021 09:17:14.200 # +monitor master mymaster 192.168.10.241 6379 quorum 3
10564:X 04 Nov 2021 09:17:16.211 * +sentinel sentinel 07d143f6577cbcb4514fabe447e2f26b588dbb34 192.168.10.244 26379 @ mymaster 192.168.10.241 6379
10564:X 04 Nov 2021 09:17:16.283 * +sentinel sentinel ff6b3ac7ec68ece91daa721f1b226f788c6ab6cd 192.168.10.243 26379 @ mymaster 192.168.10.241 6379
10564:X 04 Nov 2021 09:17:16.317 * +sentinel sentinel b7d14657a822584ea761efea6bc22257d3d248f7 192.168.10.246 26379 @ mymaster 192.168.10.241 6379
10564:X 04 Nov 2021 09:17:16.379 * +sentinel sentinel e734a4c900f5bc12292c0ae6ec603440c9c23ab7 192.168.10.245 26379 @ mymaster 192.168.10.241 6379
10564:X 04 Nov 2021 09:17:16.408 * +sentinel sentinel 45414d48a8fa8382628b975bce49ff1c4ac46284 192.168.10.242 26379 @ mymaster 192.168.10.241 6379
# 当监测到主节点故障的时候，会重新选举master，并将其他slave节点迁移到新的master
10564:X 04 Nov 2021 09:19:19.519 # +sdown master mymaster 192.168.10.241 6379
10564:X 04 Nov 2021 09:19:19.550 # +new-epoch 1
10564:X 04 Nov 2021 09:19:19.607 # +vote-for-leader 45414d48a8fa8382628b975bce49ff1c4ac46284 1
10564:X 04 Nov 2021 09:19:19.608 # +odown master mymaster 192.168.10.241 6379 #quorum 4/3
10564:X 04 Nov 2021 09:19:19.608 # Next failover delay: I will not start a failover before Thu Nov  4 09:25:20 2021
10564:X 04 Nov 2021 09:19:20.003 # +config-update-from sentinel 45414d48a8fa8382628b975bce49ff1c4ac46284 192.168.10.242 26379 @ mymaster 192.168.10.241 6379
10564:X 04 Nov 2021 09:19:20.003 # +switch-master mymaster 192.168.10.241 6379 192.168.10.242 6379
10564:X 04 Nov 2021 09:19:20.004 * +slave slave 192.168.10.245:6379 192.168.10.245 6379 @ mymaster 192.168.10.242 6379
10564:X 04 Nov 2021 09:19:20.004 * +slave slave 192.168.10.246:6379 192.168.10.246 6379 @ mymaster 192.168.10.242 6379
10564:X 04 Nov 2021 09:19:20.004 * +slave slave 192.168.10.243:6379 192.168.10.243 6379 @ mymaster 192.168.10.242 6379
10564:X 04 Nov 2021 09:19:20.004 * +slave slave 192.168.10.244:6379 192.168.10.244 6379 @ mymaster 192.168.10.242 6379
10564:X 04 Nov 2021 09:19:20.004 * +slave slave 192.168.10.241:6379 192.168.10.241 6379 @ mymaster 192.168.10.242 6379
10564:X 04 Nov 2021 09:19:50.052 # +sdown slave 192.168.10.241:6379 192.168.10.241 6379 @ mymaster 192.168.10.242 6379

# 查看哨兵的信息
[root@master2 ~]# redis-cli -p 26379   info sentinel
# Sentinel
sentinel_masters:1
sentinel_tilt:0
sentinel_running_scripts:0
sentinel_scripts_queue_length:0
sentinel_simulate_failure_flags:0
master0:name=mymaster,status=ok,address=192.168.10.242:6379,slaves=5,sentinels=6
# 最后一行，可以看到，哨兵已经监听到master的主机IP端口和运行状态，并且有5台从机，6个哨兵 master主机为192.168.10.242

# 模拟redis崩溃
127.0.0.1:6379> debug segfaultdebug segfault  

# 查看重启后的master节点 会发现自动变成了slave节点
[root@master1 ~]# redis-cli -p  6379 INFO Replication
# Replication
role:slave
master_host:192.168.10.242
master_port:6379
master_link_status:up
master_last_io_seconds_ago:1
master_sync_in_progress:0
slave_read_repl_offset:273220
slave_repl_offset:273220
slave_priority:100
slave_read_only:1
replica_announced:1
connected_slaves:0
master_failover_state:no-failover
master_replid:ddddf067de1900ff0b67f2e9313afbf40aa44f60
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:273220
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:199887
repl_backlog_histlen:73334

```





## Redis集群

**集群，即Redis Cluster**，是Redis 3.0开始引入的分布式存储方案

集群由多个节点(Node)组成，Redis的数据分布在这些节点中。集群中的节点分为主节点和从节点：只有主节点负责读写请求和集群信息的维护；从节点只进行主节点数据和状态信息的复制。

### 1、集群的作用

**（1）数据分区**：数据分区(或称数据分片)是集群最核心的功能。 集群将数据分散到多个节点，一方面突破了Redis单机内存大小的限制，存储容量大大增加；另一方面每个主节点都可以对外提供读服务和写服务，大大提高了集群的响应能力。 Redis单机内存大小受限问题，在介绍持久化和主从复制时都有提及；例如，如果单机内存太大，bgsave和bgrewriteaof的fork操作可能导致主进程阻塞，主从环境下主机切换时可能导致从节点长时间无法提供服务，全量复制阶段主节点的复制缓冲区可能溢出。

**（2）高可用**：集群支持主从复制和主节点的自动故障转移（与哨兵类似）；当任一节点发生故障时，集群仍然可以对外提供服务。

### 2、Redis集群的数据分片

Redis集群引入了哈希槽的概念 Redis集群有16384个哈希槽（编号0-16383） 集群的每个节点负责一部分哈希槽 每个Key通过CRC16校验后对16384取余来决定放置哪个哈希槽，通过这个值，去找到对应的插槽所对应的节点，然后直接自动跳转到这个对应的节点上进行存取操作

### 以3个节点组成的集群为例：

节点A包含0到5460号哈希槽 节点B包含5461到10922号哈希槽 节点C包含10923到16383号哈希槽

### Redis集群的主从复制模型

集群中具有A、B、C三个节点，如果节点B失败了，整个集群就会因缺少5461-10922这个范围的槽而不可以用。 为每个节点添加一个从节点A1、B1、C1整个集群便有三个Master节点和三个slave节点组成，在节点B失败后，集群选举B1位为的主节点继续服务。当B和B1都失败后，集群将不可用



### Redis集群部署

文件配置

```bash
# 注意集群中的每个端口都要不一样
vim redis.conf

bind 10.0.0.11                          # 修改bind项，监听自己的IP
protected-mode no                       # 修改，关闭保护模式
port 7001                               # 修改，redis监听端口，
daemonize yes                           # 以独立进程启动
cluster-enabled yes                     # 取消注释，开启群集功能
cluster-config-file nodes-6379.conf     # 取消注释，群集名称文件设置，无需修改
cluster-node-timeout 15000              # 取消注释群集超时时间设置
appendonly yes                          # 修改，开启AOF持久化
```





```bash
redis-cli --cluster create 192.168.10.241:6379 192.168.10.242:6380 192.168.10.243:6381 192.168.10.244:6382 192.168.10.245:6383 192.168.10.246:6384 --cluster-replicas 1   # 只有一个副本，如需要多个副本，改变1即可

# 初始化集群
[root@master1 ~]# redis-cli --cluster create 192.168.10.241:6379 192.168.10.242:6380 192.168.10.243:6381 192.168.10.244:6382 192.168.10.245:6383 192.168.10.246:6384 --cluster-replicas 1
>>> Performing hash slots allocation on 6 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 192.168.10.245:6383 to 192.168.10.241:6379
Adding replica 192.168.10.246:6384 to 192.168.10.242:6380
Adding replica 192.168.10.244:6382 to 192.168.10.243:6381
M: f13b06e0cfa8a4871cca4802b3bce9d9b07c59f9 192.168.10.241:6379
   slots:[0-5460] (5461 slots) master
M: d78165004cab47ff580517355f0f8a3d2b9cf3c2 192.168.10.242:6380
   slots:[5461-10922] (5462 slots) master
M: fc86959c03da2c58528c628fe8b354529cc78a8d 192.168.10.243:6381
   slots:[10923-16383] (5461 slots) master
S: 8e02645c0d6881242bad32384fc8ef6d5964310e 192.168.10.244:6382
   replicates fc86959c03da2c58528c628fe8b354529cc78a8d
S: 78abc38380aaf2b278331f10e767dff3e90d0d4b 192.168.10.245:6383
   replicates f13b06e0cfa8a4871cca4802b3bce9d9b07c59f9
S: ec538bfe3586c13e50c0e3f64437f26e4d76249b 192.168.10.246:6384
   replicates d78165004cab47ff580517355f0f8a3d2b9cf3c2
Can I set the above configuration? (type 'yes' to accept): yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join

>>> Performing Cluster Check (using node 192.168.10.241:6379)
M: f13b06e0cfa8a4871cca4802b3bce9d9b07c59f9 192.168.10.241:6379
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
M: fc86959c03da2c58528c628fe8b354529cc78a8d 192.168.10.243:6381
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
M: d78165004cab47ff580517355f0f8a3d2b9cf3c2 192.168.10.242:6380
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
S: 8e02645c0d6881242bad32384fc8ef6d5964310e 192.168.10.244:6382
   slots: (0 slots) slave
   replicates fc86959c03da2c58528c628fe8b354529cc78a8d
S: 78abc38380aaf2b278331f10e767dff3e90d0d4b 192.168.10.245:6383
   slots: (0 slots) slave
   replicates f13b06e0cfa8a4871cca4802b3bce9d9b07c59f9
S: ec538bfe3586c13e50c0e3f64437f26e4d76249b 192.168.10.246:6384
   slots: (0 slots) slave
   replicates d78165004cab47ff580517355f0f8a3d2b9cf3c2
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.


```



**注意**，如果出现如下报错

```bash
[ERR] Node 192.168.10.241:6379 is not empty. Either the nodealready knows other nodes (check with CLUSTER NODES) or contains some key in database 0.

解决方法：

1)、将需要新增的节点下aof、rdb等本地备份文件删除； # 该文件在redis数据保存到本地的目录 如/var/lib/redis/等

2)、同时将新Node的集群配置文件删除,即：删除你redis.conf里面cluster-config-file所在目录的文件；

3)、再次添加新节点如果还是报错，则登录新Node,./redis-cli–h x –p对数据库进行清除：

192.168.10.241:6379>  flushdb      #清空当前数据库
```



测试查看集群服务器

```bash
redis-cli -h 192.168.10.241 -p 6379 -c   # 加-c参数，节点之间就可以互相跳转 ,不加-c则无法跳转
cluster slots             # 查看节点的哈希槽编号范围
set sky bluelight              # 设置一个键值
cluster keyslot sky      # 查看name键的槽编号

[root@master1 ~]# redis-cli -h 192.168.10.241 -p 6379 -c
192.168.10.241:6379> cluster slots
1) 1) (integer) 0
   2) (integer) 5460
   3) 1) "192.168.10.241"
      2) (integer) 6379
      3) "f13b06e0cfa8a4871cca4802b3bce9d9b07c59f9"
   4) 1) "192.168.10.245"
      2) (integer) 6383
      3) "78abc38380aaf2b278331f10e767dff3e90d0d4b"
2) 1) (integer) 5461
   2) (integer) 10922
   3) 1) "192.168.10.242"
      2) (integer) 6380
      3) "d78165004cab47ff580517355f0f8a3d2b9cf3c2"
   4) 1) "192.168.10.246"
      2) (integer) 6384
      3) "ec538bfe3586c13e50c0e3f64437f26e4d76249b"
3) 1) (integer) 10923
   2) (integer) 16383
   3) 1) "192.168.10.243"
      2) (integer) 6381
      3) "fc86959c03da2c58528c628fe8b354529cc78a8d"
   4) 1) "192.168.10.244"
      2) (integer) 6382
      3) "8e02645c0d6881242bad32384fc8ef6d5964310e"
192.168.10.241:6379> set sky bluelight
-> Redirected to slot [14646] located at 192.168.10.243:6381
OK
192.168.10.243:6381> cluster keyslot  sky
(integer) 14646
192.168.10.243:6381> 


```



## Redis使用

### Redis数据类型

```shell
1. string类型:
	字符串类型是 Redis 中最为基础的数据存储类型，它在 Redis 中是二进制安全的，也就是byte类型
	最大容量是512M。
	
2. hash类型:
		hash用于存储对象，对象的结构为属性、值，值的类型为string。
		key:{
            域:值[这里的值只能是字符串]，
            域:值，            
            域:值，
            域:值，
            ...
		}
		
3. list类型:
		列表的元素类型为string。
		key:[ 值1，值2,值3..... ]
		
4. set类型:
	无序集合，元素为string类型，元素唯一不重复，没有修改操作。
	{值1,值4,值3,值5}
	
5. zset类型:
	有序集合，元素为string类型，元素唯一不重复，没有修改操作。
```

**如何验证Redis是否连接成功**

```powershell
PS C:\> redis-cli
127.0.0.1:6379> ping
PONG
127.0.0.1:6379>

# 常用参数
redis-cli -h host -p port -a password
```

### Redis键

```bash
# 查找所有符合给定模式( pattern)的 key 。
127.0.0.1:6379> keys *
1) "hello"

# 查看key类型
127.0.0.1:6379> type "hello"
string

# 序列化给定 key ，并返回被序列化的值。
127.0.0.1:6379> dump "hello"
"\x00\x05world\t\x00\xc9#mH\x84/\x11s"

# 检查给定 key 是否存在，存在返回1，否则返回0
127.0.0.1:6379> exists "hello"
(integer) 1
127.0.0.1:6379>
127.0.0.1:6379> exists "hello1"
(integer) 0

# 为给定key设置过期时间，以秒计
127.0.0.1:6379> expire hello 3
(integer) 1
127.0.0.1:6379> get hello
(nil)

# 将当前数据库的key移动到给定的数据库db当中。
127.0.0.1:6379> move hello 2
(integer) 1
127.0.0.1:6379> get hello
(nil)

# 移除key的过期时间，key将持久保持。
127.0.0.1:6379> persist hello
(integer) 1

# 以毫秒为单位返回 key 的剩余的过期时间。
127.0.0.1:6379> pttl hello
(integer) 6153

# 以秒为单位，返回给定 key 的剩余生存时间(TTL, time to live)。
127.0.0.1:6379> ttl hello
(integer) 9

# 从当前数据库中随机返回一个key 
127.0.0.1:6379> RANDOMKEY
"hello"

# 修改 key 的名称
127.0.0.1:6379> rename hello keys
OK

# 仅当newkey不存在时，将key改名为newkey
127.0.0.1:6379> renamenx keys hello
(integer) 1
```



### string类型

```bash
# 设置指定 key 的值。
127.0.0.1:6379> set hello redis
OK

# 获取指定key的值
127.0.0.1:6379> get hello
"redis"

# 返回key中字符串值的子字符，相当于对值进行切片
127.0.0.1:6379> getrange hello 0 4
"redis"

# 将给定key的值设为value ，并返回key的旧值(old value)。
127.0.0.1:6379> getset hello world
"redis"

# 获取所有(一个或多个)给定key的值。
127.0.0.1:6379> mget k1 k2 k3
1) "v1"
2) "v2"
3) "v3"

# 返回key所储存的字符串值的长度。
127.0.0.1:6379> strlen hello
(integer) 5

# 将值value关联到key，并将key的过期时间设为seconds(以秒为单位)。
127.0.0.1:6379> setex hello 120 hahaha
OK

# 只有在key不存在时设置key的值。
127.0.0.1:6379> setnx age 18
(integer) 1

# 同时设置一个或多个key-value对，当且仅当所有给定key都不存在。
127.0.0.1:6379> msetnx k4 v4 k5 v5 k6 v6
(integer) 1

# 如果key已经存在并且是一个字符串， APPEND命令将指定的value追加到该key原来值（value）的末尾。
127.0.0.1:6379> append k1 v1
(integer) 4

# 将 key 中储存的数字值增一。value值必须是数字
127.0.0.1:6379> incr age
(integer) 19

# 将 key 中储存的数字值减一。value值必须是数字
127.0.0.1:6379> decr age
(integer) 18
```

### hash类型

```bash
# 设置值
127.0.0.1:6379> hset myhash field "hello"
(integer) 1

# 获取存储在哈希表中指定字段的值。
127.0.0.1:6379> hget myhash field
"hello"

# 查看key的类型
127.0.0.1:6379> type myhash
hash

# 一次性设置多个值
127.0.0.1:6379> hmset user name "zhangsan" age 18 sex "nan"
OK

# 获取在哈希表中指定 key 的所有字段和值
127.0.0.1:6379> hgetall
(error) ERR wrong number of arguments for 'hgetall' command
127.0.0.1:6379> hgetall user
1) "name"
2) "zhangsan"
3) "age"
4) "18"
5) "sex"
6) "nan"

# 删除一个或多个哈希表字段
127.0.0.1:6379> hdel myhash field
(integer) 1

# 查看哈希表key中，指定的字段是否存在， 存在返回1 不存在返回0
127.0.0.1:6379> hexists myhash field
(integer) 0


```







### list类型

### set类型

### zset类型



## 参考文档

https://zhuanlan.zhihu.com/p/379456122
