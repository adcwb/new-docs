---
title: "Hysteria2"
weight: 50
date: 2026-06-05
tags: ["Hysteria2", "代理", "网络", "安全"]
---

Hysteria 2 是一款基于 HTTP/3（QUIC）协议的高性能、抗审查代理工具，具备出色的弱网穿透能力。本文介绍服务端的安装、TLS 证书生成、配置文件设置及客户端接入方法。

官方文档：https://v2.hysteria.network/zh/docs/getting-started/Installation/

## Hysteria 2 服务安装配置指南

### 系统准备

```bash
# 更新系统软件包
sudo apt update && sudo apt upgrade -y

# 安装必要依赖
sudo apt install -y wget curl openssl
```



### 安装服务端

```bash
# 使用官方脚本安装
bash <(curl -fsSL https://get.hy2.sh/)
```



### 生成 TLS 证书

```bash
# 创建证书目录
sudo mkdir -p /etc/hysteria

# 生成自签名证书（生产环境建议使用 Let's Encrypt） 此处仅供参考，证书仅提供加密，不强制校验域名
sudo openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name prime256v1) \
  -keyout /etc/hysteria/private.key \
  -out /etc/hysteria/cert.crt \
  -subj "/CN=hy2.example.com" -days 3650

# 设置证书权限
sudo chmod 600 /etc/hysteria/{cert.crt,private.key}
```



### 配置文件说明

配置主文件`/etc/hysteria/config.yaml`

```yaml
# 监听地址和端口（建议使用 443 等标准端口）
listen: :8088  # 格式为 ":端口" 或 "IP:端口"

# TLS 配置
tls:
  cert: /etc/hysteria/cert.crt    # 证书路径
  key: /etc/hysteria/private.key  # 私钥路径

# QUIC 协议参数（影响传输性能）
quic:
  initStreamReceiveWindow: 16777216   # 初始流接收窗口
  maxStreamReceiveWindow: 16777216    # 最大流接收窗口
  initConnReceiveWindow: 33554432     # 初始连接接收窗口
  maxConnReceiveWindow: 33554432      # 最大连接接收窗口

# 认证方式配置
auth:
  type: password      # 认证类型（password/secret）
  password: 123456    # 客户端连接密码

# 流量伪装配置
masquerade:
  type: proxy         # 伪装类型（proxy/file/dir）
  proxy:
    url: https://maimai.sega.jp  # 伪装目标网址
    rewriteHost: true            # 重写 Host 头

```



优化文件，非必须 `/etc/hysteria/priority.conf`

```ini
[Service]
# 设置高优先级 CPU 调度（需要内核支持）
CPUSchedulingPolicy=rr     # 实时轮转调度策略
CPUSchedulingPriority=99   # 最高优先级（1-99）
```



### 防火墙配置

```bash
# 对于 UFW：
sudo ufw allow 8088/tcp
sudo ufw allow 8088/udp
sudo ufw reload

# 对于 firewalld：
sudo firewall-cmd --permanent --add-port=8088/tcp
sudo firewall-cmd --permanent --add-port=8088/udp
sudo firewall-cmd --reload

# 对于 iptables：
sudo iptables -A INPUT -p tcp --dport 8088 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 8088 -j ACCEPT
sudo iptables-save > /etc/iptables/rules.v4
```



### 服务管理

```bash
# 启动服务
sudo systemctl start hysteria-server.service

# 设置开机自启
sudo systemctl enable hysteria-server.service

# 查看服务状态
sudo systemctl status hysteria-server.service

# 查看实时日志
journalctl -u hysteria-server.service -f
```



### 客户端配置示例

```yaml
server: your-server-ip:8088  # 服务器公网 IP 和端口
auth: 123456                 # 与服务端相同的密码

tls:
  sni: hy2.example.com       # 证书的 Common Name
  insecure: true             # 使用自签名证书时需要启用

quic:
  initStreamReceiveWindow: 16777216
  maxStreamReceiveWindow: 16777216
  initConnReceiveWindow: 33554432
  maxConnReceiveWindow: 33554432
```



### 服务验证

```bash
# 检查端口监听状态
ss -tulnp | grep hysteria

# 测试 QUIC 端口连通性
curl --http3 https://your-server-ip:8088
```



### 注意事项

1. 正式环境建议使用 ACME 自动申请证书（需域名）

   ```bash
   sudo apt install certbot
   sudo certbot certonly --standalone -d your-domain.com
   ```

2. 伪装配置需要确保目标网站可访问且未屏蔽代理

3. QUIC 参数需根据实际网络环境调整

4. 服务器需开启 BBR 等拥塞控制算法优化速度

------

> 推荐客户端工具：`v2rayN` (Windows)、`Clash.Meta` (全平台)、`nekoray` (全平台)
> 遇到连接问题可检查：服务日志、防火墙设置、证书有效期、客户端配置一致性





### 附录1：Clash配置文件示例

参考文档：https://clash.wiki/

