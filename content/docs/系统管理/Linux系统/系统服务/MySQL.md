---
title: "MySQL"
weight: 55
date: 2026-06-05
tags: ["MySQL", "数据库", "SQL", "运维"]
---

MySQL 是最广泛使用的开源关系型数据库，以高性能、高可靠性著称。本文介绍在 CentOS 7 上安装 MySQL 5.7、配置数据目录与主从复制参数，以及完成初始化和主从搭建的操作步骤。

## CentOS7安装MySql

下载安装包(mysql 5.7+)

```bash
wget -i -c http://dev.mysql.com/get/mysql57-community-release-el7-10.noarch.rpm
```

运行安装包

yum -y install mysql57-community-release-el7-10.noarch.rpm

安装数据库

yum -y install mysql-community-server

创建目录文件

```bash
vim /etc/my.cnf
datadir=/data/mysqld/data
socket=/data/mysqld/data/mysql.sock
symbolic-links=0
log-error=/data/mysqld/logs/mysqld.log
pid-file=/data/mysqld/mysqld.pid
port=3306
server_id=225                             #服务器ID
log-bin=mysql-bin                         #二进制日志文件名
log-slave-updates=true                    #添加，允许从服务器更新二进制日志
binlog_format = row                       #强烈建议，其他格式可能造成数据不一致
max_binlog_size = 100M

[mysql]
socket=/data/mysqld/data/mysql.sock


mkdir -p /data/mysqld/{data,logs}
chown mysql:mysql /data/mysqld/ -R

```

启动服务

systemctl start mysqld.service && systemctl enable mysqld.service
systemctl status mysqld.service

使用默认密码进入数据库

grep "password" /var/log/mysqld.log
mysql -uroot -p

修改密码，注意密码复杂度要求

ALTER USER 'root'@'localhost' IDENTIFIED BY 'V3QM$FhKuSqcP@Xk<H+U8wIC_m1T?vn>';

授权远程访问

grant all privileges on *.* to 'root'@'%' identified by 'V3QM$FhKuSqcP@Xk<H+U8wIC_m1T?vn>' with grant option;

创建用户

```bash
create user 'slave1'@'%' identified by 'QNm*6A<.Cu$:M8Plxq%dv^B]IcW;@sig';

create user 'slave2'@'%' identified by 'QNm*6A<.Cu$:M8Plxq%dv^B]IcW;@sig';
```

刷新权限

flush privileges;

MySQL默认源在国外，如果在国内连接的话，可能会特别慢，这个时候可以去官网下载别人打包好的tar包，解压安装即可

wget https://cdn.mysql.com//Downloads/MySQL-5.7/mysql-5.7.34-1.el7.x86_64.rpm-bundle.tar
tar xvf mysql-5.7.34-1.el7.x86_64.rpm-bundle.tar
yum -y install ./mysql-community-*
systemctl start mysqld.service



## MySQL密码重置

```BASH
# 修改配置文件
[root@localhost ~]# vim /etc/my.cnf
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
symbolic-links=0
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
skip-grant-tables	# 配置文件添加此行


#重启mysql服务
[root@localhost ~]# systemctl restart mysqld

# 用户登录
mysql -uroot -p # (直接点击回车，密码为空)

# 修改密码
mysql> use mysql;
mysql> update user set authentication_string=password('V3QM$FhKuSqcP@Xk<H+U8wIC_m1T?vn>') where user='root';
Query OK, 1 row affected, 1 warning (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 1

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)


# 删除配置文件中刚才添加的一行，并重启数据库，使用新密码进去
# 重新进入后，会提示让重置密码
mysql> show databases;
ERROR 1820 (HY000): You must reset your password using ALTER USER statement before executing this statement.

# 使用alter user语句重置密码即可
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'V3QM$FhKuSqcP@Xk<H+U8wIC_m1T?vn>';
Query OK, 0 rows affected (0.00 sec)

mysql> grant all privileges on *.* to 'root'@'%' identified by 'V3QM$FhKuSqcP@Xk<H+U8wIC_m1T?vn>' with grant option;
Query OK, 0 rows affected, 1 warning (0.00 sec)

mysql> flush privileges;
Query OK, 0 rows affected (0.00 sec)


```



## MySQL主动复制

搭建并测试一主两从的主从复制环境，提高数据库的可用性和容错性

拓扑示例

