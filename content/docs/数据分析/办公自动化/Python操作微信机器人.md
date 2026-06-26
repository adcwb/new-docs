---
title: "Python操作微信机器人"
weight: 50
date: 2026-06-05
---

https://github.com/youfou/wxpy



## 获取全部好友头像

```python
from wxpy import *
import os,sys

# 初始化机器人，扫码登陆微信，适用于Windows系统
bot = Bot()
# # Linux系统，执行登陆请调用下面的这句
# bot = Bot(console_qr=2, cache_path="botoo.pkl"
# 获取当前路径信息
image_dir = os.getcwd()+'\\' + "FriendImgs\\"
# 如果保存头像的FriendImgs目录不存在就创建一个
if not os.path.exists(image_dir):
    os.mkdir(image_dir)
os.popen('explorer ' + image_dir)
my_friends = bot.friends(update=True)
# 获取好友头像信息并存储在FriendImgs目录中
n = 0
for friend in my_friends:
    print(friend)
    image_name = image_dir + str(n) + '.jpg'
    friend.get_avatar(image_name)
    n = n + 1
```



## 可视化统计好友地理位置

```python
from wxpy import *

# 初始化一个机器人对象
# cache_path缓存路径，给定值为第一次登录生成的缓存文件路径
bot = Bot()
# 获取好友列表(包括自己)
my_friends = bot.friends(update=False)
'''
stats_text 函数：帮助我们简单统计微信好友基本信息
简单的统计结果的文本    
:param total: 总体数量    
:param sex: 性别分布    
:param top_provinces: 省份分布    
:param top_cities: 城市分布    
:return: 统计结果文本
'''
print(my_friends.stats_text())
```

