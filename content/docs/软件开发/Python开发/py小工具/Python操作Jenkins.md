---
title: "Python 操作 Jenkins"
weight: 3
date: 2026-06-23
tags: ["Python", "Jenkins", "CI/CD", "自动化"]
---

Python操作Jenkins

```bash
# 官网
	https://python-jenkins.readthedocs.io/en/latest/api.html

# 安装
	pip install python-jenkins
```



示例：获取Jenkins版本号

```python
import jenkins

jenkins_cli = jenkins.Jenkins('http://192.168.202.203:31265', username='admin', password='123456')
user = jenkins_cli.get_whoami()
version = jenkins_cli.get_version()
print('Hello %s from Jenkins %s' % (user['fullName'], version))

Hello admin from Jenkins 2.448

```



Jenkins安装

```bash
mkdir -p /data/devops6/jenkins_home
chmod 777 -R  /data/devops6/jenkins_home

docker run -itd --name jenkins \
-p 8080:8080 \
-p 50000:50000 \
-e JAVA_OPTS="-Dorg.apache.commons.jelly.tags.fmt.timeZone='Asia/Shanghai'" \
--privileged=true  \
--restart=always \
-v /data/devops6/jenkins_home:/var/jenkins_home jenkins/jenkins:2.346.3-2-lts-jdk11
```

Jenkins启动后会读取JENKINS_HOME变量(/var/lib/jenkins)，根据次变量的值来决定数据存储的位置。Jenkins是以XML格式的文件存储到数据目录。





Jenkins目录的用途:

- caches: 系统缓存数据
- jobs： Jenkins项目作业
- nodes： Jenkins slave节点信息
- secrets： 秘钥信息
- userContent： 类似于web站点目录，可以上传一些文件
- workspace： 默认的工作目录
- fingerprints： 指纹验证信息
- logs ： 日志信息
- plugins： 插件相关配置
- updates： 插件更新目录
- users： jenkins系统用户目录



全局变量参考

有时我们会获取一些项目的参数来做数据处理， 此时可以通过Jenkins提供的内置变量来获取对应的关键信息。

例如: 获取当前项目的名称、构建ID、作业URL等等信息。

```groovy
BUILD_NUMBER          //构建号
BUILD_ID              //构建号
BUILD_DISPLAY_NAME    //构建显示名称
JOB_NAME              //项目名称
              
EXECUTOR_NUMBER       //执行器数量
NODE_NAME             //构建节点名称
WORKSPACE             //工作目录
JENKINS_HOME          //Jenkins home
JENKINS_URL           //Jenkins地址
BUILD_URL             //构建地址
JOB_URL               //项目地址
```



```groovy
println(env)

env.branchName = "develop"
env.commitID = "${UUID.randomUUID().toString()}"
env.commitID = "${env.commitID.split("-")[0]}"
currentBuild.displayName = "#${env.branchName}-${env.commitID}"
currentBuild.description = "Trigger by user jenkins \n branch: master"

pipeline {

    agent { label "build"}

    stages{
        stage("test"){
            steps{
                script{
                    echo "${BUILD_NUMBER}"
                    echo "${BUILD_ID}"
                    //currentBuild.displayName = "#${env.branchName}-${env.commitID}"
                    //currentBuild.description = "Trigger by user jenkins \n branch: master"


                    echo "当前下载代码分支为： ${env.branchName}"
                }
            }
        }
    }
}


result  currentResult   //构建结果
displayName      //构建名称  #111
description      //构建描述
duration         //持续时间
```



## Pipline语法



### pipeline{}	

```groovy
	根语法块，定义整条pipeline
	声明式流水线的定义， 一个pipeline{}。
```

### agent{}

```groovy
	定义Pipline中的运行节点(Jenkins Agent)
	pipline{agent{}}	流水线级别的节点
	stage{agent{}}		阶段界别的节点
```

参数： 

