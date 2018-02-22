# DESCRIPTION
# Creates .jpg (by default) files from all .eps files in a directory tree, via imagemagick. Creates 1280px jpg images by default. Also, does not overwrite files if the render target name exists (you must first delete the existing target file, then run this script to re-create it).

# USAGE
# Invoke this script with these parameters:
# $1 the number of pixels you wish the longest side of the image converted from the .eps file(s) to be.
# $2 the target file format e.g. png or jpg -- defaults to jpg if not provided.

# NOTES
# If the result image has raster upscale (jaggy) artifacts, hack the -density parameter in this script with a higher number until that isn't a problem.

# DO TO
# Calculate needed density for target image size, and calculate automatically. I think 72dpi should be good enough, or density = 72 * (longest image dimension in inches)?

# DEV NOTES: template command: gm -size 850 test.svg result.tif
# This script was adapted from allSVG2img.sh.
# NOTE that for the -size parameter, it scales the images so that the longest side is that many pixels.


# CODE
img_size=$1
img_format=$2

# If no image size parameter, set default image size of 1280.
if [ -z ${1+x} ]; then img_size=1280; echo SET img_size to DEFAULT 1280; else img_size=$1; echo SET img_size to $1; fi
# If no image format parameter, set default image format of jpg.
if [ -z ${2+x} ]; then img_format=jpg; echo SET img_format to DEFAULT jpg; else img_format=$2; echo SET img_format to $2; fi

gfind \*.eps > all_eps.txt
while read element
do
# TO DO: fix base file name format to the more elegant "echo" means. Also do this for allSVG2img.sh.
		epsFilenameNoExtension=`echo $element | sed 's/\(.*\)\.svg/\1/g'`
	if [ -a $epsFilenameNoExtension.$img_format ]
	then
		echo render candidate is $epsFilenameNoExtension.$img_format
		echo target already exists\; will not render.
		echo . . .
	else
		# Have I already tried e.g. -size 1000x1000 as described here? :  
		echo rendering $element . . .
		# -density parameter upscaling fix found here: https://stackoverflow.com/a/7584726
		echo COMMAND\: gm convert -density 300 $param3 $element $epsFilenameNoExtension.$img_format
		gm convert -density 300 $param3 -resize $img_size $element $epsFilenameNoExtension.$img_format
	fi
done < all_eps.txt

rm all_eps.txt