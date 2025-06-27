# DESCRIPTION
# Takes all images of type $2 in the current directory and overlays them with any transparency in them (e.g. if PNG or TGA type) over a background color which is randomly selected from palette file $1. Rendered image is saved to a file named after the source image and indicating the background color in the file name. Optionally does this for all files of type $1 in all subfolders also. Accomplished by repeated calls to the script img2imgAlphaOverBGcolor.sh. SEE ALSO imgs2imgsAlphaOverBGcolor.sh, which applies one color to all images. This applies any one randomly chosen color from a palette to all images.


# DEPENDENCIES
# Graphicsmagick, img2imgAlphaOverBGcolor.sh.

# USAGE
# Run with these parameters:
# - $1 REQUIRED. Palette file name pick a random color from, to overlay on; colors in the file must be sRGB hex color codes, for example ffffff for white or ff0596 for a magenta-red (rose).
# - $2 OPTIONAL. File types to operate on. Defaults to "png" if omitted.
# - $3 OPTIONAL. Anything, for example the word HEIRNSH, which will cause the script to operate on all files of type $1 recursively (in subfolders). If omitted, default off (will only operate on files in the current directory).


# For example, to override the default ffffff background color with rose ($ff0596), and operate on all files of the default type (png), run:
#    imgs2imgsAlphaOverBGcolor.sh ff0596
# To override the default png with tga, run:
#    imgs2imgsAlphaOverBGcolor.sh ff0596 tga
# (If you use $2, for the file type, you must use $1, for the color.)
# To do the same but with png files (not tga) and do so in all png files in the current folder and all subfolders, run:
#    imgs2imgsAlphaOverBGcolor.sh ff0596 png HERNSHBLAUR
# (Likewise if you use $3, to operate in all subdirectories, you must use $2, for the file type.)
# WARNINGS
# - No verification of parameters beyond $1 is done; ensure you have correct additional parameters if you use them.
# - If you run this script in a folder with already converted output files of the same format as the input, you'll get pointless redundant convert attempts resulting only in duplicate images (as the background was already filled and can't be again).


# CODE
if [ "$1" ]; then paletteToUse=$1; else echo "No parameter \$1 (palette file name to load random colors from, with sRGB hex color codes in it e.g. format e.g. ffffff. Exit."; exit 1; fi

if [ "$2" ]; then searchFileType=$2; else echo "No parameter \$2 (file type to work on e.g. png) passed to script; defaulting to png."; searchFileType="png"; fi

fullPathToPalette=$(findPalette.sh $paletteToUse)
# test if that is empty (if search for the palette file failed) and exit / fail if so:
if [ "$fullPathToPalette" == "" ]; then echo "ERROR: intended source palette file $paletteToUse not found. Exit"; exit 2; fi
echo "path to palette obtained: $fullPathToPalette -- using that."

# get array of colors from file by extracting all matches of a pattern of six hex digits preceded by a #:
colorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $fullPathToPalette | tr -d '#') )		# tr command removes pound symbol, and surrounding () makes it an actual array
# Get number of colors (from array):
numColorsInArray=${#colorsArray[@]}
echo source palette $fullPathToPalette has $numColorsInArray colors.

# if no parameter is passed for $3, default to nothing (which searches all subdirectories):
if [ ! "$3" ]; then subDirSearchParam="-maxdepth 1"; fi

filesList=( $(find . $subDirSearchParam -type f -iname "*.$searchFileType" -printf "%P\n" ) )

# iterates over files list, creating a new image for each, layering it with transparency over the background color to a new file:
nums=($(echo {0.."$numColorsInArray"}))
for file in ${filesList[@]}
do
	# fast random integer in range re https://www.baeldung.com/linux/bash-draw-random-ints
	rndBackgroundColorIDX=$(($RANDOM%($numColorsInArray+1)))
	rndBackgroundColor=${colorsArray[$rndBackgroundColorIDX]}
	echo "calling script with positional parameters:"
	echo "img2imgAlphaOverBGcolor.sh $rndBackgroundColor $file . ."
	img2imgAlphaOverBGcolor.sh $rndBackgroundColor $file 
done