---
title: "Selenium"
weight: 5
date: 2026-06-23
---

## Selenium自动化框架

- 实现浏览器自动化的相关操作!

- 环境安装:pip install selenium

- 官网：https://www.selenium.dev/zh-cn

- 下载浏览器的驱动程序(下载高版本的驱动)
    - http://npm.taobao.org/mirrors/chromedriver/
    - http://chromedriver.storage.googleapis.com/index.html
    
    

### Selenium驱动管理

使用驱动的三种方式

- 驱动管理软件

大多数机器会自动更新浏览器, 但驱动程序不会. 为了确保为浏览器提供正确的驱动程序, 这里有许多第三方库可为您提供帮助.

```python
# 安装驱动管理软件
pip install webdriver-manager

# 与Chrome浏览器一起使用
from selenium import webdriver
from webdriver_manager.chrome import ChromeDriverManager
driver = webdriver.Chrome(ChromeDriverManager().install())

# 也可以使用以下写法
service = Service(executable_path=ChromeDriverManager().install())
driver = webdriver.Chrome(service=service)

# Firefox
from selenium import webdriver
from webdriver_manager.firefox import GeckoDriverManager
driver = webdriver.Firefox(executable_path=GeckoDriverManager().install())


# Edge
from selenium import webdriver
from webdriver_manager.microsoft import EdgeChromiumDriverManager
driver = webdriver.Edge(EdgeChromiumDriverManager().install())

# Opera-linux
from selenium import webdriver
from webdriver_manager.opera import OperaDriverManager
driver = webdriver.Opera(executable_path=OperaDriverManager().install())

# Opera-Windows
from selenium import webdriver
from webdriver_manager.opera import OperaDriverManager

options = webdriver.ChromeOptions()
options.add_argument('allow-elevated-browser')
options.binary_location = "C:\\Users\\USERNAME\\FOLDERLOCATION\\Opera\\VERSION\\opera.exe"
driver = webdriver.Opera(executable_path=OperaDriverManager().install(), options=options)

# IE
from selenium import webdriver
from webdriver_manager.microsoft import IEDriverManager
driver = webdriver.Ie(IEDriverManager().install())
```



- PATH环境变量

需要先下载驱动，然后加入环境变量即可

Windows

```bash
# 要查看哪些目录已经存在PATH，请打开命令提示符并执行：
echo %PATH%

# 如果驱动程序的位置不在列出的目录中，则可以将新目录添加到 PATH：
setx PATH "%PATH%;C:\WebDriver\bin"

# 您可以通过启动驱动程序来测试它是否已正确添加
chromedriver.exe
```

Linux

```bash

echo 'export PATH=$PATH:/path/to/driver' >> ~/.bash_profile
source ~/.bash_profile
```



- 硬编码位置

```python
# 需要预先下载chromedriver，然后手动指定驱动位置
service = Service(executable_path="/path/to/chromedriver")
driver = webdriver.Chrome(service=service)
```





### Selenium简单使用

```python
# 简单使用

from selenium import webdriver
from time import sleep

#1.实例化一款浏览器对象
bro = webdriver.Chrome(executable_path='./chromedriver.exe')
#2.发起请求
bro.get('https://www.jd.com/')
#3.标签定位
text_input = bro.find_element_by_xpath('//*[@id="key"]')
#4.向指定标签中录入文本
text_input.send_keys('iphone 12')
sleep(1)
btn = bro.find_element_by_xpath('//*[@id="search"]/div/div[2]/button')
btn.click()
sleep(1)
#5.js注入，滑动到底部
bro.execute_script('window.scrollTo(0,document.body.scrollHeight)')
sleep(2)
bro.find_element_by_xpath('//*[@id="J_bottomPage"]/span[1]/a[7]').click()
sleep(3)
#关闭浏览器
bro.quit()

```



### Selenium常用操作

#### 类与方法

```python
import time

from selenium import webdriver  # 驱动浏览器
from selenium.webdriver import ActionChains   # 鼠标的相关操作，比如滑动验证
from selenium.webdriver.common.by import By   # 选择器，以什么方式选择标签元素
from selenium.webdriver.common.keys import Keys   # 键盘相关
from selenium.webdriver.support import expected_conditions as EC  # 各种判断，一般跟等待事件连用，比如说等待某个元素加载出来
from selenium.webdriver.support.wait import WebDriverWait  # 等待事件，可以与EC连用
from webdriver_manager.chrome import ChromeDriverManager

# 加载Chrome驱动
driver = webdriver.Chrome(ChromeDriverManager().install())

# 发起get请求
driver.get("https://www.baidu.com")

# 窗口最大化
driver.maximize_window()
print("当前请求的URL为：%s" % driver.current_url)
print("当前页面的title为：%s" % driver.title)
print("当前浏览器对象为：%s" % driver.name)
print(driver.current_window_handle)  # 获取当前窗口
print(driver.get_cookies())   # 获取cookies
print(driver.page_source)   # 获取当前页面内容

time.sleep(5)
driver.close()	# 关闭当前窗口
driver.quit()	# 关闭浏览器

```