- any: 运行在任一可用节点。
- none：当pipeline全局指定agent为none，则根据每个stage中定义的agent运行（stage必须指定）。
- label：在指定的标签的节点运行。（标签=分组）
- node：支持自定义流水线的工作目录。



```groovy
## 一
pipeline {
	agent any
}

## 二
pipeline {
	agent { label "label Name" }
}


## 三 自定义节点
pipeline {
  agent { 
     node {
        label "labelName"
        customWorkspace "/opt/agent/workspace"
     }
  }
}
```



### stages{}

```groovy
	定义pipline的阶段
	pipline{stages{}}
	stages > stage > steps
```

- 关系： stages > stage > steps > script
- 定义：

- - stages：包含多个stage阶段
  - stage：包含多个steps步骤
  - steps: 包含一组特定的脚本（加上**script后就可以实现在声明式脚本中嵌入脚本式语法**了）

```groovy
pipeline {
	agent { label "build" }
  
  stages {
  		stage("build") {
      		steps {
          		echo "hello"
          }
      }
   }
}

## 在阶段中定义agent

pipeline {

  agent none 
  
  stages{
  	stage('Build'){
    	agent { label "build" }
        steps {
            echo "building......"
        }
     }
  }
}
```

### post{}

- 定义： 根据流水线的最终状态匹配后做一些操作。
- 状态：

- - always：  不管什么状态总是执行
  - success： 仅流水线成功后执行
  - failure：   仅流水线失败后执行
  - aborted： 仅流水线被取消后执行
  - unstable：不稳定状态，单侧失败等等

```groovy
pipeline {
    
    .....
        
    .....
        
    post {
        always{
            script{
                println("流水线结束后，经常做的事情")
            }
        }
        
        success{
            script{
                println("流水线成功后，要做的事情")
            }
        
        }
        failure{
            script{
                println("流水线失败后，要做的事情")
            }
        }
        
        aborted{
            script{
                println("流水线取消后，要做的事情")
            }
        
        }
    }
}
```



### environment{}

定义： 通过键值对（k-v）格式定义流水线在运行时的环境变量， 分为流水线级别和阶段级别。

- 流水线级别的变量：pipline{environment{}}
- 阶段级别的变量：stage{environment{}}

```groovy
// 流水线级别环境变量参考
pipeline {
    environment {
     	NAME = "zeyang"
        VERSION = "1.1.10"
        ENVTYPE = "DEV"
    }
}

// 阶段级别环境变量参考
pipeline {
    
    ...
    ...
    stages {
        stage("build"){
            environment {
                
                
                VERSION = "1.1.20"
            }
            steps {
                script {
                    echo "${VERSION}"
                }
            }
        }
    }
}

```



### options{}

定义：Pipline运行时的一些选项

- 设置保存最近的记录
- 禁止并行构建
- 跳过默认的代码检出
- 设定流水线的超时时间(可用于阶段级别)
- 设定流水线的重试次数(可用于阶段级别)
- 设置日志时间输出(可用于阶段级别)

以代码的方式定义的配置，需要流水线构建运行后才能看到效果

```groovy
## 设置保存最近的记录
options { buildDiscarder(logRotator(numToKeepStr: '1')) }

## 禁止并行构建
options { disableConcurrentBuilds() }


## 跳过默认的代码检出
options { skipDefaultCheckout() }


## 设定流水线的超时时间(可用于阶段级别)
options { timeout(time: 1, unit: 'HOURS') }


## 设定流水线的重试次数(可用于阶段级别)
options { retry(3) }


## 设置日志时间输出(可用于阶段级别)
options { timestamps() }
```

```groovy
pipeline {
    options {
        disableConcurrentBuilds()
        skipDefaultCheckout()
        timeout(time: 1, unit: 'HOURS')
    }
    
    stages {
        stage("build"){
            options {
                timeout(time: 5, unit: 'MINUTES')
                retry(3)
                timestamps()
            }
        }
    }
}
    
}
```



