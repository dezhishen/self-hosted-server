# /bin/bash
echo $COPY_NGINX_FILE_LANG
case $ssl in
[yY]* )
    http_scheme="https"
    websocket_scheme="wss"
    cp -f `dirname $0`/../conf.d.https/aria2.conf $base_data_dir/nginx/conf/conf.d/aria2.conf
    ;;
* )
    http_scheme="http"
    websocket_scheme="ws"
    cp -f `dirname $0`/../conf.d/aria2.conf $base_data_dir/nginx/conf/conf.d/aria2.conf
    ;;
esac

sh `dirname $0`/fun-create-dir.sh $base_data_dir/aria2
sh `dirname $0`/fun-create-dir.sh $base_data_dir/public
sh `dirname $0`/fun-create-dir.sh $base_data_dir/public/downloads

## input or random ARIA2_RPC_SECRET if not exist
ARIA2_RPC_SECRET=$(sh `dirname $0`/read-args-with-history.sh ARIA2_RPC_SECRET "aria2 RPC密码/aria2 rpc secret" )
if [ ! -n "$ARIA2_RPC_SECRET" ]; then
    ## input your ARIA2_RPC_SECRET
    echo "请输入ara2的rpc密钥，如果不设置，将会在随机生成"
    echo "please input your aria2 rpc secret,if not set,will be random"
    read ARIA2_RPC_SECRET
    if [ ! -n "$ARIA2_RPC_SECRET" ]; then
        ARIA2_RPC_SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
        echo "随机生成的密钥为：$ARIA2_RPC_SECRET"
        echo "random generate secret:$ARIA2_RPC_SECRET"
    fi
    sh `dirname $0`/set-args-to-history.sh ARIA2_RPC_SECRET $ARIA2_RPC_SECRET
fi
sh `dirname $0`/fun-container-stop.sh aria2

docker run -d   --name aria2   --restart unless-stopped   --log-opt max-size=1m \
    --network=$docker_network_name --network-alias=aria2 \
    -e UMASK_SET=022 \
    -e RPC_SECRET=`echo $ARIA2_RPC_SECRET` \
    -e "TZ=Asia/Shanghai" \
    -e RPC_PORT=6800 \
    -e LISTEN_PORT=6888 \
    -p 6888:6888/udp \
    -p 6800:6800/tcp \
    -v $base_data_dir/aria2:/config \
    -v $base_data_dir/public/downloads:/downloads \
    -v $base_data_dir/public/:/public \
    p3terx/aria2-pro
echo "启动 aria2成功，当前rpc地址为：$http_scheme://aria2-rpc.$domain/jsonrpc"
echo "start aria2 success,current rpc address is:$http_scheme://aria2-rpc.$domain/jsonrpc"