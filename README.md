# 自建服务脚本
## 清单
* $domain为创建时指定，默认为`self.docker.com`

服务名称|描述|端口|访问地址
-|-|-|-
portainer|容器管理界面|-|portainer.$domain
adguardhome|私人dns|53/udp| adguardhome-init.$domain（初始化地址） / adguardhome.$domain（初始化时，修改管理界面端口为80，则通过该地址访问）
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
* 使用自己的ssl证书
    * 如需外网访问，务必启用https
    * 将ssl的证书的以下放在`./ssl_key`下
        * *.$domain.key
        * fullchain.cer
    * 证书获取方式[github.com/acmesh-official/acme.sh](https://github.com/acmesh-official/acme.sh)获取
* 给予当前用户所需要的权限（或者以sudo运行）
    * docker的权限
    * 根目录的权限
* 执行命令 `./all-in-one.sh`
    * -p 持久化存储根目录
    * -d 域名
    * -s 启用https
    * -g 自动生成https证书（仅支持acme.sh获取的免费时限证书）
        * 需要提供以下环境变量
            * `CF_Token`
            * `CF_Account_ID`
            * `CF_Zone_ID`
            * `SSL_EMAIL` ssl证书的邮箱账号
        * 使用cloudflare，如有其他需求，请自行修改`all-in-one.sh`
    * -u 自动更新https（仅支持acme.sh获取的免费时限证书）
        * 需要提供以下环境变量
            * `CF_Token`
            * `CF_Account_ID`
            * `CF_Zone_ID`
            * `SSL_EMAIL` ssl证书的邮箱账号
        * 使用cloudflare，如有其他需求，请自行修改`all-in-one.sh`

## 注意事项
* 切勿使用已存在的文件夹，或提前备份自己的文件夹
* windows下`portainer`容器需要根据[https://docs.portainer.io/v/ce-2.9/start/install/server/docker/wcs](https://docs.portainer.io/v/ce-2.9/start/install/server/docker/wcs)进行修改