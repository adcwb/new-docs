---
title: "Python操作kubernetes"
weight: 70
date: 2026-06-23
---

## Python操作kubernetes集群资源

### 安装

仓库地址：https://github.com/kubernetes-client/python

文档参考：https://github.com/kubernetes-client/python/blob/master/kubernetes/README.md

#### pip安装模块

```bash
pip install kubernetes
```

#### 源码编译安装

```	BASH
git clone --recursive https://github.com/kubernetes-client/python.git
cd python
python setup.py install
```



### 认证信息

- 在使用 Kubernetes Python Client 之前，需要先加载本地计算机的 Kubernetes 配置文件。可以使用 `config.load_kube_config()` 方法来加载这个文件。这个方法默认会从本地计算机的 `$HOME/.kube/config` 文件中读取配置信息，并将其存储到 Python 运行时环境中。

```python
# 示例
from kubernetes import client, config

# 可以直接在配置类中设置配置，也可以使用辅助实用程序
# 默认加载 $HOME/.kube/config
config.load_kube_config()

# 实例化CoreV1Api，用于与 Kubernetes API 的核心 v1 版本进行交互。
v1 = client.CoreV1Api()

```



- 如果 Kubernetes 配置文件存储在其他位置，或者你需要连接多个 Kubernetes 集群，可以使用以下方式来加载配置文件：

```python
# 示例
from kubernetes import client, config

# 指定多个配置文件
config.load_kube_config(config_file=['/path/to/config1', '/path/to/config2'])

# 实例化CoreV1Api，用于与 Kubernetes API 的核心 v1 版本进行交互。
v1 = client.CoreV1Api()

```

- 若配置文件是存储在数据库中的，可以通过以下方式加载

```python
# 示例
import yaml
from kubernetes import client, config

# 从数据库中查询出记录
k8s_obj = K8sCluster.objects.get(id="1")

# 通过yaml模块加载配置文件并转化为字典格式
kubeconfig_dict = yaml.safe_load(kubecfg)

# 以字典的格式加载配置文件
config.load_kube_config_from_dict(config_dict=kubeconfig_dict)

# 实例化CoreV1Api，用于与 Kubernetes API 的核心 v1 版本进行交互。
v1 = client.CoreV1Api()
```





### 常用操作



#### ApisApi

- get_api_versions：查看API版本信息

```python
from kubernetes import client, config

config.load_kube_config()

api_instance = client.ApisApi()

api_response = api_instance.get_api_versions()
print(api_response)

```



#### AppsApi

- get_api_group：查看API分组

```python
from kubernetes import client, config

config.load_kube_config()

api_instance = client.AppsApi()

api_response = api_instance.get_api_group()
print(api_response)

```



#### AppsV1Api

##### Deployment相关

- list_namespaced_deployment：查看Deployment

```python
from datetime import datetime
import pytz
from kubernetes import client, config

# 指定配置文件路径
config.load_kube_config(config_file='config')

# 创建 Kubernetes API 客户端
api_instance = client.AppsV1Api()

namespaces = ['my-test', 'opx']  # 命名空间名称列表

# 遍历每个命名空间下的 Deployment 列表
for namespace in namespaces:
    deployment_list = api_instance.list_namespaced_deployment(namespace)

    # 输出命名空间名称
    print(f'NAMESPACE: {namespace}')

    # 打印表头
    print(f'{"NAME":10} {"READY":8} {"UP-TO-DATE":12} {"AVAILABLE":10} {"AGE":>5} {"CREATED AT":26}')

    # 遍历 Deployment 列表
    for deployment in deployment_list.items:
        name = deployment.metadata.name
        ready_replicas = deployment.status.ready_replicas or 0
        up_to_date_replicas = deployment.status.updated_replicas or 0
        available_replicas = deployment.status.available_replicas or 0
        created_at = deployment.metadata.creation_timestamp.timestamp()
        age = (datetime.now(pytz.utc).timestamp() - created_at) / 3600

        # 打印输出每个 Deployment 的名称、状态和年龄
        print(f'{name:10} {ready_replicas}/{deployment.spec.replicas or 0:<8} {up_to_date_replicas:<12} {available_replicas:<10} {age:>3.0f}h {datetime.fromtimestamp(created_at, pytz.utc).strftime("%Y-%m-%d %H:%M:%S %Z%z"):26}')

    # 输出分隔符
    print('-' * 100)
```



