# /bin/bash
echo "copy config file to nginx"
if [ $ssl -eq 1 ]; then
    http_scheme="https"
    websocket_scheme="wss"
    cp -f ./conf.d.https/aria2.conf $base_data_dir/nginx/conf/conf.d/aria2.conf
    echo "copy config ./conf.d.https/aria2.conf to $base_data_dir/nginx/conf/conf.d/aria2.conf success"
else
    http_scheme="http"
    websocket_scheme="ws"
    cp -f ./conf.d/aria2.conf $base_data_dir/nginx/conf/conf.d/aria2.conf
    echo "copy config ./conf.d/aria2.conf to $base_data_dir/nginx/conf/conf.d/aria2.conf success"
fi
sh fun-create-dir.sh $base_data_dir/aria2
sh fun-create-dir.sh $base_data_dir/public
sh fun-create-dir.sh $base_data_dir/public/downloads

## input or random ARIA2_RPC_SECRET if not exist
if [ ! -n "$ARIA2_RPC_SECRET" ]; then
    ## input your ARIA2_RPC_SECRET
    read -p "input your ARIA2_RPC_SECRET: " ARIA2_RPC_SECRET
    ## if still not exist, use random
    if [ ! -n "$ARIA2_RPC_SECRET" ]; then
        ARIA2_RPC_SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    fi
fi
sh fun-container-stop.sh aria2
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
    p3terx/aria2
echo "start aria2 success"
echo "aria2 is listen on $http_scheme://aria2-rpc.$domain/jsonrpc or use websocket at $websocket_scheme://aria2-rpc.$domain/jsonrpc"