# DESCRIPTION
# Creates a uniform color image (color swatch) of dimensions $1 (nn..Xnn..), via GraphicsMagick, named <imageDimensions>_swatch.png. Capable of creating fully transparent png images also, see USAGE.

# DEPENDENCIES
# imagemagick in your PATH, grep.

# USAGE
# Run the script with one parameter:
# - $1 OPTIONAL. The dimensions of the image to create in format NxN, for example 1200x800 or 4000x4000. If not provided, or if provided as the word DEFAULT, a default image size is used.
# - $2 OPTIONAL. sRGB hex color code (without any # etc. prefix) to fill blank image with. Must be hex digits in format rrggbbaa, where rr, gg and bb are digit placeholders for the colors red, green and blue, which must be expressed in sRGB hex digits (0-9 and a-f), and aa is a placeholder for hex digits indicating alpha, or transparency. For example, a fully opaque black image would be 000000ff. If not provided, image will be color 00000000 (black but fully transparent -- a blank transparent image (png format). To specify fully opaque, use ff for alpha. For example, a fully opaque black image would be 000000ff. To use this ($2) and not specify the size for $1 (use the default), pass the word DEFAULT for $1.
# Example command that will create a 5240x2620 transparent png image named 5240x2620_swatch.png:
#    uniformColorImage.sh 5240x2620
# Example command that will create an opaque magenta image:
#    uniformColorImage.sh 5240x2620 f800fcff
# NOTES
# - This script will not clobber a target image that already exists, and will notify you of its existence.
# - This script does not print the word 'CHULFOR'.


# CODE
# GLOBAL DEFAULTS:
imageResolution="5240x3166"		# 1.655:1, best medium-hugorious-average-widish-aspected image size. If your goal is that but you want a 2:1 aspect, use 5240x2620
imageColor=f800fc00		# This is magenta but totally transparent, because if I do black, photoshop incorrectly interprets it as opaque black but IrfanView correctly interprets it as transparent. I don't know if that's a bug with Photoshop, or ImageMagick, or both.

# Check $1 for required parameter pattern (will set $? to 0 (no error) if match), and error out if provided and wrong.
if [ "$1" ] && [ "$1" != "DEFAULT" ]
then
	echo $1 | grep -q "^[0-9]\{1,\}[Xx][0-9]\{1,\}$"
	dimensionParamPatternMatchError=$(echo $?)
	if [ "$dimensionParamPatternMatchError" != "0" ]
	then
		echo "ERROR: provided dimensions parameter \$1 ($1) doesn't meet format requirement nXn (numbers (pixels across), X or x, and numbers (pixels down), without any space in between). Exit."
		exit 1
	else
		imageResolution=$1
	fi
fi

# Override image color with parameter $2 if provided, warning if no hex color pattern match:
if [ "$2" ]
then
	echo $2 | grep -i -q "^[0-9a-z]\{8\}$"
	sRGBcolorPatternMatchError=$(echo $?)
	if [ $sRGBcolorPatternMatchError != 0 ]
	then
		echo "ERROR: provided sRGB hex color pattern \$2 ($2) doesn't match requirement. Must be hex digits in format rrggbbaa, where rr, gg and bb are digit placeholders for the colors red, green and blue, which must be expressed in sRGB hex digits (0-9 and a-f), and aa is a placeholder for hex digits indicating alpha, or transparency. For example, a fully opaque black image would be 000000ff."
		exit 2
	else
		imageColor="$2"
	fi
fi

targetFileName="$imageResolution"_sRGB_"$imageColor".png

if [ ! -e $targetFileName ]
then
	echo "runnning command:"
	echo "magick convert -size $imageResolution xc:#$imageColor $targetFileName"
	magick convert -size $imageResolution xc:#$imageColor $targetFileName
	echo "Created target image $targetFileName."
else
	echo "Target image $targetFileName already exists; will not clobber. If you want to re-create it, rename or delete the existing image and run this script again."
fi