```yaml
port: 7890									# 监听端口
socks-port: 7891
external-controller: :9090
allow-lan: true
mode: rule
log-level: debug
proxies:
  - name: 新加坡-Hysteria2  					# 节点名称
    type: hysteria2							  # 节点类型
    server: 23.223.8.9  					  # 节点实际IP
    port: 8088								  # 端口
    password: 123            				  # 密码
    sni: www.bing.com			              # 流量代理，保持默认即可
    skip-cert-verify: true			
  - name: 马来西亚-Hysteria2
    type: hysteria2
    server: 23.123.9.8
    port: 8088
    password: 111111111
    sni: www.bing.com
    skip-cert-verify: true
proxy-groups:
  - name: 🚀 节点选择
    type: select
    proxies:
      - ♻️ 自动选择
      - DIRECT
      - 新加坡-Hysteria2
      - 马来西亚-Hysteria2
  - name: ♻️ 自动选择
    type: url-test
    url: http://www.gstatic.com/generate_204
    interval: 300
    tolerance: 50
    proxies:
      - 新加坡-Hysteria2
      - 马来西亚-Hysteria2
  - name: 🎯 全球直连
    type: select
    proxies:
      - DIRECT
      - 🚀 节点选择
      - ♻️ 自动选择
  - name: 🛑 全球拦截
    type: select
    proxies:
      - REJECT
      - DIRECT
      
rules:
  - IP-CIDR,127.0.0.0/8,DIRECT
  - IP-CIDR,10.0.0.0/8,DIRECT
  - IP-CIDR,192.168.0.0/16,DIRECT
  - IP-CIDR,172.16.0.0/16,DIRECT
  - DOMAIN-SUFFIX,baidu.com,DIRECT
  - DOMAIN-SUFFIX,default.svc.cluster.local,DIRECT
  - DOMAIN-SUFFIX,clashverge.dev,♻️ 自动选择
  - DOMAIN,chat.deepseek.com,DIRECT
  - DOMAIN-SUFFIX,services.googleapis.cn,🚀 节点选择
  - DOMAIN-SUFFIX,xn--ngstr-lra8j.com,🚀 节点选择
  - DOMAIN,safebrowsing.urlsec.qq.com,DIRECT
  - DOMAIN,safebrowsing.googleapis.com,DIRECT
  - DOMAIN,developer.apple.com,🚀 节点选择
  - DOMAIN-SUFFIX,digicert.com,🎯 全球直连
  - DOMAIN,ocsp.apple.com,🎯 全球直连
  - DOMAIN,github.com,🎯 全球直连
  - DOMAIN,ocsp.comodoca.com,🎯 全球直连
  - DOMAIN,ocsp.usertrust.com,🎯 全球直连
  - DOMAIN,ocsp.sectigo.com,🎯 全球直连
  - DOMAIN,ocsp.verisign.net,🎯 全球直连
  - DOMAIN-SUFFIX,apple-dns.net,🎯 全球直连
  - DOMAIN,testflight.apple.com,🎯 全球直连
  - DOMAIN,sandbox.itunes.apple.com,🎯 全球直连
  - DOMAIN,itunes.apple.com,🎯 全球直连
  - DOMAIN-SUFFIX,apps.apple.com,🎯 全球直连
  - DOMAIN-SUFFIX,blobstore.apple.com,🎯 全球直连
  - DOMAIN,cvws.icloud-content.com,🎯 全球直连
  - DOMAIN-SUFFIX,mzstatic.com,DIRECT
  - DOMAIN-SUFFIX,itunes.apple.com,DIRECT
  - DOMAIN-SUFFIX,icloud.com,DIRECT
  - DOMAIN-SUFFIX,icloud-content.com,DIRECT
  - DOMAIN-SUFFIX,me.com,DIRECT
  - DOMAIN-SUFFIX,aaplimg.com,DIRECT
  - DOMAIN-SUFFIX,cdn20.com,DIRECT
  - DOMAIN-SUFFIX,cdn-apple.com,DIRECT
  - DOMAIN-SUFFIX,akadns.net,DIRECT
  - DOMAIN-SUFFIX,akamaiedge.net,DIRECT
  - DOMAIN-SUFFIX,edgekey.net,DIRECT
  - DOMAIN-SUFFIX,mwcloudcdn.com,DIRECT
  - DOMAIN-SUFFIX,mwcname.com,DIRECT
  - DOMAIN-SUFFIX,apple.com,DIRECT
  - DOMAIN-SUFFIX,apple-cloudkit.com,DIRECT
  - DOMAIN-SUFFIX,apple-mapkit.com,DIRECT
  - DOMAIN-SUFFIX,126.com,DIRECT
  - DOMAIN-SUFFIX,126.net,DIRECT
  - DOMAIN-SUFFIX,127.net,DIRECT
  - DOMAIN-SUFFIX,163.com,DIRECT
  - DOMAIN-SUFFIX,360buyimg.com,DIRECT
  - DOMAIN-SUFFIX,36kr.com,DIRECT
  - DOMAIN-SUFFIX,acfun.tv,DIRECT
  - DOMAIN-SUFFIX,air-matters.com,DIRECT
  - DOMAIN-SUFFIX,aixifan.com,DIRECT
  - DOMAIN-KEYWORD,alicdn,DIRECT
  - DOMAIN-KEYWORD,alipay,DIRECT
  - DOMAIN-KEYWORD,taobao,DIRECT
  - DOMAIN-SUFFIX,amap.com,DIRECT
  - DOMAIN-SUFFIX,autonavi.com,DIRECT
  - DOMAIN-KEYWORD,baidu,DIRECT
  - DOMAIN-SUFFIX,bdimg.com,DIRECT
  - DOMAIN-SUFFIX,bdstatic.com,DIRECT
  - DOMAIN-SUFFIX,bilibili.com,DIRECT
  - DOMAIN-SUFFIX,bilivideo.com,DIRECT
  - DOMAIN-SUFFIX,caiyunapp.com,DIRECT
  - DOMAIN-SUFFIX,clouddn.com,DIRECT
  - DOMAIN-SUFFIX,cnbeta.com,DIRECT
  - DOMAIN-SUFFIX,cnbetacdn.com,DIRECT
  - DOMAIN-SUFFIX,cootekservice.com,DIRECT
  - DOMAIN-SUFFIX,csdn.net,DIRECT
  - DOMAIN-SUFFIX,ctrip.com,DIRECT
  - DOMAIN-SUFFIX,dgtle.com,DIRECT
  - DOMAIN-SUFFIX,dianping.com,DIRECT
  - DOMAIN-SUFFIX,douban.com,DIRECT
  - DOMAIN-SUFFIX,doubanio.com,DIRECT
  - DOMAIN-SUFFIX,duokan.com,DIRECT
  - DOMAIN-SUFFIX,easou.com,DIRECT
  - DOMAIN-SUFFIX,ele.me,DIRECT
  - DOMAIN-SUFFIX,feng.com,DIRECT
  - DOMAIN-SUFFIX,fir.im,DIRECT
  - DOMAIN-SUFFIX,frdic.com,DIRECT
  - DOMAIN-SUFFIX,g-cores.com,DIRECT
  - DOMAIN-SUFFIX,godic.net,DIRECT
  - DOMAIN-SUFFIX,gtimg.com,DIRECT
  - DOMAIN,cdn.hockeyapp.net,DIRECT
  - DOMAIN-SUFFIX,hongxiu.com,DIRECT
  - DOMAIN-SUFFIX,hxcdn.net,DIRECT
  - DOMAIN-SUFFIX,iciba.com,DIRECT
  - DOMAIN-SUFFIX,ifeng.com,DIRECT
  - DOMAIN-SUFFIX,ifengimg.com,DIRECT
  - DOMAIN-SUFFIX,ipip.net,DIRECT
  - DOMAIN-SUFFIX,iqiyi.com,DIRECT
  - DOMAIN-SUFFIX,jd.com,DIRECT
  - DOMAIN-SUFFIX,jianshu.com,DIRECT
  - DOMAIN-SUFFIX,knewone.com,DIRECT
  - DOMAIN-SUFFIX,le.com,DIRECT
  - DOMAIN-SUFFIX,lecloud.com,DIRECT
  - DOMAIN-SUFFIX,lemicp.com,DIRECT
  - DOMAIN-SUFFIX,licdn.com,DIRECT
  - DOMAIN-SUFFIX,luoo.net,DIRECT
  - DOMAIN-SUFFIX,meituan.com,DIRECT
  - DOMAIN-SUFFIX,meituan.net,DIRECT
  - DOMAIN-SUFFIX,mi.com,DIRECT
  - DOMAIN-SUFFIX,miaopai.com,DIRECT
  - DOMAIN-SUFFIX,microsoft.com,DIRECT
  - DOMAIN-SUFFIX,microsoftonline.com,DIRECT
  - DOMAIN-SUFFIX,miui.com,DIRECT
  - DOMAIN-SUFFIX,miwifi.com,DIRECT
  - DOMAIN-SUFFIX,mob.com,DIRECT
  - DOMAIN-SUFFIX,netease.com,DIRECT
  - DOMAIN-SUFFIX,office.com,DIRECT
  - DOMAIN-SUFFIX,office365.com,DIRECT
  - DOMAIN-KEYWORD,officecdn,DIRECT
  - DOMAIN-SUFFIX,oschina.net,DIRECT
  - DOMAIN-SUFFIX,ppsimg.com,DIRECT
  - DOMAIN-SUFFIX,pstatp.com,DIRECT
  - DOMAIN-SUFFIX,qcloud.com,DIRECT
  - DOMAIN-SUFFIX,qdaily.com,DIRECT
  - DOMAIN-SUFFIX,qdmm.com,DIRECT
  - DOMAIN-SUFFIX,qhimg.com,DIRECT
  - DOMAIN-SUFFIX,qhres.com,DIRECT
  - DOMAIN-SUFFIX,qidian.com,DIRECT
  - DOMAIN-SUFFIX,qihucdn.com,DIRECT
  - DOMAIN-SUFFIX,qiniu.com,DIRECT
  - DOMAIN-SUFFIX,qiniucdn.com,DIRECT
  - DOMAIN-SUFFIX,qiyipic.com,DIRECT
  - DOMAIN-SUFFIX,qq.com,DIRECT
  - DOMAIN-SUFFIX,qqurl.com,DIRECT
  - DOMAIN-SUFFIX,rarbg.to,DIRECT
  - DOMAIN-SUFFIX,ruguoapp.com,DIRECT
  - DOMAIN-SUFFIX,segmentfault.com,DIRECT
  - DOMAIN-SUFFIX,sinaapp.com,DIRECT
  - DOMAIN-SUFFIX,smzdm.com,DIRECT
  - DOMAIN-SUFFIX,snapdrop.net,DIRECT
  - DOMAIN-SUFFIX,sogou.com,DIRECT
  - DOMAIN-SUFFIX,sogoucdn.com,DIRECT
  - DOMAIN-SUFFIX,sohu.com,DIRECT
  - DOMAIN-SUFFIX,soku.com,DIRECT
  - DOMAIN-SUFFIX,speedtest.net,DIRECT
  - DOMAIN-SUFFIX,sspai.com,DIRECT
  - DOMAIN-SUFFIX,suning.com,DIRECT
  - DOMAIN-SUFFIX,taobao.com,DIRECT
  - DOMAIN-SUFFIX,tencent.com,DIRECT
  - DOMAIN-SUFFIX,tenpay.com,DIRECT
  - DOMAIN-SUFFIX,tianyancha.com,DIRECT
  - DOMAIN-SUFFIX,tmall.com,DIRECT
  - DOMAIN-SUFFIX,tudou.com,DIRECT
  - DOMAIN-SUFFIX,umetrip.com,DIRECT
  - DOMAIN-SUFFIX,upaiyun.com,DIRECT
  - DOMAIN-SUFFIX,upyun.com,DIRECT
  - DOMAIN-SUFFIX,veryzhun.com,DIRECT
  - DOMAIN-SUFFIX,weather.com,DIRECT
  - DOMAIN-SUFFIX,weibo.com,DIRECT
  - DOMAIN-SUFFIX,xiami.com,DIRECT
  - DOMAIN-SUFFIX,xiami.net,DIRECT
  - DOMAIN-SUFFIX,xiaomicp.com,DIRECT
  - DOMAIN-SUFFIX,ximalaya.com,DIRECT
  - DOMAIN-SUFFIX,xmcdn.com,DIRECT
  - DOMAIN-SUFFIX,xunlei.com,DIRECT
  - DOMAIN-SUFFIX,yhd.com,DIRECT
  - DOMAIN-SUFFIX,yihaodianimg.com,DIRECT
  - DOMAIN-SUFFIX,yinxiang.com,DIRECT
  - DOMAIN-SUFFIX,ykimg.com,DIRECT
  - DOMAIN-SUFFIX,youdao.com,DIRECT
  - DOMAIN-SUFFIX,youku.com,DIRECT
  - DOMAIN-SUFFIX,zealer.com,DIRECT
  - DOMAIN-SUFFIX,zhihu.com,DIRECT
  - DOMAIN-SUFFIX,zhimg.com,DIRECT
  - DOMAIN-SUFFIX,zimuzu.tv,DIRECT
  - DOMAIN-SUFFIX,zoho.com,DIRECT
  - DOMAIN-KEYWORD,amazon,🎯 全球直连
  - DOMAIN-KEYWORD,google,🎯 全球直连
  - DOMAIN-KEYWORD,gmail,🎯 全球直连
  - DOMAIN-KEYWORD,youtube,🎯 全球直连
  - DOMAIN-KEYWORD,facebook,🎯 全球直连
  - DOMAIN-SUFFIX,fb.me,🎯 全球直连
  - DOMAIN-SUFFIX,fbcdn.net,🎯 全球直连
  - DOMAIN-KEYWORD,twitter,🎯 全球直连
  - DOMAIN-KEYWORD,instagram,🎯 全球直连
  - DOMAIN-KEYWORD,dropbox,🎯 全球直连
  - DOMAIN-SUFFIX,twimg.com,🎯 全球直连
  - DOMAIN-KEYWORD,blogspot,🎯 全球直连
  - DOMAIN-SUFFIX,youtu.be,🎯 全球直连
  - DOMAIN-KEYWORD,whatsapp,🎯 全球直连
  - DOMAIN-KEYWORD,admarvel,REJECT
  - DOMAIN-KEYWORD,admaster,REJECT
  - DOMAIN-KEYWORD,adsage,REJECT
  - DOMAIN-KEYWORD,adsmogo,REJECT
  - DOMAIN-KEYWORD,adsrvmedia,REJECT
  - DOMAIN-KEYWORD,adwords,REJECT
  - DOMAIN-KEYWORD,adservice,REJECT
  - DOMAIN-SUFFIX,appsflyer.com,REJECT
  - DOMAIN-KEYWORD,domob,REJECT
  - DOMAIN-SUFFIX,doubleclick.net,REJECT
  - DOMAIN-KEYWORD,duomeng,REJECT
  - DOMAIN-KEYWORD,dwtrack,REJECT
  - DOMAIN-KEYWORD,guanggao,REJECT
  - DOMAIN-KEYWORD,lianmeng,REJECT
  - DOMAIN-SUFFIX,mmstat.com,REJECT
  - DOMAIN-KEYWORD,mopub,REJECT
  - DOMAIN-KEYWORD,omgmta,REJECT
  - DOMAIN-KEYWORD,openx,REJECT
  - DOMAIN-KEYWORD,partnerad,REJECT
  - DOMAIN-KEYWORD,pingfore,REJECT
  - DOMAIN-KEYWORD,supersonicads,REJECT
  - DOMAIN-KEYWORD,uedas,REJECT
  - DOMAIN-KEYWORD,umeng,REJECT
  - DOMAIN-KEYWORD,usage,REJECT
  - DOMAIN-SUFFIX,vungle.com,REJECT
  - DOMAIN-KEYWORD,wlmonitor,REJECT
  - DOMAIN-KEYWORD,zjtoolbar,REJECT
  - DOMAIN-SUFFIX,9to5mac.com,🎯 全球直连
  - DOMAIN-SUFFIX,abpchina.org,🎯 全球直连
  - DOMAIN-SUFFIX,adblockplus.org,🎯 全球直连
  - DOMAIN-SUFFIX,adobe.com,🎯 全球直连
  - DOMAIN-SUFFIX,akamaized.net,🎯 全球直连
  - DOMAIN-SUFFIX,alfredapp.com,🎯 全球直连
  - DOMAIN-SUFFIX,amplitude.com,🎯 全球直连
  - DOMAIN-SUFFIX,ampproject.org,🎯 全球直连
  - DOMAIN-SUFFIX,android.com,🎯 全球直连
  - DOMAIN-SUFFIX,angularjs.org,🎯 全球直连
  - DOMAIN-SUFFIX,aolcdn.com,🎯 全球直连
  - DOMAIN-SUFFIX,apkpure.com,🎯 全球直连
  - DOMAIN-SUFFIX,appledaily.com,🎯 全球直连
  - DOMAIN-SUFFIX,appshopper.com,🎯 全球直连
  - DOMAIN-SUFFIX,appspot.com,🎯 全球直连
  - DOMAIN-SUFFIX,arcgis.com,🎯 全球直连
  - DOMAIN-SUFFIX,archive.org,🎯 全球直连
  - DOMAIN-SUFFIX,armorgames.com,🎯 全球直连
  - DOMAIN-SUFFIX,aspnetcdn.com,🎯 全球直连
  - DOMAIN-SUFFIX,att.com,🎯 全球直连
  - DOMAIN-SUFFIX,awsstatic.com,🎯 全球直连
  - DOMAIN-SUFFIX,azureedge.net,🎯 全球直连
  - DOMAIN-SUFFIX,azurewebsites.net,🎯 全球直连
  - DOMAIN-SUFFIX,bing.com,🎯 全球直连
  - DOMAIN-SUFFIX,bintray.com,🎯 全球直连
  - DOMAIN-SUFFIX,bit.com,🎯 全球直连
  - DOMAIN-SUFFIX,bit.ly,🎯 全球直连
  - DOMAIN-SUFFIX,bitbucket.org,🎯 全球直连
  - DOMAIN-SUFFIX,bjango.com,🎯 全球直连
  - DOMAIN-SUFFIX,bkrtx.com,🎯 全球直连
  - DOMAIN-SUFFIX,blog.com,🎯 全球直连
  - DOMAIN-SUFFIX,blogcdn.com,🎯 全球直连
  - DOMAIN-SUFFIX,blogger.com,🎯 全球直连
  - DOMAIN-SUFFIX,blogsmithmedia.com,🎯 全球直连
  - DOMAIN-SUFFIX,blogspot.com,🎯 全球直连
  - DOMAIN-SUFFIX,blogspot.hk,🎯 全球直连
  - DOMAIN-SUFFIX,bloomberg.com,🎯 全球直连
  - DOMAIN-SUFFIX,box.com,🎯 全球直连
  - DOMAIN-SUFFIX,box.net,🎯 全球直连
  - DOMAIN-SUFFIX,cachefly.net,🎯 全球直连
  - DOMAIN-SUFFIX,chromium.org,🎯 全球直连
  - DOMAIN-SUFFIX,cl.ly,🎯 全球直连
  - DOMAIN-SUFFIX,cloudflare.com,🎯 全球直连
  - DOMAIN-SUFFIX,cloudfront.net,🎯 全球直连
  - DOMAIN-SUFFIX,cloudmagic.com,🎯 全球直连
  - DOMAIN-SUFFIX,cmail19.com,🎯 全球直连
  - DOMAIN-SUFFIX,cnet.com,🎯 全球直连
  - DOMAIN-SUFFIX,cocoapods.org,🎯 全球直连
  - DOMAIN-SUFFIX,comodoca.com,🎯 全球直连
  - DOMAIN-SUFFIX,crashlytics.com,🎯 全球直连
  - DOMAIN-SUFFIX,culturedcode.com,🎯 全球直连
  - DOMAIN-SUFFIX,d.pr,🎯 全球直连
  - DOMAIN-SUFFIX,danilo.to,🎯 全球直连
  - DOMAIN-SUFFIX,dayone.me,🎯 全球直连
  - DOMAIN-SUFFIX,db.tt,🎯 全球直连
  - DOMAIN-SUFFIX,deskconnect.com,🎯 全球直连
  - DOMAIN-SUFFIX,disq.us,🎯 全球直连
  - DOMAIN-SUFFIX,disqus.com,🎯 全球直连
  - DOMAIN-SUFFIX,disquscdn.com,🎯 全球直连
  - DOMAIN-SUFFIX,dnsimple.com,🎯 全球直连
  - DOMAIN-SUFFIX,docker.com,🎯 全球直连
  - DOMAIN-SUFFIX,dribbble.com,🎯 全球直连
  - DOMAIN-SUFFIX,droplr.com,🎯 全球直连
  - DOMAIN-SUFFIX,duckduckgo.com,🎯 全球直连
  - DOMAIN-SUFFIX,dueapp.com,🎯 全球直连
  - DOMAIN-SUFFIX,dytt8.net,🎯 全球直连
  - DOMAIN-SUFFIX,edgecastcdn.net,🎯 全球直连
  - DOMAIN-SUFFIX,edgekey.net,🎯 全球直连
  - DOMAIN-SUFFIX,edgesuite.net,🎯 全球直连
  - DOMAIN-SUFFIX,engadget.com,🎯 全球直连
  - DOMAIN-SUFFIX,entrust.net,🎯 全球直连
  - DOMAIN-SUFFIX,eurekavpt.com,🎯 全球直连
  - DOMAIN-SUFFIX,evernote.com,🎯 全球直连
  - DOMAIN-SUFFIX,fabric.io,🎯 全球直连
  - DOMAIN-SUFFIX,fast.com,🎯 全球直连
  - DOMAIN-SUFFIX,fastly.net,🎯 全球直连
  - DOMAIN-SUFFIX,fc2.com,🎯 全球直连
  - DOMAIN-SUFFIX,feedburner.com,🎯 全球直连
  - DOMAIN-SUFFIX,feedly.com,🎯 全球直连
  - DOMAIN-SUFFIX,feedsportal.com,🎯 全球直连
  - DOMAIN-SUFFIX,fiftythree.com,🎯 全球直连
  - DOMAIN-SUFFIX,firebaseio.com,🎯 全球直连
  - DOMAIN-SUFFIX,flexibits.com,🎯 全球直连
  - DOMAIN-SUFFIX,flickr.com,🎯 全球直连
  - DOMAIN-SUFFIX,flipboard.com,🎯 全球直连
  - DOMAIN-SUFFIX,g.co,🎯 全球直连
  - DOMAIN-SUFFIX,gabia.net,🎯 全球直连
  - DOMAIN-SUFFIX,geni.us,🎯 全球直连
  - DOMAIN-SUFFIX,gfx.ms,🎯 全球直连
  - DOMAIN-SUFFIX,ggpht.com,🎯 全球直连
  - DOMAIN-SUFFIX,ghostnoteapp.com,🎯 全球直连
  - DOMAIN-SUFFIX,git.io,🎯 全球直连
  - DOMAIN-KEYWORD,github,🎯 全球直连
  - DOMAIN-SUFFIX,globalsign.com,🎯 全球直连
  - DOMAIN-SUFFIX,gmodules.com,🎯 全球直连
  - DOMAIN-SUFFIX,godaddy.com,🎯 全球直连
  - DOMAIN-SUFFIX,golang.org,🎯 全球直连
  - DOMAIN-SUFFIX,gongm.in,🎯 全球直连
  - DOMAIN-SUFFIX,goo.gl,🎯 全球直连
  - DOMAIN-SUFFIX,goodreaders.com,🎯 全球直连
  - DOMAIN-SUFFIX,goodreads.com,🎯 全球直连
  - DOMAIN-SUFFIX,gravatar.com,🎯 全球直连
  - DOMAIN-SUFFIX,gstatic.com,🎯 全球直连
  - DOMAIN-SUFFIX,gvt0.com,🎯 全球直连
  - DOMAIN-SUFFIX,hockeyapp.net,🎯 全球直连
  - DOMAIN-SUFFIX,hotmail.com,🎯 全球直连
  - DOMAIN-SUFFIX,icons8.com,🎯 全球直连
  - DOMAIN-SUFFIX,ifixit.com,🎯 全球直连
  - DOMAIN-SUFFIX,ift.tt,🎯 全球直连
  - DOMAIN-SUFFIX,ifttt.com,🎯 全球直连
  - DOMAIN-SUFFIX,iherb.com,🎯 全球直连
  - DOMAIN-SUFFIX,imageshack.us,🎯 全球直连
  - DOMAIN-SUFFIX,img.ly,🎯 全球直连
  - DOMAIN-SUFFIX,imgur.com,🎯 全球直连
  - DOMAIN-SUFFIX,imore.com,🎯 全球直连
  - DOMAIN-SUFFIX,instapaper.com,🎯 全球直连
  - DOMAIN-SUFFIX,ipn.li,🎯 全球直连
  - DOMAIN-SUFFIX,is.gd,🎯 全球直连
  - DOMAIN-SUFFIX,issuu.com,🎯 全球直连
  - DOMAIN-SUFFIX,itgonglun.com,🎯 全球直连
  - DOMAIN-SUFFIX,itun.es,🎯 全球直连
  - DOMAIN-SUFFIX,ixquick.com,🎯 全球直连
  - DOMAIN-SUFFIX,j.mp,🎯 全球直连
  - DOMAIN-SUFFIX,js.revsci.net,🎯 全球直连
  - DOMAIN-SUFFIX,jshint.com,🎯 全球直连
  - DOMAIN-SUFFIX,jtvnw.net,🎯 全球直连
  - DOMAIN-SUFFIX,justgetflux.com,🎯 全球直连
  - DOMAIN-SUFFIX,kat.cr,🎯 全球直连
  - DOMAIN-SUFFIX,klip.me,🎯 全球直连
  - DOMAIN-SUFFIX,libsyn.com,🎯 全球直连
  - DOMAIN-SUFFIX,linkedin.com,🎯 全球直连
  - DOMAIN-SUFFIX,line-apps.com,🎯 全球直连
  - DOMAIN-SUFFIX,linode.com,🎯 全球直连
  - DOMAIN-SUFFIX,lithium.com,🎯 全球直连
  - DOMAIN-SUFFIX,littlehj.com,🎯 全球直连
  - DOMAIN-SUFFIX,live.com,🎯 全球直连
  - DOMAIN-SUFFIX,live.net,🎯 全球直连
  - DOMAIN-SUFFIX,livefilestore.com,🎯 全球直连
  - DOMAIN-SUFFIX,llnwd.net,🎯 全球直连
  - DOMAIN-SUFFIX,macid.co,🎯 全球直连
  - DOMAIN-SUFFIX,macromedia.com,🎯 全球直连
  - DOMAIN-SUFFIX,macrumors.com,🎯 全球直连
  - DOMAIN-SUFFIX,mashable.com,🎯 全球直连
  - DOMAIN-SUFFIX,mathjax.org,🎯 全球直连
  - DOMAIN-SUFFIX,medium.com,🎯 全球直连
  - DOMAIN-SUFFIX,mega.co.nz,🎯 全球直连
  - DOMAIN-SUFFIX,mega.nz,🎯 全球直连
  - DOMAIN-SUFFIX,megaupload.com,🎯 全球直连
  - DOMAIN-SUFFIX,microsofttranslator.com,🎯 全球直连
  - DOMAIN-SUFFIX,mindnode.com,🎯 全球直连
  - DOMAIN-SUFFIX,mobile01.com,🎯 全球直连
  - DOMAIN-SUFFIX,modmyi.com,🎯 全球直连
  - DOMAIN-SUFFIX,msedge.net,🎯 全球直连
  - DOMAIN-SUFFIX,myfontastic.com,🎯 全球直连
  - DOMAIN-SUFFIX,name.com,🎯 全球直连
  - DOMAIN-SUFFIX,nextmedia.com,🎯 全球直连
  - DOMAIN-SUFFIX,nsstatic.net,🎯 全球直连
  - DOMAIN-SUFFIX,nssurge.com,🎯 全球直连
  - DOMAIN-SUFFIX,nyt.com,🎯 全球直连
  - DOMAIN-SUFFIX,nytimes.com,🎯 全球直连
  - DOMAIN-SUFFIX,omnigroup.com,🎯 全球直连
  - DOMAIN-SUFFIX,onedrive.com,🎯 全球直连
  - DOMAIN-SUFFIX,onenote.com,🎯 全球直连
  - DOMAIN-SUFFIX,ooyala.com,🎯 全球直连
  - DOMAIN-SUFFIX,openvpn.net,🎯 全球直连
  - DOMAIN-SUFFIX,openwrt.org,🎯 全球直连
  - DOMAIN-SUFFIX,orkut.com,🎯 全球直连
  - DOMAIN-SUFFIX,osxdaily.com,🎯 全球直连
  - DOMAIN-SUFFIX,outlook.com,🎯 全球直连
  - DOMAIN-SUFFIX,ow.ly,🎯 全球直连
  - DOMAIN-SUFFIX,paddleapi.com,🎯 全球直连
  - DOMAIN-SUFFIX,parallels.com,🎯 全球直连
  - DOMAIN-SUFFIX,parse.com,🎯 全球直连
  - DOMAIN-SUFFIX,pdfexpert.com,🎯 全球直连
  - DOMAIN-SUFFIX,periscope.tv,🎯 全球直连
  - DOMAIN-SUFFIX,pinboard.in,🎯 全球直连
  - DOMAIN-SUFFIX,pinterest.com,🎯 全球直连
  - DOMAIN-SUFFIX,pixelmator.com,🎯 全球直连
  - DOMAIN-SUFFIX,pixiv.net,🎯 全球直连
  - DOMAIN-SUFFIX,playpcesor.com,🎯 全球直连
  - DOMAIN-SUFFIX,playstation.com,🎯 全球直连
  - DOMAIN-SUFFIX,playstation.com.hk,🎯 全球直连
  - DOMAIN-SUFFIX,playstation.net,🎯 全球直连
  - DOMAIN-SUFFIX,playstationnetwork.com,🎯 全球直连
  - DOMAIN-SUFFIX,pushwoosh.com,🎯 全球直连
  - DOMAIN-SUFFIX,rime.im,🎯 全球直连
  - DOMAIN-SUFFIX,servebom.com,🎯 全球直连
  - DOMAIN-SUFFIX,sfx.ms,🎯 全球直连
  - DOMAIN-SUFFIX,shadowsocks.org,🎯 全球直连
  - DOMAIN-SUFFIX,sharethis.com,🎯 全球直连
  - DOMAIN-SUFFIX,shazam.com,🎯 全球直连
  - DOMAIN-SUFFIX,skype.com,🎯 全球直连
  - DOMAIN-SUFFIX,smartdns🚀 节点选择.com,🎯 全球直连
  - DOMAIN-SUFFIX,smartmailcloud.com,🎯 全球直连
  - DOMAIN-SUFFIX,sndcdn.com,🎯 全球直连
  - DOMAIN-SUFFIX,sony.com,🎯 全球直连
  - DOMAIN-SUFFIX,soundcloud.com,🎯 全球直连
  - DOMAIN-SUFFIX,sourceforge.net,🎯 全球直连
  - DOMAIN-SUFFIX,spotify.com,🎯 全球直连
  - DOMAIN-SUFFIX,squarespace.com,🎯 全球直连
  - DOMAIN-SUFFIX,sstatic.net,🎯 全球直连
  - DOMAIN-SUFFIX,st.luluku.pw,🎯 全球直连
  - DOMAIN-SUFFIX,stackoverflow.com,🎯 全球直连
  - DOMAIN-SUFFIX,startpage.com,🎯 全球直连
  - DOMAIN-SUFFIX,staticflickr.com,🎯 全球直连
  - DOMAIN-SUFFIX,steamcommunity.com,🎯 全球直连
  - DOMAIN-SUFFIX,symauth.com,🎯 全球直连
  - DOMAIN-SUFFIX,symcb.com,🎯 全球直连
  - DOMAIN-SUFFIX,symcd.com,🎯 全球直连
  - DOMAIN-SUFFIX,tapbots.com,🎯 全球直连
  - DOMAIN-SUFFIX,tapbots.net,🎯 全球直连
  - DOMAIN-SUFFIX,tdesktop.com,🎯 全球直连
  - DOMAIN-SUFFIX,techcrunch.com,🎯 全球直连
  - DOMAIN-SUFFIX,techsmith.com,🎯 全球直连
  - DOMAIN-SUFFIX,thepiratebay.org,🎯 全球直连
  - DOMAIN-SUFFIX,theverge.com,🎯 全球直连
  - DOMAIN-SUFFIX,time.com,🎯 全球直连
  - DOMAIN-SUFFIX,timeinc.net,🎯 全球直连
  - DOMAIN-SUFFIX,tiny.cc,🎯 全球直连
  - DOMAIN-SUFFIX,tinypic.com,🎯 全球直连
  - DOMAIN-SUFFIX,tmblr.co,🎯 全球直连
  - DOMAIN-SUFFIX,todoist.com,🎯 全球直连
  - DOMAIN-SUFFIX,trello.com,🎯 全球直连
  - DOMAIN-SUFFIX,trustasiassl.com,🎯 全球直连
  - DOMAIN-SUFFIX,tumblr.co,🎯 全球直连
  - DOMAIN-SUFFIX,tumblr.com,🎯 全球直连
  - DOMAIN-SUFFIX,tweetdeck.com,🎯 全球直连
  - DOMAIN-SUFFIX,tweetmarker.net,🎯 全球直连
  - DOMAIN-SUFFIX,twitch.tv,🎯 全球直连
  - DOMAIN-SUFFIX,txmblr.com,🎯 全球直连
  - DOMAIN-SUFFIX,typekit.net,🎯 全球直连
  - DOMAIN-SUFFIX,ubertags.com,🎯 全球直连
  - DOMAIN-SUFFIX,ublock.org,🎯 全球直连
  - DOMAIN-SUFFIX,ubnt.com,🎯 全球直连
  - DOMAIN-SUFFIX,ulyssesapp.com,🎯 全球直连
  - DOMAIN-SUFFIX,urchin.com,🎯 全球直连
  - DOMAIN-SUFFIX,usertrust.com,🎯 全球直连
  - DOMAIN-SUFFIX,v.gd,🎯 全球直连
  - DOMAIN-SUFFIX,v2ex.com,🎯 全球直连
  - DOMAIN-SUFFIX,vimeo.com,🎯 全球直连
  - DOMAIN-SUFFIX,vimeocdn.com,🎯 全球直连
  - DOMAIN-SUFFIX,vine.co,🎯 全球直连
  - DOMAIN-SUFFIX,vivaldi.com,🎯 全球直连
  - DOMAIN-SUFFIX,vox-cdn.com,🎯 全球直连
  - DOMAIN-SUFFIX,vsco.co,🎯 全球直连
  - DOMAIN-SUFFIX,vultr.com,🎯 全球直连
  - DOMAIN-SUFFIX,w.org,🎯 全球直连
  - DOMAIN-SUFFIX,w3schools.com,🎯 全球直连
  - DOMAIN-SUFFIX,webtype.com,🎯 全球直连
  - DOMAIN-SUFFIX,wikiwand.com,🎯 全球直连
  - DOMAIN-SUFFIX,wikileaks.org,🎯 全球直连
  - DOMAIN-SUFFIX,wikimedia.org,🎯 全球直连
  - DOMAIN-SUFFIX,wikipedia.com,🎯 全球直连
  - DOMAIN-SUFFIX,wikipedia.org,🎯 全球直连
  - DOMAIN-SUFFIX,windows.com,🎯 全球直连
  - DOMAIN-SUFFIX,windows.net,🎯 全球直连
  - DOMAIN-SUFFIX,wire.com,🎯 全球直连
  - DOMAIN-SUFFIX,wordpress.com,🎯 全球直连
  - DOMAIN-SUFFIX,workflowy.com,🎯 全球直连
  - DOMAIN-SUFFIX,wp.com,🎯 全球直连
  - DOMAIN-SUFFIX,wsj.com,🎯 全球直连
  - DOMAIN-SUFFIX,wsj.net,🎯 全球直连
  - DOMAIN-SUFFIX,xda-developers.com,🎯 全球直连
  - DOMAIN-SUFFIX,xeeno.com,🎯 全球直连
  - DOMAIN-SUFFIX,xiti.com,🎯 全球直连
  - DOMAIN-SUFFIX,yahoo.com,🎯 全球直连
  - DOMAIN-SUFFIX,yimg.com,🎯 全球直连
  - DOMAIN-SUFFIX,ying.com,🎯 全球直连
  - DOMAIN-SUFFIX,yoyo.org,🎯 全球直连
  - DOMAIN-SUFFIX,ytimg.com,🎯 全球直连
  - DOMAIN-SUFFIX,telegra.ph,🎯 全球直连
  - DOMAIN-SUFFIX,telegram.org,🎯 全球直连
  - IP-CIDR,127.0.0.0/8,DIRECT
  - IP-CIDR,172.16.0.0/12,DIRECT
  - IP-CIDR,192.168.0.0/16,DIRECT
  - IP-CIDR,10.0.0.0/8,DIRECT
  - IP-CIDR,17.0.0.0/8,DIRECT
  - IP-CIDR,100.64.0.0/10,DIRECT
  - IP-CIDR,224.0.0.0/4,DIRECT
  - IP-CIDR,91.108.4.0/22,🚀 节点选择,no-resolve
  - IP-CIDR,91.108.8.0/21,🚀 节点选择,no-resolve
  - IP-CIDR,91.108.16.0/22,🚀 节点选择,no-resolve
  - IP-CIDR,91.108.56.0/22,🚀 节点选择,no-resolve
  - IP-CIDR,149.154.160.0/20,🚀 节点选择,no-resolve
  - IP-CIDR6,2001:67c:4e8::/48,🚀 节点选择,no-resolve
  - IP-CIDR6,2001:b28:f23d::/48,🚀 节点选择,no-resolve
  - IP-CIDR6,2001:b28:f23f::/48,🚀 节点选择,no-resolve
  - IP-CIDR,120.232.181.162/32,🚀 节点选择,no-resolve
  - IP-CIDR,120.241.147.226/32,🚀 节点选择,no-resolve
  - IP-CIDR,120.253.253.226/32,🚀 节点选择,no-resolve
  - IP-CIDR,120.253.255.162/32,🚀 节点选择,no-resolve
  - IP-CIDR,120.253.255.34/32,🚀 节点选择,no-resolve
  - IP-CIDR,120.253.255.98/32,🚀 节点选择,no-resolve
  - IP-CIDR,180.163.150.162/32,🚀 节点选择,no-resolve
  - IP-CIDR,180.163.150.34/32,🚀 节点选择,no-resolve
  - IP-CIDR,180.163.151.162/32,🚀 节点选择,no-resolve
  - IP-CIDR,180.163.151.34/32,🚀 节点选择,no-resolve
  - IP-CIDR,203.208.39.0/24,🚀 节点选择,no-resolve
  - IP-CIDR,203.208.40.0/24,🚀 节点选择,no-resolve
  - IP-CIDR,203.208.41.0/24,🚀 节点选择,no-resolve
  - IP-CIDR,203.208.43.0/24,🚀 节点选择,no-resolve
  - IP-CIDR,203.208.50.0/24,🚀 节点选择,no-resolve
  - IP-CIDR,220.181.174.162/32,🚀 节点选择,no-resolve
  - IP-CIDR,220.181.174.226/32,🚀 节点选择,no-resolve
  - IP-CIDR,220.181.174.34/32,🚀 节点选择,no-resolve
  - IP-CIDR6,fe80::/10,DIRECT
  - DOMAIN,injections.adguard.org,DIRECT
  - DOMAIN,local.adguard.org,DIRECT
  - DOMAIN-SUFFIX,local,DIRECT
  - DOMAIN-SUFFIX,cn,DIRECT
  - DOMAIN-KEYWORD,-cn,DIRECT
  - GEOIP,CN,DIRECT
  - MATCH,🚀 节点选择

```



