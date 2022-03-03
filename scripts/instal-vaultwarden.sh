# /bin/bash
echo "复制nginx配置文件"
echo "copy nginx config file"
case $ssl in
[yY]* )
    http_scheme="https"
    cp -f `dirname $0`/../conf.d.https/vaultwarden.conf $base_data_dir/nginx/conf/conf.d/vaultwarden.conf
    ;;
* )
    http_scheme="http"
    cp -f `dirname $0`/../conf.d/vaultwarden.conf $base_data_dir/nginx/conf/conf.d/vaultwarden.conf
    ;;
esac

sh `dirname $0`/fun-create-dir.sh $base_data_dir/vaultwarden
sh `dirname $0`/fun-create-dir.sh $base_data_dir/vaultwarden/data

sh `dirname $0`/fun-container-stop.sh vaultwarden

docker run -d --name vaultwarden \
--restart=always \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-u $(id -u):$(id -g) \
--network=$docker_network_name --network-alias=vaultwarden \
-v $base_data_dir/vaultwarden/data:/data/  \
vaultwarden/server:latest

echo "启动vaultwarden成功，vaultwarden 运行在 $http_scheme://vaultwarden.$domain"
echo "star vaultwarden success，vaultwarden is running at $http_scheme://vaultwarden.$domain"

# install vaultwarden-backup    
echo "是否安装vaultwarden-backup？"
echo "do you want to install/reinstall vaultwarden-backup? [y/n]: "
read yn
case $yn in
[Yy]* )
    sh `dirname $0`/fun-create-dir.sh $base_data_dir/vaultwarden-backup
    sh `dirname $0`/fun-create-dir.sh $base_data_dir/vaultwarden-backup/data
    sh `dirname $0`/fun-container-stop.sh vaultwarden-backup
    docker run -d --name vaultwarden-backup \
    --restart=always \
    -e TZ="Asia/Shanghai" \
    -e LANG="zh_CN.UTF-8" \
    -u $(id -u):$(id -g) \
    --network=$docker_network_name --network-alias=vaultwarden-backup \
    -v $base_data_dir/vaultwarden-backup/data:/data/  \
    vaultwarden/backup:latest
    echo "启动vaultwarden-backup成功，vaultwarden-backup 运行在 $http_scheme://vaultwarden-backup.$domain"
    echo "star vaultwarden-backup success,vaultwarden-backup is running at $http_scheme://vaultwarden-backup.$domain"
    ;;
esac