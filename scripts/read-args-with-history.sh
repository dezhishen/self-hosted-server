# /bin/bash
arg_name=$1
desc=$2
## if file not exist, return empty string
if [ ! -f `dirname $0`/../args/$arg_name ]; then
    echo ""
fi
## read value from file ./args/$arg_name
value=$(cat `dirname $0`/../args/$arg_name)
## check value is empty or not
if [ -z "$value" ]; then
    echo ""
fi
## if value is not empty, to check value is user excepted
text=$(printf "$INPUT_TO_CHANGE_LANG" "$desc" "$value")
read -p "$text" new_value
if [ -n "$new_value" ]; then
    value=$new_value
    echo $new_value > `dirname $0`/../args/$arg_name
fi
echo "$value"
