# /bin/bash
docker_network_name=$1
# create docker network $docker_network_name
echo "creating network for docker"

# check has ipv6 address
## show eth-interfaces and choose one
eth_interface=$(sh `dirname $0`/read-args-with-history.sh eth_interface)
echo $eth_interface
if [ ! -n "$eth_interface" ];then
    ip addr | grep -E '^[0-9]+: ' | awk '{print $2}' | sed 's/://g' | sed 's/@//g'
    read -p "please input your main eth-interface:" eth_interface
    sh `dirname $0`/set-args-to-history.sh eth_interface $eth_interface
fi
ipv6_addr=$(ip -6 addr show $eth_interface | grep inet6 | grep -v "fe80" | awk '{print $2}' | awk -F '/' '{print $1}')
if [ -n "$ipv6_addr" ]; then
    ipv6_addr="$ipv6_addr"
    echo "ipv6 address is $ipv6_addr"
    ipv6_enable=y
else
    echo "[warning] no ipv6 address found, please check your eth-interface,will create docker network $docker_network_name with out ipv6 address"
    ipv6_enable=n
fi


# check docker.service enable ipv6
if [ "$ipv6_enable" = "y" ]; then
    echo "checking docker.service enable ipv6"
    ipv6_enable=n
    if [ -f /etc/docker/daemon.json ];then
        docker_enable_ipv6=$(cat /etc/docker/daemon.json | grep "ipv6" | awk -F '"' '{print $4}')
        if [ "$docker_enable_ipv6" = "true" ]; then
            echo "docker.service enable ipv6"
            ipv6_enable=y
        fi
    fi
    if [ "$ipv6_enable" != "y" ]; then
        echo "[warning] docker service not enable ipv6, please check your docker.service"
    fi
fi

# check if docker network $docker_network_name exist
echo "checking if docker network $docker_network_name exist"
docker_network_exists=$(docker network ls | grep $docker_network_name | awk '{print $2}')
if [ -n "$docker_network_exists" ]; then
    echo "docker network $docker_network_name exist"
    docker_network_exists=y
fi

# check docker network $docker_network_name config is right if docker network $docker_network_name exist
if [ "$docker_network_exists" = "y" ]; then
    echo "checking if docker network $docker_network_name config is right"
    # check if network $docker_network_name driver is bridge
    docker_network_name_driver=$(docker network inspect $docker_network_name | grep "Driver" | awk -F '"' '{print $4}')
    if [ "$docker_network_name_driver"=~bridge  ]; then
        echo "docker network $docker_network_name driver is bridge"
    else
        error "docker network $docker_network_name driver is not bridge, please check your docker network $docker_network_name config"
        exit 1
    fi
    if [ "$ipv6_enable" = "y" ]; then
        echo "checking docker network $docker_network_name if enable ipv6"
        docker_network_name_ipv6=$(docker network inspect $docker_network_name | grep "EnableIPv6" | awk -F '"' '{print $4}')
        if [ "$docker_network_name_ipv6" = "true" ]; then
            echo "docker network $docker_network_name enable ipv6"
        else
            warning "docker network $docker_network_name not enable ipv6, please check your docker network $docker_network_name config"
        fi
    fi
else
    echo "docker network $docker_network_name not exist"
    echo "creating docker network $docker_network_name"
    # create docker network $docker_network_name
    if [ "$ipv6_enable" = "y" ]; then
        docker network create --driver bridge --ipv6 $docker_network_name
    else
        docker network create --driver bridge $docker_network_name
    fi
fi

echo "docker network $docker_network_name created sucessfully, you can run 'docker network inspect $docker_network_name' to check"