#### 选择器

```python
from selenium import webdriver   # 驱动浏览器
from selenium.webdriver.support.wait import WebDriverWait  # 等待事件
from webdriver_manager.chrome import ChromeDriverManager
driver = webdriver.Chrome(ChromeDriverManager().install())

wait = WebDriverWait(driver, 10)



driver.get('https://www.baidu.com')
driver.find_element_by_id('su')  # id选择器
driver.find_element_by_class_name('xx')  # 类选择器，1个
driver.find_elements_by_class_name('xx')  # 类选择器，多个
driver.find_element_by_link_text('xxx')  # 链接文本选择器
driver.find_element_by_xpath('xxxx')  # xpath选择器
driver.find_element_by_tag_name('h1')  # 标签选择器，获取1个
driver.find_elements_by_tag_name('h1')  # 标签选择器，获取多个
driver.find_element_by_css_selector('xxx')  # 样式选择器

```



### selenium操作远程浏览器

镜像地址：https://hub.docker.com/u/selenium

仓库地址：https://github.com/SeleniumHQ/docker-selenium

官方文档：http://selenium.dev/zh-cn/documentation/



>- Hub：负责将从 WebDriver 接收的浏览器操作指令分发至对应的 Node，并将从 Node 接收的结果返回给 WebDriver。
>- Node：负责接收来自 Hub 的指令，并调用浏览器驱动来完成页面操作。

Hub 与 Node 可位于不同的主机，通过 HTTP 协议来通信。



| 镜像名称                          | 功能说明                                                     |
| :-------------------------------- | ------------------------------------------------------------ |
| selenium/base                     | 包含了Java和SeleniumServer的基础镜像，这个一般用不上         |
| selenium/hub                      | SeleniumGrid运行方式中的Hub镜像，需要结合node-xxx或node-xxx-debug使用 |
| selenium/node-base                | 包含了虚拟桌面的SeleniumGrid运行方式中的Node基础镜像，这个一般用不上 |
| selenium/node-chrome              | SeleniumGrid运行方式中的带Chrome的Node镜像                   |
| selenium/node-firefox             | SeleniumGrid运行方式中的带Firefox的Node镜像                  |
| selenium/node-edge                | SeleniumGrid运行方式中的带Edge的Node镜像                     |
| selenium/node-chromium            | SeleniumGrid运行方式中的带Chromium的Node镜像                 |
| selenium/node-chrome-debug        | SeleniumGrid运行方式中的带Chrome和VNC服务器的Node镜像        |
| selenium/node-firefox-debug       | SeleniumGrid运行方式中的带Firefox和VNC服务器的Node镜像       |
| selenium/standalone-chrome        | 单独运行Selenium的带Chrome的镜像                             |
| selenium/standalone-firefox       | 单独运行Selenium的带Firefox的镜像                            |
| selenium/standalone-edge          | 单独运行Selenium的带Edge的镜像                               |
| selenium/standalone-chromium      | 单独运行Selenium的带Chromium的镜像                           |
| selenium/standalone-chrome-debug  | 单独运行Selenium的带Chrome和VNC服务器的镜像                  |
| selenium/standalone-firefox-debug | 单独运行Selenium的带Firefox和VNC服务器的镜像                 |

#### jar文件启动

Grid `jar` 文件依赖的 Java 版本为 11 或以上。

欲使用 Grid，Standalone 模式是最简单快速的一种。

