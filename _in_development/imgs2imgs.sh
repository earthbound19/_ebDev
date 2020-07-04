echo Script is in development.
exit

# DESCRIPTION: converts all images of one type in a directory tree to another.

# WARNING: for svgs, use SVG2img.sh or allsvg2img.sh, not this. This will do very crummy upscaling of vector images, _post-resterization_.
# USAGE: invoke this script with these parameters:
# $1 the source file format e.g. bmp or png
# $2 the target file format e.g. tif or jpg


# CODE
# DEV NOTE: template command: gm -size 850 test.svg result.tif
# NOTE that for the -size parameter, it scales the images so that the longest side is that many pixels.

img_format_1=$1
img_format_2=$2

# OPTIONAL e.g. resize command:
# additionalParams="-scale 1920 "

array=(`gfind . -maxdepth 1 -type f -iname \*.$img_format_1 -printf '%f\n'`)
for element in ${array[@]}
do
	fileNameNoExtension=`basename $element .$img_format_1`
			# REFERENCE for script hacking for custom runs: the [-scale n] switch will resize the image maintaining aspect with the longest side at n pixels.
	# what parameter was I after here? : -size $1x$1
	command="gm convert $additionalParams $element $fileNameNoExtension.$img_format_2"
	echo running command\: $command
	echo . . .
	$command
done