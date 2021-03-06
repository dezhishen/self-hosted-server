# /bin/bash
# read -p "choose your language [zh/en]:" lang_set
lang_set="zh"
case $lang_set in
    zh)
        echo "你选择了中文"
        . ./lang/zh.sh
        export LANG_SET=$lang_set
        ;;
    en)
        echo "you choose english"
        . `dirname $0`/lang/en.sh
        export LANG_SET=$lang_set
        ;;
    *)
        echo "you choose nothing"
        . `dirname $0`./lang/zh.sh
        export LANG_SET=zh
        ;;
esac

while getopts p:d:sugh OPTION; do
    case $OPTION in
    p)
        base_data_dir=$OPTARG
        ;;
    d)
        domain=$OPTARG
        ;;
    s)
        ssl=y
        ;;
    u)
        autossl=y
        ;;
    g)
        generatessl=y
        ;;
    h)
        echo "$ARGS_TIPS"
        exit 1;;
    ?)
        printf "$ARGS_ERROR" "$OPTARG" "$OPTION"
        exit 1;;
    esac
done

if [ ! -n "$domain" ]; then 
    domain=`./scripts/read-args-with-history.sh domain "$DOMAIN_LANG"`
    if [ ! -n "$domain" ]; then  
        printf "$INPUT_TIPS" "$DOMAIN_LANG"
        read domain
        if [ ! -n "$domain" ]; then  
            domain="self.docker.com"
        fi
        ./scripts/set-args-to-history.sh domain $domain
    fi
fi
if [ ! -n "$base_data_dir" ]; then  
    base_data_dir=$(./scripts/read-args-with-history.sh base_data_dir "$BASE_DATA_DIR_LANG")
    if [ ! -n "$base_data_dir" ];then
        printf "$INPUT_TIPS" "$BASE_DATA_DIR_LANG"
        read base_data_dir
        if [ ! -n "$base_data_dir" ]; then  
            base_data_dir="/docker_data"
        fi
        ./scripts/set-args-to-history.sh base_data_dir $base_data_dir
    fi
fi

if [ ! -n "$ssl" ]; then
    prompt=`printf " $ENABLE_TIPS " https`
    ssl=$(./scripts/read-args-with-history.sh ssl "$prompt")
    if [ ! -n "$ssl" ]; then
        echo $prompt
        read yn
        case $yn in
            [Yy]* )
                ssl=y
                ;;
            [Nn]* )
                ssl=n
                ;;
            * )
                ssl=n
                ;;
        esac
        ./scripts/set-args-to-history.sh ssl $ssl
    fi
fi

if [ ! -n "$generatessl" ]; then  
    generatessl=$(./scripts/read-args-with-history.sh generatessl " $GENERATE_TIPS ")
    if [ ! -n "$generatessl" ]; then
        printf "$GENERATE_TIPS"
        read yn
        case $yn in
            [Yy]* )
                generatessl=y
                ;;
            [Nn]* )
                generatessl=n
                ;;
            * )
                generatessl=n
                ;;
        esac
        ./scripts/set-args-to-history.sh generatessl $generatessl
    fi
fi

if [ ! -n "$autossl" ]; then  
    autossl=$(./scripts/read-args-with-history.sh autossl " `printf "$ENABLE_TIPS" "$UPDATE_SSL_CERT_LANG"` ")
    if [ ! -n "$autossl" ]; then
        printf "$ENABLE_TIPS" "$UPDATE_SSL_CERT_LANG"
        read yn
        case $yn in
            [Yy]* )
                autossl=y
                ;;
            [Nn]* )
                autossl=n
                ;;
            * )
                autossl=n
                ;;
        esac
        ./scripts/set-args-to-history.sh autossl $autossl
    fi
fi
echo ""
echo ""

printf "$INSTALL_CONFIG_LANG" "$domain" "$base_data_dir" "$ssl" "$generatessl" "$autossl"

echo ""
echo ""

echo "waiting for 5 seconds,if you want to stop, press Ctrl+C"
sleep 1
echo "waiting for 4 seconds,if you want to stop, press Ctrl+C"
sleep 1
echo "waiting for 3 seconds,if you want to stop, press Ctrl+C"
sleep 1
echo "waiting for 2 seconds,if you want to stop, press Ctrl+C"
sleep 1
echo "waiting for 1 seconds,if you want to stop, press Ctrl+C"
echo "staring..."
perl -MPOSIX -e 'tcflush 0,0'

export domain=$domain
export base_data_dir=$base_data_dir
export ssl=$ssl
export autossl=$autossl
export generatessl=$generatessl

# create base data dir if not exist
echo $CREATE_BASE_DATA_DIR_LANG

