# /bin/bash

while getopts p:d:sugh OPTION; do
    case $OPTION in
    p)
        base_data_dir=$OPTARG
        ;;
    d)
        domain=$OPTARG
        ;;
    s)
        ssl=1
        ;;
    u)
        autossl=1
        ;;
    g)
        generatessl=1
        ;;
    h)
        echo "-d domian -u 自动更新https证书 -s 使用https -g 生成https证书 -p 持久化根目录"
        exit 1;;
    ?)
        echo "get a non option $OPTARG and OPTION is $OPTION"
        exit 1;;
    esac
done

if [ ! -n "$domain" ]; then  
    echo "请输入域名,默认为self.docker.com"
    read domain
    if [ ! -n "$domain" ]; then  
        domain="self.docker.com"
    fi
fi

if [ ! -n "$base_data_dir" ]; then  
    echo "请输入docker卷使用的根目录,默认为/docker_data"
    read base_data_dir
    if [ ! -n "$base_data_dir" ]; then  
        base_data_dir="/docker_data"
    fi
fi

if [ ! -n "$ssl" ]; then  
    echo "是否启用https: y/n?"
    read flag
    if [ "$flag" = "y" ];then
        ssl=1
    else
        ssl=0
    fi
fi

if [ ! -n "$generatessl" ]; then  
    echo "是否生成https证书: y/n?"
    read flag
    if [ "$flag" = "y" ];then
        generatessl=1
    else
        generatessl=0
    fi

fi

if [ ! -n "$autossl" ]; then  
    echo "是否自动更新https证书: y/n?"
    read flag
    if [ "$flag" = "y" ];then
        autossl=1
    else
        autossl=0
    fi
fi
echo "配置信息如下"
echo ""
echo ""
printf "%s:\t%s\n%s:\t%s\n%s:\t%s\n%s:\t%s\n%s:\t%s\n" \
路径 $base_data_dir \
域名 $domain \
启用ssl $ssl \
生成ssl证书 $generatessl \
自动更新ssl证书  $autossl | column -t

echo ""
echo ""
printf "开始进入安装程序。。。
注意:如无特殊说明重装不会影响数据持久化，如担心风险请在备份环节中选择数据备份 
"

echo "是否继续安装 y/n"
read flag
if [ ! "$flag" = "y" ];then
    exit 1
fi


funCreateDir(){
    dir=$1
    if [ ! -d $dir ];then
        mkdir $dir
        echo "成功创建文件夹 $dir"
    else
        echo "文件夹 $dir 已存在，跳过"
    fi
}

funStopContainer(){
    name=$1
    echo "停止和删除容器 $name（如果已存在）"
    docker ps -a -q --filter "name=$name" | grep -q . && docker rm -fv $name
}

# 创建根目录
echo "正在创建根目录 $base_data_dir"
if [ ! -d $base_data_dir ];then
    mkdir $base_data_dir
else
    echo "文件夹[$base_data_dir]已存在，是否需要备份:y/n"
    read flag
    if [ "$flag" = "y" ];then
        foldername=$(date +%Y%m%d%H%M%S)
        cp -r $base_data_dir $base_data_dir.bak.$foldername
        echo "已备份到:[ $base_data_dir.bak.$foldername ]"
    fi
fi

# 创建网络
echo "创建容器的网络"

docker network inspect ingress > network.info || docker network create --driver bridge ingress

echo "网络信息在 network.info 文件中，也可以执行 docker network inspect ingress 查看"

# filebrowser
echo "是否安装/重装 filebrowser y/n"
read flag
if [ "$flag" = "y" ];then
    echo "复制nginx需要的配置文件"
    if [ $ssl -eq 1 ]; then
        cp -f ./conf.d.https/filebrowser.conf $base_data_dir/nginx/conf/conf.d/filebrowser.conf
    else
        cp -f ./conf.d/filebrowser.conf $base_data_dir/nginx/conf/conf.d/filebrowser.conf
    fi
    funCreateDir $base_data_dir/filebrowser
    funStopContainer filebrowser 
    if [ ! -f $base_data_dir/filebrowser/filebrowser.db ];then
        echo "配置文件[filebrowser.db]不存在，创建"
        cp  -f ./filebrowser/filebrowser.db $base_data_dir/filebrowser/filebrowser.db 
    else
        echo "配置文件[filebrowser.db]已存在，跳过"
    fi
    if [ ! -f $base_data_dir/filebrowser/filebrowser.json ];then
        echo "配置文件[filebrowser.json]不存在，创建"
        cp  -f ./filebrowser/filebrowser.json $base_data_dir/filebrowser/filebrowser.json
    else
        echo "配置文件[filebrowser.json]已存在，跳过"
    fi
    echo "开始启动容器 filebrowser"
    docker run -d --restart=always --name=filebrowser \
    --network=ingress --network-alias=filebrowser \
    -u $(id -u):$(id -g) \
    -v $base_data_dir:/srv \
    -v "$base_data_dir/filebrowser/filebrowser.db:/database.db" \
    -v "$base_data_dir/filebrowser/filebrowser.json:/.filebrowser.json" \
    -e TZ="Asia/Shanghai" \
    filebrowser/filebrowser
    echo "完成启动容器 filebrowser"
    echo "访问路径 filebrowser.$domain"
