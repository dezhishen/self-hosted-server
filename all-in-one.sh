# /bin/bash
# read -p "choose your language [zh/en]:" lang_set
lang_set="zh"
case $lang_set in
    zh)
        echo "你选择了中文"
        source ./lang/zh.sh
        export LANG_SET=$lang_set
        ;;
    en)
        echo "you choose english"
        source ./lang/en.sh
        export LANG_SET=$lang_set
        ;;
    *)
        echo "you choose nothing"
        source ./lang/zh.sh
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
    domain=`sh ./scripts/read-args-with-history.sh domain "$DOMAIN_LANG"`
    if [ ! -n "$domain" ]; then  
        printf "$INPUT_TIPS" "$DOMAIN_LANG"
        read domain
        if [ ! -n "$domain" ]; then  
            domain="self.docker.com"
        fi
        sh ./scripts/set-args-to-history.sh domain $domain
    fi
fi
if [ ! -n "$base_data_dir" ]; then  
    base_data_dir=$(sh ./scripts/read-args-with-history.sh base_data_dir "$BASE_DATA_DIR_LANG")
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
    ssl=$(sh ./scripts/read-args-with-history.sh ssl "$prompt")
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
    generatessl=$(sh ./scripts/read-args-with-history.sh generatessl " $GENERATE_TIPS ")
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
    autossl=$(sh ./scripts/read-args-with-history.sh autossl " `printf "$ENABLE_TIPS" "$UPDATE_SSL_CERT_LANG"` ")
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
printf "$INSTALL_CONFIG_LANG" $domain $base_data_dir $ssl $generatessl $autossl | column -t
echo ""
echo ""
echo $ARE_YOU_SURE_INSTALL_LANG
sleep 2 && read yn
case $yn in
    [Yy]* )
        ;;
    [Nn]* )
        exit 1;;
    * )
        exit 1;;
esac

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
    echo $IF_BACKUP_LANG
    read yn
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
## input or choose your docker network name,default is ingrees
docker_network_name=$(./scripts/read-args-with-history.sh docker_network_name "docker网络名称/docker network name")
if [ ! -n "$docker_network_name" ]; then
    printf "$INPUT_TIPS" "docker network name"
    read docker_network_name
    if [ ! -n "$docker_network_name" ]; then
        docker_network_name="ingrees"
    fi
    sh ./scripts/set-args-to-history.sh docker_network_name $docker_network_name
fi

export docker_network_name=$docker_network_name

sh ./scripts/create-docker-network.sh $docker_network_name || exit 1

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

printf "$INSTALL_TIPS" filebrowser
read yn
case $yn in
    [Yy]* )
        #echo "installing filebrowser"
        ./scripts/install-filebrowser.sh
        ;;
esac
# install/reinstall adguardhome

printf "$INSTALL_TIPS" adguardhome
read yn
case $yn in
    [Yy]* )
        #echo "installing adguardhome"
        ./scripts/install-adguardhome.sh
        ;;
esac

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
printf "$INSTALL_TIPS" navidrome
read yn
case $yn in
    [Yy]* )
        #echo "installing navidrome"
    ./scripts/install-navidrome.sh
        ;;
esac


# install/reinstall vaultwarden
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

printf "$INSTALL_TIPS" aria2
read yn

case $yn in
    [Yy]* )
        sh ./scripts/install-aria2.sh
        ;;
esac

# install/reinstall nginx
printf "$INSTALL_TIPS" nginx 
read yn
case $yn in
    [Yy]* )
        ./scripts/install-nginx.sh
        ;;
esac
echo $FINNISH_MESSAGE
docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"