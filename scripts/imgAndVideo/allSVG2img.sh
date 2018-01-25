# DESCRIPTION: creates .jpg (by default) files from all .svg files in a directory tree, via imagemagick. Creates 4120px jpg images by default. Also, does not overwrite files if the render target name exists (you must first delete the existing target file, then run this script to re-create it).
# This script was formerly entitled allSVG2PNG.sh.

# USAGE: invoke this script with these parameters:
# $1 the number of pixels you wish the longest side of the converted .svg file(s) to be.
# $2 the target file format e.g. png or jpg -- defaults to jpg if not provided.
# $3 optional--include this parameter (it can be anything) to make white transparent; otherwise white will default to opaque.

# WARNING: Many svgs, despite being technically infinitely scaleable, are upscaled by graphicsmagick using poor raster techniquies. You must manually upscale such svgs in svg editing software before rendering them at a resolution "larger" than they had originally been defined.

# DEV NOTE: template command: gm -size 850 test.svg result.tif
# NOTE that for the -size parameter, it scales the images so that the longest side is that many pixels.


# CODE
img_size=$1
img_format=$2

# If no image size parameter, set default image size of 4280.
if [ -z ${1+x} ]; then img_size=4280; echo SET img_size to DEFAULT 4280; else img_size=$1; echo SET img_size to $1; fi
# If no image format parameter, set default image format of jpg.
if [ -z ${2+x} ]; then img_format=jpg; echo SET img_format to DEFAULT jpg; else img_format=$2; echo SET img_format to $2; fi
# If no third parameter, make background transparent.
if [ -z ${3+x} ]; then param3="-background none"; echo SET parameter DEFAULT \"-background none\"; else img_format=$2; echo DID NOT SET any background control parameter; fi
# NOTE: you may tweak that line to say "-background gray" to replace a transparent background with gray, if you leave off the third parameter when calling this script. Or instead of gray, any hex color code e.g. #555555. Otherwise, revert it to the default "-background none" to leave transparency in the resultant image. You may uncomment any of the following (and comment out the previous line) for various options:
# if [ -z ${3+x} ]; then param3="-background white"; fi
# if [ -z ${3+x} ]; then param3="-background black"; fi
# if [ -z ${3+x} ]; then param3="-background #584560"; fi		# Darkish plum?
if [ -z ${3+x} ]; then param3="-background #39383b"; fi		# Medium-dark purplish-gray
# potentially good black line color change options: #2fd5fe #bde4e4

find . -iname \*.svg > all_svgs.txt
while read element
do
		svgFilenameNoExtension=`echo $element | sed 's/\(.*\)\.svg/\1/g'`
	if [ -a $svgFilenameNoExtension.$img_format ]
	then
		echo render candidate is $svgFilenameNoExtension.$img_format
		echo target already exists\; will not render.
		echo . . .
	else
		# Have I already tried e.g. -size 1000x1000 as described here? :  
		echo rendering $element . . .
				# DEPRECATED, as it causes the problem described at this question: https://stackoverflow.com/a/27919097/1397555 -- for which the active solution is also given:
				# gm convert $param3 -scale $1 $element $svgFilenameNoExtension.$img_format
		echo COMMAND\: convert -size $1 $param3 $element $svgFilenameNoExtension.$img_format
		gm convert -size $1 $param3 $element $svgFilenameNoExtension.$img_format
	fi
done < all_svgs.txt

rm all_svgs.txt