fi


# portainer

echo "是否安装/重装 portainer y/n"
read flag
if [ "$flag" = "y" ];then
    echo "复制nginx需要的配置文件"
    if [ $ssl -eq 1 ]; then
        cp -f ./conf.d.https/portainer.conf $base_data_dir/nginx/conf/conf.d/portainer.conf
    else
        cp -f ./conf.d/portainer.conf $base_data_dir/nginx/conf/conf.d/portainer.conf
    fi
    funCreateDir $base_data_dir/portainer
    funCreateDir $base_data_dir/portainer/data
    funStopContainer portainer 
    
    echo "开始启动容器 portainer"
    docker run -d --restart=always --name=portainer \
    -u $(id -u):$(id -g) \
    -e TZ="Asia/Shanghai" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $base_data_dir/portainer/data:/data \
    --network=ingress --network-alias=portainer \
    portainer/portainer-ce
    echo "完成启动容器 portainer"
    echo "访问路径 portainer.$domain"
fi


echo "是否安装/重装 adguardhome y/n"
read flag
if [ "$flag" = "y" ];then
    echo "复制nginx需要的配置文件"
    if [ $ssl -eq 1 ]; then
        cp -f ./conf.d.https/adguardhome.conf $base_data_dir/nginx/conf/conf.d/adguardhome.conf
    else
        cp -f ./conf.d/adguardhome.conf $base_data_dir/nginx/conf/conf.d/adguardhome.conf
    fi
    funCreateDir $base_data_dir/adguardhome
    funCreateDir $base_data_dir/adguardhome/work
    funCreateDir $base_data_dir/adguardhome/conf
    funStopContainer adguardhome 
    
    echo "开始启动容器 adguardhome"
    docker run -d --restart=always --name=adguardhome \
    -u $(id -u):$(id -g) \
    -p 53:53/udp -p 53:53/tcp \
    -e TZ="Asia/Shanghai" \
    --network=ingress --network-alias=adguardhome \
    -v $base_data_dir/adguardhome/work:/opt/adguardhome/work \
    -v $base_data_dir/adguardhome/conf:/opt/adguardhome/conf \
    adguard/adguardhome
    echo "完成启动容器 adguardhome"
    echo "访问路径: adguardhome-init.$domain"
    echo "配置完成后访问路径: adguardhome.$domain"
fi

# webssh
echo "webssh 目前arm不兼容兼容，arm不建议安装"
echo "是否安装/重装 webssh y/n"
read flag
if [ "$flag" = "y" ];then
    echo "复制nginx需要的配置文件"
    if [ $ssl -eq 1 ]; then
        cp -f ./conf.d.https/webssh2.conf $base_data_dir/nginx/conf/conf.d/webssh2.conf
    else
        cp -f ./conf.d/webssh2.conf $base_data_dir/nginx/conf/conf.d/webssh2.conf
    fi
    funCreateDir $base_data_dir/webssh2
    if [ ! -f $base_data_dir/webssh2/config.json ];then
        echo "配置文件[config.json]不存在，创建"
        cp  -f ./webssh2/config.json $base_data_dir/webssh2/config.json
    else
        echo "配置文件[config.json]已存在，跳过"
    fi
    funStopContainer webssh2 
    echo "开始启动容器 webssh2"
    docker run --name webssh2 -d \
    --restart=always \
    -v $base_data_dir/webssh2/config.json:/usr/src/config.json \
    --network=ingress --network-alias=webssh2  \
    -u $(id -u):$(id -g) \
    psharkey/webssh2
    echo "完成启动容器 webssh2"
    echo "访问路径: webssh2.$domain"
