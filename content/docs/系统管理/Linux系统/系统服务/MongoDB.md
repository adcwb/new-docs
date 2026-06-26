---
title: "MongoDB"
weight: 65
date: 2026-06-05
---

## CentOS安装MongoDB数据库

1、下载安装包

```bash
wget http://downloads.mongodb.org/linux/mongodb-linux-x86_64-rhel70-5.0.2.tgz
```

2、解压，并将安装包放到合适的位置，如`/usr/local/mongodb`, 并添加环境变量

```bash
tar zxvf mongodb-linux-x86_64-rhel70-5.0.2.tgz
mv mongodb-linux-x86_64-rhel70-5.0.2 /usr/local/mongodb

echo "export PATH=/usr/local/mongodb/bin:\$PATH" >>/etc/profile
source /etc/profile
```

3、创建MongoDB配置文件及服务启动文件

```bash
# 创建配置文件目录
mkdir /etc/mongodb

# 配置文件，指定的日志文件，必须事先存在
[root@www ~]# cat /etc/mongodb/mongodb.conf 
bind_ip=0.0.0.0
port=27017
dbpath=/data/mongodb/data/
logpath=/data/mongodb/logs/mongodb.log
logappend=true
fork=true
maxConns=5000


# 创建数据文件存放目录
mkdir /data/mongodb/{data,logs} -p
touch /data/mongodb/logs/mongodb.log

# 创建服务启动文件
touch /usr/lib/systemd/system/mongodb.service

# 服务启动文件详情
[root@www ~]# cat <<END >> /usr/lib/systemd/system/mongodb.service
[Unit]
Description=mongodb
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
ExecStart=/usr/local/mongodb/bin/mongod -f /etc/mongodb/mongodb.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/usr/local/mongodb/bin/mongod --shutdown -f /etc/mongodb/mongodb.conf
PrivateTmp=true

[Install]
WantedBy=multi-user.target
END

# 启动MongoDB
systemctl daemon-reload
systemctl start mongodb
systemctl status mongodb

```

4、防火墙放行

```bash
firewall-cmd --add-port=27017/tcp --permanent 
firewall-cmd --reload
```



## MongoDB单节点备份

工具下载： https://www.mongodb.com/try/download/database-tools

