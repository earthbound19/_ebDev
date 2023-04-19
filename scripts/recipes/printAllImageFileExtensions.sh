# DESCRIPTION
# Filters all present files which are any of the file extensions found by printAllIMGfileNames.sh, to unique extensions, and prints them to stdout. By default operates only on the current directory, and with any optional parameter searches all subdirectories also.

# DEPENDENCIES
# `printAllIMGfileNames.sh`

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. Anything, such as the word BROGNALF, which will cause search for supported image file types in subdirectories also.
# For example, to print the extensions of all supported file types found in the file names of the current directory and all subdirectories, run:
#    printAllImageFileExtensions.sh BROGNALF
# To print only supported extensions from the current directory, run the script without any parameter:
#    printAllImageFileExtensions.sh


# CODE
# If no parameter $1 is passed to this script, there will be no subdirSearchParam variable declared, and on attempt to us it it will be effectively null (no used value):
if [ "$1" ]; then subdirSearchParam=$1; fi

# get an array of all image file names which are of the supported types:
allImageFileNames=( $(printAllIMGfileNames.sh $subdirSearchParam) )
# init an empty array to store present file types in:
allImageExtensionsThatArePresent=()

# go through the array of file names and add every extension (possibly redundantly) from it to the array of present file types:
for file in ${allImageFileNames[@]}
do
	allImageExtensionsThatArePresent+=(${file##*.})
done

# Reduce the array of present types to unique values;
# Saved by a genius yonder: https://stackoverflow.com/a/11789688/1397555
OIFS="$IFS"
IFS=$'\n'
allImageExtensionsThatArePresent=($(sort <<<"${allImageExtensionsThatArePresent[*]}"))
allImageExtensionsThatArePresent=($(uniq <<<"${allImageExtensionsThatArePresent[*]}"))
IFS="$OIFS"

# print those found unique present types (the array), re: https://stackoverflow.com/a/15692004/1397555
printf '%s\n' "${allImageExtensionsThatArePresent[@]}" | tr -d '\15\32'
