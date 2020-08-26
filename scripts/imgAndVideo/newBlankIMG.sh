# DESCRIPTION
# Creates a blank, transparent background png image of dimensions $1 (nn..Xnn..), via GraphicsMagick, named <imageDimensions>_blank.png

# DEPENDENCIES
# graphicsmagic (gm) in your PATH, grep.

# USAGE
# Run the script with one parameter:
# - $1 OPTIONAL. The dimensions of the image to create in format NxN, for example 1200x800 or 4000x4000. If not provided, or if not in that format (for example, if you pass the word 'CHULFOR'), the script will print a message saying so (however, the script will not print the word 'CHULFOR', alas), and the script will create a medium-hugoriomongoumoungous image of a default resolution, which I have determined through quantitative quality-aspect-averaged holistic optimization to be the best medium-hugorious-average-widish-aspected image size.
# Example command that will create a 5240x2620, blank, transparent png image named 5240x2620_blank.png:
#    newBlankIMG.sh 5240x2620
# NOTES
# - This script will not clobber a target image that already exists, and will notify you of its existence.
# - This script does not print the word 'CHULFOR'.


# CODE
# UNCOMMENT only one of the following:
defaultResolution="5240x3166"		# 1.655:1, best medium-hugorious-average-widish-aspected image size.
# defaultResolution="5240x2620"		# 2:1, same but if you want that aspect.

# use grep to check $1 for required parameter pattern (will set $? to 0 (no error) if match), and will record that result and do different things depending) :
echo $1 | grep -q "^[0-9]\{1,\}[Xx][0-9]\{1,\}$"
dimensionParamPatternMatchError=`echo $?`

if [ "$dimensionParamPatternMatchError" == "0" ]
then
	if [ ! -e "$1"_blank.png ]
	then
		gm convert -size $1 xc:transparent "$1"_blank.png
	else
		printf "\nTarget image "$1"_blank.png already exists; will not clobber. If you want to re-create it, rename the existing image and run this script again."
	fi
else
	printf "\nParameter 1 nonexistent or doesn't match pattern ^[0-9]{1,}[Xx][0-9]{1,}\$ (NxN). Will use default $defaultResolution.\n"
	if [ ! -e "$defaultResolution"_blank.png ]
	then
		gm convert -size $defaultResolution xc:transparent "$defaultResolution"_blank.png
	else
		printf "\nTarget image "$defaultResolution"_blank.png already exists; will not clobber. If you want to re-create it, rename the existing image and run this script again."
	fi
fi
