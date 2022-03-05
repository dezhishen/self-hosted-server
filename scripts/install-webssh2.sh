# /bin/bash
echo $COPY_NGINX_FILE_LANG

case $ssl in
[yY]* )
    http_scheme="https"
    cp -f `dirname $0`/../conf.d.https/webssh2.conf $base_data_dir/nginx/conf/conf.d/webssh2.conf
    ;;
* )
    http_scheme="http"
    cp -f `dirname $0`/../conf.d/webssh2.conf $base_data_dir/nginx/conf/conf.d/webssh2.conf
    ;;
esac


`dirname $0`/fun-create-dir.sh $base_data_dir/webssh2

if [ ! -f $base_data_dir/webssh2/config.json ];then
    echo "config.json 不存在，复制./webssh2/config.json到$base_data_dir/webssh2/config.json"
    echo "config.json not exist,copy ./webssh2/config.json to $base_data_dir/webssh2/config.json"
    copy -f ./webssh2/config.json $base_data_dir/webssh2/config.json
else
    echo "config.json 已存在，不需要复制,config.json already exist"
fi  

`dirname $0`/fun-container-stop.sh webssh2

docker run -d --restart=always --name=webssh2 \
--network=$docker_network_name --network-alias=webssh2 \
-u $(id -u):$(id -g) \
-v $base_data_dir/webssh2/config.json:/config.json \
psharkey/webssh2

echo "启动webssh2容器成功，webssh2运行在$http_scheme://webssh2.$domain"
echo "start webssh2 success,webssh2 is running at $http_scheme://webssh2.$domain"
