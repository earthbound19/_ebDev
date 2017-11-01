# DESCRIPTION
# Combines all input image files of type $1 (parameter 1 to script) into a layered output image file (at this writing, tif format), _all$1_layered.tif

# USAGE
# Invoke this script with one parameter, being the file type to operate on, e.g.:
# ./thisScript.sh png

# TO DO
# Parameterize output file type

# Template command:
# gm convert 1.png 2.png 3.png 4.png out.tif

gfind *.$1 > all_$1.txt
dos2unix all_$1.txt

while read element
do
	# echo $element
	inputFiles="$inputFiles $element"
done < all_$1.txt
rm all_$1.txt

# echo $inputFiles
gm convert $inputFiles _all_$1_layered.tif

echo DONE. See result image _all_$1_layered.tif.