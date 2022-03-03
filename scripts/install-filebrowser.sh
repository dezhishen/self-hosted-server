# /bin/bash

echo "copy config file to nginx"
if [ $ssl -eq 1 ]; then
    http_scheme="https"
    cp -f ./conf.d.https/filebrowser.conf $base_data_dir/nginx/conf/conf.d/filebrowser.conf
    echo "copy config ./conf.d.https/filebrowser.conf to $base_data_dir/nginx/conf/conf.d/filebrowser.conf success"
else
    http_scheme="http"
    cp -f ./conf.d/filebrowser.conf $base_data_dir/nginx/conf/conf.d/filebrowser.conf
    echo "copy config ./conf.d/filebrowser.conf to $base_data_dir/nginx/conf/conf.d/filebrowser.conf success"
fi
sh fun-create-dir.sh $base_data_dir/filebrowser
sh fun-container-stop.sh filebrowser

echo "copy config file to filebrowser"
if [ ! -f $base_data_dir/filebrowser/filebrowser.db ];then
    echo "filebrowser.db not exist, create it"
    cp  -f ./filebrowser/filebrowser.db $base_data_dir/filebrowser/filebrowser.db 
    echo "copy filebrowser.db to $base_data_dir/filebrowser/filebrowser.db success"
else
    echo "filebrowser.db already exist"
fi
if [ ! -f $base_data_dir/filebrowser/filebrowser.json ];then
    echo "filebrowser.json not exist, create it"
    cp  -f ./filebrowser/filebrowser.json $base_data_dir/filebrowser/filebrowser.json
    echo "copy filebrowser.json to $base_data_dir/filebrowser/filebrowser.json success"
else
    echo "filebrowser.json already exist"
fi
echo "star filebrowser"

docker run -d --restart=always --name=filebrowser \
--network=$docker_network_name --network-alias=filebrowser \
-u $(id -u):$(id -g) \
-v $base_data_dir:/srv \
-v "$base_data_dir/filebrowser/filebrowser.db:/database.db" \
-v "$base_data_dir/filebrowser/filebrowser.json:/.filebrowser.json" \
-e TZ="Asia/Shanghai" \
filebrowser/filebrowser

echo "start filebrowser success"
echo "filebrowser is running at $http_scheme://filebrowser.$domain"