![image-20210902112612921](https://raw.githubusercontent.com/adcwb/storages/master/image-20210902112612921.png)

![image-20210902105050670](https://raw.githubusercontent.com/adcwb/storages/master/image-20210902105050670.png)

环境准备

|       系统类型        |     IP地址      |      主机名      |                         所需软件                         |          硬件          |
| :-------------------: | :-------------: | :--------------: | :------------------------------------------------------: | :--------------------: |
|    Centos 7.9.2009    |  43.249.28.50   |     server1      |            boost_1_59_0.tar.gz  mysql-5.7.35             |          2H4G          |
|    Centos 7.9.2009    | 106.13.208.193  |     server2      |            boost_1_59_0.tar.gz  mysql-5.7.35             |          2H4G          |
|    Centos 7.9.2009    | 208.90.122.143  |     server3      |            boost_1_59_0.tar.gz  mysql-5.7.35             |          4H8G          |
|    Centos 7.9.2009    | 192.168.100.104 |  am.linuxfan.cn  | jdk-6u14-linux-x64.bin  amoeba-mysql-binary-2.2.0.tar.gz | 内存：512M  CPU核心：1 |
| Centos 7.4 1708 64bit | 192.168.80.138  | lamp.linuxfan.cn |                                                          | 内存：512M  CPU核心：1 |



MySQL配置文件

```bash
[root@www ~]# vim /etc/my.cnf

[mysqld]

datadir=/data/mysql/data
socket=/data/mysql/data/mysql.sock
symbolic-links=0
log-error=/data/mysql/logs/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
port=3306
server_id=193                             #服务器ID
log-bin=mysql-bin                         #二进制日志文件名
log-slave-updates=true                    #添加，允许从服务器更新二进制日志
binlog_format = row                       #强烈建议，其他格式可能造成数据不一致
max_binlog_size = 100M
log-slave-updates = 1                     #是否记录从服务器同步数据动作
gtid-mode = on                            #启用gitd功能
enforce-gtid-consistency = 1              #开启强制GTID一致性
master-info-repository = TABLE            #记录IO线程读取已经读取到的master binlog位置，用于slave宕机后IO线程根据文件中的POS点重新拉取binlog日志
relay-log-info-repository = TABLE         #记录SQL线程读取Master binlog的位置，用于Slave 宕机后根据文件中记录的pos点恢复Sql线程
sync-master-info = 1                      #启用确保无信息丢失；任何一个事务提交后, 将二进制日志的文件名及事件位置记录到文件中
slave-parallel-workers = 8                #设定从服务器的复制线程数；0表示关闭多线程复制功能
binlog-checksum = CRC32                   #设置binlog校验算法（循环冗余校验码）
master-verify-checksum = 1                #设置主服务器是否校验
slave-sql-verify-checksum = 1             #设置从服务器是否校验
binlog-rows-query-log_events = 1          #用于在二进制日志记录事件相关的信息，可降低故障排除的复杂度
sync_binlog = 1                           #保证master crash safe，该参数必须设置为1
innodb_flush_log_at_trx_commit = 1        #保证master crash safe，该参数必须设置为1


[mysql]
default-character-set=utf8
socket=/data/mysql/data/mysql.sock

```



根据配置文件，创建相对应的目录

```bash
mkdir -p /data/mysqld/{data,logs}
chown mysql:mysql /data/mysqld/ -R
```



```mysql

mysql> GRANT REPLICATION SLAVE ON *.* TO 'slave'@'%' IDENTIFIED BY 'QNm*6A<.Cu$:M8Plxq%dv^B]IcW;@sig'; 
Query OK, 0 rows affected, 1 warning (0.03 sec)

mysql> flush privileges; 
Query OK, 0 rows affected (0.02 sec)

mysql> show master status;
+------------------+----------+--------------+------------------+------------------------------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                        |
+------------------+----------+--------------+------------------+------------------------------------------+
| mysql-bin.000003 |     1284 |              |                  | fbdb27e6-1b68-11ec-884e-faad9d5a0000:1-5 |
+------------------+----------+--------------+------------------+------------------------------------------+
1 row in set (0.00 sec)



```



```bash
change master to master_host='192.168.10.241',master_port=3306,master_user='slave',master_password='QNm*6A<.Cu$:M8Plxq%dv^B]IcW;@sig',master_log_file='mysql-bin.000003',master_log_pos=1284; 

change master to master_host='43.249.28.50',master_port=3306,master_user='slave2',master_password='QNm*6A<.Cu$:M8Plxq%dv^B]IcW;@sig',master_log_file='mysql-bin.000005',master_log_pos=66813; 
```



客户端配置master同步

```	MYSQL
mysql> show variables like 'server_id';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| server_id     | 242   |
+---------------+-------+
1 row in set (0.01 sec)

mysql> change master to master_host='192.168.10.241',master_port=3306,master_user='slave',master_password='QNm*6A<.Cu$:M8Plxq%dv^B]IcW;@sig',master_log_file='mysql-bin.000003',master_log_pos=1284; 

Query OK, 0 rows affected, 2 warnings (0.18 sec)

mysql> start slave;
Query OK, 0 rows affected (0.21 sec)

```



查看客户端集群状态

```mysql
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 192.168.10.241
                  Master_User: slave
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000003
          Read_Master_Log_Pos: 1284
               Relay_Log_File: master2-relay-bin.000002
                Relay_Log_Pos: 320
        Relay_Master_Log_File: mysql-bin.000003
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 1284
              Relay_Log_Space: 529
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 241
                  Master_UUID: fbdb27e6-1b68-11ec-884e-faad9d5a0000
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 
            Executed_Gtid_Set: fe0417de-1b74-11ec-b459-fa87939ee000:1-3
                Auto_Position: 0
         Replicate_Rewrite_DB: 
                 Channel_Name: 
           Master_TLS_Version: 
1 row in set (0.00 sec)


```



验证集群同步状态是否正常

```mysql
# ster节点创建数据库

mysql> create database cloud;
Query OK, 1 row affected (0.03 sec)

# ave节点查看数据库是否同步
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| cloud              |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)

```



### 基于二进制日志的主从复制

```bash
[root@master ~]# vi /etc/my.cnf
[mysqld]
datadir=/data/mysql/data
socket=/data/mysql/data/mysql.sock
symbolic-links=0
log-error=/data/mysql/logs/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
port=3306
server_id=193                               # 服务器ID
log-bin=mysql-bin                           # 二进制日志文件名
log-slave-updates							# 指定开启slave角色的更新
binlog-ignore-db=mysql				# 复制过滤：也就是指定哪个数据库不用同步（mysql库一般不同步）
binlog_cache_size=1M				# 为每个session 分配的内存，在事务过程中用来存储二进制日志的缓存
binlog_format=mixed		# 主从复制的格式（mixed,statement,row，默认格式是statement）
expire_logs_days=7		# 二进制日志自动删除/过期的天数。默认值为0，表示不自动删除。
innodb_flush_log_at_trx_commit=2
master_info_repository=table
relay_log_info_repository=TABLE
slave_skip_errors=1062		# 跳过主从复制中遇到的所有错误或指定类型的错误


[root@slave ~]# vi /etc/my.cnf
relay-log=relay1-log-bin
relay-log-index=slave-relay1-bin.index
server-id=2
innodb_flush_log_at_trx_commit=2
slave-parallel-type=LOGICAL_CLOCK
slave_parallel_workers=16
master_info_repository=table
relay_log_info_repository=TABLE


```



### 基于GTID方式的主从复制

```bash
[root@master ~]# vim /etc/my.cnf
log-bin=mysql-bin
log-slave-updates
server-id=1
innodb_flush_log_at_trx_commit=2
master_info_repository=table
relay_log_info_repository=TABLE
binlog-format=ROW
gtid-mode=ON
enforce-gtid-consistency=true
binlog_cache_size = 4M
max_binlog_size = 1G
max_binlog_cache_size = 2G
skip-name-resolve


[root@slave ~]# vim /etc/my.cnf							##末尾添加
relay-log=relay1-log-bin
relay-log-index=slave-relay1-bin.index
server-id=2
innodb_flush_log_at_trx_commit=2
slave-parallel-type=LOGICAL_CLOCK
slave_parallel_workers=16
master_info_repository=table
relay_log_info_repository=TABLE
binlog-format=ROW
binlog-row-image = minimal
log-bin=slave1-bin
log-bin-index=slave1-log-bin.index
gtid-mode=ON
enforce-gtid-consistency=true
binlog_cache_size = 4M
max_binlog_size = 1G
max_binlog_cache_size = 2G
slave-sql-verify-checksum=1
binlog-rows-query-log_events=1
log-slave-updates
relay_log_purge = 1
relay_log_recovery = 1
skip-name-resolve

```



## MySQL读写分离

```bash
```



















