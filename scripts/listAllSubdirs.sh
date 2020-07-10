# DESCRIPTION
# Prints all subdirectories (and their subdirectories) in the current directory, relative to the current directory (so sub-subdirectories etc. will show their parent, then /).

# USAGE
#  listAllSubdirs.sh


# CODE
# If there's a printf command that chops off the leading ./ but still prints all subdirs to, I don't know it yet:
directories_list=`find . -type d | sed 's/\.\///g' | tr -d '\15\32' | sort -n`
# :1 cuts off the first element, '.' :
for element in "${directories_list[@]:1}"
do
    echo "$element"
done