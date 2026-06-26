---
title: "Python 发送邮件"
weight: 1
date: 2026-06-23
tags: ["Python", "邮件", "smtplib", "SMTP"]
---

## Python发送邮件



### 通过Selenium自动发送163邮件

```python
import time
import datetime
from selenium import webdriver
from selenium.webdriver.support.wait import WebDriverWait  # 等待页面加载某些元素
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By

def login(user, pwd):
    """ 登录163邮箱 """
    # 由于可以扫码登录，而我们选择用户名和密码登录，所以，要点击 密码登录
    time.sleep(1)
    wait.until(EC.presence_of_element_located((By.ID, 'switchAccountLogin'))).click()
    # 进入iframe，因为有多个iframe，所以获取的是数组，在分析页面后，数组0索引的iframe是登陆的iframe
    time.sleep(3)
    iframe = driver.find_elements_by_tag_name('iframe')
    # print(iframe)
    '''
    [
        <selenium.webdriver.remote.webelement.WebElement (session="3f92dbd96e72746e7d27d64e6b412318", element="0.855888743369456-2")>, 
        <selenium.webdriver.remote.webelement.WebElement (session="3f92dbd96e72746e7d27d64e6b412318", element="0.855888743369456-3")>, 
        <selenium.webdriver.remote.webelement.WebElement (session="3f92dbd96e72746e7d27d64e6b412318", element="0.855888743369456-4")>, 
        <selenium.webdriver.remote.webelement.WebElement (session="3f92dbd96e72746e7d27d64e6b412318", element="0.855888743369456-5")>
    ]
    '''
    driver.switch_to.frame(iframe[0])

    # 获取用户名和密码标签，并输入对应的值
    time.sleep(1)
    driver.find_element_by_class_name('dlemail').send_keys(user)
    time.sleep(2)
    driver.find_element_by_class_name('dlpwd').send_keys(pwd)
    time.sleep(2)
    driver.find_element_by_id('dologin').click()


def send_mail():
    """ 发送163邮件，需要传递163的用户名和密码,收件人和内容 """

    try:
        # 第1步，执行登陆
        login(user, pwd)

        # 第2步，点击写信按钮
        wait.until(EC.presence_of_element_located((By.ID, '_mail_component_24_24'))).click()
        # driver.find_element_by_id('_mail_component_24_24').click()

        # 第3步，获取收件人，主题，内容框标签，写入内容
        time.sleep(1)
        # 3.1 填写收件人
        wait.until(EC.presence_of_element_located((By.CLASS_NAME, 'nui-editableAddr-ipt'))).send_keys(addr)  # 收件人
        time.sleep(2)
        # 3.2 填写主题
        title = driver.find_elements_by_class_name('nui-ipt-input')
        # print(11111, title)
        title[2].send_keys(theme)  # 主题
        # title.send_keys(theme)  # 主题

        # 3.3 进入content所在iframe，填写内容
        time.sleep(1)
        content_iframe = driver.find_element_by_class_name('APP-editor-iframe')
        driver.switch_to.frame(content_iframe)
        # 虽然nui-scroll这个类名在整个网页中有多个，但是这个iframe中只有一个，所以我们直接send_keys就行
        nui_scroll = wait.until(EC.presence_of_element_located((By.CLASS_NAME, 'nui-scroll')))
        # print(22222222, nui_scroll)  # <selenium.webdriver.remote.webelement.WebElement (session="106a6f5778c14568827014435ddcfcd9", element="0.07847410617283446-1")>
        nui_scroll.send_keys(content)

        # 第4步，因为发送按钮不在此时的iframe中，所以要先退出iframe，才能点击发送按钮
        # 4.1 退出iframe
        time.sleep(1)
        driver.switch_to.default_content()
        # 4.2 点击发送按钮
        time.sleep(1)
        # 这个发送按钮的类名有多个，最好for循环一下，因为有坑，发送按钮是第3个，前面还有两个空标签，但是前端检查中看不到
        driver.find_elements_by_class_name('nui-btn-text')[2].click()



    finally:
        # 关闭浏览器
        time.sleep(3)
        driver.quit()
        # 截止2019-6-11，代码无误


if __name__ == '__main__':
    
    from getpass import getpass
    user = input("邮箱: ").strip()  # 填写你的163账号
    pwd = getpass('密码: ')  # 填写你的163密码
    # 获取driver
    driver = webdriver.Chrome()
    wait = WebDriverWait(driver, 10)
    # driver.maximize_window()
    # 发请求
    driver.get('https://mail.163.com/')

    addr = "1206180814@qq.com"  # 收件人
    theme = '我是你爸爸'  # 主题
    content = '天不生我李淳罡，剑道万古如长夜 ————\n{}'.format(datetime.datetime.now())  # 发送内容
    send_mail()

```