### parameters{}

- 定义： 流水线在运行时设置的参数，UI页面的参数。所有的参数都存储在params对象中。
- 将web ui页面中定义的参数，以代码的方式定义。 (以代码的方式定义的配置，需要流水线构建运行后才能看到效果)

```groovy
pipeline {
    agent any
    
	parameters { 
        string(name: 'VERSION', defaultValue: '1.1.1', description: '') 
    }
    
    stages {
        stage("Build"){
            steps {
                echo "${params.VERSION}"
            }
        }
    }
}
```



### trigger{}

- 流水线的触发方式

- - cron 定时触发: `triggers { cron('H */7 * * 1-5') }` 
  - pollSCM: `triggers { pollSCM('H */7 * * 1-5') }` 

```groovy
## upstream

triggers { 
    upstream(upstreamProjects: 'job1,job2', 
             threshold: hudson.model.Result.SUCCESS) 
}

```



```GROOVY
// Demo
pipeline {
    agent any
    triggers {
        cron('H */7 * * 1-5')
    }
    stages {
        stage('build') {
            steps {
                echo 'Hello World'
            }
        }
    }
}
```



### input{}

参数解析

- message: 提示信息

- ok: 表单中确认按钮的文本

- submitter: 提交人，默认所有人可以

- parameters： 交互时用户选择的参数

```groovy
pipeline {
    agent any
    stages {
        stage('Deploy') {
            input {
                message "是否继续发布"
                ok "Yes"
                submitter "zeyang,aa"
                parameters {
                    string(name: 'ENVTYPE', defaultValue: 'DEV', description: 'env type..[DEV/STAG/PROD]')
                }
            }
            steps {
                echo "Deploy to  ${ENVTYPE}, doing......."
            }
        }
    }
}
```



### when{}

判断条件

- 根据环境变量判断
- 根据表达式判断
- 根据条件判断（not/allOf/anyOf） 

```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'build......'
            }
        }
        stage('Deploy') {
            when {
                environment name: 'DEPLOY_TO', value: 'DEV'
            }
            steps {
                echo 'Deploying.......'
            }
        }
    }
}


###  allOf 条件全部成立
 when {
     allOf {
         environment name: 'CAN_DEPLOY', value: 'true'
         environment name: 'DEPLOY_ENV', value: 'dev'
     }
 }


### anyOf 条件其中一个成立
when {
     anyOf {
         environment name: 'CAN_DEPLOY', value: 'true'
         environment name: 'DEPLOY_ENV', value: 'dev'
     }
 }
```



### parallel{}

场景： 自动化测试，多主机并行发布。 

stage并行运行

```groovy
pipeline {
    agent any
    stages {
        stage('Parallel Stage') {
            failFast true
            parallel {
                stage('windows') {
                    agent {
                        label "master"
                    }
                    steps {
                        echo "windows"
                    }
                }
                stage('linux') {
                    agent {
                        label "build"
                    }
                    steps {
                        echo "linux"
                    }
                }
            }
        }
    }
}
```



示例