- create_namespaced_deployment：创建Deployment

```python
from kubernetes import client, config

config.load_kube_config(config_file='config')

v1 = client.CoreV1Api()
api_instance = client.AppsV1Api()

namespace = 'my-test'

# 创建 Deployment
deployment_manifest = {
    'apiVersion': 'apps/v1',
    'kind': 'Deployment',
    'metadata': {
        'name': 'myapp'
    },
    'spec': {
        'replicas': 1,
        'selector': {
            'matchLabels': {
                'app': 'myapp'
            }
        },
        'template': {
            'metadata': {
                'labels': {
                    'app': 'myapp'
                }
            },
            'spec': {
                'containers': [{
                    'name': 'mycontainer',
                    'image': 'nginx:latest',
                    'ports': [{
                        'containerPort': 80,
                        'hostPort': 80
                    }]
                }]
            }
        }
    }
}

# 检查 Deployment 是否已存在
try:
    api_instance.read_namespaced_deployment(name=deployment_manifest['metadata']['name'], namespace=namespace)
    print(f"Deployment '{deployment_manifest['metadata']['name']}' 已经存在.")
except client.exceptions.ApiException as e:
    if e.status == 404:
        resp = api_instance.create_namespaced_deployment(body=deployment_manifest, namespace=namespace)
        print("Deployment created. status='%s'" % resp.status)
    else:
        raise e

# 获取 Deployment 的名称和 Pod Selector
deployment_name = deployment_manifest['metadata']['name']
pod_selector = deployment_manifest['spec']['selector']['matchLabels']

# 检查 Deployment 是否成功创建
ready_replicas = 0
while ready_replicas < deployment_manifest['spec']['replicas']:
    deployments = api_instance.list_namespaced_deployment(namespace=namespace).items
    for deployment in deployments:
        if deployment.metadata.name == deployment_name:
            ready_replicas = deployment.status.ready_replicas or 0
            print(
                f"等待部署 '{deployment_name}' 有 {deployment_manifest['spec']['replicas']} 现成的副本 (当前副本数: {ready_replicas}个)...")
            break
    else:
        print(f"Deployment '{deployment_name}' not found, waiting...")
```



#### CoreApi

- get_api_versions：获取可用的 API 版本

```python
from __future__ import print_function
import time
import kubernetes.client
from kubernetes.client.rest import ApiException
from pprint import pprint


configuration = kubernetes.client.Configuration()
configuration.api_key['authorization'] = 'YOUR_API_KEY'

configuration.host = "http://localhost"

with kubernetes.client.ApiClient(configuration) as api_client:
    api_instance = kubernetes.client.CoreApi(api_client)
    
    try:
        api_response = api_instance.get_api_versions()
        pprint(api_response)
    except ApiException as e:
        print("Exception when calling CoreApi->get_api_versions: %s\n" % e)
```



#### CoreV1Api

##### Pod相关操作

- list_pod_for_all_namespaces：获取所有Pod信息

```python

from kubernetes import client, config

config.load_kube_config()

v1 = client.CoreV1Api()

ret = v1.list_pod_for_all_namespaces(watch=False)
for i in ret.items:
    print("%s\t%s\t%s" % (i.status.pod_ip, i.metadata.namespace, i.metadata.name))
```

- list_pod_for_all_namespaces：获取Pod信息，可通过指定名称空间来获取不同名称空间下的Pod信息

```python
from kubernetes import client, config

config.load_kube_config()

v1 = client.CoreV1Api()

# 指定名称空间
namespace = 'your-namespace'
namespaces = ['my-test', 'opx']  # 命名空间名称列表，可以同时查询多个名称空间

# 获取 Pod 列表
ret = v1.list_namespaced_pod(namespace)

# 遍历 Pod 列表
for i in ret.items:
    print("%s\t%s\t%s" % (i.status.pod_ip, i.metadata.namespace, i.metadata.name))
```

- patch_namespaced_pod：更新指定Pod信息

