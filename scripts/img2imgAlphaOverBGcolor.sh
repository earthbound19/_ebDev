# DESCRIPTION
# Makes an image with background color $1 behind source image file (with transparency) $2. e.g. if the source file is PNG or TGA type. Destination file type will be the same as the source file type.

# DEPENDENCIES
# Graphicsmagick

# USAGE
# Run with these parameters:
# - $1 REQUIRED. Background color to overly on in sRGB hex color code, for example ffffff for white or ff0596 for a magenta-red (rose).
# - $2 REQUIRED. Source file name to operate on and set over background color $1.
# For example, to creat a background of rose ($ff0596) under the background (transparency) of the source file 03__2025-03-03zb.png, run:
#    img2imgAlphaOverBGcolor.sh ff0596 03__2025-03-03zb.png
# NOTE
# This was only tested with png images but could potentially work with all image types that support alpha and which graphicsmagick can work with.


# CODE
if [ "$1" ]; then backgroundColor=$1; else echo "No parameter \$1 (background color to layer source images with transparency over, in sRGB hex color code format e.g. ffffff; defaulting to ffffff."; backgroundColor="ffffff"; fi

if [ "$2" ]; then sourceFile=$2; else echo "No parameter \$2 (source file name to work on e.g. image.png) passed to script; defaulting to png."; searchFileType="png"; fi

targetFileName="${sourceFile%.*}_bg_$backgroundColor.${sourceFile##*.}"
if [ ! -f $targetFileName ]
then
	gm convert "$sourceFile" -background "#$backgroundColor" -flatten $targetFileName
else
	echo ""
	echo "target file name $targetFileName already exists; skipping. To recreate it, delete that file and run this script again."
fi


