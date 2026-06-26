---
title: "云原生-rook-ceph"
weight: 20
date: 2026-06-05
---

## 安装

```bash
$ git clone --single-branch --branch v1.14.0 https://github.com/rook/rook.git
cd rook/deploy/examples
kubectl create -f crds.yaml -f common.yaml -f operator.yaml
kubectl create -f cluster.yaml
```



### 创建RBD存储

```bash
$ kubectl create -f deploy/examples/csi/rbd/storageclass.yaml
```

### 创建CpehFS文件系统

- 创建文件系统

```yaml
# filesystem.yaml
apiVersion: ceph.rook.io/v1
kind: CephFilesystem
metadata:
  name: myfs
  namespace: rook-ceph
spec:
  metadataPool:
    replicated:
      size: 3
  dataPools:
    - name: replicated
      replicated:
        size: 3
  preserveFilesystemOnDelete: true
  metadataServer:
    activeCount: 1
    activeStandby: true
```



```bash
$ kubectl create -f filesystem.yaml
# 要确认文件系统已配置，请等待 mds pod 启动
$ kubectl -n rook-ceph get pod -l app=rook-ceph-mds
NAME                                      READY     STATUS    RESTARTS   AGE
rook-ceph-mds-myfs-7d59fdfcf4-h8kw9       1/1       Running   0          12s
rook-ceph-mds-myfs-7d59fdfcf4-kgkjp       1/1       Running   0          12s
# 调配存储，创建storageclass
$ kubectl create -f deploy/examples/csi/cephfs/storageclass.yaml
```

### 创建RGW存储

- 创建本地对象存储

 创建对象存储

```bash
$ kubectl create -f object.yaml
```

`object.yaml`

```yaml
apiVersion: ceph.rook.io/v1
kind: CephObjectStore
metadata:
  name: my-store
  namespace: rook-ceph
spec:
  metadataPool:
    failureDomain: host
    replicated:
      size: 3
  dataPool:
    failureDomain: host
    # For production it is recommended to use more chunks, such as 4+2 or 8+4
    erasureCoded:
      dataChunks: 2
      codingChunks: 1
  preservePoolsOnDelete: true
  gateway:
    sslCertificateRef:
    port: 80
    # securePort: 443
    instances: 1
```

要确认对象存储已配置，请等待 RGW pod 启动：

```bash
$ kubectl -n rook-ceph get pod -l app=rook-ceph-rgw
```

创建存储桶

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
   name: rook-ceph-bucket
# Change "rook-ceph" provisioner prefix to match the operator namespace if needed
provisioner: rook-ceph.ceph.rook.io/bucket
reclaimPolicy: Delete
parameters:
  objectStoreName: my-store
  objectStoreNamespace: rook-ceph
```

```bash
$ kubectl create -f storageclass-bucket-delete.yaml
```

创建桶的回收策略

```yaml
apiVersion: objectbucket.io/v1alpha1
kind: ObjectBucketClaim
metadata:
  name: ceph-bucket
spec:
  generateBucketName: ceph-bkt
  storageClassName: rook-ceph-bucket
```

```bash
$ kubectl create -f object-bucket-claim-delete.yaml
```





## 告警记录

最近有一个或多个Ceph守护进程崩溃，管理员尚未对该崩溃进行存档(确认)。这可能表示软件错误、硬件问题(例如，故障磁盘)或某些其它问题。

```bash
[root@master ~]# kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash
bash-4.4$ ceph status 
  cluster:
    id:     2517bd08-ceed-40ad-9e90-44dbfd3e6968
    health: HEALTH_WARN
            2 daemons have recently crashed
 
  services:
    mon: 3 daemons, quorum a,b,c (age 2h)
    mgr: a(active, since 2h), standbys: b
    mds: 1/1 daemons up, 1 hot standby
    osd: 3 osds: 3 up (since 2h), 3 in (since 13d)
    rgw: 1 daemon active (1 hosts, 1 zones)
 
  data:
    volumes: 1/1 healthy
    pools:   12 pools, 169 pgs
    objects: 2.12k objects, 6.2 GiB
    usage:   23 GiB used, 277 GiB / 300 GiB avail
    pgs:     169 active+clean
 
  io:
    client:   1.2 KiB/s rd, 1.2 MiB/s wr, 2 op/s rd, 67 op/s wr

