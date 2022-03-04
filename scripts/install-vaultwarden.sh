# /bin/bash
echo $COPY_NGINX_FILE_LANG
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

printf "$START_SUCCESS_LANG,$PLEASE_VISIT_ADDRESS_LANG" "vaultwarden" "$http_scheme://vaultwarden.$domain"
echo ""

# todo impl backup vaultwarden
# # install vaultwarden-backup    
# printf "$INSTALL_TIPS" "vaultwarden-backup"
# read yn
# case $yn in
# [Yy]* )
#     sh `dirname $0`/fun-create-dir.sh $base_data_dir/vaultwarden-backup
#     sh `dirname $0`/fun-create-dir.sh $base_data_dir/vaultwarden-backup/data
#     sh `dirname $0`/fun-container-stop.sh vaultwarden-backup
#     docker run -d --name vaultwarden-backup \
#     --restart=always \
#     -e TZ="Asia/Shanghai" \
#     -e LANG="zh_CN.UTF-8" \
#     -u $(id -u):$(id -g) \
#     --network=$docker_network_name --network-alias=vaultwarden-backup \
#     -v $base_data_dir/vaultwarden-backup/data:/data/  \
#     vaultwarden/backup:latest
#     printf "$START_SUCCESS_LANG" "vaultwarden"
#     echo ""
#     ;;
# esac