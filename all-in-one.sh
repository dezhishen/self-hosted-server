#/bin/bash

while getopts p:d:sug OPTION;do
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
    ?)
        echo "get a non option $OPTARG and OPTION is $OPTION"
        exit 1;;
    esac
done

if [ ! -n "$domain" ]; then  
    domain="self.docker.com"
fi

if [ ! -n "$base_data_dir" ]; then  
    base_data_dir="/docker_data"
fi

if [ ! -n "$generatessl" ]; then  
    generatessl=0
fi

if [ ! -n "$ssl" ]; then  
    ssl=0
fi

if [ ! -n "$autossl" ]; then  
    autossl=0
fi

echo "路径:$base_data_dir" 
echo "域名:$domain" 
echo "是否启用ssl:$ssl" 
echo "是否生成ssl证书:$generatessl" 
echo "是否自动更新ssl证书:$autossl" 




if [ ! -d $base_data_dir ];then
    mkdir $base_data_dir
# else
    #foldername=$(date +%Y%m%d%H%M%S)
    #cp -r $base_data_dir $base_data_dir.bak.$foldername
    #echo "已备份到:$dir.bak.$foldername"
fi

funCreateDir(){
    dir=$1
    if [ ! -d $dir ];then
        mkdir $dir
    fi
}

funStopContainer(){
    name=$1
    docker ps -a -q --filter "name=$name" | grep -q . && docker rm -fv $name
}

# 创建网络
docker network inspect ingress > network.info || docker network create --driver bridge ingress


# filebrowser
echo "是否安装/重装 filebrowser y/n"
read flag
if [ "$flag" = "y" ];then

    funCreateDir $base_data_dir/filebrowser

    cp ./filebrowser/filebrowser.db $base_data_dir/filebrowser/
    cp ./filebrowser/filebrowser.json $base_data_dir/filebrowser/

    funStopContainer filebrowser 

    docker run -d --restart=always --name=filebrowser \
    --network=ingress --network-alias=filebrowser \
    -u $(id -u):$(id -g) \
    -v $base_data_dir:/srv \
    -v "$base_data_dir/filebrowser/filebrowser.db:/database.db" \
    -v "$base_data_dir/filebrowser/filebrowser.json:/.filebrowser.json" \
    -e TZ="Asia/Shanghai" \
    filebrowser/filebrowser

fi

# portainer

echo "是否安装/重装 portainer y/n"
read flag
if [ "$flag" = "y" ];then

    funCreateDir $base_data_dir/portainer
    funCreateDir $base_data_dir/portainer/data
    funStopContainer portainer 
    docker run -d --restart=always --name=portainer \
    -e TZ="Asia/Shanghai" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $base_data_dir/portainer/data:/data \
    --network=ingress --network-alias=portainer \
    portainer/portainer-ce
fi

# adguardhome

echo "是否安装/重装 adguardhome y/n"
read flag
if [ "$flag" = "y" ];then

    funCreateDir $base_data_dir/adguardhome
    funCreateDir $base_data_dir/adguardhome/work
    funCreateDir $base_data_dir/adguardhome/conf
    funStopContainer adguardhome 
    docker run -d --restart=always --name=adguardhome \
    -p 53:53 \
    -e TZ="Asia/Shanghai" \
    --network=ingress --network-alias=adguardhome \
    -v $base_data_dir/adguardhome/work:/opt/adguardhome/work \
    -v $base_data_dir/adguardhome/conf:/opt/adguardhome/conf \
    adguard/adguardhome
fi
# webssh

# echo "是否安装/重装 webssh y/n"
# read flag
# if [ "$flag" = "y" ];then
#     funStopContainer webssh2 
#     docker run --name webssh2 -d --network=ingress --network-alias=webssh2  psharkey/webssh2
# fi

# nginx
echo "是否安装/重装 nginx y/n"
read flag
if [ "$flag" = "y" ];then

    funCreateDir $base_data_dir/nginx
    funCreateDir $base_data_dir/nginx/conf
    funCreateDir $base_data_dir/nginx/conf/conf.d
    funStopContainer nginx

    if [ $ssl -eq 1 ]; then
        cp nginx.conf.https $base_data_dir/nginx/conf/nginx.conf
        cp -r ./conf.d.https/* $base_data_dir/nginx/conf/conf.d/
        #funCreateDir $base_data_dir/nginx/ssl
        funCreateDir $base_data_dir/acmeout
        if [ $generatessl -eq 1 ]; then
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

            docker run -it --rm \
                -e TZ="Asia/Shanghai" \
                -e CF_Token=`echo $CF_Token` \
                -e CF_Account_ID=`echo $CF_Account_ID` \
                -e CF_Zone_ID=`echo $CF_Zone_ID` \
                -v $base_data_dir/acmeout:/acme.sh \
                neilpang/acme.sh --issue -d *.$domain --dns dns_cf -m `echo $SSL_EMAIL` || exit 1
        else
            funCreateDir $base_data_dir/acmeout/*.$domain
            cp -r ./ssl_key/* $base_data_dir/acmeout/*.$domain/
        fi
    else
        cp nginx.conf $base_data_dir/nginx/conf/
        cp -r ./conf.d/* $base_data_dir/nginx/conf/conf.d/
    fi

    sed -i `echo "s/\\$domain/$domain/g"` $base_data_dir/nginx/conf/nginx.conf
    sed -i `echo "s/\\$domain/$domain/g"` $base_data_dir/nginx/conf/conf.d/*.conf

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
        docker run -d --restart=always --name=nginx \
        -v $base_data_dir/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
        -v $base_data_dir/nginx/conf/conf.d:/etc/nginx/conf.d \
        -p 80:80 -p 443:443 \
        -e TZ="Asia/Shanghai" \
        --network=ingress --network-alias=ingress \
        nginx
    fi
fi
