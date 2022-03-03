# /bin/bash
name=$1
echo "停止并且删除容器[$name]"
echo "stop and remove container[$name]"
docker ps -a -q --filter "name=$name" | grep -q . && docker rm -fv $name
