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
        echo "-d set domian -p set base data dir -s enable ssl -g generate ssl cert -u enable auto update ssl cert"
        echo "-d set 根域名 -p 设置存储根目录 -s 启用https -g 生成https证书 -u 自动更新https证书"
        exit 1;;
    ?)
        echo "get a non option $OPTARG and OPTION is $OPTION"
        echo "非法参数 $OPTARG:$OPTION"
        exit 1;;
    esac
done

if [ ! -n "$domain" ]; then  
    domain=$(./scripts/read-args-with-history.sh domain) 
    if [ ! -n "$domain" ]; then  
        echo "请输入根域名"
        read -p "please input root domain:" domain
        if [ ! -n "$domain" ]; then  
            domain="self.docker.com"
        fi
        sh ./scripts/set-args-to-history.sh domain $domain
    fi
fi
if [ ! -n "$base_data_dir" ]; then  
    base_data_dir=$(./scripts/read-args-with-history.sh base_data_dir)
    if [ ! -n "$base_data_dir" ];then
        echo "请输入docker卷使用的根目录,默认为/docker_data"
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
        echo "是否启用https?[y/n]"
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
        echo "是否生成https证书?[y/n]"
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
        echo "是否自动更新https证书?[y/n]"
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
echo "你的服务配置如下"
echo "the config of your home server is:"
printf "根域名: %s\n" $domain
printf "domain: %s\n" $domain
printf "存储根目录: %s\n" $base_data_dir
printf "base_data_dir: %s\n" $base_data_dir
printf "是否启用https: %s\n" $ssl
printf "ssl: %s\n" $ssl
printf "是否生成https证书: %s\n" $generatessl
printf "autossl: %s\n" $autossl
printf "是否自动更新https证书: %s\n" $autossl
printf "generatessl: %s\n" $generatessl

echo "请确认是否正确，输入y确认，输入n退出"
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
echo "创建存储根目录"
echo "create base data dir if not exist"
if [ ! -d $base_data_dir ]; then
    mkdir -p $base_data_dir
    echo "创建存储根目录成功"
    echo "create base data dir $base_data_dir success"
else
    # do you want to backup old data dir?
    echo "是否备份旧的存储目录"
    read -p "Do you want to backup old data dir? [y/n]: " yn
    case $yn in
        [Yy]* )
            backup_dir=$base_data_dir.bak.$(date +%Y%m%d%H%M%S)
            copy -f $base_data_dir $backup_dir
            echo "备份存储目录[$backup_dir]成功"
            echo "backup old data dir $base_data_dir to $backup_dir success"
            ;;
        [Nn]* )
            ;;
        * )
            ;;
    esac
fi

# generate ssl cert
case $generatessl in
    [Yy]* )
        ./scripts/generate-ssl-cert.sh
        ;;
    [Nn]* )
        ;;
    * )
        ;;
esac

# create docker network
## print docker network list
## input or choose your docker network name,default is ingrees
docker_network_name=$(./scripts/read-args-with-history.sh docker_network_name)
if [ ! -n "$docker_network_name" ]; then
    echo "请输入docker网络名称,默认为ingrees"
    read -p "please input your docker network name,default is ingrees:" docker_network_name
    if [ ! -n "$docker_network_name" ]; then
        docker_network_name="ingrees"
    fi
    ./scripts/set-args-to-history.sh docker_network_name $docker_network_name
fi
export docker_network_name=$docker_network_name

sh ./scripts/create-docker-network.sh $docker_network_name

# insatll/reinstall portainer
echo "是否安装/重装portainer"
read -p "do you want to install/reinstall portainer ? [y/n]:" yn
case $yn in
    [Yy]* )
        #echo "installing portainer"
        eval ./scripts/install-portainer.sh
        ;;
esac
# install/reinstall filebrowser
echo "是否安装/重装filebrowser"
read -p "do you want to install/reinstall filebrowser ? [y/n]:" yn
case $yn in
    [Yy]* )
        #echo "installing filebrowser"
        ./scripts/install-filebrowser.sh
        ;;
esac
# install/reinstall adguardhome
echo "是否安装/重装adguardhome"
read -p "do you want to install/reinstall adguardhome ? [y/n]:" yn
case $yn in
    [Yy]* )
        #echo "installing adguardhome"
        ./scripts/install-adguardhome.sh
        ;;
esac

# install/reinstall webssh2 with warning "webssh2 is not support on arm"
echo "[警告] webssh2 在arm平台上无法运行"
echo "是否安装/重装webssh2"
echo "[warning] webssh2 is not support on arm"
read -p "do you want to install/reinstall webssh2 ? [y/n]:" yn
case $yn in
    [Yy]* )
        #echo "installing webssh2"
        ./scripts/install-webssh2.sh
        ;;
esac

# install/reinstall navidrome
echo "是否安装/重装navidrome"
read -p "do you want to install/reinstall navidrome ? [y/n]:" yn
case $yn in
    [Yy]* )
        #echo "installing navidrome"
    ./scripts/install-navidrome.sh
        ;;
esac


# install/reinstall vaultwarden
case $ssl in
[yY]*)
    echo "是否安装/重装vaultwarden"
    echo "do you want to install/reinstall vaultwarden ? [y/n]:"
    read flag
    if [ "$flag" = "y" ];then
        ./scripts/install-vaultwarden.sh
    fi
    ;;
*)
    echo "vaultwarden 必须使用https 才能安装"
    echo "vaultwarden must running with ssl , skip vaultwarden"
    ;;
esac

# install/reinstall aria2
echo "是否安装/重装aria2"
read -p "do you want to install/reinstall aria2 ? [y/n]:" yn

case $yn in
    [Yy]* )
        #echo "installing aria2"
        ./scripts/install-aria2.sh
        ;;
esac

# install/reinstall nginx
echo "是否安装/重装nginx"
read -p "do you want to install/reinstall nginx ? [y/n]:" yn
case $yn in
    [Yy]* )
        ./scripts/install-nginx.sh
        ;;
esac
echo "感谢使用本安装脚本，你已经完成了所有的安装，当docker容器准备好后，你的服务就可以被访问了"
echo "thanks for used this script,you have finished all install,when docker container ready,your service can be accessed"
echo "即将退出和打印当前docker容器运行的状态"
echo "will exit and print current docker container status"
docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"