可以从 [github.com/SeleniumHQ/selenium](https://github.com/SeleniumHQ/selenium/releases/latest) 发布页面下载最新的`selenium-server-<version>.jar`文件，然后使用如下命令启动：

```bash
java -jar selenium-server-<version>.jar standalone
```

Grid 启动完成后，打开网址`http://localhost:4444`可以看到可使用的所有浏览器类型以及会话的状态。

使用 Hub 与 Node 分工的方式来启动 Grid 的命令如下：

```bash
# 启动 Hub
java -jar selenium-server-<version>.jar hub

# 启动 Node 1
java -jar selenium-server-<version>.jar node --port 5555

# 启动 Node 2
java -jar selenium-server-<version>.jar node --port 6666

```





#### Docker部署

```bash

JPN（日本）,KOR（韩国）, MYS（马来西亚）,IDN（印度尼西亚）, BRN（文莱）, PHL（菲律宾）, SGP（新加坡）, MEX（墨西哥），
THA（泰国）, VNM（越南）, AUS（澳大利亚）, NZL（新西兰）, PNG（巴布亚新几内亚）, CHL（智利）, PER（秘鲁），RUS(俄罗斯）。其他经济体的英文缩写是:CHN（中国）, HKG(中国香港)，TWN（中国台湾），USA(美国),CAN（加拿大)

```



启动hub

```bash
docker run -d --name myhub -p 5555:4444 selenium/hub
```

将selenium/node-chrome-debug节点容器与容器myhub之间链接起来(--link是链接别名为hub的容器)

```bash
docker run -d --name node -p 5902:5900 --link myhub:hub selenium/node-chrome-debug
```

创建firefox node容器，将selenium/node-firefox-debug容器与容器myhub之间链接起来(--link是链接别名为hub的容器)

```bash
docker run -d --name node1 -p 5901:5900 --link myhub:hub selenium/node-firefox-debug
```

使用虚拟机ip+映射端口打开http://192.168.222.132:5555/grid/console，这时候selenium grid环境已经部署完成，这就是在docker里部署的好处，用容器的隔离，省去好几台设备部署node，



Viewer远程链接：debug结尾的镜像都带有VNC服务端，本机安装VNC客户端，即可远程连接（密码是secret）



示例部署：

```bash
# 1、部署HUB
docker run -d --name tencent-sgp-hub -p 4442-4444:4442-4444  selenium/hub

# 2、部署Node节点-chrome浏览器

docker run -d \
  --name tencent-sgp-selenium-chrome \
  -p 5900:5900 \
  -e SE_EVENT_BUS_HOST=172.17.0.2 \
  -e SE_EVENT_BUS_PUBLISH_PORT=4442 \
  -e SE_EVENT_BUS_SUBSCRIBE_PORT=4443 \
  -v /dev/shm:/dev/shm \
  --shm-size="2g" \
  selenium/node-chrome
  
# 参数说明
	-d: 以守护进程（后台）模式运行容器
	--name tencent-sgp-selenium-chrome: 为容器指定名称（便于管理）
	-p 5900:5900: 端口映射, 主机5900 → 容器5900（VNC服务端口）
	-e SE_EVENT_BUS_HOST=10.3.0.9: 设置事件总线主机地址（指向Hub节点IP）
	-e SE_EVENT_BUS_PUBLISH_PORT=4442: 事件总线发布端口（与Hub配置一致）
	-e SE_EVENT_BUS_SUBSCRIBE_PORT=4443: 事件总线订阅端口（与Hub配置一致）
	-e SE_NODE_MAX_SESSIONS=5: 限制单个节点的最大会话数
	-v /dev/shm:/dev/shm: 共享内存卷挂载, 解决浏览器内存不足问题
	--shm-size="2g": 设置容器共享内存大小为2GB, Chrome/Firefox 需要较大共享内存
	--restart unless-stopped: 重启策略, 除非手动停止，否则自动重启
	selenium/node-edge:4.11.0: 使用的镜像,包含Edge浏览器和WebDriver
```





#### k8s部署

yaml文件参考：https://github.com/kubernetes/examples/tree/master/staging/selenium





### selenium和爬虫之间的关联

- 可以便捷的捕获到动态加载的数据(可见即可得)
- 可以实现模拟登陆



```python
#捕获动态加载数据
from lxml import etree

bro = webdriver.Chrome(executable_path='./chromedriver.exe')
bro.get('http://scxk.nmpa.gov.cn:81/xk/')
sleep(1)
#page_source返回当前打开的页面源码数据(包含动态加载数据)
page_text = bro.page_source
page_text_list = [page_text]#保存前五页的页面源码数据

for i in range(5):
    bro.find_element_by_xpath('//*[@id="pageIto_next"]').click()
    sleep(1)
    page_text_list.append(bro.page_source)

for page_text in page_text_list:
    tree = etree.HTML(page_text)
    li_list = tree.xpath('//*[@id="gzlist"]/li')
    for li in li_list:
        title = li.xpath('./dl/@title')[0]
        print(title)
bro.quit()
```



- 动作链
    - 封装了很多连续的行为动作

```text
from selenium.webdriver import ActionChains
```

- 如果直接定位一个子页面中的标签,会报错
    - 解决:使用switch_to函数处理
        - bro.switch_to.frame('iframe的id')



```python
bro = webdriver.Chrome(executable_path='./chromedriver.exe')
bro.get('https://www.runoob.com/try/try.php?filename=jqueryui-api-droppable')
sleep(1)
bro.switch_to.frame('iframeResult')
div_tag = bro.find_element_by_xpath('//*[@id="draggable"]')

#1.实例化动作链对象且将动作链关联到当前浏览器
action = ActionChains(bro)
#2.制定行为动作
action.click_and_hold(div_tag) #点击且长按
for i in range(5):
    action.move_by_offset(7,5).perform()#perform表示让动作链立即执行
    sleep(0.5)
sleep(2)
bro.quit()
```

- cookie的处理



```python
browser = webdriver.Chrome(executable_path='./chromedriver.exe')
browser.get('https://www.zhihu.com/explore')
print(browser.get_cookies())

browser.add_cookie({'name': 'name', 'domain': 'www.zhihu.com', 'value': 'germey'})
print(browser.get_cookies())

browser.delete_all_cookies()

print(browser.get_cookies())
```

- 无头浏览器
    - 无可视化界面的浏览器(谷歌)

```python
from selenium.webdriver.chrome.options import Options
# 创建一个参数对象，用来控制chrome以无界面模式打开
chrome_options = Options()
chrome_options.add_argument('--headless')
chrome_options.add_argument('--disable-gpu')


browser = webdriver.Chrome(executable_path='./chromedriver.exe',chrome_options=chrome_options)
browser.get('https://www.zhihu.com/explore')
print(browser.page_source)
browser.save_screenshot('./zhihu.jpg') #截图
browser.quit()
```

#### 案例： 模拟12306登录

```python
#!/usr/bin/env python
# coding:utf-8

import requests
from hashlib import md5

class Chaojiying_Client(object):

    def __init__(self, username, password, soft_id):
        self.username = username
        password =  password.encode('utf8')
        self.password = md5(password).hexdigest()
        self.soft_id = soft_id
        self.base_params = {
            'user': self.username,
            'pass2': self.password,
            'softid': self.soft_id,
        }
        self.headers = {
            'Connection': 'Keep-Alive',
            'User-Agent': 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0)',
        }

    def PostPic(self, im, codetype):
        """
        im: 图片字节
        codetype: 题目类型 参考 http://www.chaojiying.com/price.html
        """
        params = {
            'codetype': codetype,
        }
        params.update(self.base_params)
        files = {'userfile': ('ccc.jpg', im)}
        r = requests.post('http://upload.chaojiying.net/Upload/Processing.php', data=params, files=files, headers=self.headers)
        return r.json()

    def ReportError(self, im_id):
        """
        im_id:报错题目的图片ID
        """
        params = {
            'id': im_id,
        }
        params.update(self.base_params)
        r = requests.post('http://upload.chaojiying.net/Upload/ReportError.php', data=params, headers=self.headers)
        return r.json()
    
#定义一个识别验证码图片的函数
def getCode_text(imgPath,imgType):
    chaojiying = Chaojiying_Client('227851369', '123456', '	911685')	
    im = open(imgPath, 'rb').read()
    return chaojiying.PostPic(im,imgType)['pic_str']



from selenium import webdriver
from time import sleep
from selenium.webdriver import ActionChains
#pip install PIL (Pillow)
from PIL import Image

# 裁剪验证码， 图片裁剪务必将电脑的缩放比例调成100%

bro = webdriver.Chrome(executable_path='./chromedriver.exe')
bro.get('https://kyfw.12306.cn/otn/login/init')
sleep(1)
#截屏
bro.save_screenshot('main.png') #截取的是当前完整的页面图片
#获取验证码图片左下角和右上角两点坐标
img_tag = bro.find_element_by_xpath('//*[@id="loginForm"]/div/ul[2]/li[4]/div/div/div[3]/img')
#左下角坐标
location = img_tag.location
#返回验证码图片的尺寸
size = img_tag.size
#指定裁剪的范围
rangle = (int(location['x']),int(location['y']),int(location['x']+size['width']),int(location['y']+size['height']))
i = Image.open('./main.png')
frame = i.crop(rangle)#根据裁剪的范围进行裁剪
frame.save('code.png')

#验证码识别，返回点击坐标
result = getCode_text('code.png',9004)
print(result) #:x1,y1|x2,y2|x3,y3
#将result转换成[[x1,y1],[x2,y2]]
all_list = []
if '|' in result:
    list_1 = result.split('|')
    count_1 = len(list_1)
    for i in range(count_1):
        xy_list = []
        x = int(list_1[i].split(',')[0])
        y = int(list_1[i].split(',')[1])
        xy_list.append(x)
        xy_list.append(y)
        all_list.append(xy_list)
else:
    x = int(result.split(',')[0])
    y = int(result.split(',')[1])
    xy_list = []
    xy_list.append(x)
    xy_list.append(y)
    all_list.append(xy_list)
    
for loc in all_list:
    x = loc[0]
    y = loc[1]
    ActionChains(bro).move_to_element_with_offset(img_tag,x,y).click().perform()
    sleep(1)
bro.find_element_by_id('username').send_keys('1234567890')
sleep(1)
bro.find_element_by_id('password').send_keys('0000000000')
sleep(1)
#验证码的处理

bro.find_element_by_id('loginSub').click()
sleep(3)
bro.quit()
```

- phantomJs:一款无头浏览器
- appnium:基于手机app的自动化模块


