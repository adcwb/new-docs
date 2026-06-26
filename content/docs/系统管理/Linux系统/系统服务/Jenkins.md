---
title: "Jenkins"
weight: 130
date: 2026-06-05
---

## Jenkins 安装

CentOS 7 安装方式如下，前提是保证有 JDK 环境：

```bash
$ sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
$ sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
$ sudo yum install jenkins
```

启动：

```bash
$ sudo systemctl enable jenkins
$ sudo systemctl start jenkins
```

查看状态：

```bash
$ sudo systemctl status jenkins
```

默认的配置文件是：`/etc/sysconfig/jenkins`

web界面地址默认是：http://localhost:8080/

初始密码默认在 `/var/lib/jenkins/secrets/initialAdminPassword` 中。用户名是 admin。

修改端口，在文件 `/etc/sysconfig/jenkins` 中：

```text
JENKINS_PORT="18080"
```

在 `/var/lib/jenkins/hudson.model.UpdateCenter.xml` 中，可以配置插件地址。

默认地址是：https://updates.jenkins.io/update-center.json

现在新版本修改插件地址还是有点麻烦的。

不过可以在 Jenkins 中可以设置代理。



## Git 提交触发 Jenkins 自动构建

在 Jenkins 中，需要安装 Gihub 插件，这里安装过程略过，配置好代理还是很好下载的。

### 获取 GitHub 的 Personal access token

在 Github 的 Setting -> Developer settings -> Personal access tokens 中，点击 Generate new token 按钮，然后配置如下：

![image-20200801141606574](https://xujiyou.work/resource/image-20200801141606574.png)

然后点击下面的按钮生成一个 Token，记住这个 Token，比如：228805e1c15e81ecc6107220db7b94fcaaf28ab3

**一定要保存，后面就看不到了**

### 配置 Jenkins

在 Manage Jenkins -> Configure System 中配置 Github。如下：

![image-20200801142050988](https://xujiyou.work/resource/image-20200801142050988.png)

![image-20200801142125786](https://xujiyou.work/resource/image-20200801142125786.png)

我这里在使用连接测试时，报错说连不上，一气之前就不用 Secret Text 了，而是用的 Username and Password。

### 在 GIthub 项目中配置 webhook

在 Github 中，做出如下配置：

![image-20200801153413437](https://xujiyou.work/resource/image-20200801153413437.png)

注意这里的 url 要是一个公网地址。

http://118.1.2.3:8080/github-webhook/ 是一个固定的格式，替换 ip 地址即可。

### 在 Jenkins 中添加项目

在创建项目时 github 库的配置如下：

![image-20200801153710157](https://xujiyou.work/resource/image-20200801153710157.png)

当遇到 push 时，执行以下命令：

![image-20200801153847812](https://xujiyou.work/resource/image-20200801153847812.png)

这里要注意命令是不是在 Jenkins 的 PATH 中，可以在 Jenkins 中设置 PATH 的环境变量，将命令加入进去。这个 WORKSPACE 就是 Jenkins 下载到本地的代码地址。

```bash
echo $WORKSPACE
generate-md --layout /opt/blog/my-layout --input $WORKSPACE --output /opt/blog/output
```

默认 $WORKSPACE 是 `/var/lib/jenkins/workspace/`