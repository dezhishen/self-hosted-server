# /bin/bash
docker_network_name=$1
# create docker network $docker_network_name
echo "创建docker网络[$docker_network_name]"
echo "docker network create $docker_network_name"

# check has ipv6 address
## show eth-interfaces and choose one
eth_interface=$(sh `dirname $0`/read-args-with-history.sh eth_interface "网卡设备名称/eth-interface")
echo $eth_interface
if [ ! -n "$eth_interface" ];then
    ip addr | grep -E '^[0-9]+: ' | awk '{print $2}' | sed 's/://g' | sed 's/@//g'
    echo "请输入你的主网卡"
    echo "please input your eth-interface:"
    read eth_interface
    sh `dirname $0`/set-args-to-history.sh eth_interface $eth_interface
fi
ipv6_addr=$(ip -6 addr show $eth_interface | grep inet6 | grep -v "fe80" | awk '{print $2}' | awk -F '/' '{print $1}')
if [ -n "$ipv6_addr" ]; then
    ipv6_addr="$ipv6_addr"
    echo "你的ipv6地址为:$ipv6_addr"
    echo "ipv6 address is $ipv6_addr"
    ipv6_enable=y
else
    echo "[warning] no ipv6 address found, please check your eth-interface,create docker network $docker_network_name with out ipv6 address"
    echo "[警告] 没有找到ipv6地址,请检查你的主网卡,创建docker网络[$docker_network_name]时不启用ipv6地址"
    ipv6_enable=n
fi


# check docker.service enable ipv6
if [ "$ipv6_enable" = "y" ]; then
    echo "检查docker.service是否启用ipv6"
    echo "checking docker.service enable ipv6"
    ipv6_enable=n
    if [ -f /etc/docker/daemon.json ];then
        docker_enable_ipv6=$(cat /etc/docker/daemon.json | grep "ipv6" | awk -F '"' '{print $4}')
        if [ "$docker_enable_ipv6" = "true" ]; then
            echo "docker服务已启用ipv6"
            echo "docker.service enable ipv6"
            ipv6_enable=y
        fi
    fi
    if [ "$ipv6_enable" != "y" ]; then
        echo "[警告] docker服务未启用ipv6"
        echo "[warning] docker service not enable ipv6"
    fi
fi

# check if docker network $docker_network_name exist
docker_network_exists=$(docker network ls | grep $docker_network_name | awk '{print $2}')
if [ -n "$docker_network_exists" ]; then
    echo "docker网络[$docker_network_name]已存在"
    echo "docker network $docker_network_name exist"
    docker_network_exists=y
fi

# check docker network $docker_network_name config is right if docker network $docker_network_name exist
if [ "$docker_network_exists" = "y" ]; then
    echo "校验docker网络[$docker_network_name]配置"
    echo "check docker network $docker_network_name config"
    # check if network $docker_network_name driver is bridge
    docker_network_name_driver=$(docker network inspect $docker_network_name | grep "Driver" | awk -F '"' '{print $4}')
    if [ "$docker_network_name_driver"=~bridge  ]; then
        echo "docker网络[$docker_network_name]驱动为[bridge]"
        echo "docker network $docker_network_name driver is bridge"
    else
        echo "[错误] docker网络[$docker_network_name]驱动不包含[bridge],请检查"
        exit 1
    fi
    if [ "$ipv6_enable" = "y" ]; then
        echo "检查docker网络[$docker_network_name]是否启用了ipv6"
        echo "check docker network $docker_network_name enable ipv6"
        docker_network_name_ipv6=$(docker network inspect $docker_network_name | grep "EnableIPv6" | awk -F '"' '{print $4}')
        if [ "$docker_network_name_ipv6" = "true" ]; then
            echo "docker网络[$docker_network_name]已启用ipv6"
            echo "docker network $docker_network_name enable ipv6"
        else
            echo "[警告] docker网络[$docker_network_name]未启用ipv6"
            warning "docker network $docker_network_name not enable ipv6"
        fi
    fi
else
    echo "docker网络[$docker_network_name]不存在，即将创建"
    echo "docker network $docker_network_name not exist,it will be created"
    if [ "$ipv6_enable" = "y" ]; then
        docker network create --driver bridge --ipv6 $docker_network_name
    else
        docker network create --driver bridge $docker_network_name
    fi
fi
echo "创建docker网络[$docker_network_name]完成"
echo "docker network $docker_network_name created success"