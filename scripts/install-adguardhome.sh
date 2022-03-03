# /bin/bash

echo "copy config file to nginx"
case $ssl in
[yY]* )
    http_scheme="https"
    cp -f `dirname $0`/../conf.d.https/adguardhome.conf $base_data_dir/nginx/conf/conf.d/adguardhome.conf
    echo "copy config `dirname $0`/conf.d.https/adguardhome.conf to $base_data_dir/nginx/conf/conf.d/adguardhome.conf success"
    ;;
* )
    http_scheme="http"
    cp -f `dirname $0`/../conf.d/adguardhome.conf $base_data_dir/nginx/conf/conf.d/adguardhome.conf
    echo "copy config `dirname $0`/conf.d/adguardhome.conf to $base_data_dir/nginx/conf/conf.d/adguardhome.conf success"
    ;;
esac

sh `dirname $0`/fun-create-dir.sh $base_data_dir/adguardhome
sh `dirname $0`/fun-create-dir.sh $base_data_dir/adguardhome/work
sh `dirname $0`/fun-create-dir.sh $base_data_dir/adguardhome/conf

sh `dirname $0`/fun-container-stop.sh adguardhome

echo "star adguardhome"
docker run -d --restart=always --name=adguardhome \
-p 53:53 \
-e TZ="Asia/Shanghai" \
--network=$docker_network_name --network-alias=adguardhome \
-v $base_data_dir/adguardhome/work:/opt/adguardhome/work \
-v $base_data_dir/adguardhome/conf:/opt/adguardhome/conf \
adguard/adguardhome

echo "star adguardhome success"
echo "please visit $http_scheme://adguardhome-init.$domain/admin/login.html to start configuration wizard"
echo "after funished, please visit $http_scheme://adguardhome.$domain/admin/login.html to start adguardhome"
