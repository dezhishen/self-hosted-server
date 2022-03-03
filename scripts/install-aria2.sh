# /bin/bash
echo "copy config file to nginx"
case $ssl in
[yY]* )
    http_scheme="https"
    websocket_scheme="wss"
    cp -f `dirname $0`/../conf.d.https/aria2.conf $base_data_dir/nginx/conf/conf.d/aria2.conf
    echo "copy config `dirname $0`/conf.d.https/aria2.conf to $base_data_dir/nginx/conf/conf.d/aria2.conf success"
    ;;
* )
    http_scheme="http"
    websocket_scheme="ws"
    cp -f `dirname $0`/../conf.d/aria2.conf $base_data_dir/nginx/conf/conf.d/aria2.conf
    echo "copy config `dirname $0`/conf.d/aria2.conf to $base_data_dir/nginx/conf/conf.d/aria2.conf success"
    ;;
esac

sh `dirname $0`/fun-create-dir.sh $base_data_dir/aria2
sh `dirname $0`/fun-create-dir.sh $base_data_dir/public
sh `dirname $0`/fun-create-dir.sh $base_data_dir/public/downloads

## input or random ARIA2_RPC_SECRET if not exist
ARIA2_RPC_SECRET=$(sh `dirname $0`/read-args-with-history.sh ARIA2_RPC_SECRET)
if [ ! -n "$ARIA2_RPC_SECRET" ]; then
    ## input your ARIA2_RPC_SECRET
    read -p "input your ARIA2_RPC_SECRET: " ARIA2_RPC_SECRET
    ## if still not exist, use random
    if [ ! -n "$ARIA2_RPC_SECRET" ]; then
        ARIA2_RPC_SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    fi
    sh `dirname $0`/set-args-to-history.sh ARIA2_RPC_SECRET $ARIA2_RPC_SECRET
fi
sh `dirname $0`/fun-container-stop.sh aria2
echo "start aria2"
docker run -d   --name aria2   --restart unless-stopped   --log-opt max-size=1m \
    --network=$docker_network_name --network-alias=aria2 \
    -e UMASK_SET=022 \
    -e RPC_SECRET=`echo $ARIA2_RPC_SECRET` \
    -e "TZ=Asia/Shanghai" \
    -e RPC_PORT=6800 \
    -e LISTEN_PORT=6888 \
    -v $base_data_dir/aria2:/config \
    -v $base_data_dir/public/downloads:/downloads \
    -v $base_data_dir/public/:/public \
    p3terx/aria2-pro
echo "start aria2 success"
echo "aria2 is listen on $http_scheme://aria2-rpc.$domain/jsonrpc or use websocket at $websocket_scheme://aria2-rpc.$domain/jsonrpc"