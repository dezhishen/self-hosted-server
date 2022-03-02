# 自建服务脚本

## 介绍
* 纯`docker`环境下自建服务的脚本
### 期望

结合ddns实现外网访问

#### 推荐
* ipv6+cloudflare-ddns 实现外网访问

## 清单
* $domain 是反向代理的域名,创建时指定，默认为`self.docker.com`
* $base_data_dir 是所有存储的根目录，创建时指定，默认为`docker_data`

服务名称|描述|端口|访问地址
-|:-----|-|:------
[portainer](https://github.com/portainer/portainer)|容器管理界面|-|portainer.$domain
[adguardhome](https://github.com/AdguardTeam/AdGuardHome)|私人dns|53/tcp,53/udp| adguardhome-init.$domain(初始化地址)<br>adguardhome.$domain(初始化时，修改管理界面端口为**80**，则通过该地址访问)
[filebrowser](https://github.com/filebrowser/filebrowser)|文件管理|-|filebrowser.$domain
[nginx](https://github.com/nginx/nginx)|反向代理|80;443|$domain
[aria2-pro](https://github.com/P3TERX/Aria2-Pro-Docker)|下载神器|-|aria2-rpc.sdniu.top/jsonrpc(aria2的监听路径)
[vaultwarden](https://github.com/dani-garcia/vaultwarden)|密码管理器(适配`Bitwarden`)|-|valutwarden.$domain
[navidrome](https://github.com/navidrome/navidrome)|音乐服务(适配`Subsonic/Airsonic`)|-|navidrome.$domamin
[aliyundrive-webdav](https://github.com/messense/aliyundrive-webdav)|阿里云盘 WebDAV 服务(rust)|-|aliyundrive-webdav.$domain
[webssh2]|web端的ssh，无ipv6的外部环境需要ssh调试ipv6的宿主机时使用|-|webssh2.$domain
[samba](https://github.com/dperson/samba)|smb|139;445|宿主机ip/www<br>或者运行命令行查看<pre>echo "\`hostname -I \| cut -d ' ' -f 1\`/www"</pre>账号和密码在安装时指定
[acme](https://github.com/acmesh-official/acme.sh)|https自动续期的容器|-|-

## 根目录下文件夹布局
```
- $base_data_dir
    - A应用文件夹(同容器名)
        ...
    - public
        - downloads
        - music
        - videos 
        ...
            其他公共文件夹
        ...

        ...
    - Z应用文件夹(同容器名)
        ...

```

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
    * 由于https证书生成过程经常发生超时问题，请单独生成
        * 可以考虑通过`generate_ssl.sh`生成        
        * 使用acme.sh
        * 文件需要复制到 `$base_data_dir/acmeout/*.$domian` 下
            ```
            - ca.cer  
            - fullchain.cer  
            - *.$domain.cer  
            - *.$domain.conf  
            - *.$domain.csr  
            - *.$domain.csr.conf  
            - *.$domain.key
            ```
    * ~~-g 自动生成https证书（仅支持acme.sh获取的免费时限证书）~~
        ~~* 需要提供以下环境变量~~
            ~~* `CF_Token`~~
            ~~* `CF_Account_ID`~~
            ~~* `CF_Zone_ID`~~
            ~~* `SSL_EMAIL` ssl证书的邮箱账号~~
        ~~* 使用cloudflare，如有其他需求，请自行修改`all-in-one.sh`~~
    * -u 自动更新https（仅支持acme.sh获取的免费时限证书），且只支持`cloudflare`
        * 需要提供以下环境变量
            * `CF_Token`
            * `CF_Account_ID`
            * `CF_Zone_ID`
            * `SSL_EMAIL` ssl证书的邮箱账号
        * 使用cloudflare，如有其他需求，请自行修改`all-in-one.sh`
## todo
- [x] 收集和编写脚本
- [ ] 拆分`all-in-one.sh`的内容到其他脚本中
- [ ] 在当前会话中记录已输入的数据?
- [ ] 安装完成后打印结果

## 注意事项
* 避免使用已存在的文件夹，或备份自己的文件夹
* windows下`portainer`容器需要根据[https://docs.portainer.io/v/ce-2.9/start/install/server/docker/wcs](https://docs.portainer.io/v/ce-2.9/start/install/server/docker/wcs)进行修改