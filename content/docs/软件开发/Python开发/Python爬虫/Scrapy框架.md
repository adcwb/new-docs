---
title: "Scrapy框架"
weight: 4
date: 2026-06-23
---

## Scrapy框架简介

```python
	Scrapy是一个为了爬取网站数据，提取结构性数据而编写的应用框架。可以应用在包括数据挖掘， 信息处理或存储历史数据等一系列的程序中。其最初是为了页面抓取(更确切来说,网络抓取)所设计的， 也可以应用在获取API所返回的数据(比如Web Services)或者通用的网络爬虫。

	Scrapy也能帮你实现高阶的爬虫框架，比如爬取时的网站认证、内容的分析处理、重复抓取、分布式爬取等等很复杂的事。

参考文档：
	https://www.osgeo.cn/scrapy/intro/install.html
```



## 安装指南 

```python
	Scrapy需要python3.6+，CPython实现（默认）或pypy7.2.0+实现
    
    Linux：
    	pip install Scrapy
	
    Windows：
        a. pip3 install wheel
        b. 下载twisted http://www.lfd.uci.edu/~gohlke/pythonlibs/#twisted
        c. 进入下载目录，执行 pip3 install Twisted‑17.1.0‑cp35‑cp35m‑win_amd64.whl
        d. pip3 install pywin32
        e. pip3 install scrapy
            
```

## 基本使用

```python
创建项目
	scrapy startproject tutorial

    - 创建一个工程：scrapy startproject ProName
    - cd ProName
    - 必须创建在spiders中:scrapy genspider spiderName www.xxx.com
    - 执行工程：scrapy crawl spiderName
        - settings：
            - 1.指定UA
            - 2.关闭robots
            - 3.指定日志等级

            
持久化存储：
    - 方式1：基于终端指令的持久化存储
        - 只可以将parse方法的返回值进行本地指定后缀文件的存储
        scrapy crawl 脚本文件名称 -o 文件路径
            --注意：持久化储存对应的文本文件的类型只可以是('json', 'jsonlines', 'jl', 'csv', 'xml', 'marshal', 'pickle')数据格式
            --好处：简介高效便捷
            --缺点：局限性比较强（数据只可以储存到指定后缀的文本文件中）
            
    - 方式2：基于管道的持久化存储
        - 在爬虫文件中进行数据解析
        - 在items文件中定义相关的字段（在爬虫文件中解析的字段）
        - 将爬虫文件中解析出的内容存储到items类型的对象中
        - 将items类型的对象提交给管道
        - 在管道类中接收item且对其进行任意形式的持久化存储操作
        - 在配置文件中开启管道机制
    - 什么时候可以定义多个管道类？
        - 想要实现数据的备份。将一份数据存储到多个平台中。
        - 一个管道类负责将数据存储到一个平台中。
    - 爬虫文件的parse中yield item是将item提交给了优先级最高那一个管道类
        - 管道类的process_item中，return item是将item提交给下一个即将被执行的管道类
        
        

```



## 项目目录

```python

reptiles_1
    │  scrapy.cfg
    │
    └─reptiles_1
        │  items.py
        │  middlewares.py
        │  pipelines.py			# 管道文件
        │  settings.py			# 配置文件
        │  __init__.py
        │
        └─spiders			
           │  bili.py			# 爬虫文件
           └─  __init__.py

        
spiders.bili文件分析
	class BiliSpider(scrapy.Spider):
        name = 'first' #爬虫文件的唯一标识
        # allowed_domains = ['www.baidu.com']		# 允许访问的域名
        # 起始的url列表：存放在该列表中的url都会被进行get请求的发送
        start_urls = ['https://www.baidu.com/','https://www.sogou.com']
        #数据解析：参数response就是响应对象
        #parse方法的调用次数和start_url中元素的个数是一直
        def parse(self, response):
            里面写你想要获取的内容
            print(response)

reptiles_1.settings配置文件
	ROBOTSTXT_OBEY = False			# 是否遵循robots协议
	LOG_LEVEL = 'ERROR'				# 控制台日志的输出等级
    CONCURRENT_REQUESTS = 32		# 最大线程数
    USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.111 Safari/537.36'	# 全局UA伪装
    ITEM_PIPELINES = {
        #300：表示的管道类的优先级，数字越小优先级越高
       'ParsePro.pipelines.ParseproPipeline': 300,
       # 'ParsePro.pipelines.MysqlPipeLine': 301,
}
    

案例：爬取哔哩哔哩视频信息
	import scrapy

	# 基于终端指令的持久化存储
    class BiliSpider(scrapy.Spider):
        name = 'bili'
        # allowed_domains = ['https://search.bilibili.com/']
        start_urls = ['https://search.bilibili.com/all?keyword=%E8%88%9E%E8%B9%88']

        def parse(self, response):
            li_list = response.xpath('//*[@id="all-list"]/div[1]/div[2]/ul/li')
            all_data = []

            for i in li_list:
                title = i.xpath('./a/@title')[0].extract()
                video_url = 'https:' + i.xpath('./a/@href')[0].extract()
                dic = {
                    'title': title,
                    'url': video_url
                }

                all_data.append(dic)
                print(dic)

            return all_data
	
    # 基于管道的持久化存储
    

```




