# /bin/bash
echo "copy config file to nginx"
case $ssl in
[yY]* )
    http_scheme="https"
    cp -f `dirname $0`/../conf.d.https/vaultwarden.conf $base_data_dir/nginx/conf/conf.d/vaultwarden.conf
    echo "copy config `dirname $0`/conf.d.https/vaultwarden.conf to $base_data_dir/nginx/conf/conf.d/vaultwarden.conf success"
    ;;
* )
    http_scheme="http"
    cp -f `dirname $0`/../conf.d/vaultwarden.conf $base_data_dir/nginx/conf/conf.d/vaultwarden.conf
    echo "copy config `dirname $0`/conf.d/vaultwarden.conf to $base_data_dir/nginx/conf/conf.d/vaultwarden.conf success"
    ;;
esac

sh `dirname $0`/fun-create-dir.sh $base_data_dir/vaultwarden
sh `dirname $0`/fun-create-dir.sh $base_data_dir/vaultwarden/data

sh `dirname $0`/fun-container-stop.sh vaultwarden

echo "star vaultwarden"

docker run -d --name vaultwarden \
--restart=always \
-e TZ="Asia/Shanghai" \
-e LANG="zh_CN.UTF-8" \
-u $(id -u):$(id -g) \
--network=$docker_network_name --network-alias=vaultwarden \
-v $base_data_dir/vaultwarden/data:/data/  \
vaultwarden/server:latest

echo "star vaultwarden success"
echo "vaultwarden is running at $http_scheme://vaultwarden.$domain"

# install vaultwarden-backup    
read -p "Do you want to install/reinstall vaultwarden-backup? [y/n]: " yn
case $yn in
    [Yy]* )
        echo "install vaultwarden-backup"
        sh `dirname $0`/fun-create-dir.sh $base_data_dir/vaultwarden-backup
        sh `dirname $0`/fun-create-dir.sh $base_data_dir/vaultwarden-backup/data
        sh `dirname $0`/fun-container-stop.sh vaultwarden-backup
        echo "star vaultwarden-backup"
        docker run -d --name vaultwarden-backup \
        --restart=always \
        -e TZ="Asia/Shanghai" \
        -e LANG="zh_CN.UTF-8" \
        -u $(id -u):$(id -g) \
        --network=$docker_network_name --network-alias=vaultwarden-backup \
        -v $base_data_dir/vaultwarden-backup/data:/data/  \
        vaultwarden/backup:latest
        echo "star vaultwarden-backup success"
        echo "vaultwarden-backup is running at $http_scheme://vaultwarden-backup.$domain"
        ;;
    [Nn]* )
        echo "skip install vaultwarden-backup"
        ;;
    * )
        echo "skip install vaultwarden-backup"
        ;;
    esac