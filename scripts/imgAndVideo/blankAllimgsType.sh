# DESCRIPTION
# Via GraphicsMagic, overwrites every image of format $1 in the current directory with a new image which is the same size (dimensions), of flat color $2. See USAGE. As this is a permanently destructive (or transformative) action, the script requires the user to type two different given confirmation words to do this.

# USAGE
# Run with these parameters:
# - $1 file format without dot in the extension (for example png) to scan for in the current directory.
# - $2 color to make the overwritten image. May be any color code that GraphicsMagick accepts, for example the word 'cyan' or the hex color code '#f800fc'. Default #f800fc (medium max chroma magenta) if not specified. For hex color codes it only seems to work if you surround the parameter with double or single quote marks.
# Example that will overwrite all png images in the current directory with blank images of a default color:
#    blankAllimgsType.sh png
# Example that will overwrite all png images in the current directory with what red as defined by GraphicsMagick:
#    blankAllimgsType.sh png red


# CODE
#set default color; will be overwritten if user passes $2:
color=#f800fc
if [ ! "$1" ]; then printf "\nNo parameter \$1 (image type, or in other words extension, to use) passed to script. Exit."; exit 1; else imgs_extension=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (color for image overwrite) passed;\n using default $color.\n"; else color=$2; fi
current_dir=$(pwd)

echo ""
read -p "WARNING: This script overwrites all files of type $imgs_extension with blank images of color $color, in the directory $current_dir. This is a permenent, irriversible action. DO NOT DO THIS with files you don't have backups of and wish to potentially keep as they are. If this is not what you want to do, press ENTER or RETURN, or CTRL+C or CTRL+Z. If this _is_ what you want to\n do, type PLIBPLUP and then press ENTER or RETURN: " CHORFL

if ! [ "$CHORFL" == "PLIBPLUP" ]
then
	echo ""
	echo Typing mismatch\; exit.
	exit
else
	echo continuing . .
fi

echo ""
read -p "ARE YOU DOUBLY CERTAIN that you want permenatly alter all files of type $imgs_extension in the folder $current_dir with blank images of color $color? If this is not what you want to do, press ENTER or RETURN, or CTRL+C or CTRL+Z. If this _is_ what you want to\n do, type PLIBPLUPL and then press ENTER or RETURN: " CHORFLL

if ! [ "$CHORFLL" == "PLIBPLUPL" ]
then
	echo ""
	echo Typing mismatch\; exit.
	exit
else
	echo continuing . .
fi

array=( $(find . -maxdepth 1 -name "*.$imgs_extension" -printf "%f\n") )
for img in ${array[@]}
do
	# works: gm identify -format "%h %w" image.png
	img_w=$(gm identify -format "%w" $img)
	img_h=$(gm identify -format "%h" $img)
	# formatting parameter to work around quotes in parameter problem:
	# sizeArg="$img_w"x"$img_h"
	echo OVERWRITING image file $img . . .
	gm convert -size "$img_w"x"$img_h" xc:$color $img
done
