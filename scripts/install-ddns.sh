# /bin/bash
echo "仅支持cloudflare的ddns"

CLOUDFLARE_ACCOUNT_EMAIL=$(`dirname $0`/read-args-with-history.sh cloudflare_account_email "$CLOUDFLARE_ACCOUNT_EMAIL_LANG")
if [ ! -n "$CLOUDFLARE_ACCOUNT_EMAIL" ]; then
    printf "$INPUT_TIPS" "$CLOUDFLARE_ACCOUNT_EMAIL_LANG"
    read CLOUDFLARE_ACCOUNT_EMAIL
    # 如果仍然为空，则退出
    if [ ! -n "$CLOUDFLARE_ACCOUNT_EMAIL" ]; then
        echo "取消安装"
        exit
    fi
    `dirname $0`/set-args-to-history.sh cloudflare_account_email $CLOUDFLARE_ACCOUNT_EMAIL
fi

CLOUDFLARE_API_KEY=$(`dirname $0`/read-args-with-history.sh cloudflare_api_key "$CLOUDFLARE_API_KEY_LANG")
if [ ! -n "$CLOUDFLARE_API_KEY" ]; then
    printf "$INPUT_TIPS" "$CLOUDFLARE_API_KEY_LANG"
    read CLOUDFLARE_API_KEY
    # 如果仍然为空，则退出
    if [ ! -n "$CLOUDFLARE_API_KEY" ]; then
        echo "取消安装"
        exit
    fi
    `dirname $0`/set-args-to-history.sh cloudflare_api_key $CLOUDFLARE_API_KEY
fi

CLOUDFLARE_API_TOKEN=$(`dirname $0`/read-args-with-history.sh cloudflare_api_token "$CLOUDFLARE_API_TOKEN_LANG")
if [ ! -n "$CLOUDFLARE_API_TOKEN" ]; then
    printf "$INPUT_TIPS" "$CLOUDFLARE_API_TOKEN_LANG"
    read CLOUDFLARE_API_TOKEN
    # 如果仍然为空，则退出
    if [ ! -n "$CLOUDFLARE_API_TOKEN" ]; then
        echo "取消安装"
        exit
    fi
    `dirname $0`/set-args-to-history.sh cloudflare_api_token $CLOUDFLARE_API_TOKEN
fi

CLOUDFLARE_ZONE_ID=$(`dirname $0`/read-args-with-history.sh cloudflare_zone_id "$CLOUDFLARE_ZONE_ID_LANG")
if [ ! -n "$CLOUDFLARE_ZONE_ID" ]; then
    printf "$INPUT_TIPS" "$CLOUDFLARE_ZONE_ID_LANG"
    read CLOUDFLARE_ZONE_ID
    # 如果仍然为空，则退出
    if [ ! -n "$CLOUDFLARE_ZONE_ID" ]; then
        echo "取消安装"
        exit
    fi
    `dirname $0`/set-args-to-history.sh cloudflare_zone_id $CLOUDFLARE_ZONE_ID
fi
# set enable of cloudflare ddns ipv4, default is enable
CLOUDFLARE_DDNS_IPV4_ENABLE=$(`dirname $0`/read-args-with-history.sh cloudflare_ddns_ipv4_enable "$CLOUDFLARE_DDNS_IPV4_ENABLE_LANG")
if [ ! -n "$CLOUDFLARE_DDNS_IPV4_ENABLE" ];then
    printf "$INPUT_WIRH_DEFAULT_LANG" "$CLOUDFLARE_DDNS_IPV4_ENABLE_LANG" "y"
    read CLOUDFLARE_DDNS_IPV4_ENABLE
    if [ ! -n "$CLOUDFLARE_DDNS_IPV4_ENABLE" ]; then
        CLOUDFLARE_DDNS_IPV4_ENABLE="y"
    fi
    `dirname $0`/set-args-to-history.sh cloudflare_ddns_ipv4_enable $CLOUDFLARE_DDNS_IPV4_ENABLE
