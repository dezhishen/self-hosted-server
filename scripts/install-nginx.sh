# /bin/bash
echo "copy config file for nginx"
case $ssl in
[yY]* )
    http_scheme="https"
    # check if ssl cert dir exists
    if [ -d $base_data_dir/acmeout/*.$domain/ ]; then
        echo "ssl.crt already exist"
    else
        warning "ssl.crt not exist,please create it"
    fi
    sh `dirname $0`/fun-create-dir.sh $base_data_dir/nginx
    sh `dirname $0`/fun-create-dir.sh $base_data_dir/nginx/conf
    cp -f `dirname $0`/../nginx.conf.https $base_data_dir/nginx/conf/nginx.conf
    echo "copy config nginx.conf.https to $base_data_dir/nginx/conf/nginx.conf success"
    ;;
* )
    http_scheme="http"
    cp -f `dirname $0`/../nginx.conf $base_data_dir/nginx/conf/nginx.conf
    echo "copy config nginx.conf to $base_data_dir/nginx/conf/nginx.conf success"
    ;;
esac
# reset nginx conf by domain
echo "reset nginx config by domain: $domain"
sed -i `echo "s/\\$domain/$domain/g"` $base_data_dir/nginx/conf/nginx.conf
sed -i `echo "s/\\$domain/$domain/g"` $base_data_dir/nginx/conf/conf.d/*.conf

echo "reset nginx config by domain: $domain success"

sh `dirname $0`/fun-container-stop.sh nginx
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


# if enable ssl and enable auto update ssl cert,then start acme.sh if not running
case $ssl in
[yY]* )
    case $autossl in
        [yY]* )
        #check if docker container acme is running
        if [ `docker ps | grep acme | wc -l` -eq 1 ];then
            echo "acme.sh is running"
        else
            sh install-acme.sh
        fi
        ;;
    esac
;;
esac