```groovy
pipeline {
    // 选择运行节点
    //agent none

    agent {
      label 'build01'
    }

    // 全局变量
    environment {
      VERSION = "1.1.1"
    }

    //运行选项
    options {
      disableConcurrentBuilds()  // 禁止并发构建
      buildDiscarder logRotator(artifactDaysToKeepStr: '', 
                                artifactNumToKeepStr: '', 
                                daysToKeepStr: '5', 
                                numToKeepStr: '10')  //历史构建
    }
    // 构建参数
    parameters {
      string defaultValue: 'zeyang', description: 'name info', name: 'NAME'
      choice choices: ['dev', 'test', 'uat'], description: 'env names', name: 'ENVNAME'
    }

    // 构建触发器
    triggers {
      cron 'H * * * * '
    }

    stages {
        stage('build') {
            // stage level agent
            agent { 
               label 'linux'
            }

            // stage level env local
            environment {
              VERSION = "1.1.2"
            }
            steps {
                echo 'build'

                // print env
                echo "${VERSION}"

                // print param
                echo "${params.NAME}"
                echo "${params.ENVNAME}"
            }
        }

        stage('test') {
            input {
              message '请输入接下来的操作'
              ok 'ok'
              submitterParameter 'approve_user'
              parameters {
                choice choices: ['deploy', 'rollback'], name: 'ops'
              }
            }

            steps{
                echo "test"
                echo "执行的动作: ${ops}"
                echo "批准用户: ${approve_user}"
                script {
                    // 由于下个stage无法获取ops的值，所以特此定义一个新的全局变量
                    // env. 定义全局变量
                    env.OPS = "${ops}"
                }
            }
        }

        stage('deploy'){
            // 是否运行
            when {
              environment name: 'OPS', value: 'deploy'
            }

            steps{
                script{
                    //groovy script 
                    println("hello")
                    // shell 
                    result = sh returnStdout: true, script: 'echo 123'   // 123\n
                    println(result - "\n")

                    // environment self
                    println("build id: ${BUILD_ID}")
                    println("job name: ${JOB_NAME}")
                }
                echo "deploy"
            }
        }

        stage("parallelstage"){
            failFast true
            parallel {
                stage("build01"){
                    steps {
                        echo "windows"
                    }
                }

                stage("build02"){
                    steps{
                        echo "linux"
                    }
                }
            }
        }
    }

    post {
      always{
        echo "always"
      }
      success {
        // One or more steps need to be included within each condition's block.
        echo "success"
      }
      failure {
        // One or more steps need to be included within each condition's block.
        echo "failure"
      }
    }

}

```



## Groovy

Groovy是一种**功能强大，可选类型和动态 语言**，支持**Java平台**。旨在提高开发人员的生产力**得益于简洁**，熟悉且简单易学的语法。可以与任何Java程序顺利集成，并立即为您的应用程序提供强大的功能，包括脚本编写功能，**特定领域语言编写**，运行时和编译时元编程以及函数式编程。



### 注释符

- 单行注释  //   
- 多行注释  /**/



### 数据类型

- string
- list
- map



#### string

字符串类型， 是在流水线中应用最为广泛的一种类型。可以通过双引号、单引号、三引号定义；

- 如果是普通字符串： 用单引号
- 如果存在字符串插值（变量）： 用双引号

```groovy
//String


name = "zeyang"

pipeline {
	agent any
	stages{
		stage("run"){
			steps{
				script{
					// script 
					println(name)

					// buname-appname-type
					job_name = "devops05-app-service_CI"

					// ["devops05", "app", "service_CI"]
					bu_name = job_name.split('-')[0]
					println(bu_name)  //devops05

					// contains
					println(job_name.contains("CI"))

					//size/length
					println("size: ${job_name.size()}")
					println("length: ${job_name.length()}")

					//endsWith()
					println("enswith CI: ${job_name.endsWith('CI')}")

				}
			}
		}
	}
}

```



#### List

```groovy
//List


tools = ["gitlab", "jenkins", "maven", "sonar"]

pipeline {
    agent any

    stages{
        stage("run"){
            steps{
                script{

                    // script
                    println(tools)

                    // add
                    println(tools + "k8s")
                    println(tools << "ansible")
                    println(tools - "maven")
                    println(tools)

                    tools.add("maven")
                    println(tools)
                    println(tools.getClass())


                    // contains
                    println(tools.contains("jenkins"))


                    // length
                    println(tools.size())


                    // index
                    println(tools[0])
                    println(tools[-1])

                }
            }
        }
    }
}
```



#### Map

