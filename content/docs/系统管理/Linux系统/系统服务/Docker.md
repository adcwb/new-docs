---
title: "Docker"
weight: 100
date: 2026-06-05
---

## CentOS 7 安装docker

安装yum工具类

```bash
yum install -y yum-utils device-mapper-persistent-data lvm2
```

启动docker源

```bash
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

安装docker

```bash
yum -y install docker-ce
```

国内配置镜像加速器

```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
"registry-mirrors": ["https://gziwmbaz.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```



## Ubuntu 安装docker

更新ubuntu的apt源,上面如果执行过可以忽略

```bash
sudo apt-get update
```

安装包允许apt通过HTTPS使用仓库

```bash
sudo apt-get install apt-transport-https ca-certificates curl software-properties-commo
```

添加Docker官方GPG key，网络不好的话，会报错，多执行几次即可。

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

设置Docker稳定版仓库，网络不好的话，会报错，多执行几次即可。

```bash
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```

添加Docker仓库后，更新apt源索引,注意，这里更新的源是关于docker的。

```bash
sudo apt-get update
```

安装最新版Docker CE（社区版）

```bash
sudo apt-get install docker-ce
```



检查Docker CE是否安装正确,hello-world是一个打印字符串的测试镜像，docker会自动下载

```bash
sudo docker run hello-world
```



## 安装脚本

```bash
#!/bin/bash


#安装网卡转发
echo '---------------------正在安装网卡转发---------------------'

cat <<EOF >  /etc/sysctl.d/docker.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward=1
EOF
sysctl -p /etc/sysctl.d/docker.conf

echo '成功！'

echo '---------------------------查看是否具备基本yum源----------------------'
#查看是否具有yum源
yum clean all && yum repolist
#安装docker yum源
echo '--------------------------即将为你安装docker yum 源---------------------'

curl -o /etc/yum.repos.d/docker-ce.repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
echo '成功！'

#安装指定版本的docker-ce
echo '--------------------即将为你安装docker--------------------------'

yum install -y docker-ce-18.09.9

#设置开机自启并启动docker
systemctl enable docker  
systemctl daemon-reload
systemctl start docker 
if [ $? ];then
exit
fi

#查看docker状态
echo '你的docker状态为:'
systemctl status docker
#即将为你配置docker源加速 如不需要请按 ctrl+z!
echo '================即将为你配置docker源加速 如不需要请按 ctrl+z!=================='

mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://gziwmbaz.mirror.aliyuncs.com"]    #这里可更改你的加速地址。
}
EOF
systemctl daemon-reload
systemctl restart docker
echo '安装完成！5秒后退出程序！'


# 配置文件
[root@www ~]# cat /usr/lib/systemd/system/docker.service
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket containerd.service

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3

# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not support it.
# Only systemd 226 and above support this option.
TasksMax=infinity

# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes

# kill only the docker process, not all processes in the cgroup
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target

```





## Docker常用命令

服务启动类

```bash
systemctl start docker		# 启动
systemctl start docker		# 重启
systemctl stop docker		# 关闭
systemctl enable docker		# 开机启动
systemctl dsiable docker	# 关闭开机启动
systemctl status docker		# 查看状态
```



资源查看类

```bash
docker search			# 从Docker Hub查找镜像
docker images			# 列出所有镜像(images)
docker ps				# 列出正在运行的容器(containers)
docker ps -a			# 列出所有的容器
docker pull images		# 下载centos镜像
docker push images		# 上传镜像
docker top ‘container’	# 查看容器内部运行程序
```



容器管理类

```bash
docker exec -it 			# 容器ID sh	进入容器
docker stop ‘container’		# 停止一个正在运行的容器，‘container’可以是容器ID或名称
docker start ‘container’	# 启动一个已经停止的容器
docker restart ‘container’	# 重启容器
docker rm ‘container’		# 删除容器
docker run -i -t -p :80 LAMP /bin/bash	# 运行容器并做http端口转发
docker exec -it ‘container’ /bin/bash	# 进入ubuntu类容器的bash
docker exec -it /bin/sh		# 进入alpine类容器的sh
docker rm docker ps -a -q	# 删除所有已经停止的容器
docker kill $(docker ps -a -q)	# 杀死所有正在运行的容器，$()功能同``
docker pause CONTAINER 		# 暂停容器中所有的进程。
docker unpause CONTAINER 	# 恢复容器中所有的进程。
docker create CONTAINER		# 创建一个新的容器但不启动它
docker commit				# 从容器创建一个新的镜像。
docker cp					# 用于容器与主机之间的数据拷贝。
docker diff 				# 检查容器里文件结构的更改。
```



镜像管理类

```bash
docker login		# 登陆到一个Docker镜像仓库，如果未指定镜像仓库地址，默认为官方仓库 Docker Hub
docker logout		# 登出一个Docker镜像仓库，如果未指定镜像仓库地址，默认为官方仓库 Docker Hub
docker login -u 用户名 -p 密码
docker build -t wp-api .		# 构建1个镜像,-t(镜像的名字及标签) wp-api(镜像名) .(构建的目录)
docker run -i -t wp-api			# -t -i以交互伪终端模式运行,可以查看输出信息
docker run -d -p 80:80 wp-api   # -p镜像端口 -d后台模式运行镜像
docker rmi $(docker images -q)	# 删除所有镜像， -f强制删除
docker rmi $(sudo docker images --filter "dangling=true" -q --no-trunc)	# 删除无用镜像
docker images		# 列出本地镜像。
docker history		# 查看指定镜像的创建历史。
docker tag 			# 标记本地镜像，将其归入某一仓库，原标签，新标签
docker save 		# 将指定镜像保存成 tar 归档文件 -o 输出到文件
docker load			# 导入使用 docker save 命令导出的镜像 -i指定导入的文件
docker import		# 从归档文件中创建镜像，和load几乎没有区别

```





## Dockerfile 的语法规则

Dockerfile 包含创建镜像所需要的全部指令。基于在 Dockerfile 中的指令，我们可以使用 `Docker build` 命令来创建镜像。通过减少镜像和容器的创建过程来简化部署。



Dockerfile 支持支持的语法命令如下：

```text
INSTRUCTION argument 
```

指令不区分大小写。但是，命名约定为全部大写。

所有 Dockerfile 都必须以 `FROM` 命令开始。`FROM` 命令会指定镜像基于哪个基础镜像创建，接下来的命令也会基于这个基础镜像（注：CentOS 和 Ubuntu 有些命令可是不一样的）。`FROM` 命令可以多次使用，表示会创建多个镜像。具体语法如下：

```text
FROM <image name>
```

例如：

```text
FROM ubuntu
```

上面的指定告诉我们，新的镜像将基于 Ubuntu 的镜像来构建。

继 `FROM` 命令，DockefFile 还提供了一些其它的命令以实现自动化。在文本文件或 Dockerfile 文件中这些命令的顺序就是它们被执行的顺序。



让我们了解一下这些有趣的 Dockerfile 命令吧。

- MAINTAINER：设置该镜像的作者。语法如下：

  ```text
  MAINTAINER <author name> 
  ```

- RUN：在 shell 或者 exec 的环境下执行的命令。`RUN`指令会在新创建的镜像上添加新的层面，接下来提交的结果用在Dockerfile的下一条指令中。语法如下：

  ```text
  RUN <command> 
  ```

- ADD：复制文件指令。它有两个参数 source 和 destination。destination 是容器内的路径。source 可以是 URL 或者是启动配置上下文中的一个文件。语法如下：

  ```text
  ADD <source> <destination> 
  ```

- CMD：提供了容器默认的执行命令。 Dockerfile 只允许使用一次 CMD 指令。 使用多个 CMD 会抵消之前所有的指令，只有最后一个指令生效。 CMD 有三种形式：

  ```text
  CMD ["executable","param1","param2"]
  CMD ["param1","param2"]
  CMD command param1 param2 
  ```

- EXPOSE：指定容器在运行时监听的端口。语法如下：

  ```text
  EXPOSE <port>
  ```

- ENTRYPOINT：配置给容器一个可执行的命令，这意味着在每次使用镜像创建容器时一个特定的应用程序可以被设置为默认程序。同时也意味着该镜像每次被调用时仅能运行指定的应用。类似于`CMD`，Docker只允许一个ENTRYPOINT，多个ENTRYPOINT会抵消之前所有的指令，只执行最后的ENTRYPOINT指令。语法如下：

  ```text
  ENTRYPOINT ["executable", "param1","param2"]
  ENTRYPOINT command param1 param2 
  ```

- WORKDIR：指定`RUN`、`CMD`与`ENTRYPOINT` 命令的工作目录。语法如下：

  ```text
  WORKDIR /path/to/workdir 
  ```

- ENV：设置环境变量。它们使用键值对，增加运行程序的灵活性。语法如下：

  ```text
  ENV <key> <value> 
  ```

- USER：镜像正在运行时设置一个 UID。语法如下：

  ```text
  USER <uid> 
  ```

- VOLUME：授权访问从容器内到主机上的目录。语法如下：

  ```text
  VOLUME ["/data"] 
  ```



## Dockerfile最佳实践

与使用的其他任何应用程序一样，总会有可以遵循的最佳实践。你可以阅读更多有关 Dockerfile 的最佳实践。以下是我们列出的基本的 Dockerfile 最佳实践：

- 保持常见的指令像 MAINTAINER 以及从上至下更新 Dockerfile 命令。
- 当构建镜像时使用可理解的标签，以便更好地管理镜像。
- 避免在 Dockerfile 中映射公有端口。
- CMD 与 ENTRYPOINT 命令请使用数组语法。



## DaoCloud 上的 Dockerfile 编写注意事项

DaoCloud 通过读取 Dockerfile 内容，和来自代码仓库的源代码，为用户构建 Docker 镜像。由于众所周知的原因，国内访问 Docker Hub 的速度令人无法忍受，因此国内常规网络环境下的 Docker 镜像构建速度非常缓慢。DaoCloud 采用非常先进的全球分布式构建引擎，有效缓缓解国内网络问题带来的构建延迟。DaoCloud 兼容 Dockerfile 的所有格式，但是有以下几个注意事项，需要开发者知晓：

- 如您在 Dockerfile 中需要更新 Linux 组件，或安装编程语言的依赖包等，请不要使用国内源，请使用您的 Linux 发行版和编程语言分发机制提供的默认更新源。
- 您可以在构建过程中看到完整的日志文件，如果构建出现问题，日志文件是排错的首选方式。
- 考虑到您的镜像会频繁构建，我们在构建服务器端开启了缓存，之前构建过的 Docker Image Layer 不会重新执行构建，完成和传输的速度也会更快。
- 我们设定了一个构建超时的时间。对于免费用户，构建时间上限是 1 小时，如果 1 小时内您的镜像构建仍未完成（通常是遇到构建问题并死锁），系统将取消您的构建任务；对于付费用户，这个超时时限是 3 小时。





## 镜像加速

由于运营商网络原因，会导致您拉取Docker Hub镜像变慢，甚至下载失败。因此需要配置镜像加速器，从而加速官方镜像的下载。

```bash
```





### 配置Docker运行时镜像加速器

在不同的操作系统下，配置加速器的方式略有不同，下文将介绍主要操作系统的配置方法。

#### **当您的Docker版本较新时**

当您下载安装的Docker Version不低于1.10时，建议通过daemon config进行配置。使用配置文件/etc/docker/daemon.json（没有时新建该文件）。

 

```json
{
    "registry-mirrors": ["<镜像加速器地址>"]
}            
```

然后重启Docker Daemon。

#### **当您的Docker版本较旧时**

您需要根据不同的操作系统修改对应的配置文件。

- Ubuntu 12.04 - 14.04

  Ubuntu的配置文件的位置在/etc/default/docker目录下。您只需要在这个配置文件中添加加速器的配置项，重启Docker即可。

   

  ```shell
  echo "DOCKER_OPTS=\"\$DOCKER_OPTS --registry-mirror=<your accelerate address>\"" | sudo tee -a /etc/default/docker
  sudo service docker restart            
  ```

- Ubuntu 15.04 - 15.10

  Ubuntu的配置文件的位置在/etc/systemd/system/docker.service.d/目录下。在这个目录下创建任意的*.conf文件即可作为配置文件。然后在这个配置文件中添加加速器的配置项，之后重启Docker即可。

   

  ```shell
  sudo mkdir -p /etc/systemd/system/docker.service.d
  sudo tee /etc/systemd/system/docker.service.d/mirror.conf <<-'EOF'
  [Service]
  ExecStart=
  ExecStart=/usr/bin/docker daemon -H fd:// --registry-mirror=<your accelerate address>
  EOF
  sudo systemctl daemon-reload
  sudo systemctl restart docker            
  ```

- CentOS 7

  CentOS的配置方式略微复杂，需要先将默认的配置文件（/lib/systemd/system/docker.service）复制到/etc/systemd/system/docker.service。然后再将加速器地址添加到配置文件的启动命令中，之后重启Docker即可。

   

  ```shell
  sudo cp -n /lib/systemd/system/docker.service /etc/systemd/system/docker.service
  sudo sed -i "s|ExecStart=/usr/bin/docker daemon|ExecStart=/usr/bin/docker daemon --registry-mirror=<your accelerate address>|g" /etc/systemd/system/docker.service
  sudo sed -i "s|ExecStart=/usr/bin/dockerd|ExecStart=/usr/bin/dockerd --registry-mirror=<your accelerate address>|g" /etc/systemd/system/docker.service
  sudo systemctl daemon-reload
  sudo service docker restart            
  ```

- Redhat 7

  Red Hat 7配置加速器，需要编辑/etc/sysconfig/docker配置文件。在`OPTIONS`配置项中添加加速器配置`--registry-mirror=<your accelerate address>`。最后执行`sudo service docker restart`命令以重启Docker Daemon。

- Redhat 6/CentOS 6

  在这两个系统上无法直接安装Docker，需要升级内核。

  配置加速器时需要编辑/etc/sysconfig/docker配置文件。 在`other_args`配置项中添加加速器配置`--registry-mirror=<your accelerate address>`。最后执行`sudo service docker restart`命令以重启Docker Daemon。

- Docker Toolbox

  在Windows、Mac系统上使用Docker Toolbox的话，推荐做法是在创建Linux虚拟机的时候，就将加速器的地址配置进去。

   

  ```shell
  docker-machine create --engine-registry-mirror=<your accelerate address> -d virtualbox default
  docker-machine env default
  eval "$(docker-machine env default)"
  docker info            
  ```

  如果您已经通过docker-machine创建了虚拟机的话，则需要通过登录该虚拟机来修改配置。

  1. 执行`docker-machine ssh <machine-name>`命令以登录虚拟机。
  2. 修改/var/lib/boot2docker/profile文件，将`--registry-mirror=<your accelerate address>`添加到`EXTRA_ARGS`中。
  3. 执行`sudo /etc/init.d/docker restart`命令以重启Docker服务。

### 配置Containerd运行时镜像加速器

Containerd通过在启动时指定一个配置文件夹，使后续所有镜像仓库相关的配置都可以在里面热加载，无需重启Containerd。

1. 在/etc/containerd/config.toml配置文件中插入如下**config_path**：

    

   ```shell
   config_path = "/etc/containerd/certs.d"
   ```

   **说明**

   /etc/containerd/config.toml非默认路径，您可以根据实际使用情况进行调整。

   1. 若已有`plugins."io.containerd.grpc.v1.cri".registry`，则在下面添加一行，注意要有Indent。若没有，则可以在任意地方写入。

       

      ```json
      [plugins."io.containerd.grpc.v1.cri".registry]
        config_path = "/etc/containerd/certs.d"
      ```

   2. 之后需要检查配置文件中是否有原有mirror相关的配置，如下：

       

      ```json
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
          endpoint = ["https://registry-1.docker.io"]
      ```

      若有原有mirror相关的配置，则需要清理。

   3. 执行**systemctl restart containerd**重启Containerd。

   4. 若启动失败，执行**journalctl -u containerd**检查为何失败，通常是配置文件仍有冲突导致，您可以依据报错做相应调整。

2. 在步骤一中指定的**config_path**路径中创建docker.io/hosts.toml文件。

   在文件中写入如下配置。

    

   ```json
   server = "https://registry-1.docker.io"
   
   [host."$(镜像加速器地址，如https://xxx.mirror.aliyuncs.com)"]
     capabilities = ["pull", "resolve", "push"]
   ```

3. 拉取Docker镜像验证加速是否生效。如未生效，请参见[Reference](https://github.com/containerd/containerd/blob/main/docs/hosts.md)。







## 查询Docker创建命令

给定一个现有的 docker 容器，打印运行其副本所需的命令行。

仓库地址：https://github.com/lavie/runlike

安装：`pip install runlike`



使用示例：`runlike -p $DOCKER_ID OR $DOCKER_NAME`

- -p: 将命令拆分成多行显示

```bash
root@node3:~# runlike -p casdoor
docker run --name=casdoor \
	--hostname=5b0a52f375d1 \
	--env='dataSourceName=root:Kaka_2022@tcp(192.168.202.206:32577)/' \
	--env=driverName=mysql \
	--workdir=/ \
	-p 8000:8000 \
	--runtime=runc \
	--detach=true \
	-t \
	casbin/casdoor:20241008-v1.723.0-dirty \
	/docker-entrypoint.sh

```

给它提供输出`docker inspect`也是可行的：

`docker inspect <container-name> | runlike --stdin`

```bash
root@node3:~# docker inspect casdoor | runlike --stdin -p
docker run --name=casdoor \
	--hostname=5b0a52f375d1 \
	--entrypoint /bin/bash \
	--env='dataSourceName=root:Kaka_2022@tcp(192.168.202.206:32577)/' \
	--env=driverName=mysql \
	--env=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
	--env=BUILDX_ARCH=linux_amd64 \
	--workdir=/ \
	-p 8000:8000 \
	--label='MAINTAINER=https://casdoor.org/' \
	--runtime=runc \
	--detach=true \
	-t \
	casbin/casdoor:20241008-v1.723.0-dirty \
	/docker-entrypoint.sh

```



## 构建空镜像

我们在使用Dockerfile构建docker镜像时，一种方式是使用官方预先配置好的容器镜像。优点是我们不用从头开始构建，节省了很多工作量，但付出的代价是需要下载很大的镜像包。若是需要构建的镜像尺寸尽可能的小，就需要用到scratch 镜像

scratch 的 Docker 官方镜像地址：https://hub.docker.com/_/scratch

官方说明：该镜像是一个空的镜像，可以用于构建基础镜像（例如 Debian、Busybox）或超小镜像，可以说是真正的从零开始构建属于自己的镜像。要知道，一个官方的ubuntu镜像有60MB+，CentOS镜像有70MB+。可以把一个可执行文件扔进来直接执行。



### 查看空镜像

可以通过命令`docker search scratch`查询到该镜像，但是无法直接pull下载

scratch 是一个 search 得到，但是 pull 不了的特殊镜像

```bash
# docker pull scratch
Using default tag: latest
Error response from daemon: 'scratch' is a reserved name
```

可以通过如下命令构建出一个大小为零的镜像

```bash
tar cv --files-from /dev/null | docker import - scratch
```





### 构建空镜像

需要先准备一个可执行的二进制文件

```go

import "fmt"

func main() {
	fmt.Println("Hello World")
}

// 编译命令：go build -o hello main.go 
// Docker 是go语言写的，C语言不行，跑的话会报错。
```

准备Dockerfile文件

```dockerfile
FROM scratch

ADD hello /
CMD ["/hello"]
```



构建镜像

```bash
# docker build -t hello .
[+] Building 23.2s (5/5) FINISHED                                                                                                                            
 => [internal] load build definition from Dockerfile                                                                                                         
 => => transferring dockerfile: 77B                                                                                                                          
 => [internal] load .dockerignore                                                                                                                            
 => => transferring context: 2B                                                                                                                              
 => [internal] load build context                                                                                                                            
 => => transferring context: 2.20MB                                                                                                                          
 => [1/1] ADD hello /                                                                                                                                        
 => exporting to image                                                                                                                                       
 => => exporting layers                                                                                                                                      
 => => writing image sha256:3220ed4b071d30f5c59ffba012b247664b019e8a29f205e6dc6ff91948be21a7                                                                 
 => => naming to docker.io/library/hello    

```



测试执行镜像

```bash
# docker run --rm hello
Hello World
```

