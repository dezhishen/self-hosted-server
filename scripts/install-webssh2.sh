# /bin/bash

echo "copy config file to nginx"
case $ssl in
[yY]* )
    http_scheme="https"
    cp -f `dirname $0`/../conf.d.https/webssh2.conf $base_data_dir/nginx/conf/conf.d/webssh2.conf
    echo "copy config `dirname $0`/conf.d.https/webssh2.conf to $base_data_dir/nginx/conf/conf.d/webssh2.conf success"
    ;;
* )
    http_scheme="http"
    cp -f `dirname $0`/../conf.d/webssh2.conf $base_data_dir/nginx/conf/conf.d/webssh2.conf
    echo "copy config `dirname $0`/conf.d/webssh2.conf to $base_data_dir/nginx/conf/conf.d/webssh2.conf success"
    ;;
esac


sh `dirname $0`/fun-create-dir.sh $base_data_dir/webssh2

if [ ! -f $base_data_dir/webssh2/config.json ];then
    copy -f ./webssh2/config.json $base_data_dir/webssh2/config.json
    echo "copy config.json to $base_data_dir/webssh2/config.json success"
else
    echo "config.json already exist"
fi  

sh `dirname $0`/fun-container-stop.sh webssh2

docker run -d --restart=always --name=webssh2 \
--network=$docker_network_name --network-alias=webssh2 \
-u $(id -u):$(id -g) \
-v $base_data_dir/webssh2/config.json:/config.json \
psharkey/webssh2

echo "start webssh2 success"
echo "webssh2 is running at $http_scheme://webssh2.$domain"