### 附录2：代理工具下载地址

Windows：https://github.com/clash-verge-rev/clash-verge-rev

Android：https://github.com/MetaCubeX/ClashMetaForAndroid







## Clash 规则配置完全指南

------

### 一、规则基础语法与结构

#### 1. 规则三要素

每条规则由 **规则类型**、**匹配目标**、**路由策略** 三部分构成，格式为：

```yaml
规则类型,  匹配目标,  路由策略(,附加参数)
```

- **规则类型**：定义匹配流量的方式（如域名、IP、地理位置等）23
- **匹配目标**：具体匹配内容（如 `google.com` 或 `CN`）
- **路由策略**：决定流量处理方式（`DIRECT` 直连、`PROXY` 代理、`REJECT` 拦截）



#### 2. 常用规则类型

| 类型             | 说明                         | 示例                             |
| :--------------- | :--------------------------- | :------------------------------- |
| `DOMAIN`         | 精确匹配域名                 | `DOMAIN,www.google.com,PROXY`    |
| `DOMAIN-SUFFIX`  | 匹配域名后缀                 | `DOMAIN-SUFFIX,google.com,PROXY` |
| `DOMAIN-KEYWORD` | 匹配包含关键字的域名         | `DOMAIN-KEYWORD,ads,REJECT`      |
| `GEOIP`          | 按IP地理位置匹配（国家代码） | `GEOIP,CN,DIRECT`                |
| `IP-CIDR`        | IPv4地址段匹配               | `IP-CIDR,192.168.1.0/24,DIRECT`  |
| `MATCH`          | 兜底规则（必须最后一条）     | `MATCH,PROXY`                    |

