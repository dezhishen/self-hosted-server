# /bin/bash

echo "copy config file to nginx"
if [ $ssl -eq 1 ]; then
    http_scheme="https"
    cp -f ./conf.d.https/adguardhome.conf $base_data_dir/nginx/conf/conf.d/adguardhome.conf
    echo "copy config ./conf.d.https/adguardhome.conf to $base_data_dir/nginx/conf/conf.d/adguardhome.conf success"
else
    http_scheme="http"
    cp -f ./conf.d/adguardhome.conf $base_data_dir/nginx/conf/conf.d/adguardhome.conf
    echo "copy config ./conf.d/adguardhome.conf to $base_data_dir/nginx/conf/conf.d/adguardhome.conf success"
fi
sh fun-create-dir.sh $base_data_dir/adguardhome
sh fun-create-dir.sh $base_data_dir/adguardhome/work
sh fun-create-dir.sh $base_data_dir/adguardhome/conf

sh fun-container-stop.sh adguardhome

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
