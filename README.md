# 自建服务脚本
## 清单
* $domain为创建时指定，默认为`self.docker.com`

服务名称|描述|端口|访问地址
-|-|-|-
portainer|容器管理界面|-|portainer.$domain
adguardhome|私人dns|53/udp|adguardhome.$domain
filebrowser|文件管理|-|filebrowser.$domain
nginx|反向代理|80；443|$domain

## 介绍
纯`docker`环境下自建服务的脚本
### 期望
结合ddns实现外网访问
#### 推荐
* ipv6+cloudflare-ddns 实现外网访问
## 步骤
* 安装docker
* 修改提供ssl证书
    * 如需外网访问，务必启用https
    * 将ssl的证书的以下放在`./ssl_key`下
        * private.key
        * fullchain.cer
    * 证书获取方式[github.com/acmesh-official/acme.sh](https://github.com/acmesh-official/acme.sh)获取
* 给予当前用户所需要的权限（或者以sudo运行）
    * docker的权限
    * 根目录的权限
* 执行命令 `./all-in-one.sh`
    * -p 持久化存储根目录
    * -d 域名
    * -s 任意值代表启用https

## 注意事项
* 切勿使用已存在的文件夹，或提前备份自己的文件夹
* windows下`portainer`容器需要根据[https://docs.portainer.io/v/ce-2.9/start/install/server/docker/wcs](https://docs.portainer.io/v/ce-2.9/start/install/server/docker/wcs)进行修改