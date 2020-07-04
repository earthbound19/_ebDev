# TO DO: printf as I do in other scripts to chop off the ./:
directories_list=`gfind . -type d | sed 's/\.\///g' | tr -d '\15\32' | sort -n`
# :2 cuts off the first element, '.' :
for element in "${directories_list[@]:2}"
do
    echo "$element"
done