# /bin/bash
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
        echo "-d set domian -u enable auto update ssl cert -p set base data dir -s enable ssl -g generate ssl cert"
        exit 1;;
    ?)
        echo "get a non option $OPTARG and OPTION is $OPTION"
        exit 1;;
    esac
done

if [ ! -n "$domain" ]; then  
    domain=$(./scripts/read-args-with-history.sh domain) 
    if [ ! -n "$domain" ]; then  
        read -p "please input the domain of your home server:" domain
        if [ ! -n "$domain" ]; then  
            domain="self.docker.com"
        fi
        ./scripts/set-args-to-history.sh domain $domain
    fi
fi
if [ ! -n "$base_data_dir" ]; then  
    base_data_dir=$(./scripts/read-args-with-history.sh base_data_dir)
    if [ ! -n "$base_data_dir" ];then
        read -p "please input the base data dir of your home server,default is /data/data:" base_data_dir
        if [ ! -n "$base_data_dir" ]; then  
            base_data_dir="/docker_data"
        fi
        ./scripts/set-args-to-history.sh base_data_dir $base_data_dir
    fi
fi

if [ ! -n "$ssl" ]; then
    ssl=$(./scripts/read-args-with-history.sh ssl)
    if [ ! -n "$ssl" ]; then
        read -p "Do you want to enable ssl? [y/n]: " yn
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
    generatessl=$(./scripts/read-args-with-history.sh generatessl)
    if [ ! -n "$generatessl" ]; then
        read -p "Do you want to generate ssl cert? [y/n]: " yn
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
    autossl=$(./scripts/read-args-with-history.sh autossl)
    if [ ! -n "$autossl" ]; then
        read -p "Do you want to enable auto update ssl cert? [y/n]: " yn
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

echo "the config of your home server is:"
printf "domain: %s\n" $domain
printf "base_data_dir: %s\n" $base_data_dir
printf "ssl: %s\n" $ssl
printf "autossl: %s\n" $autossl
printf "generatessl: %s\n" $generatessl
read -p "Are you sure? [y/n]: " yn
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
echo "create base data dir if not exist"
if [ ! -d $base_data_dir ]; then
    mkdir -p $base_data_dir
    echo "create base data dir $base_data_dir success"
else
    # do you want to backup old data dir?
    read -p "Do you want to backup old data dir? [y/n]: " yn
    case $yn in
        [Yy]* )
            read -p "please input the backup dir:" backup_dir
            if [ ! -d $backup_dir ]; then
                backup_dir=$base_data_dir.bak.$(date +%Y%m%d%H%M%S)
            fi
            copy -f $base_data_dir $backup_dir
            echo "backup old data dir $base_data_dir to $backup_dir success"
            ;;
        [Nn]* )
            ;;
        * )
            ;;
    esac
fi

# create docker network
## print docker network list
## input or choose your docker network name,default is ingrees
docker_network_name=$(./scripts/read-args-with-history.sh docker_network_name)
if [ ! -n "$docker_network_name" ]; then
    read -p "please input your docker network name,default is ingrees:" docker_network_name
    if [ ! -n "$docker_network_name" ]; then
        docker_network_name="ingrees"
    fi
    ./scripts/set-args-to-history.sh docker_network_name $docker_network_name
fi
export docker_network_name=$docker_network_name

./scripts/create-docker-network.sh $docker_network_name

# insatll/reinstall portainer
read -p "do you want to install/reinstall portainer ? [y/n]:" yn
case $yn in
    [Yy]* )
        echo "installing portainer"
        eval ./scripts/install-portainer.sh
        ;;
    [Nn]* )
        echo "skip portainer"
        ;;
    * )
        echo "skip portainer"
        ;;
esac
# install/reinstall filebrowser
read -p "do you want to install/reinstall filebrowser ? [y/n]:" yn

case $yn in
    [Yy]* )
        echo "installing filebrowser"
        ./scripts/install-filebrowser.sh
        ;;
    [Nn]* )
        echo "skip filebrowser"
        ;;
    * )
        echo "skip filebrowser"
        ;;
esac
# install/reinstall adguardhome
read -p "do you want to install/reinstall adguardhome ? [y/n]:" yn
case $yn in
    [Yy]* )
        echo "installing adguardhome"
        ./scripts/install-adguardhome.sh
        ;;
    [Nn]* )
        echo "skip adguardhome"
        ;;
    * )
        echo "skip adguardhome"
        ;;
esac

# install/reinstall webssh2 with warning "webssh2 is not support on arm"
echo "[warning] webssh2 is not support on arm"
read -p "do you want to install/reinstall webssh2 ? [y/n]:" yn
case $yn in
    [Yy]* )
        echo "installing webssh2"
        ./scripts/install-webssh2.sh
        ;;
    [Nn]* )
        echo "skip webssh2"
        ;;
    * )
        echo "skip webssh2"
        ;;
esac

# install/reinstall navidrome
read -p "do you want to install/reinstall navidrome ? [y/n]:" yn
case $yn in
    [Yy]* )
        echo "installing navidrome"
    ./scripts/install-navidrome.sh
        ;;
    [Nn]* )
        echo "skip webssh2"
        ;;
    * )
        echo "skip webssh2"
        ;;
esac


# install/reinstall vaultwarden
case $ssl in
[yY]*)
    echo "do you want to install/reinstall vaultwarden ? [y/n]:"
    read flag
    if [ "$flag" = "y" ];then
        ./scripts/install-vaultwarden.sh
    fi
    ;;
*)
echo "vaultwarden must running with ssl , skip vaultwarden"
;;
esac

# install/reinstall aria2
read -p "do you want to install/reinstall aria2 ? [y/n]:" yn

case $yn in
    [Yy]* )
        echo "installing aria2"
        ./scripts/install-aria2.sh
        ;;
    [Nn]* )
        echo "skip aria2"
        ;;
    * )
        echo "skip aria2"
        ;;
esac

# install/reinstall nginx
read -p "do you want to install/reinstall nginx ? [y/n]:" yn
case $yn in
    [Yy]* )
        echo "installing nginx"
        ./scripts/install-nginx.sh
        ;;
    [Nn]* )
        echo "skip nginx"
        ;;
    * )
        echo "skip nginx"
        ;;
esac

echo "You have finished the install and your home server is ready after all docker container ready"

echo "There is docker container status or you can run docker ps -a to check them,thinks for used this script"

docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"