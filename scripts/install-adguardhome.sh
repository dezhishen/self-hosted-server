# /bin/bash

echo "复制nginx的配置文件"
echo "copy nginx config file"
case $ssl in
[yY]* )
    http_scheme="https"
    cp -f `dirname $0`/../conf.d.https/adguardhome.conf $base_data_dir/nginx/conf/conf.d/adguardhome.conf
    ;;
* )
    http_scheme="http"
    cp -f `dirname $0`/../conf.d/adguardhome.conf $base_data_dir/nginx/conf/conf.d/adguardhome.conf
    ;;
esac

sh `dirname $0`/fun-create-dir.sh $base_data_dir/adguardhome
sh `dirname $0`/fun-create-dir.sh $base_data_dir/adguardhome/work
sh `dirname $0`/fun-create-dir.sh $base_data_dir/adguardhome/conf

sh `dirname $0`/fun-container-stop.sh adguardhome

docker run -d --restart=always --name=adguardhome \
-p 53:53 \
-e TZ="Asia/Shanghai" \
--network=$docker_network_name --network-alias=adguardhome \
-v $base_data_dir/adguardhome/work:/opt/adguardhome/work \
-v $base_data_dir/adguardhome/conf:/opt/adguardhome/conf \
adguard/adguardhome
echo "启动adguardhome成功，请访问$http_scheme://adguardhome-init.$domain初始化配置，完成后请访问$http_scheme://adguardhome.$domain"
echo "start adguardhome success,please visit $http_scheme://adguardhome-init.$domain to init config,then visit $http_scheme://adguardhome.$domain"

