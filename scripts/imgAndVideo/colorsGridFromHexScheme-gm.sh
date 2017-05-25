# DEPENDENCIES
# GraphicsMagick e.g. for:
# $ gm convert

# PARAMETERS
# $1 hex color palette flat file list (input file).
# $2 edge length of each square tile to be composited into final image.
# $3 number of tiles accross of tiles-assembled image (columns)
# $4 number of tiles down of tiles-assembled image (rows)
# $5 Any value--if set, it will randomly shuffle the hex color files before compositing them to one image

# NOTES
# This produces individual color tiles in a subfolder and runs slower. colorsGridFromHexScheme.sh (note no -gm.sh in that file name) runs much faster but doesn't produce the subfolder of color tiles.

# TO DO: rename this for clarity that it is intended to render limited number of color palette images; also update any scripts that use it.


# NOTE
# doc. wut following block is:
if [ -e ~/palettesRootDir.txt ]
then
	palettesRootDir=$(< ~/palettesRootDir.txt)
			echo palettesRootDir.txt found\;
			echo searching in path $palettesRootDir found therien for file $1 . . .
	hexColorSrcFullPath=`find "$palettesRootDir" -iname *$1`
	echo -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
	if [ "$hexColorSrcFullPath" == "" ]
		then
			echo No file of name $1 found in path \"$palettesRootDir\" \! ABORTING script.
			exit
		# else
			# echo File name $1 found in path \"$palettesRootDir\" \! PROCEEDING. IN ALL CAPS.
	fi
else
	echo !--------------------------------------------------------!
	echo file ~/palettesRootDir.txt \(in your root user path\) not found. This file should exist and have one line, being the path of your palette text files e.g.:
	echo
	echo /cygdrive/c/_devtools/scripts/imgAndVideo/palettes
	echo
	echo ABORTING script.
	echo !--------------------------------------------------------!
	exit
fi

# IF RENDER TARGET already exists, abort script. Otherwise continue.
if [ -f ./$1.png ]
then
	echo Render target $1.png already exists\; SKIPPING render.
	exit
else
	echo Render target $1.png does not exist\; WILL RENDER.
fi

if [ -d ./$1.colors ]
then
# TO DO
# Add a yes/no delete prompt here.
	rm -rf $1.colors
fi

if [ ! -d ./_hexPaletteIMGgenTMP_2bbVyVxD ]
then
	mkdir ./_hexPaletteIMGgenTMP_2bbVyVxD
else
	rm -rf _hexPaletteIMGgenTMP_2bbVyVxD
	mkdir ./_hexPaletteIMGgenTMP_2bbVyVxD
fi

# this here complexity solves a problem of not reading a last line if it doesn't end with a new line; dunno how but magic says ok re http://stackoverflow.com/a/31398490 ;
# make directory of color tiles from palette:
while IFS= read -r line || [ -n "$line" ]
do
	hexNoHash=`echo $line | sed 's/\#//g'`
	gm convert -size $2x$2 xc:\#$hexNoHash _hexPaletteIMGgenTMP_2bbVyVxD/$hexNoHash.png
done < $hexColorSrcFullPath

# make the actual montage image.
# e.g. gm montage colors/5A6D40.png colors/757F26.png colors/C68C15.png colors/8F322F.png colors/954B29.png out.png

# TO DO: implement e.g. -tile 8x40 flag depending on desired aspect, etc. (will determine params $3 and $4 depending on desired aspect?)
tileParam="-tile ""$3"x"$4"

  # make temporary script to create a grid montage of the colors:
echo gm montage $tileParam -background gray -geometry "$2"x"$2"+0+0 \\ > mkGridHead.txt
  # convert hex color scheme text list file to parameter list for ~magick:
sed 's/.*#\(.*\)$/_hexPaletteIMGgenTMP_2bbVyVxD\/\1.png \\/' $hexColorSrcFullPath > ./mkGridSRCimgs.txt
# IF PARAMATER $5 was passed, randomly sort that list:
	if [ ! -z ${5+x} ];	then shuf ./mkGridSRCimgs.txt > ./tmp_3A7u2ZymRgdss4rsXuxs.txt; rm ./mkGridSRCimgs.txt; mv ./tmp_3A7u2ZymRgdss4rsXuxs.txt ./mkGridSRCimgs.txt; fi
echo $1.png > mkGridTail.txt
cat mkGridHead.txt mkGridSRCimgs.txt mkGridTail.txt > mkColorPaletteGrid.sh

rm mkGridHead.txt mkGridSRCimgs.txt mkGridTail.txt
chmod 777 ./mkColorPaletteGrid.sh

./mkColorPaletteGrid.sh
# mv ./mkColorPaletteGrid.sh ./$1-mkColorPaletteGrid.sh.txt
	# OR, to delete that if you've no permanent need of it:
	rm ./mkColorPaletteGrid.sh
# mv _hexPaletteIMGgenTMP_2bbVyVxD $1.colors
	# OR, to delete that dir if it annoys you ;)  :
	rm ./_hexPaletteIMGgenTMP_2bbVyVxD/*
	rmdir ./_hexPaletteIMGgenTMP_2bbVyVxD

echo DONE--created color palette image is $1, and the .sh script that generated it has been renamed to $1-mkColorPaletteGrid.sh.txt. You will also find color swatch images from the palette in the folder $1.colors.