```python
from __future__ import print_function
import time
import kubernetes.client
from kubernetes.client.rest import ApiException
from pprint import pprint

configuration = kubernetes.client.Configuration()
configuration.api_key['authorization'] = 'YOUR_API_KEY'
configuration.host = "http://localhost"

with kubernetes.client.ApiClient(configuration) as api_client:
    api_instance = kubernetes.client.CoreV1Api(api_client)

# 指定Pod名称和所在的名称空间
name = 'name_example
namespace = 'namespace_example'

body = None 
pretty = 'pretty_example' 
dry_run = 'dry_run_example' 
field_manager = 'field_manager_example'
field_validation = 'field_validation_example'

api_response = api_instance.patch_namespaced_pod(name, namespace, body, pretty=pretty, dry_run=dry_run, field_manager=field_manager, field_validation=field_validation, force=force)

```



- delete_namespaced_pod：删除pod

```python
from kubernetes import client, config

# 加载 Kubernetes 配置
config.load_kube_config()

# 创建 Kubernetes API 客户端
v1 = client.CoreV1Api()

# 指定 Pod 的命名空间和名称
namespace = 'your-namespace'
name = 'your-pod-name'

# 删除 Pod
v1.delete_namespaced_pod(name, namespace)
```

>需要注意的是，删除 Pod 操作是不可逆的，一旦删除了一个 Pod，将无法恢复。因此，在执行删除操作之前，请确保你已经备份了相关数据，并且已经确认该操作不会对应用程序产生不良影响。



- create_namespaced_pod：创建pod

```python 
from kubernetes import client, config

config.load_kube_config(config_file='/tmp/config')

v1 = client.CoreV1Api()
api_instance = client.CoreV1Api()

namespace = 'my-test'

# 创建 Pod
pod_manifest = {
    'apiVersion': 'v1',
    'kind': 'Pod',
    'metadata': {
        'name': 'mypod'
    },
    'spec': {
        'containers': [{
            'name': 'mycontainer',
            'image': 'nginx:latest',
            'ports': [{
                'containerPort': 80,
                'hostPort': 80
            }]
        }]
    }
}
resp = v1.create_namespaced_pod(body=pod_manifest, namespace=namespace)
print("Pod created. status='%s'" % resp.status.phase)
```



##### Service相关操作

- create_namespaced_service：创建Service

```python
from kubernetes import client, config

config.load_kube_config(config_file='/tmp/config')

v1 = client.CoreV1Api()
api_instance = client.CoreV1Api()

namespace = 'my-test'

# 创建 Service
service_manifest = {
    'apiVersion': 'v1',
    'kind': 'Service',
    'metadata': {
        'name': 'myservice'
    },
    'spec': {
        'selector': {
            'app': 'myapp'
        },
        'ports': [{
            'protocol': 'TCP',
            'port': 80,
            'targetPort': 80,
            'nodePort': 30001
        }],
        'type': 'NodePort'
    }
}
resp = api_instance.create_namespaced_service(
    body=service_manifest,
    namespace=namespace)
print("Service created. status='%s'" % resp)
```



- list_namespaced_service：查看Service

```python
from kubernetes import client, config

config.load_kube_config(config_file='/tmp/config')

v1 = client.CoreV1Api()
api_instance = client.CoreV1Api()

namespace = 'my-test'

resp = api_instance.list_namespaced_service(namespace=namespace)
print("Service list. status='%s'" % resp)
```







#### NetworkingApi



#### NetworkingV1Api



#### StorageApi



#### StorageV1Api





#### 示例

