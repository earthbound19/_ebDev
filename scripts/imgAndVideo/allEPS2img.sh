# DESCRIPTION
# Creates .jpg (by default) files from all .eps files in a directory tree, via imagemagick. Creates 1280px jpg images by default. Also, does not overwrite files if the render target name exists (you must first delete the existing target file, then run this script to re-create it).


# USAGE
# Invoke this script with these parameters:
# $1 the number of pixels you wish the longest side of the image converted from the .eps file(s) to be.
# $2 the target file format e.g. png or jpg -- defaults to png if not provided.
# NOTES
# If the result image has raster upscale (jaggy) artifacts, hack the -density parameter in this script with a higher number until that isn't a problem.

# DEPENDENCIES
# graphicsmagick and ghostscript both installed and in your PATH.

# DO TO
# Calculate needed density for target image size, and calculate automatically. I think 72dpi should be good enough, or density = 72 * (longest image dimension in inches)?


# CODE
# If no image size parameter, set default image size of 1280.
if [ "$1" ]
then
	img_size=$1
	echo SET img_size to $img_size.
else
	img_size=1280
	echo SET img_size to DEFAULT $img_size
fi
# If no image format parameter, set default image format of jpg.
if [ "$2" ]
then
	img_format=$2
	echo SET img_format to $img_format
else
	img_format=png
	echo SET img_format to DEFAULT $img_format
fi

array=(`gfind . -maxdepth 1 -type f -iname \*.eps -printf '%f\n'`)

for element in ${array[@]}
do
	echo element is $element
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
done