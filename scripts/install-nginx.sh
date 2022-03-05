# /bin/bash

. `dirname $0`/fun-container-stop.sh nginx
pwd
case $ssl in
[yY]* )
    http_scheme="https"
    # check if ssl cert dir exists
    echo "检查证书目录,check ssl cert dir"
    if [ -d $base_data_dir/acmeout/*.$domain/ ]; then
        echo "证书目录存在,cert dir exists"
    else
        echo "[警告] 证书目录不存在"
        echo "[warning]cert dir not exists"
    fi
    pwd
    . `dirname $0`/fun-create-dir.sh $base_data_dir/nginx
    . `dirname $0`/fun-create-dir.sh $base_data_dir/nginx/conf
    cp "`dirname $0`/../nginx.conf.https" $base_data_dir/nginx/conf/nginx.conf
    ;;
* )
    http_scheme="http"
    rm -rf $base_data_dir/nginx/conf/nginx.conf
    cp " `dirname $0`/../nginx.conf" $base_data_dir/nginx/conf/nginx.conf
    ;;
esac

# reset nginx conf by domain
echo "使用$domain替换root domain"
echo "replace root domian in nginx conf by $domain"
sed -i `echo "s/\\$domain/$domain/g"` $base_data_dir/nginx/conf/nginx.conf
sed -i `echo "s/\\$domain/$domain/g"` $base_data_dir/nginx/conf/conf.d/*.conf
case $ssl in
[yY]* )
    docker run -d --restart=always --name=nginx \
        -v $base_data_dir/acmeout/*.$domain:/etc/nginx/ssl/ \
        -v $base_data_dir/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
        -v $base_data_dir/nginx/conf/conf.d:/etc/nginx/conf.d \
        -p 80:80 -p 443:443 \
        -e TZ="Asia/Shanghai" \
        -e LANG="zh_CN.UTF-8" \
        --label=sh.acme.autoload.domain=*.$domain \
        --network=ingress --network-alias=ingress \
        nginx
    ;;
* )
    echo "start nginx"
    docker run -d --restart=always --name=nginx \
    -v $base_data_dir/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
    -v $base_data_dir/nginx/conf/conf.d:/etc/nginx/conf.d \
    -p 80:80 -p 443:443 \
    -e TZ="Asia/Shanghai" \
    --network=ingress --network-alias=ingress \
    nginx
    ;;
esac


case $ssl in
[yY]* )
    case $autossl in
        [yY]* )
        #check if docker container acme is running
        if [ `docker ps | grep acme | wc -l` -eq 1 ];then
            echo "证书自动更新容器acme正在运行,acme is running"
        else
            install-acme.sh
        fi
        ;;
    esac
;;
esac