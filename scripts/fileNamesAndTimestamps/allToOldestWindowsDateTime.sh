# DESCRIPTION
# Invokes toOldestWindowsDateTime.sh for all image formats (hard coded) in the current directory.

# CODE
list=$(ls *.*)

for element in ${list[@]}
do
	echo "INVOKING toOldestWindowsDateTime.sh for file \"$element\" . . ."
	toOldestWindowsDateTime.sh $element
done