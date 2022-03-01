# 自建服务脚本
## 介绍
纯`docker`环境下自建服务的脚本
### 期望
结合ddns实现外网访问
#### 推荐
* ipv6+cloudflare-ddns 实现外网访问
## 步骤
* 安装docker
* 修改 [conf.d](./conf.d/) 下的域名
* 给予当前用户所需要的权限（或者以sudo运行）
* sh ./all-in-one.sh -p $数据存放根目录（默认为/docker_data） -d domain (默认为：self.docker.com 如 foo.bar, 最终访问域名为 portainer.foo.bar 等)

## 注意事项
* 切勿使用已存在的文件夹，或提前备份自己的文件夹
* windows下`portainer`容器需要根据[https://docs.portainer.io/v/ce-2.9/start/install/server/docker/wcs](https://docs.portainer.io/v/ce-2.9/start/install/server/docker/wcs)进行修改