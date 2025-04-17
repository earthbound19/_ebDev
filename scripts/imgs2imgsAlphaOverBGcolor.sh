# DESCRIPTION
# Takes all images of type $1 in the current directory and overlays them with any transparency in them (e.g. if PNG or TGA type) over background color $2, saving to a file named after the source image and indicating the background color in the file name. Destination file will be the same as the source file. Optionally does this for all files of type $1 in all subfolders also.

# DEPENDENCIES
# Graphicsmagick

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. Background color to overly on in sRGB hex color code, for example ffffff for white or ff0596 for a magenta-red (rose).
# - $2 OPTIONAL. File types to operate on. Defaults to "png" if omitted.
# - $3 OPTIONAL. Anything, for example the word HEIRNSH, which will cause the script to operate on all files of type $1 recursively (in subfolders). If omitted, default off (will only operate on files in the current directory).
# For example, to override the default ffffff background color with rose ($ff0596), run:
#    imgs2imgsAlphaOverBGcolor.sh ff0596
# To override the default png with tga and keep all other defaults, run:
#    imgs2imgsAlphaOverBGcolor.sh ff0596 tga
# (If you use $2, for the file type, you must use $1, for the color.)
# To do the same but with png files (not tga) and do so in all png files in the current folder and all subfolders, run:
#    imgs2imgsAlphaOverBGcolor.sh ff0596 png HERNSHBLAUR
# (Likewise if you use $3, to operate in all subdirectories, you must use $2, for the file type.)
# NOTE
# This was only tested with png images but could potentially work with all image types that support alpha and which graphicsmagick can work with.


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
	echo overlaying source file $file with transparency on background color $backgroundColor to target file name "${file%.*}_bg_$backgroundColor.${file##*.}" . .
	gm convert "$file" -background "#$backgroundColor" -flatten "${file%.*}_bg_$backgroundColor.${file##*.}"
done


