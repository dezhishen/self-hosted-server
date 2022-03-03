# /bin/bash
dir=$1

if [ ! -d $dir ];then
    mkdir $dir
    echo "创建目录[$dir]成功"
    echo "create dir[$dir] success"
else
    echo "目录[$dir]已经存在"
    echo "dir[$dir] already exist"
fi