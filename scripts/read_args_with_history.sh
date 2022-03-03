# /bin/bash
arg_name=$1
## if file not exist, return empty string
if [ ! -f ./args/$arg_name ]; then
    echo ""
    exit 0
fi
## read value from file ./args/$arg_name
value=$(cat ./args/$1)
## check value is empty or not
if [ -z "$value" ]; then
    echo ""
    exit 0
fi
## if value is not empty, to check value is user excepted
read -p "value of $arg_name:[$value] is not empty, do you want to change it?[y/n]" yn
case $yn in
    [Yy]* )
        read -p "please input new value:" value
        echo $value > ./args/$arg_name
        ;;
    [Nn]* )
        ;;
    * )
        ;;
esac
echo $value
exit 0