```

系统中所有的崩溃可以通过以下方式列出：

```bash
bash-4.4$ ceph crash ls
ID                                                                ENTITY                NEW  
2024-04-10T13:16:13.626137Z_f7c0ffe9-a989-46ef-9118-73d198416610  mds.myfs-a             *   
2024-04-15T22:44:59.790580Z_4f5bfed0-b8fa-46f8-bdcd-99ab9a6f51aa  client.ceph-exporter   *   

```

新的崩溃可以通过以下方式列出：

```bash
bash-4.4$ ceph crash ls-new
```

有关特定崩溃的信息可以通过以下方式检查：

```bash
bash-4.4$ ceph crash info 2024-04-10T13:16:13.626137Z_f7c0ffe9-a989-46ef-9118-73d198416610
{
    "backtrace": [
        "/lib64/libpthread.so.0(+0x12d20) [0x7f804afa8d20]",
        "pthread_getname_np()",
        "(ceph::logging::Log::dump_recent()+0x4b8) [0x7f804c5d13f8]",
        "(MDSDaemon::respawn()+0x12b) [0x55f29e036bdb]",
        "(Context::complete(int)+0xd) [0x55f29e03d5fd]",
        "(MDSRank::respawn()+0x1c) [0x55f29e047b8c]",
        "ceph-mds(+0x1c193c) [0x55f29e04e93c]",
        "(Context::complete(int)+0xd) [0x55f29e03d5fd]",
        "(Finisher::finisher_thread_entry()+0x18d) [0x7f804c29cabd]",
        "/lib64/libpthread.so.0(+0x81ca) [0x7f804af9e1ca]",
        "clone()"
    ],
    "ceph_version": "18.2.2",
    "crash_id": "2024-04-10T13:16:13.626137Z_f7c0ffe9-a989-46ef-9118-73d198416610",
    "entity_name": "mds.myfs-a",
    "os_id": "centos",
    "os_name": "CentOS Stream",
    "os_version": "8",
    "os_version_id": "8",
    "process_name": "ceph-mds",
    "stack_sig": "815ea341707935b686a2542f788995258f33af401574b0f9475fed8863812dd1",
    "timestamp": "2024-04-10T13:16:13.626137Z",
    "utsname_hostname": "rook-ceph-mds-myfs-a-944c69db9-bxx4d",
    "utsname_machine": "x86_64",
    "utsname_release": "5.4.273-1.el7.elrepo.x86_64",
    "utsname_sysname": "Linux",
    "utsname_version": "#1 SMP Wed Mar 27 15:58:08 EDT 2024"
}

```

可以通过“存档”崩溃（可能是在管理员检查之后）来消除此警告，从而不会生成此警告：

```bash
bash-4.4$ ceph crash archive  2024-04-10T13:16:13.626137Z_f7c0ffe9-a989-46ef-9118-73d198416610

```

同样，所有新的崩溃都可以通过以下方式存档：

```bash
bash-4.4$ ceph crash archive-all
```

通过ceph crash ls仍然可以看到已存档的崩溃，但不是ceph crash ls-new即可看到。

默认 `recent` 是两周，这个参数可以通过 `mgr/crash/warn_recent_interval` 修改

检查ceph crash配置的recent间隔值

```bash
bash-4.4$ ceph config get mgr mgr/crash/warn_recent_interval
1209600
```

彻底关闭ceph crash记录近期告警

```bash
bash-4.4$ ceph config set mgr mgr/crash/warn_recent_interval 0
```



磁盘空间不足报错，已用空间大于70%

```shell
[root@master ~]# kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash
bash-4.4$ ceph status 
  cluster:
    id:     2517bd08-ceed-40ad-9e90-44dbfd3e6968
    health: HEALTH_WARN
            mon c is low on available space
 
  services:
    mon: 3 daemons, quorum a,b,c (age 90m)
    mgr: a(active, since 4w), standbys: b
    mds: 1/1 daemons up, 1 hot standby
    osd: 3 osds: 3 up (since 4w), 3 in (since 6w)
    rgw: 1 daemon active (1 hosts, 1 zones)
 
  data:
    volumes: 1/1 healthy
    pools:   12 pools, 169 pgs
    objects: 3.16k objects, 10 GiB
    usage:   33 GiB used, 267 GiB / 300 GiB avail
    pgs:     169 active+clean
 
  io:
    client:   1.2 KiB/s rd, 2 op/s rd, 0 op/s wr

```











