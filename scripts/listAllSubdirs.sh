# the gsed and tr commands cut off the ./ and windows newlines on cygwin:
directories_list=`gfind . -type d | gsed 's/\.\///g' | tr -d '\15\32' | sort -n`
# :2 cuts off the first element, '.' :
for element in "${directories_list[@]:2}"
do
    echo "$element"
done