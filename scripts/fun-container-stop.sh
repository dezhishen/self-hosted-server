# /bin/bash
name=$1
echo "stop and remove container [$name] if exist"
docker ps -a -q --filter "name=$name" | grep -q . && docker rm -fv $name
