# DESCRIPTION: creates .tif files from all .svg files in a directory tree, via imagemagick. Creates 4120px jpg images by default. This script was formerly entitled allSVG2PNG.sh.

# USAGE: invoke this script with these parameters:
# $1 the number of pixels you wish the longest side of the converted .svg file to be.
# $2 the target file format e.g. tif or jpg
# $3 optional--include this parameter (it can be anything) to make white transparent; otherwise white will be opaque.

# template command: magick -size 850 test.svg result.tif
# NOTE that for the -size parameter, it scales the imagesso that the longest side is that many pixels.

# If no image size parameter, set default image size of 300.
# TO DO: update this to use the more robust non-parameter (/variable) detection method I found.
img_format=$1
img_size=$2

if [ -z ${1+x} ]; then img_size=4120; else img_size=$1; fi
if [ -z ${2+x} ]; then img_format=jpg; else img_format=$2; fi
if [ -z ${3+x} ]; then param3="-background none"; fi

CygwinFind . -iname \*.svg > all_svgs.txt
mapfile -t all_svgs < all_svgs.txt
for element in "${all_svgs[@]}"
do
		# Because I couldn't get this done with an echo piped to sed:
		echo $element > temp.txt
		sed -i 's/\(.*\)\.svg/\1/g' temp.txt
	svgFilenameNoExtension=$( < temp.txt)
	if [ -a $svgFilenameNoExtension.$img_format ]
	then
		echo render candidate is $svgFilenameNoExtension.$img_format
		echo target already exists\; will not render.
		echo . . .
	else
		echo rendering $element . . .
		magick $param3 -size $1x$1 $element $svgFilenameNoExtension.$img_format
	fi
done

rm temp.txt all_svgs.txt