![image-20211109163643311](https://raw.githubusercontent.com/adcwb/storages/master/image-20211109163643311.png)



备份数据库

```bash
[root@MyCloudServer ~]# mongodump --gzip --out /backup/mongodb/
2021-11-09T16:23:42.509+0800    writing test.runoob to /backup/mongodb/test/runoob.bson
2021-11-09T16:23:42.513+0800    done dumping test.runoob (1 document)

--db： 指定备份的数据集，若不指定则默认备份所有
--host="mongodb0.example.com:27017" 指定主机地址和端口

--host="mongodb0.example.com"  分开指定
--port=27017

--uri="mongodb://mongodb0.example.com:27017
--gzip 压缩输出

mongodump --gzip --out /backup/mongodb/			# 备份所有数据库
mongodump --db mydb --out /backup/mongodb/ 		# 备份单个数据库
mongodump -d mydb  --collection users -o /backup/mongodb/ # 备份单个集合

```



还原数据库

```bash
[root@MyCloudServer ~]# mongorestore --db test /backup/mongodb/test/runoob.bson 
2021-11-09T16:32:36.125+0800    checking for collection data in /backup/mongodb/test/runoob.bson
2021-11-09T16:32:36.126+0800    reading metadata for test.runoob from /backup/mongodb/test/runoob.metadata.json
2021-11-09T16:32:36.159+0800    restoring test.runoob from /backup/mongodb/test/runoob.bson
2021-11-09T16:32:36.209+0800    finished restoring test.runoob (1 document, 0 failures)
2021-11-09T16:32:36.209+0800    no indexes to restore for collection test.runoob
2021-11-09T16:32:36.209+0800    1 document(s) restored successfully. 0 document(s) failed to restore.

--quiet 	# 静默输出
--version	# 版本号
--host=<hostname><:port>, -h=<hostname><:port>
--username=<username>, -u=<username>
--password=<password>, -p=<password>
--db=<database>, -d=<database>
--collection=<collection>, -c=<collection>
--drop		# 还原前先删除
--gzip		# 从压缩包中还原
--dir=string	# 指定转储目录

mongorestore --gzip /backup/mongodb/			# 恢复所有数据库
mongorestore --db mydb /var/backups/mongo/mydb		# 恢复单个数据库
mongorestore -d mydb -c users mydb/users.bson		# 恢复单个集合
mongoimport --db mydb --collection users --file users.json --jsonArray # 恢复单个集合 json格式 
```





## MongoDB复制集

![image-20210903092250414](https://raw.githubusercontent.com/adcwb/storages/master/image-20210903092250414.png)

**一、复制集概述：**

**组成：**

 	Mongodb复制集（副本集replica set）由一组Mongod实例（进程）组成，包含一个Primary节点和多个Secondary节点，Mongodb Driver（客户端）的所有数据都写入Primary，Secondary通过oplog来同步Primary的数据，保证主节点和从节点数据的一致性，复制集在完成主从复制的基础上，通过心跳机制，一旦primary节点出现宕机，则触发选举一个新的主节点，剩下的secondary节点指向新的primary，时间应该在10-30s内完成感知primary节点故障，实现高可用数据库集群；

**特点：**

 	主是唯一的，但不是固定的；
 	
 	通过oplog同步数据保证数据的一致性；
 	
 	从库无法写入（默认情况下，不使用驱动连接时，读也是不能查询的）；
 	
 	相对于传统的主从结构，复制集可以自动容灾；



**二、复制集原理：**

**角色（按是否存储数据划分）：**

 	Primary：主节点，由选举产生，负责客户端的写操作，产生oplog日志文件；
 	
 	Secondary：从节点，负责客户端的读操作，提供数据的备份和故障的切换；
 	
 	Arbiter：仲裁节点，只参与选举的投票，不会成为primary，也不向Primary同步数据，若部署了一个2个节点的复制集，1个Primary，1个Secondary，任意节点宕机，复制集将不能提供服务了（无法选出Primary），这时可以给复制集添加一个Arbiter节点，即使有节点宕机，仍能选出Primary；



**角色（按类型区分）：**

 	Standard（标准）：这种是常规节点，它存储一份完整的数据副本，参与投票选举，有可能成为主节点；
 	
 	Passive（被动）：存储完整的数据副本，参与投票，不能成为活跃节点。
 	
 	Arbiter（投票）：仲裁节点只参与投票，不接收复制的数据，也不能成为活跃节点。

注：每个参与节点（非仲裁者）有个优先权（0-1000），优先权（priority）为0则是被动的，不能成为活跃节点，优先权不为0的，按照由大到小选出活跃节点，优先值一样的则看谁的数据比较新；

注：Mongodb 3.0里，复制集成员最多50个，参与Primary选举投票的成员最多7个；

 

**选举：**

 	每个节点通过优先级定义出节点的类型（标准、被动、投票）；
 	
 	标准节点通过对比自身数据进行选举出primary节点或者secondary节点；



**影响选举的因素**：

 	1.心跳检测：复制集内成员每隔两秒向其他成员发送心跳检测信息，若10秒内无响应，则标记其为不可用；
 	
 	2.连接：在多个节点中，最少保证两个节点为活跃状态，如果集群中共三个节点，挂掉两个节点，那么剩余的节点无论状态是primary还是处于选举过程中，都会直接被降权为secondary；



**触发选举的情况**：

 	1.初始化状态 

 2.从节点们无法与主节点进行通信  

 3.主节点辞职



主节点辞职的情况：

 	1.在接收到replSetStepDown命令后；
 	
 	2.在现有的环境中，其他secondary节点的数据落后于本身10s内，且拥有更高优先级；
 	
 	3.当主节点无法与群集中多数节点通信；

注：当主节点辞职后，主节点将关闭自身所有的连接，避免出现客户端在从节点进行写入操作；

                               

 **异常处理：** 

 		当Primary宕机时，如果有数据未同步到Secondary，当Primary重新加入时，如果新的Primary上已经发生了写操作，则旧Primary需要回滚部分操作，以保证数据集与新的Primary一致。旧Primary将回滚的数据写到单独的rollback目录下，数据库管理员可根据需要使用mongorestore进行恢复。



```bash
# 默认三台MongoDB数据库单机版配置完成
# MongoDB启动复制集，需要先在配置文件中声明集群的名字，每个节点都需要
replSet=mongodb_cluster

# 声明配置文件
> cfg = {
    "_id": "mongodb_cluster",
    "members": [
        {
            "_id": 0,
            "host": "43.249.28.50:27017"
        },
        {
            "_id": 1,
            "host": "106.13.208.193:27017"
        },
        {
            "_id": 2,
            "host": "208.90.122.143:27017"
        }
    ]
}

# 初始化集群
> rs.initiate(cfg)
{ "ok" : 1 }

rs.add()			# 添加标准节点
rs.remove()			# 删除标准节点
rs.isMaster()		# 查看复制集节点
rs.initiate(cfg)	# 初始化节点
rs.addArb("ip:port")	# 添加仲裁节点，有就添加
rs.printSlaveReplicationInfo()			# 查看节点信息
rs.printReplicationInfo()
db.oplog.rs.stats()	

注意：
	secondary节点默认无法读取，可以通过以下方式或者驱动方式实现
		> db.getMongo().setSecondaryOk();
在初始化集群的时候，还可以手动指定集群的优先级
	cfg={"_id":"haha","members":[{"_id":0,"host":"43.249.28.50:27017","priority":100},{"_id":1,"host":"106.13.208.193:27017","priority":100},{"_id":2,"host":"208.90.122.143:27017","priority":10}]}
	
```

查看集群状态

```bash
mongodb_cluster:SECONDARY>  rs.status()
{
	"set" : "mongodb_cluster",
	"date" : ISODate("2021-09-02T15:01:21.612Z"),
	"myState" : 2,
	"term" : NumberLong(0),
	"syncSourceHost" : "",
	"syncSourceId" : -1,
	"heartbeatIntervalMillis" : NumberLong(2000),
	"majorityVoteCount" : 2,
	"writeMajorityCount" : 2,
	"votingMembersCount" : 3,
	"writableVotingMembersCount" : 3,
	"optimes" : {
		"lastCommittedOpTime" : {
			"ts" : Timestamp(0, 0),
			"t" : NumberLong(-1)
		},
		"lastCommittedWallTime" : ISODate("1970-01-01T00:00:00Z"),
		"appliedOpTime" : {
			"ts" : Timestamp(1630594860, 1),
			"t" : NumberLong(-1)
		},
		"durableOpTime" : {
			"ts" : Timestamp(1630594860, 1),
			"t" : NumberLong(-1)
		},
		"lastAppliedWallTime" : ISODate("2021-09-02T15:01:00.867Z"),
		"lastDurableWallTime" : ISODate("2021-09-02T15:01:00.867Z")
	},
	"lastStableRecoveryTimestamp" : Timestamp(0, 0),
	"members" : [
		{
			"_id" : 0,
			"name" : "43.249.28.50:27017",
			"health" : 1,
			"state" : 2,
			"stateStr" : "SECONDARY",
			"uptime" : 952,
			"optime" : {
				"ts" : Timestamp(1630594860, 1),
				"t" : NumberLong(-1)
			},
			"optimeDate" : ISODate("2021-09-02T15:01:00Z"),
			"syncSourceHost" : "",
			"syncSourceId" : -1,
			"infoMessage" : "",
			"configVersion" : 1,
			"configTerm" : 0,
			"self" : true,
			"lastHeartbeatMessage" : ""
		},
		{
			"_id" : 1,
			"name" : "106.13.208.193:27017",
			"health" : 1,
			"state" : 0,
			"stateStr" : "STARTUP",
			"uptime" : 20,
			"optime" : {
				"ts" : Timestamp(0, 0),
				"t" : NumberLong(-1)
			},
			"optimeDurable" : {
				"ts" : Timestamp(0, 0),
				"t" : NumberLong(-1)
			},
			"optimeDate" : ISODate("1970-01-01T00:00:00Z"),
			"optimeDurableDate" : ISODate("1970-01-01T00:00:00Z"),
			"lastHeartbeat" : ISODate("2021-09-02T15:01:21.122Z"),
			"lastHeartbeatRecv" : ISODate("1970-01-01T00:00:00Z"),
			"pingMs" : NumberLong(83),
			"lastHeartbeatMessage" : "",
			"syncSourceHost" : "",
			"syncSourceId" : -1,
			"infoMessage" : "",
			"configVersion" : -2,
			"configTerm" : -1
		},
		{
			"_id" : 2,
			"name" : "208.90.122.143:27017",
			"health" : 1,
			"state" : 0,
			"stateStr" : "STARTUP",
			"uptime" : 20,
			"optime" : {
				"ts" : Timestamp(0, 0),
				"t" : NumberLong(-1)
			},
			"optimeDurable" : {
				"ts" : Timestamp(0, 0),
				"t" : NumberLong(-1)
			},
			"optimeDate" : ISODate("1970-01-01T00:00:00Z"),
			"optimeDurableDate" : ISODate("1970-01-01T00:00:00Z"),
			"lastHeartbeat" : ISODate("2021-09-02T15:01:21.212Z"),
			"lastHeartbeatRecv" : ISODate("1970-01-01T00:00:00Z"),
			"pingMs" : NumberLong(184),
			"lastHeartbeatMessage" : "",
			"syncSourceHost" : "",
			"syncSourceId" : -1,
			"infoMessage" : "",
			"configVersion" : -2,
			"configTerm" : -1
		}
	],
	"ok" : 1,
	"$clusterTime" : {
		"clusterTime" : Timestamp(1630594860, 1),
		"signature" : {
			"hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
			"keyId" : NumberLong(0)
		}
	},
	"operationTime" : Timestamp(1630594860, 1)
}

```



查看复制集节点

```bash
mongodb_cluster:PRIMARY> rs.isMaster()
{
	"topologyVersion" : {
		"processId" : ObjectId("6130e389412eb5232ea1228d"),
		"counter" : NumberLong(6)
	},
	"hosts" : [
		"43.249.28.50:27017",
		"106.13.208.193:27017",
		"208.90.122.143:27017"
	],
	"setName" : "mongodb_cluster",
	"setVersion" : 1,
	"ismaster" : true,
	"secondary" : false,
	"primary" : "43.249.28.50:27017",
	"me" : "43.249.28.50:27017",
	"electionId" : ObjectId("7fffffff0000000000000001"),
	"lastWrite" : {
		"opTime" : {
			"ts" : Timestamp(1630631577, 1),
			"t" : NumberLong(1)
		},
		"lastWriteDate" : ISODate("2021-09-03T01:12:57Z"),
		"majorityOpTime" : {
			"ts" : Timestamp(1630631577, 1),
			"t" : NumberLong(1)
		},
		"majorityWriteDate" : ISODate("2021-09-03T01:12:57Z")
	},
	"maxBsonObjectSize" : 16777216,
	"maxMessageSizeBytes" : 48000000,
	"maxWriteBatchSize" : 100000,
	"localTime" : ISODate("2021-09-03T01:13:03.971Z"),
	"logicalSessionTimeoutMinutes" : 30,
	"connectionId" : 1,
	"minWireVersion" : 0,
	"maxWireVersion" : 13,
	"readOnly" : false,
	"ok" : 1,
	"$clusterTime" : {
		"clusterTime" : Timestamp(1630631577, 1),
		"signature" : {
			"hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
			"keyId" : NumberLong(0)
		}
	},
	"operationTime" : Timestamp(1630631577, 1)
}
mongodb_cluster:PRIMARY> 

```

## 部署用户认证登录（密钥对）

```bash
mongodb_cluster:PRIMARY> use admin
switched to db admin
mongodb_cluster:PRIMARY> db.createUser({"user":"root","pwd":"HyvBV2mb%8tf1kLx8DT%0TG7uEaKSuvbsD*9R0dXox1cXsqDH%1#Cd#%#Npjvp6Y","roles":["root"]})
Successfully added user: { "user" : "root", "roles" : [ "root" ] }


# 认证
use admin
db.auth("root", "HyvBV2mb%8tf1kLx8DT%0TG7uEaKSuvbsD*9R0dXox1cXsqDH%1#Cd#%#Npjvp6Y")

```



## MongoDB分片

**一、分片概述：**

**概述：**

分片（sharding）是指将数据库拆分，将其分散在不同的机器上的过程。分片集群（sharded cluster）是一种水平扩展数据库系统性能的方法，能够将数据集分布式存储在不同的分片（shard）上，每个分片只保存数据集的一部分，MongoDB保证各个分片之间不会有重复的数据，所有分片保存的数据之和就是完整的数据集。分片集群将数据集分布式存储，能够将负载分摊到多个分片上，每个分片只负责读写一部分数据，充分利用了各个shard的系统资源，提高数据库系统的吞吐量。

注：mongodb3.2版本后，分片技术必须结合复制集完成；

**应用场景：**

1.单台机器的磁盘不够用了，使用分片解决磁盘空间的问题。

2.单个mongod已经不能满足写数据的性能要求。通过分片让写压力分散到各个分片上面，使用分片服务器自身的资源。

3.想把大量数据放到内存里提高性能。和上面一样，通过分片使用分片服务器自身的资源。

 

**二、分片存储原理：**

![image-20210903102847105](https://raw.githubusercontent.com/adcwb/storages/master/image-20210903102847105.png)



**存储方式：**

数据集被拆分成数据块（chunk），每个数据块包含多个doc，数据块分布式存储在分片集群中。

**角色：**

**Config server**：MongoDB负责追踪数据块在shard上的分布信息，每个分片存储哪些数据块，叫做分片的元数据，保存在config server上的数据库 config中，一般使用3台config server，所有config server中的config数据库必须完全相同（建议将config server部署在不同的服务器，以保证稳定性）；

**Shard server**：将数据进行分片，拆分成数据块（chunk），每个trunk块的大小默认为64M，数据块真正存放的单位；

**Mongos server**：数据库集群请求的入口，所有的请求都通过mongos进行协调，查看分片的元数据，查找chunk存放位置，mongos自己就是一个请求分发中心，在生产环境通常有多mongos作为请求的入口，防止其中一个挂掉所有的mongodb请求都没有办法操作。

 

**总结：**

应用请求mongos来操作mongodb的增删改查，配置服务器存储数据库元信息，并且和mongos做同步，数据最终存入在shard（分片）上，为了防止数据丢失，同步在副本集中存储了一份，仲裁节点在数据存储到分片的时候决定存储到哪个节点。



**三、分片的片键；**

**概述：**

片键是文档的一个属性字段或是一个复合索引字段，一旦建立后则不可改变，片键是拆分数据的关键的依据，如若在数据极为庞大的场景下，片键决定了数据在分片的过程中数据的存储位置，直接会影响集群的性能；

注：创建片键时，需要有一个支撑片键运行的索引；



**片键分类：**

1、递增片键：使用时间戳，日期，自增的主键，ObjectId，_id等，此类片键的写入操作集中在一个分片服务器上，写入不具有分散性，这会导致单台服务器压力较大，但分割比较容易，这台服务器可能会成为性能瓶颈；

```bash
# 语法解析：
mongos> use 库名
mongos> db.集合名.ensureIndex({"键名":1})				##创建索引				
mongos> sh.enableSharding("库名")						##开启库的分片
mongos> sh.shardCollection("库名.集合名",{"键名":1})		##开启集合的分片并指定片键

```



2、哈希片键：也称之为散列索引，使用一个哈希索引字段作为片键，优点是使数据在各节点分布比较均匀，数据写入可随机分发到每个分片服务器上，把写入的压力分散到了各个服务器上。但是读也是随机的，可能会命中更多的分片，但是缺点是无法实现范围区分；



3、组合片键： 数据库中没有比较合适的键值供片键选择，或者是打算使用的片键基数太小（即变化少如星期只有7天可变化），可以选另一个字段使用组合片键，甚至可以添加冗余字段来组合；	



4、标签片键：数据存储在指定的分片服务器上，可以为分片添加tag标签，然后指定相应的tag，比如让10.*.*.*(T)出现在shard0000上，11.*.*.*(Q)出现在shard0001或shard0002上，就可以使用tag让均衡器指定分发；





## 案例：mongodb分片结合复制集高效存储



### 环境:

|      角色      |       ip       |    配置    |
| :------------: | :------------: | :--------: |
| Mongos server  | 192.168.10.241 |            |
| Config Server1 | 192.168.10.242 | 配置副本集 |
| Config Server2 | 192.168.10.243 |            |
| Shard server1  | 192.168.10.244 | 配置副本集 |
| Shard server2  | 192.168.10.245 |            |
| Shard server3  | 192.168.10.246 |            |



### 内核调优：

```bash
ulimit -n 25000
ulimit -u 25000 
echo 0 >/proc/sys/vm/zone_reclaim_mode
sysctl -w vm.zone_reclaim_mode=0
echo never >/sys/kernel/mm/transparent_hugepage/enabled 
echo never >/sys/kernel/mm/transparent_hugepage/defrag

```



### Mongos节点配置：

```bash
[root@config bin]# cat <<END >>/etc/mongodb/mongodb.conf
bind_ip=192.168.10.241
port=27017
logpath=/data/mongodb/logs/mongodb.log
fork=true
maxConns=5000
configdb=configs/192.168.10.242:27017,192.168.10.243:27017
END

# mongos的configdb参数只能指定一个（复制集中的primary）或多个（复制集中的全部节点）；
# mongos的实例可以配置多个，只要config节点的配置指定为同一个即可
# mongos相当于是一个入口文件，指定了config所在的位置
```



### Config节点配置：

```bash
[root@master2 ~]# cat <<END >>/etc/mongodb/mongodb.conf
bind_ip=192.168.10.242
port=27017
dbpath=/data/mongodb/data/
logpath=/data/mongodb/logs/mongodb.log
logappend=true
fork=true
maxConns=5000
replSet=configs
#replication name
configsvr=true
END

[root@master3 ~]# cat <<END >>/etc/mongodb/mongodb.conf
bind_ip=192.168.10.243
port=27017
dbpath=/data/mongodb/data/
logpath=/data/mongodb/logs/mongodb.log
logappend=true
fork=true
maxConns=5000
replSet=configs
#replication name
configsvr=true
END

# 配置副本集
>cfg={"_id":"configs","members":[{"_id":0,"host":"192.168.10.242:27017"},{"_id":1,"host":"192.168.10.243:27017"}]}

>rs.initiate(cfg)

configs:SECONDARY> rs.status()


```



### Shard节点配置：

```bash
[root@node1 ~]# cat <<END >>/etc/mongodb/mongodb.conf
bind_ip=192.168.10.244
port=27017
dbpath=/data/mongodb/data/
logpath=/data/mongodb/logs/mongodb.log
logappend=true
fork=true
maxConns=5000
replSet=shard1
#replication name
shardsvr=true
END


[root@node2 ~]# cat <<END >>/etc/mongodb/mongodb.conf
bind_ip=192.168.10.245
port=27017
dbpath=/data/mongodb/data/
logpath=/data/mongodb/logs/mongodb.log
logappend=true
fork=true
maxConns=5000
replSet=shard2
#replication name
shardsvr=true
END


[root@node3 ~]# cat <<END >>/etc/mongodb/mongodb.conf
bind_ip=192.168.10.246
port=27017
dbpath=/data/mongodb/data/
logpath=/data/mongodb/logs/mongodb.log
logappend=true
fork=true
maxConns=5000
replSet=shard3
#replication name
shardsvr=true
END


>cfg={"_id":"shards","members":[{"_id":0,"host":"192.168.10.244:27017"},{"_id":1,"host":"192.168.10.245:27017"},{"_id":2,"host":"192.168.10.246:27017"}]}

>rs.initiate(cfg)

configs:SECONDARY> rs.status()
```



### 配置mongos：

```bash
# 添加shards副本集，可以添加多个
mongos> db.runCommand({ addshard: 'shards/192.168.10.244:27017,192.168.10.245:27017,192.168.10.246:27017'})
{
        "shardAdded" : "shards",
        "ok" : 1,
        "operationTime" : Timestamp(1635913527, 4),
        "$clusterTime" : {
                "clusterTime" : Timestamp(1635913527, 4),
                "signature" : {
                        "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
                        "keyId" : NumberLong(0)
                }
        }
}

# 设置要切片的数据库
mongos> db.runCommand({ enablesharding: 'sd-wan'})
{
        "ok" : 1,
        "operationTime" : Timestamp(1635913932, 8),
        "$clusterTime" : {
                "clusterTime" : Timestamp(1635913932, 8),
                "signature" : {
                        "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
                        "keyId" : NumberLong(0)
                }
        }
}

# 开启数据库中集合的分片，同时会创建该数据库该集合
mongos> db.runCommand({ shardcollection: 'sd-wan.user', key: {_id: 1}})
{
        "collectionsharded" : "sd-wan.user",
        "collectionUUID" : UUID("af913b2b-ac6d-46e0-9bc6-0cbf3da7ce12"),
        "ok" : 1,
        "operationTime" : Timestamp(1635913959, 8),
        "$clusterTime" : {
                "clusterTime" : Timestamp(1635913959, 8),
                "signature" : {
                        "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
                        "keyId" : NumberLong(0)
                }
        }
}

```



### 测试分片是否开启：

```bash
mongos> use sd-wan
switched to db sd-wan

mongos> db.user.find();

mongos>  for(i=1;i<=10000;i++){db.user.insert({"id":i,"name":"huge"})};
WriteResult({ "nInserted" : 1 })

mongos> show collections
user

mongos> db.user.count()
10000

mongos> db.user.find();
{ "_id" : ObjectId("618211fb6fdca0485267ddb6"), "id" : 1, "name" : "huge" }
{ "_id" : ObjectId("618211fb6fdca0485267ddb7"), "id" : 2, "name" : "huge" }
{ "_id" : ObjectId("618211fb6fdca0485267ddb8"), "id" : 3, "name" : "huge" }
{ "_id" : ObjectId("618211fb6fdca0485267ddb9"), "id" : 4, "name" : "huge" }
{ "_id" : ObjectId("618211fb6fdca0485267ddba"), "id" : 5, "name" : "huge" }
{ "_id" : ObjectId("618211fb6fdca0485267ddbb"), "id" : 6, "name" : "huge" }
{ "_id" : ObjectId("618211fb6fdca0485267ddbc"), "id" : 7, "name" : "huge" }
{ "_id" : ObjectId("618211fb6fdca0485267ddbd"), "id" : 8, "name" : "huge" }
{ "_id" : ObjectId("618211fb6fdca0485267ddbe"), "id" : 9, "name" : "huge" }
{ "_id" : ObjectId("618211fb6fdca0485267ddbf"), "id" : 10, "name" : "huge" }
{ "_id" : ObjectId("618211fb6fdca0485267ddc0"), "id" : 11, "name" : "huge" }
{ "_id" : ObjectId("618211fb6fdca0485267ddc1"), "id" : 12, "name" : "huge" }
{ "_id" : ObjectId("618211fb6fdca0485267ddc2"), "id" : 13, "name" : "huge" }
{ "_id" : ObjectId("618211fb6fdca0485267ddc3"), "id" : 14, "name" : "huge" }
{ "_id" : ObjectId("618211fb6fdca0485267ddc4"), "id" : 15, "name" : "huge" }
{ "_id" : ObjectId("618211fb6fdca0485267ddc5"), "id" : 16, "name" : "huge" }
{ "_id" : ObjectId("618211fb6fdca0485267ddc6"), "id" : 17, "name" : "huge" }
{ "_id" : ObjectId("618211fb6fdca0485267ddc7"), "id" : 18, "name" : "huge" }
{ "_id" : ObjectId("618211fb6fdca0485267ddc8"), "id" : 19, "name" : "huge" }
{ "_id" : ObjectId("618211fb6fdca0485267ddc9"), "id" : 20, "name" : "huge" }
Type "it" for more

mongos> sh.status()
--- Sharding Status --- 
  sharding version: {
        "_id" : 1,
        "minCompatibleVersion" : 5,
        "currentVersion" : 6,
        "clusterId" : ObjectId("6182091350d25c808a1c9542")
  }
  shards:
        {  "_id" : "shards",  "host" : "shards/192.168.10.244:27017,192.168.10.245:27017,192.168.10.246:27017",  "state" : 1 }
  active mongoses:
        "4.4.10" : 2
  autosplit:
        Currently enabled: yes
  balancer:
        Currently enabled:  yes
        Currently running:  no
        Failed balancer rounds in last 5 attempts:  0
        Migration Results for the last 24 hours: 
                No recent migrations
  databases:
        {  "_id" : "config",  "primary" : "config",  "partitioned" : true }
                config.system.sessions
                        shard key: { "_id" : 1 }
                        unique: false
                        balancing: true
                        chunks:
                                shards  1024
                        too many chunks to print, use verbose if you want to force print
        {  "_id" : "sd-wan",  "primary" : "shards",  "partitioned" : true,  "version" : {  "uuid" : UUID("0e13cfd0-db20-4806-9501-3589446d0da9"),  "lastMod" : 1 } }
                sd-wan.user
                        shard key: { "name" : 1 }
                        unique: false
                        balancing: true
                        chunks:
                                shards  1
                        { "name" : { "$minKey" : 1 } } -->> { "name" : { "$maxKey" : 1 } } on : shards Timestamp(1, 0) 


mongos> db.user.stats()
{
        "sharded" : true,
        "capped" : false,
        "wiredTiger" : {
                "metadata" : {
                        "formatVersion" : 1
                },
                "creationString" : "access_pattern_hint=none,allocation_size=4KB,app_metadata=(formatVersion=1),assert=(commit_timestamp=none,durable_timestamp=none,read_timestamp=none,write_timestamp=off),block_allocation=best,block_compressor=snappy,cache_resident=false,checksum=on,colgroups=,collator=,columns=,dictionary=0,encryption=(keyid=,name=),exclusive=false,extractor=,format=btree,huffman_key=,huffman_value=,ignore_in_memory_cache_size=false,immutable=false,import=(enabled=false,file_metadata=,repair=false),internal_item_max=0,internal_key_max=0,internal_key_truncate=true,internal_page_max=4KB,key_format=q,key_gap=10,leaf_item_max=0,leaf_key_max=0,leaf_page_max=32KB,leaf_value_max=64MB,log=(enabled=false),lsm=(auto_throttle=true,bloom=true,bloom_bit_count=16,bloom_config=,bloom_hash_count=8,bloom_oldest=false,chunk_count_limit=0,chunk_max=5GB,chunk_size=10MB,merge_custom=(prefix=,start_generation=0,suffix=),merge_max=15,merge_min=0),memory_page_image_max=0,memory_page_max=10m,os_cache_dirty_max=0,os_cache_max=0,prefix_compression=false,prefix_compression_min=4,readonly=false,source=,split_deepen_min_child=0,split_deepen_per_child=0,split_pct=90,tiered_object=false,tiered_storage=(auth_token=,bucket=,bucket_prefix=,cache_directory=,local_retention=300,name=,object_target_size=10M),type=file,value_format=u,verbose=[],write_timestamp_usage=none",
                "type" : "file",
                "uri" : "statistics:table:collection-25--5750522000130823178",
                "LSM" : {
                        "bloom filter false positives" : 0,
                        "bloom filter hits" : 0,
                        "bloom filter misses" : 0,
                        "bloom filter pages evicted from cache" : 0,
                        "bloom filter pages read into cache" : 0,
                        "bloom filters in the LSM tree" : 0,
                        "chunks in the LSM tree" : 0,
                        "highest merge generation in the LSM tree" : 0,
                        "queries that could have benefited from a Bloom filter that did not exist" : 0,
                        "sleep for LSM checkpoint throttle" : 0,
                        "sleep for LSM merge throttle" : 0,
                        "total size of bloom filters" : 0
                },
                "block-manager" : {
                        "allocations requiring file extension" : 12,
                        "blocks allocated" : 12,
                        "blocks freed" : 1,
                        "checkpoint size" : 131072,
                        "file allocation unit size" : 4096,
                        "file bytes available for reuse" : 32768,
                        "file magic number" : 120897,
                        "file major version number" : 1,
                        "file size in bytes" : 180224,
                        "minor version number" : 0
                },
                "btree" : {
                        "btree checkpoint generation" : 52,
                        "btree clean tree checkpoint expiration time" : NumberLong("9223372036854775807"),
                        "column-store fixed-size leaf pages" : 0,
                        "column-store internal pages" : 0,
                        "column-store variable-size RLE encoded values" : 0,
                        "column-store variable-size deleted values" : 0,
                        "column-store variable-size leaf pages" : 0,
                        "fixed-record size" : 0,
                        "maximum internal page key size" : 368,
                        "maximum internal page size" : 4096,
                        "maximum leaf page key size" : 2867,
                        "maximum leaf page size" : 32768,
                        "maximum leaf page value size" : 67108864,
                        "maximum tree depth" : 3,
                        "number of key/value pairs" : 0,
                        "overflow pages" : 0,
                        "pages rewritten by compaction" : 0,
                        "row-store empty values" : 0,
                        "row-store internal pages" : 0,
                        "row-store leaf pages" : 0
                },
                "cache" : {
                        "bytes currently in the cache" : 1349804,
                        "bytes dirty in the cache cumulative" : 1341,
                        "bytes read into cache" : 0,
                        "bytes written from cache" : 602364,
                        "checkpoint blocked page eviction" : 0,
                        "checkpoint of history store file blocked non-history store page eviction" : 0,
                        "data source pages selected for eviction unable to be evicted" : 0,
                        "eviction gave up due to detecting an out of order on disk value behind the last update on the chain" : 0,
                        "eviction gave up due to detecting an out of order tombstone ahead of the selected on disk update" : 0,
                        "eviction gave up due to detecting an out of order tombstone ahead of the selected on disk update after validating the update chain" : 0,
                        "eviction gave up due to detecting out of order timestamps on the update chain after the selected on disk update" : 0,
                        "eviction walk passes of a file" : 0,
                        "eviction walk target pages histogram - 0-9" : 0,
                        "eviction walk target pages histogram - 10-31" : 0,
                        "eviction walk target pages histogram - 128 and higher" : 0,
                        "eviction walk target pages histogram - 32-63" : 0,
                        "eviction walk target pages histogram - 64-128" : 0,
                        "eviction walk target pages reduced due to history store cache pressure" : 0,
                        "eviction walks abandoned" : 0,
                        "eviction walks gave up because they restarted their walk twice" : 0,
                        "eviction walks gave up because they saw too many pages and found no candidates" : 0,
                        "eviction walks gave up because they saw too many pages and found too few candidates" : 0,
                        "eviction walks reached end of tree" : 0,
                        "eviction walks restarted" : 0,
                        "eviction walks started from root of tree" : 0,
                        "eviction walks started from saved location in tree" : 0,
                        "hazard pointer blocked page eviction" : 0,
                        "history store table insert calls" : 0,
                        "history store table insert calls that returned restart" : 0,
                        "history store table out-of-order resolved updates that lose their durable timestamp" : 0,
                        "history store table out-of-order updates that were fixed up by reinserting with the fixed timestamp" : 0,
                        "history store table reads" : 0,
                        "history store table reads missed" : 0,
                        "history store table reads requiring squashed modifies" : 0,
                        "history store table truncation by rollback to stable to remove an unstable update" : 0,
                        "history store table truncation by rollback to stable to remove an update" : 0,
                        "history store table truncation to remove an update" : 0,
                        "history store table truncation to remove range of updates due to key being removed from the data page during reconciliation" : 0,
                        "history store table truncation to remove range of updates due to out-of-order timestamp update on data page" : 0,
                        "history store table writes requiring squashed modifies" : 0,
                        "in-memory page passed criteria to be split" : 0,
                        "in-memory page splits" : 0,
                        "internal pages evicted" : 0,
                        "internal pages split during eviction" : 0,
                        "leaf pages split during eviction" : 0,
                        "modified pages evicted" : 0,
                        "overflow pages read into cache" : 0,
                        "page split during eviction deepened the tree" : 0,
                        "page written requiring history store records" : 0,
                        "pages read into cache" : 0,
                        "pages read into cache after truncate" : 1,
                        "pages read into cache after truncate in prepare state" : 0,
                        "pages requested from the cache" : 10013,
                        "pages seen by eviction walk" : 0,
                        "pages written from cache" : 8,
                        "pages written requiring in-memory restoration" : 0,
                        "tracked dirty bytes in the cache" : 0,
                        "unmodified pages evicted" : 0
                },
                "cache_walk" : {
                        "Average difference between current eviction generation when the page was last considered" : 0,
                        "Average on-disk page image size seen" : 0,
                        "Average time in cache for pages that have been visited by the eviction server" : 0,
                        "Average time in cache for pages that have not been visited by the eviction server" : 0,
                        "Clean pages currently in cache" : 0,
                        "Current eviction generation" : 0,
                        "Dirty pages currently in cache" : 0,
                        "Entries in the root page" : 0,
                        "Internal pages currently in cache" : 0,
                        "Leaf pages currently in cache" : 0,
                        "Maximum difference between current eviction generation when the page was last considered" : 0,
                        "Maximum page size seen" : 0,
                        "Minimum on-disk page image size seen" : 0,
                        "Number of pages never visited by eviction server" : 0,
                        "On-disk page image sizes smaller than a single allocation unit" : 0,
                        "Pages created in memory and never written" : 0,
                        "Pages currently queued for eviction" : 0,
                        "Pages that could not be queued for eviction" : 0,
                        "Refs skipped during cache traversal" : 0,
                        "Size of the root page" : 0,
                        "Total number of pages currently in cache" : 0
                },
                "checkpoint-cleanup" : {
                        "pages added for eviction" : 0,
                        "pages removed" : 0,
                        "pages skipped during tree walk" : 0,
                        "pages visited" : 2
                },
                "compression" : {
                        "compressed page maximum internal page size prior to compression" : 4096,
                        "compressed page maximum leaf page size prior to compression " : 131072,
                        "compressed pages read" : 0,
                        "compressed pages written" : 6,
                        "page written failed to compress" : 0,
                        "page written was too small to compress" : 2
                },
                "cursor" : {
                        "Total number of entries skipped by cursor next calls" : 0,
                        "Total number of entries skipped by cursor prev calls" : 0,
                        "Total number of entries skipped to position the history store cursor" : 0,
                        "Total number of times a search near has exited due to prefix config" : 0,
                        "bulk loaded cursor insert calls" : 0,
                        "cache cursors reuse count" : 10004,
                        "close calls that result in cache" : 10008,
                        "create calls" : 7,
                        "cursor next calls that skip due to a globally visible history store tombstone" : 0,
                        "cursor next calls that skip greater than or equal to 100 entries" : 0,
                        "cursor next calls that skip less than 100 entries" : 210,
                        "cursor prev calls that skip due to a globally visible history store tombstone" : 0,
                        "cursor prev calls that skip greater than or equal to 100 entries" : 0,
                        "cursor prev calls that skip less than 100 entries" : 1,
                        "insert calls" : 10000,
                        "insert key and value bytes" : 511426,
                        "modify" : 0,
                        "modify key and value bytes affected" : 0,
                        "modify value bytes modified" : 0,
                        "next calls" : 210,
                        "open cursor count" : 0,
                        "operation restarted" : 0,
                        "prev calls" : 1,
                        "remove calls" : 0,
                        "remove key bytes removed" : 0,
                        "reserve calls" : 0,
                        "reset calls" : 20021,
                        "search calls" : 0,
                        "search history store calls" : 0,
                        "search near calls" : 0,
                        "truncate calls" : 0,
                        "update calls" : 0,
                        "update key and value bytes" : 0,
                        "update value size change" : 0
                },
                "reconciliation" : {
                        "approximate byte size of timestamps in pages written" : 17376,
                        "approximate byte size of transaction IDs in pages written" : 0,
                        "dictionary matches" : 0,
                        "fast-path pages deleted" : 0,
                        "internal page key bytes discarded using suffix compression" : 9,
                        "internal page multi-block writes" : 0,
                        "internal-page overflow keys" : 0,
                        "leaf page key bytes discarded using prefix compression" : 0,
                        "leaf page multi-block writes" : 1,
                        "leaf-page overflow keys" : 0,
                        "maximum blocks required for a page" : 1,
                        "overflow values written" : 0,
                        "page checksum matches" : 0,
                        "page reconciliation calls" : 4,
                        "page reconciliation calls for eviction" : 0,
                        "pages deleted" : 0,
                        "pages written including an aggregated newest start durable timestamp " : 1,
                        "pages written including an aggregated newest stop durable timestamp " : 0,
                        "pages written including an aggregated newest stop timestamp " : 0,
                        "pages written including an aggregated newest stop transaction ID" : 0,
                        "pages written including an aggregated newest transaction ID " : 1,
                        "pages written including an aggregated oldest start timestamp " : 1,
                        "pages written including an aggregated prepare" : 0,
                        "pages written including at least one prepare" : 0,
                        "pages written including at least one start durable timestamp" : 1,
                        "pages written including at least one start timestamp" : 1,
                        "pages written including at least one start transaction ID" : 0,
                        "pages written including at least one stop durable timestamp" : 0,
                        "pages written including at least one stop timestamp" : 0,
                        "pages written including at least one stop transaction ID" : 0,
                        "records written including a prepare" : 0,
                        "records written including a start durable timestamp" : 1086,
                        "records written including a start timestamp" : 1086,
                        "records written including a start transaction ID" : 0,
                        "records written including a stop durable timestamp" : 0,
                        "records written including a stop timestamp" : 0,
                        "records written including a stop transaction ID" : 0
                },
                "session" : {
                        "object compaction" : 0,
                        "tiered operations dequeued and processed" : 0,
                        "tiered operations scheduled" : 0,
                        "tiered storage local retention time (secs)" : 0,
                        "tiered storage object size" : 0
                },
                "transaction" : {
                        "race to read prepared update retry" : 0,
                        "rollback to stable history store records with stop timestamps older than newer records" : 0,
                        "rollback to stable inconsistent checkpoint" : 0,
                        "rollback to stable keys removed" : 0,
                        "rollback to stable keys restored" : 0,
                        "rollback to stable restored tombstones from history store" : 0,
                        "rollback to stable restored updates from history store" : 0,
                        "rollback to stable skipping delete rle" : 0,
                        "rollback to stable skipping stable rle" : 0,
                        "rollback to stable sweeping history store keys" : 0,
                        "rollback to stable updates removed from history store" : 0,
                        "transaction checkpoints due to obsolete pages" : 0,
                        "update conflicts" : 0
                }
        },
        "ns" : "sd-wan.user",
        "count" : 10000,
        "size" : 490000,
        "storageSize" : 180224,
        "totalIndexSize" : 299008,
        "totalSize" : 479232,
        "indexSizes" : {
                "_id_" : 204800,
                "name_1" : 94208
        },
        "avgObjSize" : 49,
        "maxSize" : NumberLong(0),
        "nindexes" : 2,
        "nchunks" : 1,
        "shards" : {
                "shards" : {
                        "ns" : "sd-wan.user",
                        "size" : 490000,
                        "count" : 10000,
                        "avgObjSize" : 49,
                        "storageSize" : 180224,
                        "freeStorageSize" : 32768,
                        "capped" : false,
                        "wiredTiger" : {
                                "metadata" : {
                                        "formatVersion" : 1
                                },
                                "creationString" : "access_pattern_hint=none,allocation_size=4KB,app_metadata=(formatVersion=1),assert=(commit_timestamp=none,durable_timestamp=none,read_timestamp=none,write_timestamp=off),block_allocation=best,block_compressor=snappy,cache_resident=false,checksum=on,colgroups=,collator=,columns=,dictionary=0,encryption=(keyid=,name=),exclusive=false,extractor=,format=btree,huffman_key=,huffman_value=,ignore_in_memory_cache_size=false,immutable=false,import=(enabled=false,file_metadata=,repair=false),internal_item_max=0,internal_key_max=0,internal_key_truncate=true,internal_page_max=4KB,key_format=q,key_gap=10,leaf_item_max=0,leaf_key_max=0,leaf_page_max=32KB,leaf_value_max=64MB,log=(enabled=false),lsm=(auto_throttle=true,bloom=true,bloom_bit_count=16,bloom_config=,bloom_hash_count=8,bloom_oldest=false,chunk_count_limit=0,chunk_max=5GB,chunk_size=10MB,merge_custom=(prefix=,start_generation=0,suffix=),merge_max=15,merge_min=0),memory_page_image_max=0,memory_page_max=10m,os_cache_dirty_max=0,os_cache_max=0,prefix_compression=false,prefix_compression_min=4,readonly=false,source=,split_deepen_min_child=0,split_deepen_per_child=0,split_pct=90,tiered_object=false,tiered_storage=(auth_token=,bucket=,bucket_prefix=,cache_directory=,local_retention=300,name=,object_target_size=10M),type=file,value_format=u,verbose=[],write_timestamp_usage=none",
                                "type" : "file",
                                "uri" : "statistics:table:collection-25--5750522000130823178",
                                "LSM" : {
                                        "bloom filter false positives" : 0,
                                        "bloom filter hits" : 0,
                                        "bloom filter misses" : 0,
                                        "bloom filter pages evicted from cache" : 0,
                                        "bloom filter pages read into cache" : 0,
                                        "bloom filters in the LSM tree" : 0,
                                        "chunks in the LSM tree" : 0,
                                        "highest merge generation in the LSM tree" : 0,
                                        "queries that could have benefited from a Bloom filter that did not exist" : 0,
                                        "sleep for LSM checkpoint throttle" : 0,
                                        "sleep for LSM merge throttle" : 0,
                                        "total size of bloom filters" : 0
                                },
                                "block-manager" : {
                                        "allocations requiring file extension" : 12,
                                        "blocks allocated" : 12,
                                        "blocks freed" : 1,
                                        "checkpoint size" : 131072,
                                        "file allocation unit size" : 4096,
                                        "file bytes available for reuse" : 32768,
                                        "file magic number" : 120897,
                                        "file major version number" : 1,
                                        "file size in bytes" : 180224,
                                        "minor version number" : 0
                                },
                                "btree" : {
                                        "btree checkpoint generation" : 52,
                                        "btree clean tree checkpoint expiration time" : NumberLong("9223372036854775807"),
                                        "column-store fixed-size leaf pages" : 0,
                                        "column-store internal pages" : 0,
                                        "column-store variable-size RLE encoded values" : 0,
                                        "column-store variable-size deleted values" : 0,
                                        "column-store variable-size leaf pages" : 0,
                                        "fixed-record size" : 0,
                                        "maximum internal page key size" : 368,
                                        "maximum internal page size" : 4096,
                                        "maximum leaf page key size" : 2867,
                                        "maximum leaf page size" : 32768,
                                        "maximum leaf page value size" : 67108864,
                                        "maximum tree depth" : 3,
                                        "number of key/value pairs" : 0,
                                        "overflow pages" : 0,
                                        "pages rewritten by compaction" : 0,
                                        "row-store empty values" : 0,
                                        "row-store internal pages" : 0,
                                        "row-store leaf pages" : 0
                                },
                                "cache" : {
                                        "bytes currently in the cache" : 1349804,
                                        "bytes dirty in the cache cumulative" : 1341,
                                        "bytes read into cache" : 0,
                                        "bytes written from cache" : 602364,
                                        "checkpoint blocked page eviction" : 0,
                                        "checkpoint of history store file blocked non-history store page eviction" : 0,
                                        "data source pages selected for eviction unable to be evicted" : 0,
                                        "eviction gave up due to detecting an out of order on disk value behind the last update on the chain" : 0,
                                        "eviction gave up due to detecting an out of order tombstone ahead of the selected on disk update" : 0,
                                        "eviction gave up due to detecting an out of order tombstone ahead of the selected on disk update after validating the update chain" : 0,
                                        "eviction gave up due to detecting out of order timestamps on the update chain after the selected on disk update" : 0,
                                        "eviction walk passes of a file" : 0,
                                        "eviction walk target pages histogram - 0-9" : 0,
                                        "eviction walk target pages histogram - 10-31" : 0,
                                        "eviction walk target pages histogram - 128 and higher" : 0,
                                        "eviction walk target pages histogram - 32-63" : 0,
                                        "eviction walk target pages histogram - 64-128" : 0,
                                        "eviction walk target pages reduced due to history store cache pressure" : 0,
                                        "eviction walks abandoned" : 0,
                                        "eviction walks gave up because they restarted their walk twice" : 0,
                                        "eviction walks gave up because they saw too many pages and found no candidates" : 0,
                                        "eviction walks gave up because they saw too many pages and found too few candidates" : 0,
                                        "eviction walks reached end of tree" : 0,
                                        "eviction walks restarted" : 0,
                                        "eviction walks started from root of tree" : 0,
                                        "eviction walks started from saved location in tree" : 0,
                                        "hazard pointer blocked page eviction" : 0,
                                        "history store table insert calls" : 0,
                                        "history store table insert calls that returned restart" : 0,
                                        "history store table out-of-order resolved updates that lose their durable timestamp" : 0,
                                        "history store table out-of-order updates that were fixed up by reinserting with the fixed timestamp" : 0,
                                        "history store table reads" : 0,
                                        "history store table reads missed" : 0,
                                        "history store table reads requiring squashed modifies" : 0,
                                        "history store table truncation by rollback to stable to remove an unstable update" : 0,
                                        "history store table truncation by rollback to stable to remove an update" : 0,
                                        "history store table truncation to remove an update" : 0,
                                        "history store table truncation to remove range of updates due to key being removed from the data page during reconciliation" : 0,
                                        "history store table truncation to remove range of updates due to out-of-order timestamp update on data page" : 0,
                                        "history store table writes requiring squashed modifies" : 0,
                                        "in-memory page passed criteria to be split" : 0,
                                        "in-memory page splits" : 0,
                                        "internal pages evicted" : 0,
                                        "internal pages split during eviction" : 0,
                                        "leaf pages split during eviction" : 0,
                                        "modified pages evicted" : 0,
                                        "overflow pages read into cache" : 0,
                                        "page split during eviction deepened the tree" : 0,
                                        "page written requiring history store records" : 0,
                                        "pages read into cache" : 0,
                                        "pages read into cache after truncate" : 1,
                                        "pages read into cache after truncate in prepare state" : 0,
                                        "pages requested from the cache" : 10013,
                                        "pages seen by eviction walk" : 0,
                                        "pages written from cache" : 8,
                                        "pages written requiring in-memory restoration" : 0,
                                        "tracked dirty bytes in the cache" : 0,
                                        "unmodified pages evicted" : 0
                                },
                                "cache_walk" : {
                                        "Average difference between current eviction generation when the page was last considered" : 0,
                                        "Average on-disk page image size seen" : 0,
                                        "Average time in cache for pages that have been visited by the eviction server" : 0,
                                        "Average time in cache for pages that have not been visited by the eviction server" : 0,
                                        "Clean pages currently in cache" : 0,
                                        "Current eviction generation" : 0,
                                        "Dirty pages currently in cache" : 0,
                                        "Entries in the root page" : 0,
                                        "Internal pages currently in cache" : 0,
                                        "Leaf pages currently in cache" : 0,
                                        "Maximum difference between current eviction generation when the page was last considered" : 0,
                                        "Maximum page size seen" : 0,
                                        "Minimum on-disk page image size seen" : 0,
                                        "Number of pages never visited by eviction server" : 0,
                                        "On-disk page image sizes smaller than a single allocation unit" : 0,
                                        "Pages created in memory and never written" : 0,
                                        "Pages currently queued for eviction" : 0,
                                        "Pages that could not be queued for eviction" : 0,
                                        "Refs skipped during cache traversal" : 0,
                                        "Size of the root page" : 0,
                                        "Total number of pages currently in cache" : 0
                                },
                                "checkpoint-cleanup" : {
                                        "pages added for eviction" : 0,
                                        "pages removed" : 0,
                                        "pages skipped during tree walk" : 0,
                                        "pages visited" : 2
                                },
                                "compression" : {
                                        "compressed page maximum internal page size prior to compression" : 4096,
                                        "compressed page maximum leaf page size prior to compression " : 131072,
                                        "compressed pages read" : 0,
                                        "compressed pages written" : 6,
                                        "page written failed to compress" : 0,
                                        "page written was too small to compress" : 2
                                },
                                "cursor" : {
                                        "Total number of entries skipped by cursor next calls" : 0,
                                        "Total number of entries skipped by cursor prev calls" : 0,
                                        "Total number of entries skipped to position the history store cursor" : 0,
                                        "Total number of times a search near has exited due to prefix config" : 0,
                                        "bulk loaded cursor insert calls" : 0,
                                        "cache cursors reuse count" : 10004,
                                        "close calls that result in cache" : 10008,
                                        "create calls" : 7,
                                        "cursor next calls that skip due to a globally visible history store tombstone" : 0,
                                        "cursor next calls that skip greater than or equal to 100 entries" : 0,
                                        "cursor next calls that skip less than 100 entries" : 210,
                                        "cursor prev calls that skip due to a globally visible history store tombstone" : 0,
                                        "cursor prev calls that skip greater than or equal to 100 entries" : 0,
                                        "cursor prev calls that skip less than 100 entries" : 1,
                                        "insert calls" : 10000,
                                        "insert key and value bytes" : 511426,
                                        "modify" : 0,
                                        "modify key and value bytes affected" : 0,
                                        "modify value bytes modified" : 0,
                                        "next calls" : 210,
                                        "open cursor count" : 0,
                                        "operation restarted" : 0,
                                        "prev calls" : 1,
                                        "remove calls" : 0,
                                        "remove key bytes removed" : 0,
                                        "reserve calls" : 0,
                                        "reset calls" : 20021,
                                        "search calls" : 0,
                                        "search history store calls" : 0,
                                        "search near calls" : 0,
                                        "truncate calls" : 0,
                                        "update calls" : 0,
                                        "update key and value bytes" : 0,
                                        "update value size change" : 0
                                },
                                "reconciliation" : {
                                        "approximate byte size of timestamps in pages written" : 17376,
                                        "approximate byte size of transaction IDs in pages written" : 0,
                                        "dictionary matches" : 0,
                                        "fast-path pages deleted" : 0,
                                        "internal page key bytes discarded using suffix compression" : 9,
                                        "internal page multi-block writes" : 0,
                                        "internal-page overflow keys" : 0,
                                        "leaf page key bytes discarded using prefix compression" : 0,
                                        "leaf page multi-block writes" : 1,
                                        "leaf-page overflow keys" : 0,
                                        "maximum blocks required for a page" : 1,
                                        "overflow values written" : 0,
                                        "page checksum matches" : 0,
                                        "page reconciliation calls" : 4,
                                        "page reconciliation calls for eviction" : 0,
                                        "pages deleted" : 0,
                                        "pages written including an aggregated newest start durable timestamp " : 1,
                                        "pages written including an aggregated newest stop durable timestamp " : 0,
                                        "pages written including an aggregated newest stop timestamp " : 0,
                                        "pages written including an aggregated newest stop transaction ID" : 0,
                                        "pages written including an aggregated newest transaction ID " : 1,
                                        "pages written including an aggregated oldest start timestamp " : 1,
                                        "pages written including an aggregated prepare" : 0,
                                        "pages written including at least one prepare" : 0,
                                        "pages written including at least one start durable timestamp" : 1,
                                        "pages written including at least one start timestamp" : 1,
                                        "pages written including at least one start transaction ID" : 0,
                                        "pages written including at least one stop durable timestamp" : 0,
                                        "pages written including at least one stop timestamp" : 0,
                                        "pages written including at least one stop transaction ID" : 0,
                                        "records written including a prepare" : 0,
                                        "records written including a start durable timestamp" : 1086,
                                        "records written including a start timestamp" : 1086,
                                        "records written including a start transaction ID" : 0,
                                        "records written including a stop durable timestamp" : 0,
                                        "records written including a stop timestamp" : 0,
                                        "records written including a stop transaction ID" : 0
                                },
                                "session" : {
                                        "object compaction" : 0,
                                        "tiered operations dequeued and processed" : 0,
                                        "tiered operations scheduled" : 0,
                                        "tiered storage local retention time (secs)" : 0,
                                        "tiered storage object size" : 0
                                },
                                "transaction" : {
                                        "race to read prepared update retry" : 0,
                                        "rollback to stable history store records with stop timestamps older than newer records" : 0,
                                        "rollback to stable inconsistent checkpoint" : 0,
                                        "rollback to stable keys removed" : 0,
                                        "rollback to stable keys restored" : 0,
                                        "rollback to stable restored tombstones from history store" : 0,
                                        "rollback to stable restored updates from history store" : 0,
                                        "rollback to stable skipping delete rle" : 0,
                                        "rollback to stable skipping stable rle" : 0,
                                        "rollback to stable sweeping history store keys" : 0,
                                        "rollback to stable updates removed from history store" : 0,
                                        "transaction checkpoints due to obsolete pages" : 0,
                                        "update conflicts" : 0
                                }
                        },
                        "nindexes" : 2,
                        "indexBuilds" : [ ],
                        "totalIndexSize" : 299008,
                        "totalSize" : 479232,
                        "indexSizes" : {
                                "_id_" : 204800,
                                "name_1" : 94208
                        },
                        "scaleFactor" : 1,
                        "ok" : 1,
                        "$gleStats" : {
                                "lastOpTime" : Timestamp(0, 0),
                                "electionId" : ObjectId("7fffffff0000000000000001")
                        },
                        "lastCommittedOpTime" : Timestamp(1635916055, 1),
                        "$configServerState" : {
                                "opTime" : {
                                        "ts" : Timestamp(1635916062, 1),
                                        "t" : NumberLong(1)
                                }
                        },
                        "$clusterTime" : {
                                "clusterTime" : Timestamp(1635916062, 1),
                                "signature" : {
                                        "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
                                        "keyId" : NumberLong(0)
                                }
                        },
                        "operationTime" : Timestamp(1635916055, 1)
                }
        },
        "ok" : 1,
        "operationTime" : Timestamp(1635916055, 1),
        "$clusterTime" : {
                "clusterTime" : Timestamp(1635916062, 1),
                "signature" : {
                        "hash" : BinData(0,"AAAAAAAAAAAAAAAAAAAAAAAAAAA="),
                        "keyId" : NumberLong(0)
                }
        }
}

```

