# /bin/bash
dir=$1

if [ ! -d $dir ];then
    mkdir $dir
    printf "$CREATE_DIR_SUCCESS_LANG" $dir
    echo ""
else
    printf "$DIR_ALREADY_EXISTS_LANG" $dir
    echo ""
fi