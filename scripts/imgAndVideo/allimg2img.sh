IN PROGRESS.

# DESCRIPTION: converts all images of one type in a directory tree to another.

# USAGE: invoke this script with these parameters:
# $1 the source file format e.g. eps or svg
# $2 the target file format e.g. tif or jpg

# DEV NOTE: template command: magick -size 850 test.svg result.tif
# NOTE that for the -size parameter, it scales the imagesso that the longest side is that many pixels.

img_format_1=$1
img_format_2=$2


find . -iname \*.$1 > all_"$1".txt
mapfile -t all_imgs.txt < all_"$1".txt
for element in "${all_imgs[@]}"
do
	# ? magick $param3 -size $1x$1 $element $svgFilenameNoExtension.$img_format
done

rm all_imgs.txt all_svgs.txt