```groovy
//Map

user_info = ["id": 100, "name": "jenkins"]


pipeline {
	agent any

	stages{
		stage("run"){
			steps{
				script{
					// script 
					println(user_info)

					// get name
					println(user_info["name"])
					println(user_info["id"])

					// = 
					user_info["name"] = "jenkinsX"
					println(user_info)

					// key
					println(user_info.containsKey("name"))
				    println(user_info.containsValue(100))

				    // keys
				    println(user_info.keySet())

				    // remove
				    user_info.remove("name")
				    println(user_info)

				}
			}
		}
	}
}
```



### 条件判断

- if语句
- switch语句
- for语句
- while语句



#### if

```groovy
//if 

// dev == dev  stag == master

branchName = "dev"


pipeline {
	agent any

	stages{
		stage("run"){
			steps{
				script {
					// script

					currentBuild.displayName = branchName

					if ( branchName == "dev"){
						println("deploy to dev....")
						currentBuild.description = "deploy to dev...."

					} else if (branchName == "master"){
						println("deploy to stag....")
						currentBuild.description = "deploy to stag...."
					} else {
						currentBuild.description = "error..."
						println("error...")
					}

				}
			}
		}
	}
}
```



#### switch

```groovy
//switch

// dev == dev  stag == master

branchName = "dev"


pipeline {
	agent any

	stages{
		stage("run"){
			steps{
				script {
					// script

					currentBuild.displayName = branchName

					switch(branchName) {
						case "dev":
							println("deploy to dev....")
							currentBuild.description = "deploy to dev...."	
							break

						case "master":
							println("deploy to stag....")
							currentBuild.description = "deploy to stag...."
							break

						default:
							currentBuild.description = "error..."
							println("error...")
							break

					}
				}
			}
		}
	}
}
```

#### for

```groovy
//for 


users = [ 
			["name": "zeyang", "role": "dev"], 
			["name": "zeyang1", "role": "admin"], 
			["name": "zeyang2", "role": "ops"], 
			["name": "zeyang3", "role": "test"]
		]

pipeline {
	agent any

	stages{
		stage("run"){
			steps{
				script {
					// script
					// i = ["name": "zeyang", "role": "dev"]

					user_names = []
					for (i in users){
						println(i["name"])
						user_names << i["name"]
					}

					println(user_names)  // [zeyang, zeyang1, zeyang2, zeyang3]

					// times

					10.times {
						println('hello')
					}

					10.times { i ->
						println(i)
					}

				}
			}
		}
	}
}
```

#### while

```groovy
// while 


sleeps = true

pipeline {
	agent any 

	stages{
		stage("run"){
			steps{
				script {

					// script

					while(sleeps){
						println("sleep....")
					}

				}
			}
		}
	}
}
```



### 异常处理

- try
- catch
- finally



try

```groovy
// try catch

/*
如果println(a)失败（肯定失败，因为有语法错误）
catch捕获错误，并打印错误。
finally 总是执行。
error关键字可以抛出异常。
*/


pipeline{
	agent any

	stages{
		stage("run"){
			steps{
				script{
					// script

					try {
						println(a)   // not define a  error
					}  catch(Exception e){
						println(e)
						//error "error..."
					} finally {
						println("always....")
					}

				}
			}
		}
	}
}
```

### 函数

```groovy
//function
/*
def关键字 定义函数名为GetUserNameByID， 带有一个参数id;
函数体内的for循环遍历users的列表，如果id与参数id一致则返回用户的name；否则返回null；
*/


users = [
			["id": 1, "name": "jenkins1"],
			["id": 2, "name": "jenkins2"],
			["id": 3, "name": "jenkins3"],
		]


pipeline{
	agent any 

	stages{
		stage("run"){
			steps{
				script {
					//script
                    // 调用函数并打印返回值

					name = GetUserNameByID(1)
					println(name)   //jenkins1

				}
			}
		}
	}
}


// define GetUserName
def GetUserNameByID(id){
	for (i in users){
		if (i["id"] == id){
			return i["name"]
		}
	}
	return "null"
}


```