------



### 二、进阶配置技巧

#### 1. 策略组（Proxy Groups）

通过策略组实现复杂路由逻辑，支持以下类型：

```yaml
proxy-groups:
  - name: "🌍 流媒体"
    type: url-test  # 自动选择延迟最低节点
    proxies: [香港节点, 美国节点]
    url: "http://www.gstatic.com/generate_204"
    interval: 300

  - name: "🚀 手动选择"
    type: select     # 手动切换节点
    proxies: [日本节点, 新加坡节点]
```

- **类型说明**：
  - `select`：手动选择节点
  - `url-test`：自动测速选择最优节点
  - `fallback`：故障切换备用节点
  - `load-balance`：负载均衡

#### 2. 规则集（Rule Providers）

引用动态更新的规则集提升管理效率：

```yaml
rule-providers:
  adblock:
    type: http
    behavior: domain
    url: "https://cdn.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/reject.txt"
    path: ./rulesets/adblock.yaml
    interval: 86400  # 每天更新

rules:
  - RULE-SET,adblock,REJECT  # 引用规则集
```

推荐规则集项目：[Loyalsoldier/clash-rules](https://github.com/Loyalsoldier/clash-rules)，包含广告拦截、流媒体分流等预定义规则

------

### 三、典型场景配置示例

#### 1. 基础分流配置

```yaml
rules:
  - DOMAIN-SUFFIX,netflix.com,🌍 流媒体  # 流媒体走专用组
  - GEOIP,CN,DIRECT                   # 国内IP直连
  - DOMAIN-KEYWORD,google,PROXY       # 包含google的域名代理
  - IP-CIDR,192.168.1.0/24,DIRECT     # 局域网直连
  - MATCH,PROXY                       # 其余流量代理
```

#### 2. 广告拦截配置

```yaml
rules:
  - DOMAIN-SUFFIX,adservice.com,REJECT
  - DOMAIN-KEYWORD,ads,REJECT
  - IP-CIDR,35.190.247.0/24,REJECT    # 拦截广告服务器IP段
```

#### 3. 混合模式配置



```yaml
# 结合直连列表与代理列表
rule-providers:
  direct-list:
    type: http
    url: "https://example.com/direct.txt"
  proxy-list:
    type: http
    url: "https://example.com/proxy.txt"

rules:
  - RULE-SET,direct-list,DIRECT
  - RULE-SET,proxy-list,PROXY
  - MATCH,DIRECT  # 未匹配流量直连
```

------



### 四、高级功能

#### 1. 进程级分流（仅限Premium版）



```yaml
rules:
  - PROCESS-NAME,chrome.exe,PROXY    # 指定Chrome走代理
  - PROCESS-PATH,/usr/bin/curl,DIRECT # 指定CURL直连
```

#### 2. 保留自定义规则（避免订阅覆盖）

使用 `proxy-providers` 分离节点与规则配置：

```yaml
proxy-providers:
  airport1:
    type: http
    url: "订阅链接"
    path: ./providers/airport1.yaml

rules:
  - DOMAIN-SUFFIX,mydomain.com,DIRECT  # 自定义规则
  - GEOIP,CN,DIRECT
  - MATCH,airport1   # 使用订阅节点:cite[4]
```

------

### 五、调试与问题排查

#### 1. 常见问题

- **规则不生效**：检查规则顺序（高优先级规则需置顶），确认DNS解析设置（推荐使用`tcp://8.8.8.8:53`）
- **代理泄漏真实IP**：启用TUN模式或Socks5代理，确保UDP流量被接管



#### 2. 调试命令

```bash
# 查看规则匹配日志
clash -d . -f config.yaml -l debug

# 测试域名解析
dig @localhost -p 1053 example.com
```

