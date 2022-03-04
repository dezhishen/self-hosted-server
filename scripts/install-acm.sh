# /bin/bash

echo "start install-acm.sh for auto update ssl cert"
if [ ! -n "$CF_Token" ]; then  
    echo "请输入CF_Token:"
    read CF_Token
fi
if [ ! -n "$CF_Account_ID" ]; then  
    echo "请输入CF_Account_ID:"
    read CF_Account_ID
fi
if [ ! -n "$CF_Zone_ID" ]; then  
    echo "请输入CF_Zone_ID:"
    read CF_Zone_ID
fi
if [ ! -n "$SSL_EMAIL" ]; then  
    echo "请输入ssl的邮箱:"
    read SSL_EMAIL
fi
sh `dirname $0`/fun-container-stop.sh acme
docker run --name=acme --restart=always -d \
    -u $(id -u):$(id -g) \
    -e CF_Token=`echo $CF_Token`\
    -e CF_Account_ID=`echo $CF_Account_ID` \
    -e CF_Zone_ID=`echo $CF_Zone_ID` \
    -v $base_data_dir/nginx/ssl:/acme.sh/$domain/ \
    -v $base_data_dir/acmeout:/acme.sh \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e DEPLOY_DOCKER_CONTAINER_LABEL=sh.acme.autoload.domain=*.$domain \
    -e DEPLOY_DOCKER_CONTAINER_KEY_FILE=/etc/nginx/ssl/*.$domain.key \
    -e DEPLOY_DOCKER_CONTAINER_CERT_FILE="/etc/nginx/ssl/*.$domain.cer" \
    -e DEPLOY_DOCKER_CONTAINER_CA_FILE="/etc/nginx/ssl/ca.cer" \
    -e DEPLOY_DOCKER_CONTAINER_FULLCHAIN_FILE="/etc/nginx/ssl/fullchain.cer" \
    -e DEPLOY_DOCKER_CONTAINER_RELOAD_CMD="service nginx force-reload" \
    neilpang/acme.sh daemon