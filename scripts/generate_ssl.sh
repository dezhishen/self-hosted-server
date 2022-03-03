#/bin/bash
while getopts p:d:sugh OPTION; do
    case $OPTION in
    p)
        base_data_dir=$OPTARG
        ;;
    d)
        domain=$OPTARG
        ;;
    h)
        echo "-d domian -p 持久化根目录"
        exit 1;;
    ?)
        echo "get a non option $OPTARG and OPTION is $OPTION"
        exit 1;;
    esac
done

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

if [ ! -n "$SSL_EMAIL" ]; then  
    echo "请输入邮箱:"
    read SSL_EMAIL
fi

echo "请输入DNS服务商:"
cat <<-EOF
dns_cf : Cloudflare
dns_dp : dnspod 
dns_cx : CloudXNS
dns_gd : GoDaddy
dns_pdns : PowerDNS 
dns_lua : LuaDNS 
dns_me : DNSMadeEasy 
dns_aws : Amazon Route53
dns_ali : Aliyun domain API
dns_ispconfig : ISPConfig 3.1 API
dns_ad  : Alwaysdata
默认: dns_cf
EOF
read DNS_TYPE

if [ ! -n "$DNS_TYPE" ]; then  
    echo "使用默认: dns_cf"
    DNS_TYPE=dns_cf
fi
case $DNS_TYPE in
"dns_cf")
if [ ! -n "$CF_Token" ]; then  
    echo "请输入 CF_Token:"
    read CF_Token
fi
if [ ! -n "$CF_Account_ID" ]; then  
    echo "请输入 CF_Account_ID:"
    read CF_Account_ID
fi

if [ ! -n "$CF_Zone_ID" ]; then  
    echo "请输入 CF_Zone_ID:"
    read CF_Zone_ID
fi
cat <<-EOF
    执行 :\\
    docker run -it --rm -e CF_Token=`echo $CF_Token` \\
        -e CF_Account_ID=`echo $CF_Account_ID` \\
        -e CF_Zone_ID=`echo $CF_Zone_ID`\\
        -v $base_data_dir/acmeout:/acme.sh \\
        neilpang/acme.sh --issue -d *.$domain --dns `echo $DNS_TYPE` -m `echo $SSL_EMAIL`
EOF
docker run -it --rm \
    -e CF_Token=`echo $CF_Token` \
    -e CF_Account_ID=`echo $CF_Account_ID` \
    -e CF_Zone_ID=`echo $CF_Zone_ID` \
    -v $base_data_dir/acmeout:/acme.sh \
    neilpang/acme.sh --issue -d *.$domain --dns `echo $DNS_TYPE` -m `echo $SSL_EMAIL` || exit 1
;;

"dns_dp")
if [ ! -n "$DP_Id" ]; then  
    echo "请输入 DP_Id:"
    read DP_Id
fi

if [ ! -n "$DP_Key" ]; then  
    echo "请输入 DP_Key:"
    read DP_Key
fi

cat <<-EOF
    执行 :\\
    docker run -it --rm -e DP_Id=`echo $DP_Id` \\
        -e DP_Key=`echo $DP_Key` \\
        -v $base_data_dir/acmeout:/acme.sh \\
        neilpang/acme.sh --issue -d *.$domain --dns `echo $DNS_TYPE` -m `echo $SSL_EMAIL`
EOF
docker run -it --rm -e DP_Id=`echo $DP_Id` \
    -e DP_Key=`echo $DP_Key` \
    -v $base_data_dir/acmeout:/acme.sh \
    neilpang/acme.sh --issue -d *.$domain --dns `echo $DNS_TYPE` -m `echo $SSL_EMAIL`
;;


*)
    echo "不支持的类型"
    exit 1
    ;;
esac

