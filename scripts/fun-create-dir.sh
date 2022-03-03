# /bin/bash
dir=$1

if [ ! -d $dir ];then
    mkdir $dir
    echo "create dir[$dir] success"
else
    echo "dir[$dir] already exist"
fi