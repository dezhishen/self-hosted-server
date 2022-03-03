# /bin/bash
docker_network_name=$1
# create docker network $network_name
echo "creating network for docker"

# check has ipv6 address
## show eth-interfaces and choose one
ip addr | grep -E '^[0-9]+: ' | awk '{print $2}' | sed 's/://g' | sed 's/@//g'
read -p "please input your main eth-interface:" eth_interface

ipv6_addr=$(ip -6 addr show $eth_interface | grep inet6 | grep -v "fe80" | awk '{print $2}' | awk -F '/' '{print $1}')
if [ -n "$ipv6_addr" ]; then
    ipv6_addr="[$ipv6_addr]"
    echo "ipv6 address is $ipv6_addr"
    ipv6_enable=1
else
    warning "no ipv6 address found, please check your eth-interface,will create docker network $network_name with out ipv6 address"
    ipv6_enable=0
fi


# check docker.service enable ipv6
if [ "$ipv6_enable" = "1" ]; then
    echo "checking docker.service enable ipv6"
    docker_enable_ipv6=$(cat /etc/docker/daemon.json | grep "ipv6" | awk -F '"' '{print $4}')
    if [ "$docker_enable_ipv6" = "true" ]; then
        echo "docker.service enable ipv6"
    else
        warning "docker.service not enable ipv6, please check your docker.service"
        ipv6_enable=0
    fi
fi

# check if docker network $network_name exist
echo "checking if docker network $network_name exist"
docker_network_$network_name_exist=$(docker network ls | grep $network_name | awk '{print $2}')
if [ -n "$docker_network_$network_name_exist" ]; then
    echo "docker network $network_name exist"
    docker_network_$network_name_exist=1
fi

# check docker network $network_name config is right if docker network $network_name exist
if [ "$docker_network_$network_name_exist" = "1" ]; then
    echo "checking docker network $network_name config is right"
    # check if network $network_name driver is bridge
    docker_network_$network_name_driver=$(docker network inspect $network_name | grep "Driver" | awk -F '"' '{print $4}')
    if [[ "$docker_network_$network_name_driver"=~bridge  ]]; then
        echo "docker network $network_name driver is bridge"
    else
        error "docker network $network_name driver is not bridge, please check your docker network $network_name config"
        exit 1
    fi
    if [ "$ipv6_enable" = "1" ]; then
        echo "checking docker network $network_name if enable ipv6"
        docker_network_$network_name_ipv6=$(docker network inspect $network_name | grep "EnableIPv6" | awk -F '"' '{print $4}')
        if [ "$docker_network_$network_name_ipv6" = "true" ]; then
            echo "docker network $network_name enable ipv6"
        else
            warning "docker network $network_name not enable ipv6, please check your docker network $network_name config"
        fi
    fi
else
    echo "docker network $network_name not exist"
    echo "creating docker network $network_name"
    # create docker network $network_name
    if [ "$ipv6_enable" = "1" ]; then
        docker network create --driver bridge --ipv6 $network_name
    else
        docker network create --driver bridge $network_name
    fi
fi

echo "docker network $network_name created sucessfully, you can run 'docker network inspect $network_name' to check"