### 通过SMTP协议发送邮件

首先要了解几个协议：

- SMTP（Simple Mail Transfer Protocol）即简单邮件传输协议，它是一组用于由源地址到目的地址传送邮件的规则，由它来控制信件的中转方式。它定义了邮件客户端和SMTP邮件服务器之间，以及两台SMTP邮件服务器之间的通信规则。
- POP3（Post Office Protocol），邮局协议，它定义了邮件客户端软件和POP3邮件服务器的通信规则。
- IMAP（Internet Message Access Protocol），消息访问协议，它是POP3协议的一种扩展。
- Exchange Server 是微软公司的一套电子邮件服务组件，是个消息与协作系统。 简单而言，Exchange server可以被用来构架应用于企业、学校的邮件系统。
- CardDAV是一种通讯录同步的开放协议。使用 CardDAV 同步的通讯录可以编辑、修改或者删除，并且你在手机上的这些操作也同样会和服务器同步，并同时同步到你的其他设备上。

下图演示了用户A从QQ邮箱发送邮件到用户B的163邮箱的过程：


Python的`smtplib`提供了一种很方便的途径发送电子邮件。它对[smtp协议](https://baike.baidu.com/item/SMTP/175887?fromtitle=smtp协议&fromid=421587&fr=aladdin)进行了简单的封装。

一般的，我们可以在本地搭建支持`SMTP`的服务，如`sendmail`，但为了省事，我们可以使用其他的邮件服务商的`SMTP`服务访问，如QQ、网易等。

这里以QQ邮箱为例，首先要拿到授权码，这里登录你的QQ邮箱，在**设置**中，选择**账号**选项，下拉到**POP3/IMAP/SMTP/Exchange/CardDAV/CalDAV服务**项，获取授权码



#### 发送普通文本邮件

```python
import smtplib
from email.mime.text import MIMEText
from email.header import Header

# 第三方 SMTP 服务
mail_host = "smtp.qq.com"  # 设置服务器
mail_user = "1234567890@qq.com"  # 用户名
mail_pass = "dfpcglacrjbybafa"  # 获取授权码
sender = '1234567890@qq.com'  # 发件人账号
receivers = ['1234567890@qq.com']  # 接收邮件，可设置为你的QQ邮箱或者其他邮箱
send_content = 'Python 邮件发送测试...'
message = MIMEText(send_content, 'plain', 'utf-8')  # 第一个参数为邮件内容,第二个设置文本格式，第三个设置编码
message['From'] = Header("我是发件人", 'utf-8')  # 发件人
message['To'] = Header("我是收件人", 'utf-8')   # 收件人

subject = '邮件大标题'
message['Subject'] = Header(subject, 'utf-8')
try:
    smtpObj = smtplib.SMTP()
    smtpObj.connect(mail_host, 25)  # 25 为 SMTP 端口号
    smtpObj.login(mail_user, mail_pass)
    smtpObj.sendmail(sender, receivers, message.as_string())
    print("邮件发送成功")
except smtplib.SMTPException:
    print("Error: 无法发送邮件")

```



#### 发送HTML格式邮件

```python
import smtplib
from email.mime.text import MIMEText
from email.header import Header

# 第三方 SMTP 服务
mail_host = "smtp.qq.com"  # 设置服务器
mail_user = "1234567890@qq.com"  # 用户名
mail_pass = "dfpcglacrjbybafa"  # 口令

sender = '1234567890@qq.com'
receivers = ['1234567890@qq.com']  # 接收邮件，可设置为你的QQ邮箱或者其他邮箱
send_content = """
<h1>天不生我李淳罡</h1>
<h1>剑道万古如长夜</h1>
<p>小二上酒</p>
<img src="https://ss0.baidu.com/73t1bjeh1BF3odCf/it/u=858168512,2130327819&fm=85&s=2E4020DF1CD035FBDC9D940A0300F0F3">
<div>阅读请&nbsp;<a href="https://www.37zw.net/0/761/">点我，点我</a></div>
"""
message = MIMEText(send_content, 'html', 'utf-8')  # 第一个参数为邮件内容
message['From'] = Header("我是发件人", 'utf-8')  # 发件人
message['To'] = Header("我是收件人", 'utf-8')  # 收件人

subject = '雪中悍刀行'
message['Subject'] = Header(subject, 'utf-8')

try:
    smtpObj = smtplib.SMTP()
    smtpObj.connect(mail_host, 25)  # 25 为 SMTP 端口号
    smtpObj.login(mail_user, mail_pass)
    smtpObj.sendmail(sender, receivers, message.as_string())
    print("邮件发送成功")

except smtplib.SMTPException:
    print("Error: 无法发送邮件")

```



#### 发送HTML中带本地图片的邮件

上一个示例中的图片，是一个远程连接，那么我们要发送本地的图片，就要采用下面的方式了：

```python
import smtplib
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart
from email.header import Header

# 第三方 SMTP 服务
mail_host = "smtp.qq.com"  # 设置服务器
mail_user = "1234567890@qq.com"  # 用户名
mail_pass = "dfpcglacrjbybafa"  # 口令

sender = '1234567890@qq.com'
receivers = ['1234567890@qq.com']  # 接收邮件，可设置为你的QQ邮箱或者其他邮箱

message = MIMEMultipart('related')
message['From'] = Header("我是发件人", 'utf-8')  # 发件人
message['To'] = Header("我是收件人", 'utf-8')  # 收件人

subject = '雪中悍刀行--本地图片版'
message['Subject'] = Header(subject, 'utf-8')

msg = MIMEMultipart('alternative')
message.attach(msg)


send_content = """
<h1>天不生我李淳罡</h1>
<h1>剑道万古如长夜</h1>
<p>小二上酒</p>
<img src="cid:image">
<div>阅读请&nbsp;<a href="https://www.37zw.net/0/761/">点我，点我</a></div>
"""
msg.attach(MIMEText(send_content, 'html', 'utf-8'))  # 第一个参数为邮件内容

# 读取当前目录下的图片
f = open('img.jpg', 'rb')
img_msg = MIMEImage(f.read())
f.close()

# 定义图片在HTML文本中的位置
img_msg.add_header('Content-ID', '<image>')   # 根据id定位
message.attach(img_msg)


try:
    smtpObj = smtplib.SMTP()
    smtpObj.connect(mail_host, 25)  # 25 为 SMTP 端口号
    smtpObj.login(mail_user, mail_pass)
    smtpObj.sendmail(sender, receivers, message.as_string())
    print("邮件发送成功")

except smtplib.SMTPException:
    print("Error: 无法发送邮件")

```



#### 发送带各式类型附件的邮件

发送带附件的邮件，首先要创建`MIMEMultipart`实例，然后在构建附件，如果有多个附件的话，可依次构建，最后利用`smtplib.smtp`发送：

```python
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.header import Header

# 第三方 SMTP 服务
mail_host = "smtp.qq.com"  # 设置服务器
mail_user = "1234567890@qq.com"  # 用户名
mail_pass = "dfpcglacrjbybafa"  # 口令

sender = '1234567890@qq.com'
receivers = ['1234567890@qq.com']  # 接收邮件，可设置为你的QQ邮箱或者其他邮箱
# 创建一个带附件的实例
message = MIMEMultipart()
message['From'] = Header("我是发件人", 'utf-8')  # 发件人
message['To'] = Header("我是收件人", 'utf-8')   # 收件人

subject = 'Python发送带附件的邮件示例'
message['Subject'] = Header(subject, 'utf-8')

# 邮件正文内容
send_content = 'hi man，你收到附件了吗？'
content_obj = MIMEText(send_content, 'plain', 'utf-8')  # 第一个参数为邮件内容
message.attach(content_obj)

# 构造附件1，发送当前目录下的 t1.txt 文件
att1 = MIMEText(open('t1.txt', 'rb').read(), 'base64', 'utf-8')
att1["Content-Type"] = 'application/octet-stream'
# 这里的filename可以任意写，写什么名字，邮件附件中显示什么名字
att1["Content-Disposition"] = 'attachment; filename="t1.txt"'
message.attach(att1)

# 构造附件2，发送当前目录下的 t2.py 文件
att2 = MIMEText(open('t2.py', 'rb').read(), 'base64', 'utf-8')
att2["Content-Type"] = 'application/octet-stream'
att2["Content-Disposition"] = 'attachment; filename="t2.py"'
message.attach(att2)
try:
    smtpObj = smtplib.SMTP()
    smtpObj.connect(mail_host, 25)  # 25 为 SMTP 端口号
    smtpObj.login(mail_user, mail_pass)
    smtpObj.sendmail(sender, receivers, message.as_string())
    print("邮件发送成功")

except smtplib.SMTPException:
    print("Error: 无法发送邮件")


```

如果要发送其他类型的，如果PDF、doc、xls、MP3格式的，我们都可以通过`MIMEApplication`来完成，`MIMEApplication`默认子类型是`application/octet-stream`，而`application/octet-stream`表明**这是个二进制文件，但愿接收方知道怎么处理！！！**，然后客户端收到这个声明后会根据文件扩展名来猜测。

```python
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication
from email.header import Header

# 第三方 SMTP 服务
mail_host = "smtp.qq.com"  # 设置服务器
mail_user = "1234567890@qq.com"  # 用户名
mail_pass = "dfpcglacrjbybafa"  # 口令

sender = '1234567890@qq.com'
receivers = ['1234567890@qq.com']  # 接收邮件，可设置为你的QQ邮箱或者其他邮箱
# 创建一个带附件的实例
message = MIMEMultipart()
message['From'] = Header("我是发件人", 'utf-8')  # 发件人
message['To'] = Header("我是收件人", 'utf-8')   # 收件人

subject = 'Python发送带附件的邮件示例'
message['Subject'] = Header(subject, 'utf-8')

# 邮件正文内容
send_content = 'hi man，你收到附件了吗？'
content_obj = MIMEText(send_content, 'plain', 'utf-8')  # 第一个参数为邮件内容
message.attach(content_obj)

# 构造附件1，发送当前目录下的 t1.txt 文件
part1 = MIMEApplication(open('t1.txt', 'rb').read())
part1.add_header('Content-Disposition', 'attachment', filename='t1.txt')
message.attach(part1)


# 构造附件2，发送当前目录下的 bg.mp3 文件
part2 = MIMEApplication(open('bg.mp3', 'rb').read())
part2.add_header('Content-Disposition', 'attachment', filename='bg.mp3')
message.attach(part2)


# 构造附件3，发送当前目录下的 t3.xls 文件
part3 = MIMEApplication(open('t3.xls', 'rb').read())
part3.add_header('Content-Disposition', 'attachment', filename='t3.xls')
message.attach(part3)

# 构造附件4，发送当前目录下的 t4.doc 文件
part4 = MIMEApplication(open('t4.doc', 'rb').read())
part4.add_header('Content-Disposition', 'attachment', filename='t4.doc')
message.attach(part4)


# 构造附件5，发送当前目录下的 t5.pdf 文件
part5 = MIMEApplication(open('t5.pdf', 'rb').read())
part5.add_header('Content-Disposition', 'attachment', filename='t5.pdf')
message.attach(part5)

# 构造附件6，发送当前目录下的 img.jpg 文件
part6 = MIMEApplication(open('img.jpg', 'rb').read())
part6.add_header('Content-Disposition', 'attachment', filename='img.jpg')
message.attach(part6)

try:
    smtpObj = smtplib.SMTP()
    smtpObj.connect(mail_host, 25)  # 25 为 SMTP 端口号
    smtpObj.login(mail_user, mail_pass)
    smtpObj.sendmail(sender, receivers, message.as_string())
    print("邮件发送成功")

except smtplib.SMTPException:
    print("Error: 无法发送邮件")

```



























