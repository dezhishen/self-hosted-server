# /bin/bash

echo $COPY_NGINX_FILE_LANG
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
printf "START_SUCCESS_LANG" "adguardhome"
echo ""
printf "$PLEASE_VISIT_ADDRESS_LANG $INIT_CONFIG_LANG" "$http_scheme://adguardhome-init.$domain"
echo ""
printf "$PLEASE_VISIT_ADDRESS_LANG" "$http_scheme://adguardhome.$domain"

