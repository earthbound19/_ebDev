# DESCRIPTION
# Takes all images of type $1 in the current directory and overlays them with any transparency in them (e.g. if PNG or TGA type) over background color $2, saving to a file named after the source image and indicating the background color in the file name. Destination file will be the same as the source file. Optionally does this for all files of type $1 in all subfolders also. Accomplished by repeated calls to the script img2imgAlphaOverBGcolor.sh.

# DEPENDENCIES
# Graphicsmagick, img2imgAlphaOverBGcolor.sh.

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. Background color to overly on in sRGB hex color code, for example ffffff for white or ff0596 for a magenta-red (rose). If omitted, a default is used (at this writing white ffffff).
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
if [ "$1" ]; then backgroundColor=$1; else echo "No parameter \$1 (background color to layer source images with transparency over, in sRGB hex color code format e.g. ffffff; defaulting to ffffff."; backgroundColor="ffffff"; fi

if [ "$2" ]; then searchFileType=$2; else echo "No parameter \$2 (file type to work on e.g. png) passed to script; defaulting to png."; searchFileType="png"; fi

# echo backgroundColor is $backgroundColor
# echo searchFileType is $searchFileType

# if no parameter is passed for $3, default to nothing (which searches all subdirectories):
if [ ! "$3" ]; then subDirSearchParam="-maxdepth 1"; fi

filesList=( $(find . $subDirSearchParam -type f -iname "*.$searchFileType" -printf "%P\n" ) )

# iterates over files list, creating a new image for each layering it with transparency over the background color to a new file:
for file in ${filesList[@]}
do
	echo "calling script with positional parameters:"
	echo "img2imgAlphaOverBGcolor.sh $backgroundColor $file . ."
	img2imgAlphaOverBGcolor.sh $backgroundColor $file 
done


