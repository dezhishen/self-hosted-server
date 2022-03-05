# /bin/bash
echo $COPY_NGINX_FILE_LANG

case $ssl in
[yY]* )
    http_scheme="https"
    cp -f `dirname $0`/../conf.d.https/portainer.conf $base_data_dir/nginx/conf/conf.d/portainer.conf
    ;;
* )
    http_scheme="http"
    cp -f `dirname $0`/../conf.d/portainer.conf $base_data_dir/nginx/conf/conf.d/portainer.conf
    ;;
esac

`dirname $0`/fun-create-dir.sh $base_data_dir/portainer
`dirname $0`/fun-create-dir.sh $base_data_dir/portainer/data
`dirname $0`/fun-container-stop.sh portainer

docker run -d --restart=always --name=portainer \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-v /var/run/docker.sock:/var/run/docker.sock \
-v $base_data_dir/portainer/data:/data \
--network=$docker_network_name --network-alias=portainer \
portainer/portainer-ce

echo "portainer启动成功，请访问$http_scheme://portainer.$domain"
echo "star portainer success,portainer is running at $http_scheme://portainer.$domain"
