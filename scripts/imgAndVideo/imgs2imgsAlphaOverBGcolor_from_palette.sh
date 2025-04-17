# DESCRIPTION
# Calls imgs2imgsAlphaOverBGcolor.sh repeatedly, supplying a (next) color from palette file $1 for every call. Obtains the palette file path via findPalette.sh. Useful to preview all colors from a palette behind (adapted copies of) an image.

# DEPENDENCIES
# img2imgAlphaOverBGcolor.sh, findPalette.sh, and their dependencies.

# USAGE
# Run with these parameters:
# - $1 REQUIRED. A palette file name such as will be located by the script findPalette.sh.
# - $2 OPTIONAL. File types to operate on. Defaults to "png" if omitted.
# - $3 OPTIONAL. Anything, for example the word HEIRNSH, which will cause the script to operate on all files of type $2 recursively (in subfolders). If omitted, default off (will only operate on files in the current directory).
# SEE USAGE in imgs2imgsAlphaOverBGcolor.sh.
# For example, to create a separate image for every color from the palette file EB_Favorites_v2_Alt_2.hexplt for every png in this directory (at this writing png being the default image type used by imgs2imgsAlphaOverBGcolor.sh), run:
#    imgs2imgsAlphaOverBGcolor_from_palette.sh EB_Favorites_v2_Alt_2.hexplt
# To override the default png in the script this calls with tga file type, run:
#    imgs2imgsAlphaOverBGcolor_from_palette.sh EB_Favorites_v2_Alt_2.hexplt tga
# To moreoever operate on file type $2 in every subfolder, run:
#    imgs2imgsAlphaOverBGcolor_from_palette.sh EB_Favorites_v2_Alt_2.hexplt tga HERNSHBLAUR
# NOTES
# Parameter $1 for this script is a palette file name, and for every color in that palette, it passes that color as $1 in a call (one call for every color, respectively) to img2imgAlphaOverBGcolor.sh. It also passes on $2 and $3 for each call.
# WARNINGS
# - No verification of parameters beyond $1 is done; ensure you have correct additional parameters if you use them.
# - If you run this script in a folder with already converted output files of the same format as the input, you'll get pointless redundant convert attempts resulting only in duplicate images (as the background was already filled and can't be again).


# CODE
if [ "$1" ]; then paletteToUse=$1; else printf "\nNo parameter \$1 (palette file name to use, via findPalette.sh) passed to script. Exit."; exit 1; fi

if [ "$2" ]; then searchFileType=$2; else echo "No parameter \$2 (file type to work on e.g. png) passed to script; defaulting to png."; searchFileType="png"; fi

fullPathToPalette=$(findPalette.sh $paletteToUse)
# test if that is empty (if search for the palette file failed) and exit / fail if so:
if [ "$fullPathToPalette" == "" ]; then echo "ERROR: intended source palette file $paletteToUse not found. Exit"; exit 2; fi
echo "path to palette obtained: $fullPathToPalette -- using that."

# get array of colors from file by extracting all matches of a pattern of six hex digits preceded by a #:
colorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $fullPathToPalette | tr -d '#') )		# tr command removes pound symbol, and surrounding () makes it an actual array

# if no parameter is passed for $3, default to nothing (which searches all subdirectories):
if [ ! "$3" ]; then subDirSearchParam="-maxdepth 1"; fi

filesList=( $(find . $subDirSearchParam -type f -iname "*.$searchFileType" -printf "%P\n" ) )

# iterates over files list, creating a new image for each layering it with transparency over the background color to a new file:
for file in ${filesList[@]}
do
	for backgroundColor in ${colorsArray[@]}
	do
		echo "calling script with positional parameters:"
		echo "img2imgAlphaOverBGcolor.sh $backgroundColor $file . ."
		img2imgAlphaOverBGcolor.sh $backgroundColor $file 
	done
done

