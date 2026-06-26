---
title: "Python 操作 Etcd"
weight: 2
date: 2026-06-23
tags: ["Python", "Etcd", "分布式", "KV存储"]
---

安装

```python
pip3 install etcd3
```



基本使用

```python
# 连接到Etcd
etcd = etcd3.client(host='192.168.202.206', port=2379, )

# 插入数据
etcd.put('/key1', 'etcd')
etcd.put("/key1/value1", "etcd1")

# 获取数据
data = etcd.get('/key1/value1')
print(data)
(b'etcd1', <etcd3.client.KVMetadata object at 0x000001A03554D2B0>)

print(data[0].decode('utf-8'))
etcd1

print(data[1])
<etcd3.client.KVMetadata object at 0x000001A03554D2B0>

# 其中第二个元素是etcd3.client.KVMetadata object 具有以下属性
print(data[1].create_revision)	# 返回 11
print(data[1].key)				# 返回 b'/key1/value1'
print(data[1].lease_id)			# 返回 0
print(data[1].mod_revision)		# 返回 43


# 代码实现如下所示
class KVMetadata(object):
    def __init__(self, keyvalue, header):
        self.key = keyvalue.key
        self.create_revision = keyvalue.create_revision
        self.mod_revision = keyvalue.mod_revision
        self.version = keyvalue.version
        self.lease_id = keyvalue.lease
        self.response_header = header


# 删除数据，删除成功会返回True，删除失败或键不存在返回False
etcd.delete('/key1/value1')

```



指定读取范围key

```python
import etcd3

etcd = etcd3.client(host='192.168.202.206', port=2379, )

etcd.put('/key1', 'etcd')
etcd.put('/key2', 'etcd2')
etcd.put('/key3', 'etcd3')
etcd.put('/key4', 'etcd4')
etcd.put('/key5', 'etcd5')
etcd.put('/key6', 'etcd6')

data = etcd.get_range('/key1', '/key6')

for i in data:
    print(i[1].key.decode('utf-8'), i[0].decode('utf-8'))

```



读取以某个字符串为前缀的key

```python
import etcd3

etcd = etcd3.client(host='192.168.202.206', port=2379, )

etcd.put('/key1', 'etcd')
etcd.put('/key2', 'etcd2')
etcd.put('/key3', 'etcd3')
etcd.put('/key4', 'etcd4')
etcd.put('/key5', 'etcd5')
etcd.put('/key6', 'etcd6')


data = etcd.get_prefix('/key')
# 此处注意，若没有加/的话，是匹配不到数据的
data = etcd.get_prefix('key')

for i in data:
    print(i[1].key.decode('utf-8'), i[0].decode('utf-8'))
```



删除以某个字符串为前缀的key

```python
etcd.delete_prefix('/key')
```





租约

```python
import time
import etcd3

etcd = etcd3.client(host='192.168.202.206', port=2379, )

# 创建新的租约
lease = etcd.lease(180)
# 创建key，并绑定到租约上
etcd.put(b'hello', b'world', lease=lease)

for i in range(180):
    time.sleep(1)
    # 获取租约信息
    print(etcd.get_lease_info(lease.id))
    
# 租约续租
etcd = etcd3.client(host='192.168.202.206', port=2379)
new_lease = etcd.lease(5)
print("new_lease:{}".format(new_lease.__str__()))
etcd.get_lease_info(new_lease.id)
print("get_lease_info:{}".format(etcd.get_lease_info(new_lease.id)))

# 如果租约到期，附加到该租约的所有密钥都将过期并删除。
# 可以发送租约保持活动消息以刷新 ttl。如果超时了的话续租仍然是可以成功的
for i in range(3):
    # 续租
    print("=========={}============".format(i))
    res = list(etcd.refresh_lease(new_lease.id))
    # 打印续租是否成功信息
    time.sleep(3)
    print("refresh_lease resp:{}".format(res))

    
# 撤销一个租约
import time
import etcd3

etcd = etcd3.client(host='192.168.202.206', port=2379, )

lease = etcd.lease(180)
etcd.put(b'hello', b'world', lease=lease)
for i in range(180):
    time.sleep(1)
    if i == 15:
        print(lease.id) # ID: 7587877290793662131
        etcd.revoke_lease(lease.id)
        break
    print(etcd.get_lease_info(lease.id))
```



watch使用

```python
import etcd3
import json
import time
etcd = etcd3.client(host='127.0.0.1', port=2379)

# 查看当前集群的kv
list_of_kv = list(etcd.get_all())
for value, kv_msg in list_of_kv:
    print("key:{}, value:{}" .format(kv_msg.key, value))
# key:b'key', value:b'hello'

# 对一个key进行watch
# 这里是阻塞的，我们在其他的程序中进行key的修改
events_iterator, cancel = etcd.watch('key')
for event in events_iterator:
    print(event)
print(cancel)
etcd.close()

---

import etcd3
import json
etcd = etcd3.client(host='127.0.0.1', port=2379)

# 修改key的value initial_value：key的原值， new_value：key的新值
# 若initial_value不等于原值或key不存在的时候，修改会失败的
print(etcd.replace('key', initial_value='hello', new_value='hello2'))
# 删除key
print(etcd.delete('key'))
etcd.close()

```



监视一系列key

```python
import etcd3
import json
import time
etcd = etcd3.client(host='127.0.0.1', port=2379)

print(etcd.put('demo/bar1', 'doot'))
print(etcd.put('demo/bar2', 'doot'))
print(etcd.put('demo/bar3', 'doot'))
print(etcd.put('demo/bar4', 'doot'))

# 查看当前集群的kv
list_of_kv = list(etcd.get_all())
for value, kv_msg in list_of_kv:
    print("key:{}, value:{}" .format(kv_msg.key, value))


# 对一个key进行watch
# 这里是阻塞的，我们在其他的程序中进行key的修改
events_iterator, cancel = etcd.watch_prefix('demo/')
for event in events_iterator:
    print(event)
print(cancel)
etcd.close()


# watch_prefix_once 只监听指定的key

```



取消watch监听

```python
import etcd3
import json
import time
etcd = etcd3.client(host='127.0.0.1', port=2379)

# 查看当前集群的kv
list_of_kv = list(etcd.get_all())
for value, kv_msg in list_of_kv:
    print("key:{}, value:{}" .format(kv_msg.key, value))
# key:b'key', value:b'hello'

# 对一个key进行watch
# 这里是阻塞的，我们在其他的程序中进行key的修改
cnt = 0
events_iterator, cancel = etcd.watch('key')
for event in events_iterator:
    cnt += 1
    print(event)
    print("handle times:{}" .format(cnt))
    if 3 == cnt:
        cancel() # cancel底层调用的就是cancel_watch(watchid)
        print("cancel watch")
etcd.close()

```



向watch加入回调函数

```python
import etcd3
import time
etcd = etcd3.client(host='127.0.0.1', port=2379)

def callback(resp):
    # resp is a events_iterator
    for event in resp.events:
        print("Key:{}发生改变, 新的value是:{}" .format(event.key, event.value))

etcd.add_watch_callback('key', callback)
# 程序主流程
while True:
    time.sleep(1)

```

