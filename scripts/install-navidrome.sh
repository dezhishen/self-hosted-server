# /bin/bash
echo "copy config file to nginx"
if [ $ssl -eq 1 ]; then
    http_scheme="https"
    cp -f ./conf.d.https/navidrome.conf $base_data_dir/nginx/conf/conf.d/navidrome.conf
    echo "copy config ./conf.d.https/navidrome.conf to $base_data_dir/nginx/conf/conf.d/navidrome.conf success"
else
    http_scheme="http"
    cp -f ./conf.d/navidrome.conf $base_data_dir/nginx/conf/conf.d/navidrome.conf
    echo "copy config ./conf.d/navidrome.conf to $base_data_dir/nginx/conf/conf.d/navidrome.conf success"
fi
sh fun-create-dir.sh $base_data_dir/navidrome
sh fun-create-dir.sh $base_data_dir/navidrome/data
sh fun-create-dir.sh $base_data_dir/public
sh fun-create-dir.sh $base_data_dir/public/music

sh fun-container-stop.sh navidrome
echo "start navidrome"
docker run -d --name navidrome \
--network=$docker_network_name --network-alias=navidrome \
--user $(id -u):$(id -g) \
-e ND_LOGLEVEL=info \
-e LANG="zh_CN.UTF-8" \
-e TZ="Asia/Shanghai" \
-v $base_data_dir/public/music:/music \
-v $base_data_dir/navidrome/data:/data/ \
deluan/navidrome:latest

echo "start navidrome success"
echo "navidrome is running at $http_scheme://navidrome.$domain"