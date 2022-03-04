# /bin/bash
echo $COPY_NGINX_FILE_LANG

case $ssl in
[yY]* )
    http_scheme="https"
    cp -f `dirname $0`/../conf.d.https/filebrowser.conf $base_data_dir/nginx/conf/conf.d/filebrowser.conf
    ;;
* )
    http_scheme="http"
    cp -f `dirname $0`/../conf.d/filebrowser.conf $base_data_dir/nginx/conf/conf.d/filebrowser.conf
    ;;
esac

sh `dirname $0`/fun-create-dir.sh $base_data_dir/filebrowser
sh `dirname $0`/fun-container-stop.sh filebrowser

echo "复制filebrowser的配置文件,copy filebrowser config file"
if [ ! -f $base_data_dir/filebrowser/filebrowser.db ];then
    echo "filebrowser.db 不存在，复制./filebrowser/filebrowser.db到$base_data_dir/filebrowser/filebrowser.db"
    echo "filebrowser.db not exist,copy ./filebrowser/filebrowser.db to $base_data_dir/filebrowser/filebrowser.db"
    cp  -f ./filebrowser/filebrowser.db $base_data_dir/filebrowser/filebrowser.db 
else
    echo "filebrowser.db 已存在，不需要复制,filebrowser.db already exist"
fi
if [ ! -f $base_data_dir/filebrowser/filebrowser.json ];then
    echo "filebrowser.json 不存在，复制./filebrowser/filebrowser.json到$base_data_dir/filebrowser/filebrowser.json"
    echo "filebrowser.json not exist,copy ./filebrowser/filebrowser.json to $base_data_dir/filebrowser/filebrowser.json"
    cp  -f ./filebrowser/filebrowser.json $base_data_dir/filebrowser/filebrowser.json
else
    echo "filebrowser.json 已存在，不需要复制,filebrowser.json already exist"
fi

docker run -d --restart=always --name=filebrowser \
--network=$docker_network_name --network-alias=filebrowser \
-u $(id -u):$(id -g) \
-v $base_data_dir:/srv \
-v "$base_data_dir/filebrowser/filebrowser.db:/database.db" \
-v "$base_data_dir/filebrowser/filebrowser.json:/.filebrowser.json" \
-e TZ="Asia/Shanghai" \
filebrowser/filebrowser

echo "启动filebrowser容器成功，filebrowser运行在$http_scheme://filebrowser.$domain"
echo "start filebrowser success,filebrowser is running at $http_scheme://filebrowser.$domain"