fi

# navidrome

echo "是否安装/重装 navidrome: y/n"
read flag
if [ "$flag" = "y" ];then
    echo "复制nginx需要的配置文件"
    if [ $ssl -eq 1 ]; then
        cp -f ./conf.d.https/navidrome.conf $base_data_dir/nginx/conf/conf.d/navidrome.conf
    else
        cp -f ./conf.d/navidrome.conf $base_data_dir/nginx/conf/conf.d/navidrome.conf
    fi
    funCreateDir $base_data_dir/navidrome
    funCreateDir $base_data_dir/navidrome/data
    funCreateDir $base_data_dir/public/
    funCreateDir $base_data_dir/public/music
    funStopContainer navidrome 
    echo "开始启动容器 navidrome"
    docker run -d --name navidrome \
    --network=ingress --network-alias=navidrome \
    --user $(id -u):$(id -g) \
    -e ND_LOGLEVEL=info \
    -e LANG="zh_CN.UTF-8" \
    -e TZ="Asia/Shanghai" \
    -v $base_data_dir/public/music:/music \
    -v $base_data_dir/navidrome/data:/data/ \
    deluan/navidrome:latest
    echo "完成启动容器 navidrome"
    echo "访问路径: navidrome.$domain"
fi


# vaultwarden
echo "是否安装/重装 vaultwarden: y/n"
read flag
if [ "$flag" = "y" ];then
    echo "复制nginx需要的配置文件"
    if [ $ssl -eq 1 ]; then
        cp -f ./conf.d.https/vaultwarden.conf $base_data_dir/nginx/conf/conf.d/vaultwarden.conf
    else
        cp -f ./conf.d/vaultwarden.conf $base_data_dir/nginx/conf/conf.d/vaultwarden.conf
    fi
    funCreateDir $base_data_dir/vaultwarden
    funCreateDir $base_data_dir/vaultwarden/data
    funStopContainer vaultwarden 
    echo "开始启动容器 vaultwarden"
    docker run -d --name vaultwarden \
    -u $(id -u):$(id -g) \
    --network=ingress --network-alias=vaultwarden \
    -v $base_data_dir/vaultwarden/data:/data/  \
    vaultwarden/server:latest
    echo "完成启动容器 vaultwarden"
    echo "访问路径: vaultwarden.$domain"
fi

# aria2

echo "是否安装/重装 aria2 y/n"
read flag
if [ "$flag" = "y" ];then
    echo "复制nginx需要的配置文件"
    if [ $ssl -eq 1 ]; then
        cp -f ./conf.d.https/aria2.conf $base_data_dir/nginx/conf/conf.d/aria2.conf
    else
        cp -f ./conf.d/aria2.conf $base_data_dir/nginx/conf/conf.d/aria2.conf
    fi
    
    funCreateDir $base_data_dir/aria2
    funCreateDir $base_data_dir/public
    funCreateDir $base_data_dir/public/downloads
    if [ ! -n "$ARIA2_RPC_SECRET" ];then
        echo "请输入RPC密钥"
        read ARIA2_RPC_SECRET
        if [ ! -n "$ARIA2_RPC_SECRET" ];then
            ARIA2_RPC_SECRET=`date +%s | sha256sum | base64 | head -c 32 ; echo`
            echo "使用随机密钥 $ARIA2_RPC_SECRET"
        fi
        funStopContainer aria2 
        echo "开始启动容器 aria2"
        docker run --name aria2 -d \
            --restart unless-stopped \
            --log-opt max-size=1m \
            --network ingress --network-alias=aria2 \
            -e PUID=`id -u` \
            -e PGID=`id -g` \
            -e RPC_SECRET=`echo $ARIA2_RPC_SECRET` \
            -e RPC_PORT=6800 \
            -e LISTEN_PORT=6888 \
            -v /docker_data/aria2:/config \
            -v /docker_data/public/:/public \
        p3terx/aria2-pro
        
        echo "修改aria2默认下载路径"
        
        sed -i `echo "s/dir=\/downloads/dir=\public/downloads/g"` $base_data_dir/aria2/aria2.conf
        sed -i "s#/downloads#/public/downloads#g" $base_data_dir/aria2/aria2.conf
        docker restart aria2
        echo "完成启动容器 aria2"
        echo "rpc路径: aria2-rpc.$domain/jsonrpc"
        echo "密钥: $ARIA2_RPC_SECRET"
    fi
