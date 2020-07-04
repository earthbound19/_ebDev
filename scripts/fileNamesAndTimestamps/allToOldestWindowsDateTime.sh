# DESCRIPTION
# Invokes toOldestWindowsDateTime.sh for all image formats (hard coded) in the current directory.

# CODE
list=(`gfind . -maxdepth 1 \( -iname \*.jpg -o -iname \*.png -o -iname \*.cr2 -o -iname \*.tif -o -iname \*.mov \) -printf '%f\n' | sort`)

for element in ${list[@]}
do
	echo "INVOKING toOldestWindowsDateTime.sh for file \"$element\" . . ."
	toOldestWindowsDateTime.sh $element
done