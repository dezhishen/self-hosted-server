# /bin/bash
name=$1
printf "$STOP_AND_REMOVE_CONTAINER_LANG" $name
echo ""
docker ps -a -q --filter "name=$name" | grep -q . && docker rm -fv $name
