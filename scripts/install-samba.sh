# /bin/bash

sh `dirname $0`/fun-container-stop.sh samba

SAMBA_USER_NAME=$(sh `dirname $0`/read-args-with-history.sh SAMBA_USER_NAME "smb's userName" )
if [ ! -n "$SAMBA_USER_NAME" ]; then
    ## input your SAMBA_USER_NAME,or defaut is amdin
    printf "$INPUT_WIRH_DEFAULT_LANG" "smb's userName" "admin"
    read SAMBA_USER_NAME
    if [ ! -n "$SAMBA_USER_NAME" ]; then
        SAMBA_USER_NAME="amdin"
    fi
    sh `dirname $0`/set-args-to-history.sh SAMBA_USER_NAME $SAMBA_USER_NAME
fi

echo "user name：$SAMBA_USER_NAME"
SAMBA_USER_PASSWORD=$(sh `dirname $0`/read-args-with-history.sh SAMBA_USER_PASSWORD "smb's userPassword" )
if [ ! -n "$SAMBA_USER_PASSWORD" ]; then
    ## input your SAMBA_USER_PASSWORD,or random
    printf "$INPUT_OR_RAND_LANG" "smb's userPassword"
    read SAMBA_USER_PASSWORD
    if [ ! -n "$SAMBA_USER_PASSWORD" ]; then
        SAMBA_USER_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    fi
    sh `dirname $0`/set-args-to-history.sh ARIA2_RPC_SECRET $ARIA2_RPC_SECRET
fi
echo "password: $SAMBA_USER_PASSWORD"

sh `dirname $0`/fun-container-stop.sh samba

docker run -d --restart=always --name=samba \
        --network=ingress --network-alias=samba \
        -p 139:139 -p 445:445 \
        -e TZ="Asia/Shanghai" \
        -e LANG="zh_CN.UTF-8" \
        -e SHARE="www;/mount/;yes;no;no;all;none" \
        -e USER="$SAMBA_USER_NAME;$SAMBA_PASSWORD" \
        -e USERID=$(id -u) \
        -e GROUPID=$(id -g) \
        -v /docker_data/public:/mount \
        dperson/samba

printf "$START_SUCCESS_LANG" "samba"