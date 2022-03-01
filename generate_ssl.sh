#/bin/bash

while getopts p:d:sug OPTION;do
    case $OPTION in
    p)
        base_data_dir=$OPTARG
        ;;
    d)
        domain=$OPTARG
        ;;
    s)
        ssl=1
        ;;
    u)
        autossl=1
        ;;
    g)
        generatessl=1
        ;;
    ?)
        echo "get a non option $OPTARG and OPTION is $OPTION"
        exit 1;;
    esac
done

if [ ! -n "$domain" ]; then  
    domain="self.docker.com"
fi

if [ ! -n "$base_data_dir" ]; then  
    base_data_dir="/docker_data"
fi

if [ ! -n "$generatessl" ]; then  
    generatessl=0
fi

if [ ! -n "$ssl" ]; then  
    ssl=0
fi

if [ ! -n "$autossl" ]; then  
    autossl=0
fi

echo "路径:$base_data_dir" 
echo "域名:$domain" 

funCreateDir(){
    dir=$1
    if [ ! -d $dir ];then
        mkdir $dir
    fi
}

funStopContainer(){
    name=$1
    docker ps -a -q --filter "name=$name" | grep -q . && docker rm -fv $name
}

#CF_Account_ID=CF_Account_ID
#CF_Token=CF_Token
#CF_Zone_ID=CF_Zone_ID
#SSL_EMAIL=SSL_EMAIL

funCreateDir $base_data_dir/acmeout

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

docker run -it --rm \
    -e CF_Token=`echo $CF_Token` \
    -e CF_Account_ID=`echo $CF_Account_ID` \
    -e CF_Zone_ID=`echo $CF_Zone_ID` \
    -v $base_data_dir/acmeout:/acme.sh \
    neilpang/acme.sh --issue -d *.$domain --dns dns_cf -m `echo $SSL_EMAIL` || exit 1