fi


# nginx
echo "是否安装/重装 nginx y/n"
read flag
if [ "$flag" = "y" ];then
    echo "开始复制nginx配置文件"
    if [ $ssl -eq 1 ]; then
        echo "启用了https"
        echo "创建https证书存放目录"
        funCreateDir $base_data_dir/acmeout
        echo "复制 nginx.conf"
        cp -f nginx.conf.https $base_data_dir/nginx/conf/nginx.conf
    else
        echo "未启用https"
        echo "复制 nginx.conf"
        cp -f nginx.conf $base_data_dir/nginx/conf/nginx.conf
    fi
    echo "根据域名修改配置文件"
    sed -i `echo "s/\\$domain/$domain/g"` $base_data_dir/nginx/conf/nginx.conf
    sed -i `echo "s/\\$domain/$domain/g"` $base_data_dir/nginx/conf/conf.d/*.conf
    echo "修改完毕"
    funStopContainer nginx
    if [ $ssl -eq 1 ] ; then
        docker run -d --restart=always --name=nginx \
            -v $base_data_dir/acmeout/*.$domain:/etc/nginx/ssl/ \
            -v $base_data_dir/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
            -v $base_data_dir/nginx/conf/conf.d:/etc/nginx/conf.d \
            -p 80:80 -p 443:443 \
            -e TZ="Asia/Shanghai" \
            --label=sh.acme.autoload.domain=*.$domain \
            --network=ingress --network-alias=ingress \
            nginx
        if [ $autossl -eq 1 ]; then
            echo "启动https证书自动更新容器"
            if [ ! -n "$CF_Token" ]; then  
                echo "请输入CF_Token:"
                read CF_Token
            fi
            if [ ! -n "$CF_Account_ID" ]; then  
                echo "请输入CF_Account_ID:"
                read CF_Account_ID
            fi
            if [ ! -n "$CF_Zone_ID" ]; then  
                echo "请输入CF_Zone_ID:"
                read CF_Zone_ID
            fi
            if [ ! -n "$SSL_EMAIL" ]; then  
                echo "请输入ssl的邮箱:"
                read SSL_EMAIL
            fi
            funStopContainer acme
            docker run --name=acme --restart=always -d \
                -u $(id -u):$(id -g) \
                -e CF_Token=`echo $CF_Token`\
                -e CF_Account_ID=`echo $CF_Account_ID` \
                -e CF_Zone_ID=`echo $CF_Zone_ID` \
                -v $base_data_dir/nginx/ssl:/acme.sh/$domain/ \
                -v $base_data_dir/acmeout:/acme.sh \
                -v /var/run/docker.sock:/var/run/docker.sock \
                -e DEPLOY_DOCKER_CONTAINER_LABEL=sh.acme.autoload.domain=*.$domain \
                -e DEPLOY_DOCKER_CONTAINER_KEY_FILE=/etc/nginx/ssl/*.$domain.key \
                -e DEPLOY_DOCKER_CONTAINER_CERT_FILE="/etc/nginx/ssl/*.$domain.cer" \
                -e DEPLOY_DOCKER_CONTAINER_CA_FILE="/etc/nginx/ssl/ca.cer" \
                -e DEPLOY_DOCKER_CONTAINER_FULLCHAIN_FILE="/etc/nginx/ssl/fullchain.cer" \
                -e DEPLOY_DOCKER_CONTAINER_RELOAD_CMD="service nginx force-reload" \
                neilpang/acme.sh daemon
        fi
    else
        echo "启动nginx..."
        docker run -d --restart=always --name=nginx \
        -v $base_data_dir/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
        -v $base_data_dir/nginx/conf/conf.d:/etc/nginx/conf.d \
        -p 80:80 -p 443:443 \
        -e TZ="Asia/Shanghai" \
        --network=ingress --network-alias=ingress \
        nginx
    fi
else
    echo "是否重启nginx: y/n"
    read flag
    if [ "$flag" = "y" ];then
        echo "根据域名修改配置文件"
        sed -i `echo "s/\\$domain/$domain/g"` $base_data_dir/nginx/conf/nginx.conf
        sed -i `echo "s/\\$domain/$domain/g"` $base_data_dir/nginx/conf/conf.d/*.conf
        echo "修改完毕"
        docker restart nginx
    fi
fi
echo "安装完成，即将退出"