fi
# set enable of cloudflare ddns ipv6, default is enable
CLOUDFLARE_DDNS_IPV6_ENABLE=$(`dirname $0`/read-args-with-history.sh cloudflare_ddns_ipv6_enable "$CLOUDFLARE_DDNS_IPV6_ENABLE_LANG")
if [ ! -n "$CLOUDFLARE_DDNS_IPV6_ENABLE" ];then
    printf "$INPUT_WIRH_DEFAULT_LANG" "$CLOUDFLARE_DDNS_IPV6_ENABLE_LANG" "y"
    read CLOUDFLARE_DDNS_IPV6_ENABLE
    if [ ! -n "$CLOUDFLARE_DDNS_IPV6_ENABLE" ]; then
        CLOUDFLARE_DDNS_IPV6_ENABLE="y"
    fi
    `dirname $0`/set-args-to-history.sh cloudflare_ddns_ipv6_enable $CLOUDFLARE_DDNS_IPV6_ENABLE
fi

# 输入需要被代理的子域名，多个子域名用,分隔
CLOUDFLARE_PROXIED_SUBDOMAINS=$(`dirname $0`/read-args-with-history.sh CLOUDFLARE_PROXIED_SUBDOMAINS "$CLOUDFLARE_PROXIED_SUBDOMAINS_LANG")
# 如果为空，则需要用户输入
if [ ! -n "$CLOUDFLARE_PROXIED_SUBDOMAINS" ];then
    printf "$INPUT_TIPS" "$CLOUDFLARE_PROXIED_SUBDOMAINS_LANG"
    read CLOUDFLARE_PROXIED_SUBDOMAINS
    # 如果不为空，保存到历史记录
    if [ -n "$CLOUDFLARE_PROXIED_SUBDOMAINS" ]; then
        `dirname $0`/set-args-to-history.sh CLOUDFLARE_PROXIED_SUBDOMAINS $CLOUDFLARE_PROXIED_SUBDOMAINS
    fi
fi

# 输入不需要被代理的子域名，多个子域名用,分隔
CLOUDFLARE_UNPROXIED_SUBDOMAINS=$(`dirname $0`/read-args-with-history.sh CLOUDFLARE_UNPROXIED_SUBDOMAINS "$CLOUDFLARE_UNPROXIED_SUBDOMAINS_LANG")
# 如果为空，则需要用户输入
if [ ! -n "$CLOUDFLARE_UNPROXIED_SUBDOMAINS" ];then
    printf "$INPUT_TIPS" "$CLOUDFLARE_UNPROXIED_SUBDOMAINS_LANG"
    read CLOUDFLARE_UNPROXIED_SUBDOMAINS
    # 如果不为空，保存到历史记录
    if [ -n "$CLOUDFLARE_UNPROXIED_SUBDOMAINS" ]; then
        `dirname $0`/set-args-to-history.sh CLOUDFLARE_UNPROXIED_SUBDOMAINS $CLOUDFLARE_UNPROXIED_SUBDOMAINS
    fi
fi

# 如果用户没有输入任何子域名，则退出
if [ -z "$CLOUDFLARE_PROXIED_SUBDOMAINS" ] && [ -z "$CLOUDFLARE_UNPROXIED_SUBDOMAINS" ]; then
    echo "取消安装"
    exit
fi
# 创建ddns目录
`dirname $0`/fun-create-dir.sh $base_data_dir/ddns

# 写入配置文件 $base_data_dir/ddns/config.json
echo "正在写入配置文件..."
echo "{" > $base_data_dir/ddns/config.json
# 当ipv4为enable时，写入ipv4配置 "a":true
if [ "$CLOUDFLARE_DDNS_IPV4_ENABLE" = "y" ]; then
    echo "    \"a\":true," >> $base_data_dir/ddns/config.json