if [ ! -d $base_data_dir ]; then
    mkdir -p $base_data_dir
    printf "$CREATE_BASE_DATA_DIR_SUCCESS_LANG" "$base_data_dir"
else
    # do you want to backup old data dir?
    read -p "$IF_BACKUP_LANG" yn
    case $yn in
        [Yy]* )
            backup_dir=$base_data_dir.bak.$(date +%Y%m%d%H%M%S)
            cp -r $base_data_dir $backup_dir
            printf "$BACKUP_SUCCESS_LANG" "$base_data_dir $backup_dir"
            ;;
        [Nn]* )
            ;;
        * )
            ;;
    esac
fi
echo ""

perl -MPOSIX -e 'tcflush 0,0'

# generate ssl cert
case $generatessl in
    [Yy]* )
        ./scripts/generate-ssl-cert.sh || exit 1
        ;;
    [Nn]* )
        ;;
    * )
        ;;
esac

# create docker network
## print docker network list
## input or choose your docker network name,default is ingress

perl -MPOSIX -e 'tcflush 0,0'

echo ""
echo ""
echo "prepare docker network"
docker_network_name=$(./scripts/read-args-with-history.sh docker_network_name "docker网络名称/docker network name")
if [ ! -n "$docker_network_name" ]; then
    printf "$INPUT_TIPS" "docker network name"
    read docker_network_name
    if [ ! -n "$docker_network_name" ]; then
        docker_network_name="ingress"
    fi
    ./scripts/set-args-to-history.sh docker_network_name $docker_network_name || exit 1
fi

export docker_network_name=$docker_network_name

./scripts/create-docker-network.sh $docker_network_name || exit 1

perl -MPOSIX -e 'tcflush 0,0'

echo ""
echo ""
# insatll/reinstall portainer
printf "$INSTALL_TIPS" portainer

read yn
case $yn in
    [Yy]* )
        #echo "installing portainer"
        eval ./scripts/install-portainer.sh
        ;;
esac
# install/reinstall filebrowser

perl -MPOSIX -e 'tcflush 0,0'

echo ""
echo ""
printf "$INSTALL_TIPS" filebrowser
read yn
case $yn in
    [Yy]* )
        #echo "installing filebrowser"
        ./scripts/install-filebrowser.sh
        ;;
esac
# install/reinstall adguardhome

perl -MPOSIX -e 'tcflush 0,0'

echo ""
echo ""
printf "$INSTALL_TIPS" adguardhome
read yn
case $yn in
    [Yy]* )
        #echo "installing adguardhome"
        ./scripts/install-adguardhome.sh
        ;;
esac

perl -MPOSIX -e 'tcflush 0,0'

echo ""
echo ""
# install/reinstall webssh2 with warning "webssh2 is not support on arm"
printf "$WEBSSH2_WARNING"
echo ""
printf "$INSTALL_TIPS" webssh2

read yn
case $yn in
    [Yy]* )
        ./scripts/install-webssh2.sh
        ;;
esac

# install/reinstall navidrome
perl -MPOSIX -e 'tcflush 0,0'
echo ""
echo ""
printf "$INSTALL_TIPS" navidrome
read yn
case $yn in
    [Yy]* )
        #echo "installing navidrome"
    ./scripts/install-navidrome.sh
        ;;
esac


# install/reinstall vaultwarden
echo ""
echo ""
perl -MPOSIX -e 'tcflush 0,0'
case $ssl in
[yY]*)

    printf "$INSTALL_TIPS" vaultwarden
    read flag
    if [ "$flag" = "y" ];then
        ./scripts/install-vaultwarden.sh
    fi
    ;;
*)
    echo $VAULTWARDEN_TIPS
    ;;
esac

# install/reinstall aria2
perl -MPOSIX -e 'tcflush 0,0'
echo ""
echo ""
printf "$INSTALL_TIPS" aria2
read yn

case $yn in
    [Yy]* )
        ./scripts/install-aria2.sh
        ;;
esac

echo ""
echo ""
printf "$INSTALL_TIPS" samba
read yn
case $yn in
    [Yy]* )
        ./scripts/install-samba.sh
        ;;
esac
# install/reinstall ddns
perl -MPOSIX -e 'tcflush 0,0'
echo ""
echo ""
printf "$INSTALL_TIPS" ddns
read yn
case $yn in
    [Yy]* )
        ./scripts/install-ddns.sh
        ;;
esac

# install/reinstall nginx
perl -MPOSIX -e 'tcflush 0,0'
echo ""
echo ""
printf "$INSTALL_TIPS" nginx 
read yn
case $yn in
    [Yy]* )
        ./scripts/install-nginx.sh
        ;;
esac
echo $FINNISH_MESSAGE
docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"