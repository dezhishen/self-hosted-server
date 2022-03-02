#/bin/bash
if [ ! -n "$domain" ]; then  
    echo "请输入域名"
    read domain
    if [ ! -n "$domain" ]; then  
        echo "必须输入域名！！"
        exit 1
    fi
fi

if [ ! -n "$base_data_dir" ]; then  
    echo "请输入docker卷使用的根目录,默认为/docker_data"
    read base_data_dir
    if [ ! -n "$base_data_dir" ]; then  
        base_data_dir="/docker_data"
    fi
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

funCreateDir $base_data_dir/acmeout

echo "请选择服务商:"
echo "1.Cloudflare: dns_cf"
read DNS_TYPE
case $DNS_TYPE in
"dns_cf")
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
        neilpang/acme.sh --issue -d *.$domain --dns `echo $DNS_TYPE` -m `echo $SSL_EMAIL` || exit 1
    ;;
"")
*)
    echo "不支持的类型"
    exit 1
    ;;
esac