else
    echo "    \"a\":false," >> $base_data_dir/ddns/config.json
fi
# 当ipv6为enable时，写入ipv6配置 "aaaa":true
if [ "$CLOUDFLARE_DDNS_IPV6_ENABLE" = "y" ]; then
    echo "    \"aaaa\":true," >> $base_data_dir/ddns/config.json
else
    echo "    \"aaaa\":false," >> $base_data_dir/ddns/config.json
fi
echo "    \"cloudflare\": [" >> $base_data_dir/ddns/config.json
# 输入cloudflare的权限信息
echo "    {" >> $base_data_dir/ddns/config.json
echo "        \"authentication\":{" >> $base_data_dir/ddns/config.json
echo "            \"api_token\":\"$CLOUDFLARE_API_TOKEN\"," >> $base_data_dir/ddns/config.json
echo "            \"api_key\": {" >> $base_data_dir/ddns/config.json
echo "                \"api_key\":\"$CLOUDFLARE_API_KEY\"," >> $base_data_dir/ddns/config.json
echo "                \"account_email\":\"$CLOUDFLARE_ACCOUNT_EMAIL\"" >> $base_data_dir/ddns/config.json
echo "            }" >> $base_data_dir/ddns/config.json
echo "        }," >> $base_data_dir/ddns/config.json
echo "        \"zone_id\":\"$CLOUDFLARE_ZONE_ID\"," >> $base_data_dir/ddns/config.json
echo "        \"subdomains\":[" >> $base_data_dir/ddns/config.json
if [ -n "$CLOUDFLARE_PROXIED_SUBDOMAINS" ]; then
    echo "            \"$(echo $CLOUDFLARE_PROXIED_SUBDOMAINS | sed 's/,/\",\"/g')\"" >> $base_data_dir/ddns/config.json
fi
echo "        ]," >> $base_data_dir/ddns/config.json
echo "        \"proxied\":true" >> $base_data_dir/ddns/config.json
echo "    }," >> $base_data_dir/ddns/config.json
echo "    {" >> $base_data_dir/ddns/config.json
echo "        \"authentication\":{" >> $base_data_dir/ddns/config.json
echo "            \"api_token\":\"$CLOUDFLARE_API_TOKEN\"," >> $base_data_dir/ddns/config.json
echo "            \"api_key\": {" >> $base_data_dir/ddns/config.json
echo "                \"api_key\":\"$CLOUDFLARE_API_KEY\"," >> $base_data_dir/ddns/config.json
echo "                \"account_email\":\"$CLOUDFLARE_ACCOUNT_EMAIL\"" >> $base_data_dir/ddns/config.json
echo "            }" >> $base_data_dir/ddns/config.json
echo "        }," >> $base_data_dir/ddns/config.json
echo "        \"zone_id\":\"$CLOUDFLARE_ZONE_ID\"," >> $base_data_dir/ddns/config.json
echo "        \"subdomains\":[" >> $base_data_dir/ddns/config.json
if [ -n "$CLOUDFLARE_UNPROXIED_SUBDOMAINS" ]; then
    echo "            \"$(echo $CLOUDFLARE_UNPROXIED_SUBDOMAINS | sed 's/,/\",\"/g')\"" >> $base_data_dir/ddns/config.json
fi
echo "        ]," >> $base_data_dir/ddns/config.json
echo "        \"proxied\":false" >> $base_data_dir/ddns/config.json
echo "        }" >> $base_data_dir/ddns/config.json
echo "    ]" >> $base_data_dir/ddns/config.json
echo "}" >> $base_data_dir/ddns/config.json

# stop container
`dirname $0`/fun-container-stop ddns
docker run -u `id -u`:`id -g` --network=host \
-d --name=ddns --restart=always \
-v $base_data_dir/ddns/config.json:/config.json \
timothyjmiller/cloudflare-ddns:latest

printf "$SUCCESS_TIPS" ddns 