```python
import json

import yaml
from kubernetes import client, config, utils
from kubernetes.client.rest import ApiException
from kubernetes.client import ApiClient, V1Deployment
from integration.models import K8sCluster
from utils.tools.SpecialString import CryptographyV2


class KubernetesDeployer:
    """
    K8s部署工具类
    """
    def __init__(self, cluster="k8s-pet"):
        # 加载K8s配置
        k8s_obj = K8sCluster.objects.filter(name=cluster).first()
        p = CryptographyV2()
        if not k8s_obj:
            config.load_kube_config()  # 本地开发使用
        else:
            kubecfg = p.decrypt(k8s_obj.kubeconfig)
            kubeconfig_dict = yaml.safe_load(kubecfg)
            config.load_kube_config_from_dict(config_dict=kubeconfig_dict)

        self.api_instance = client.AppsV1Api()
        self.coreapi_instance = client.CoreV1Api()
        self.storageapi_instance = client.StorageV1Api()
        self.networking_instance = client.NetworkingV1Api()
        self.batch_instance = client.BatchV1Api()


    def get_api_instance(self):
        """返回实例化的AppsV1Api"""
        return self.api_instance

    def get_coreapi_instance(self):
        """返回实例化的CoreV1Api"""
        return self.coreapi_instance

    def get_storageapi_instance(self):
        """返回实例化的StorageV1Api"""
        return self.storageapi_instance

    def get_networking_instance(self):
        """返回实例化的NetworkingV1Api"""
        return self.networking_instance

    def get_batch_instance(self):
        """返回实例化的BatchV1Api"""
        return self.batch_instance

    def apply(self, resource_type, namespace, resource_yaml):
        """通用部署接口，通过接收资源类型和YAML自动部署"""

        if resource_type == "deployment":
            return self.apply_deployment(namespace, resource_yaml)
        elif resource_type == "service":
            return self.apply_service(namespace, resource_yaml)
        elif resource_type == "storage":
            return self.apply_storage(namespace, resource_yaml)
        elif resource_type == "ingress":
            return self.apply_ingress(namespace, resource_yaml)
        else:
            return {"success": False, "error": "暂不支持的类型！"}

    def apply_any(self, yaml_path):
        """
        直接应用任意 YAML 文件到 K8s 集群
        """
        try:
            # 使用 utils.create_from_yaml 来应用资源
            utils.create_from_yaml(ApiClient(), yaml_path)
            return {"success": True, "message": "YAML 文件应用成功"}
        except ApiException as e:
            return {"success": False, "error": str(e)}

    def apply_deployment(self, namespace, deployment_yaml):
        """应用Deployment到K8s集群"""

        try:
            deployment = client.V1Deployment(
                api_version=deployment_yaml.get('apiVersion', 'v1'),
                kind=deployment_yaml.get('kind', 'Service'),
                metadata=deployment_yaml.get('metadata', {}),
                spec=deployment_yaml.get('spec', {})
            )

            # 若存在则更新，否则创建
            try:
                existing = self.api_instance.read_namespaced_deployment(
                    name=deployment_yaml.get("metadata").get("name"),
                    namespace=namespace
                )

                result = self.api_instance.patch_namespaced_deployment(
                    name=deployment_yaml.get("metadata").get("name"),
                    namespace=namespace,
                    body=deployment
                )
                action = "updated"
            except ApiException as e:
                if e.status == 404:
                    result = self.api_instance.create_namespaced_deployment(
                        namespace=namespace,
                        body=deployment
                    )
                    action = "created"
                else:
                    raise
            return {"success": True, "action": action, "result": result.to_dict()}
        except ApiException as e:
            return {"success": False, "error": str(e), "status": e.status}

    def apply_service(self, namespace, service_yaml):
        """ 应用Service到K8s集群"""
        try:
            service = client.V1Service(
                api_version=service_yaml.get('apiVersion', 'apps/v1'),
                kind=service_yaml.get('kind', 'Deployment'),
                metadata=service_yaml.get('metadata', {}),
                spec=service_yaml.get('spec', {})
            )

            try:
                existing = self.coreapi_instance.read_namespaced_service(
                    name=service_yaml.get("metadata").get("name"),
                    namespace=namespace
                )

                result = self.coreapi_instance.patch_namespaced_service(
                    name=service_yaml.get("metadata").get("name"),
                    namespace=namespace,
                    body=service
                )
                action = "updated"
            except ApiException as e:
                if e.status == 404:
                    result = self.coreapi_instance.create_namespaced_service(
                        namespace=namespace,
                        body=service
                    )
                    action = "created"
                else:
                    raise
            return {"success": True, "action": action, "result": result.to_dict()}
        except ApiException as e:
            return {"success": False, "error": str(e), "status": e.status}

    def apply_storage(self, namespace, pvc_yaml):
        """部署PVC资源"""
        try:
            pvc = client.V1PersistentVolumeClaim(
                api_version=pvc_yaml.get('apiVersion', 'v1'),
                kind=pvc_yaml.get('kind', 'PersistentVolumeClaim'),
                metadata=pvc_yaml.get('metadata', {}),
                spec=pvc_yaml.get('spec', {})
            )

            try:
                pvc = self.coreapi_instance.read_namespaced_persistent_volume_claim(
                    name=pvc_yaml.get("metadata").get("name"),
                    namespace=namespace
                )
                # 更新
                result = self.coreapi_instance.patch_namespaced_persistent_volume_claim(
                    name=pvc_yaml.get("metadata").get("name"),
                    namespace=namespace,
                    body=pvc
                )
                action = "updated"
            except ApiException as e:
                if e.status == 404:
                    # 创建
                    result = self.coreapi_instance.create_namespaced_persistent_volume_claim(
                        namespace=namespace,
                        body=pvc
                    )
                    action = "created"
                else:
                    return {"success": False, "error": str(e)}

            return {"success": True, "action": action, "result": result.to_dict()}
        except ApiException as e:
            return {"success": False, "error": str(e), "status": e.status}

    def apply_ingress(self, namespace, ingress_yaml):
        """部署Ingress资源"""
        try:
            ingress = client.V1Ingress(
                api_version=ingress_yaml.get('apiVersion', 'networking.k8s.io/v1'),
                kind=ingress_yaml.get('kind', 'Ingress'),
                metadata=ingress_yaml.get('metadata', {}),
                spec=ingress_yaml.get('spec', {})
            )

            try:
                ingress = self.networking_instance.read_namespaced_ingress(
                    name=ingress_yaml.get("metadata").get("name"),
                    namespace=namespace
                )
                # 更新
                result = self.networking_instance.patch_namespaced_ingress(
                    name=ingress_yaml.get("metadata").get("name"),
                    namespace=namespace,
                    body=ingress
                )
                action = "updated"

            except ApiException as e:
                if e.status == 404:
                    # 创建
                    result = self.networking_instance.create_namespaced_ingress(
                        namespace=namespace,
                        body=ingress
                    )
                    action = "created"
                else:
                    return {"success": False, "error": str(e)}
            return {"success": True, "action": action, "result": result.to_dict()}

        except ApiException as e:
            return {"success": False, "error": str(e), "status": e.status}

    def delete(self, resource_type, namespace, name):
        """通用删除资源接口"""
        try:
            if resource_type == "deployment":
                return self.delete_deployment(namespace, name)
            elif resource_type == "service":
                return self.delete_service(namespace, name)
            elif resource_type == "storage":
                return self.delete_storage(namespace, name)
            elif resource_type == "ingress":
                return self.delete_ingress(namespace, name)
            else:
                return {"success": False, "error": "Unsupported resource type"}
        except ApiException as e:
            return {"success": False, "error": str(e), "status": e.status}


    def delete_deployment(self, namespace, name):
        """删除Deployment"""
        try:
            result = self.api_instance.delete_namespaced_deployment(
                name=name,
                namespace=namespace
            )
            return {"success": True, "result": result.to_dict()}
        except ApiException as e:
            return {"success": False, "error": str(e), "status": e.status}

    def delete_service(self, namespace, name):
        """删除Service"""
        try:
            result = self.coreapi_instance.delete_namespaced_service(
                name=name,
                namespace=namespace
            )
            return {"success": True, "result": result.to_dict()}
        except ApiException as e:
            return {"success": False, "error": str(e), "status": e.status}

    def delete_storage(self, name, namespace):
        """删除PersistentVolumeClaim"""

        try:
            result = self.coreapi_instance.delete_namespaced_persistent_volume_claim(
                name=name,
                namespace=namespace
            )
            return {"success": True, "result": result.to_dict()}
        except ApiException as e:
            return {"success": False, "error": str(e), "status": e.status}

    def delete_ingress(self, namespace, name):
        """ 删除Ingress"""

        try:
            result = self.networking_instance.delete_namespaced_ingress(
                name=name,
                namespace=namespace
            )
            return {"success": True, "result": result.to_dict()}
        except ApiException as e:
            return {"success": False, "error": str(e), "status": e.status}
```


