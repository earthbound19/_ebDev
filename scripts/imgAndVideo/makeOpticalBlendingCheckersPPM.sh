# DESCRIPTION
# Makes a (non-standard?) ppm image which is checkers of color $1 and $2, at dimensions $3 x 2 by $4 x 2. The checkers are 1 pixel high and wide. Create a large image of this and squint to optically blur it, and you've got optical blending of two colors. Useful to figure out how any two colors perceptually blend (for color matching in gradients or for other creative/artistic purposes). Target file is named after source colors and dimensions. Will clobber existing files.

# KNOWN ISSUES
# - sRGB hex values for pixel sources in ppm may not be standard, and may not be supported by various ppm viewers and converters.

# WARNING
# This script clobbers (overwrites) existing target files without warning.

# USAGE
# Run with these parameters:
# - $1 source color one in sRGB hex format, with or without preceding hash sign, and surrounded with single or double quote marks, for example '#000000'.
# - $2 source color two in sRGB hex format, for example '#ffffff'.
# - $3 Number of times to repeat the color pair per row. In other words, the number of pixels across, but it will be multiplied by 2.
# - $4 number of rows in pixel image (not multiplied by 2, like the previous parameter).
# Example command that will create a checker ppm of sRGB hex color #ff9710 (an orange) and #feff06 (a yellow) 2048 pixels across and 2048 pixels down, because it the third parameter is the number of times to repeat the color pair (so $3 x 2):
#    makeOpticalBlendingCheckersPPM.sh '#ff9710' '#feff06' 1024 2048
# NOTES
# See `img2imgNN.sh` to convert the resulting ppm to png.

# CODE

# =============
if [ ! "$1" ]; then printf "\nNo parameter \$1 (color one, in sRGB hex format) passed to script. Exit."; exit 1; else color1=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (color two, in sRGB hex format) passed to script. Exit."; exit 2; else color2=$2; fi
if [ ! "$3" ]; then printf "\nNo parameter \$3 (number of times to repeat colors 1 and 2 per row) passed to script. Exit."; exit 3; else xPixDiv2=$3; fi
if [ ! "$4" ]; then printf "\nNo parameter \$4 (number of rows) passed to script. Exit."; exit 4; else yPix=$4; fi

xPix=$((xPixDiv2 * 2))
# delete any/all hash characters from source colors:

color1="${color1//#/}"
color2="${color2//#/}"
# make our target file name from that hex without the hash/pound sign:
targetFileName="$color1"_and_"$color2"_1pixChecker_"$xPix"x"$yPix".ppm
# convert the hex to sRGB integer values:
color1=$(printf "%d %d %d\n" 0x${color1:0:2} 0x${color1:2:2} 0x${color1:4:2})
color2=$(printf "%d %d %d\n" 0x${color2:0:2} 0x${color2:2:2} 0x${color2:4:2})
echo that is $color1 and $color2

echo Building P3 PPM format header . . .
echo "P3" > PPMheader.txt
echo "# P3 means text file, 8 2 is cols x rows, 255 is max color, triplets of RGB vals per row." >> PPMheader.txt
echo $xPix $yPix >> PPMheader.txt
echo "255" >> PPMheader.txt

row1pair="$color1 $color2 "
row2pair="$color2 $color1 "
# build row one component:
row1=""; for ((i=0; i < $xPixDiv2; i++)); do row1="$row1 $row1pair"; done
# build row two component:
row2=""; for ((i=0; i < $xPixDiv2; i++)); do row2="$row2 $row2pair"; done

echo Building ppm body . . .
for ((i=0; i < $yPix; i++))
do
	if [ $(($i % 2)) == 0 ]
	then
		echo $row1 >> ppmBody.txt
	else
		echo $row2 >> ppmBody.txt
	fi
done

cat PPMheader.txt ppmBody.txt > $targetFileName
rm PPMheader.txt ppmBody.txt

echo DONE. Result is in $targetFileName