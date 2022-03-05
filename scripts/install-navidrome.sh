# /bin/bash

echo $COPY_NGINX_FILE_LANG
case $ssl in
[yY]* )
    http_scheme="https"
    cp -f `dirname $0`/../conf.d.https/navidrome.conf $base_data_dir/nginx/conf/conf.d/navidrome.conf
    ;;
* )
    http_scheme="http"
    cp -f `dirname $0`/../conf.d/navidrome.conf $base_data_dir/nginx/conf/conf.d/navidrome.conf
    ;;
esac

`dirname $0`/fun-create-dir.sh $base_data_dir/navidrome
`dirname $0`/fun-create-dir.sh $base_data_dir/navidrome/data
`dirname $0`/fun-create-dir.sh $base_data_dir/public
`dirname $0`/fun-create-dir.sh $base_data_dir/public/music

`dirname $0`/fun-container-stop.sh navidrome
docker run -d --name navidrome \
--network=$docker_network_name --network-alias=navidrome \
--user $(id -u):$(id -g) \
-e ND_LOGLEVEL=info \
-e LANG="zh_CN.UTF-8" \
-e TZ="Asia/Shanghai" \
-v $base_data_dir/public/music:/music \
-v $base_data_dir/navidrome/data:/data/ \
deluan/navidrome:latest

echo "navidrome启动成功，请访问$http_scheme://navidrome.$domain"
echo "start navidrome success,navidrome is running at $http_scheme://navidrome.$domain"