# DESCRIPTION
# Prints all subdirectories (and their subdirectories) in the current directory, relative to the current directory (so sub-subdirectories etc. will show their parent, then /).

# USAGE
# Call this script with these parameters:
# - $1 OPTIONAL. Any string (for example "FLORFELNAUT"), which will cause this script to _not_ search folders within subfolders (it will only search one level deep). If omitted, all folders in all subfolders (to whatever the depth limit of `find` is) will be listed.
# Example command to print folders of unlimited depth:
#    listAllSubdirs.sh
# Example command to search and print folder names only the current directory (one level deep) for folders:
#    listAllSubdirs.sh FLORFELNAUT
# To call this from another script and create an array of the output, do:
# allSubdirectoriesArray=( $(listAllSubdirs.sh) )


# CODE
if [ "$1" ]; then subdirSearchCommand="-maxdepth 1"; fi

# If there's a printf command that chops off the leading ./ but still prints all subdirs also, I don't know it yet:
directories_list=$(find . $subdirSearchCommand -type d | sed 's/\.\///g' | tr -d '\15\32' | sort -n)
# :1 cuts off the first element, '.' :
for element in "${directories_list[@]:1}"
do
    echo "$element"
done