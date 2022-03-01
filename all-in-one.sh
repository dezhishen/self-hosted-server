#/bin/bash
base_data_dir=$1
if [ ! -n "$base_data_dir" ]; then  
    base_data_dir="/docker_data"
fi

if [ ! -d base_data_dir ];then
    mkdir $base_data_dir
else
    foldername=$(date +%Y-%M-%d)
    cp -r $dir $dir.bak.$foldername
    #echo "已备份到：$dir.bak.$foldername"
fi

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


docker network create ingress -d bridge || true


# filebrowser

funCreateDir $base_data_dir/filebrowser

cp ./filebrowser/filebrowser.db $base_data_dir/filebrowser/
cp ./filebrowser/filebrowser.json $base_data_dir/filebrowser/

funStopContainer filebrowser 


docker run -d --restart=always --name=filebrowser \
--network=ingress --network-alias=filebrowser \
-u $(id -u):$(id -g) \
-v $base_data_dir:/srv \
-v "$base_data_dir/filebrowser/filebrowser.db:/database.db" \
-v "$base_data_dir/filebrowser/filebrowser.json:/.filebrowser.json" \
filebrowser/filebrowser


# portainer

funCreateDir $base_data_dir/portainer
funCreateDir $base_data_dir/portainer/data

funStopContainer portainer 

docker run -d --restart=always --name=portainer \
-v /var/run/docker.sock:/var/run/docker.sock \
-v $base_data_dir/portainer/data:/data \
--network=ingress --network-alias=portainer \
portainer/portainer-ce


# adguardhome

funCreateDir $base_data_dir/adguardhome
funCreateDir $base_data_dir/adguardhome/work
funCreateDir $base_data_dir/adguardhome/conf
funStopContainer adguardhome 
docker run -d --restart=always --name=adguardhome \
-p 53:53 \
--network=ingress --network-alias=adguardhome \
-v $base_data_dir/adguardhome/work:/opt/adguardhome/work \
-v $base_data_dir/adguardhome/conf:/opt/adguardhome/conf \
adguard/adguardhome -p 80

# nginx 

funCreateDir $base_data_dir/nginx
funCreateDir $base_data_dir/nginx/conf
funCreateDir $base_data_dir/nginx/conf/conf.d

cp nginx.conf $base_data_dir/nginx/conf/
cp -r ./conf.d/* $base_data_dir/nginx/conf/conf.d/

funStopContainer nginx

docker run -d --restart=always --name=nginx \
-v $base_data_dir/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
-v $base_data_dir/nginx/conf/conf.d:/etc/nginx/conf.d \
-p 80:80 -p 443:443 \
--network=ingress --network-alias=ingress \
nginx