# 自建服务脚本

## 步骤
* 修改 [conf.d](./conf.d/) 下的域名
* 给予当前用户所需要的权限（或者以sudo运行）
* sh ./all-in-one.sh $数据存放根目录（默认为/docker_data）

## 注意事项
* 切勿使用已存在的文件夹，或提前备份自己的文件夹
* windows下`portainer`容器需要根据[https://docs.portainer.io/v/ce-2.9/start/install/server/docker/wcs](https://docs.portainer.io/v/ce-2.9/start/install/server/docker/wcs)进行修改