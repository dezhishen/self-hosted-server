# /bin/bash
echo "copy config file to nginx"
case $ssl in
[yY]* )
    http_scheme="https"
    cp -f `dirname $0`/../conf.d.https/portainer.conf $base_data_dir/nginx/conf/conf.d/portainer.conf
    echo "copy config `dirname $0`/conf.d.https/portainer.conf to $base_data_dir/nginx/conf/conf.d/portainer.conf success"
    ;;
* )
    http_scheme="http"
    cp -f `dirname $0`/../conf.d/portainer.conf $base_data_dir/nginx/conf/conf.d/portainer.conf
    echo "copy config `dirname $0`/conf.d/portainer.conf to $base_data_dir/nginx/conf/conf.d/portainer.conf success"
    ;;
esac

sh `dirname $0`/fun-create-dir.sh $base_data_dir/portainer
sh `dirname $0`/fun-create-dir.sh $base_data_dir/portainer/data
sh `dirname $0`/fun-container-stop.sh portainer

echo "star portainer"
docker run -d --restart=always --name=portainer \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-v /var/run/docker.sock:/var/run/docker.sock \
-v $base_data_dir/portainer/data:/data \
--network=$docker_network_name --network-alias=portainer \
portainer/portainer-ce

echo "star portainer success"

echo "portainer is running at $http_scheme://portainer.$domain"

reload_nginx=1