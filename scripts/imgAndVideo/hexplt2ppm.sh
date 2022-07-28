# DESCRIPTION
# Makes a teensy ppm palette image (one pixel per color) from a hex palette .hexplt source file. Result is usable as a basis for a scaled up palette image; see NOTES

# USAGE
# Run this script with the following parameters:
# - $1 hex color palette flat file list (input file).
# - $2 OPTIONAL. Number of columns. If not provided, automatically calculated as approximate square root of total number of colors in source .hexplt file.
# - $3 OPTIONAL. Number of rows. If omitted, the script does math automatically to have enough rows for all colors.
# For example, to create a tiny ppm palette 5 tiles across and 40 tiles down from colors in the list `RAHfavoriteColorsHex.hexplt`, run:
#    hexplt2ppm.sh RAHfavoriteColorsHex.hexplt 5 40
# To create a tiny ppm image with columns and rows calculated by the script from that same palette, run:
#    hexplt2ppm.sh RAHfavoriteColorsHex.hexplt
# NOTES
# To use another script to upscale the image to a palette by nearest neighbor (hard edge) method to a png image, run e.g.:
#    img2imgNN.sh source.ppm png 640 480



# CODE
# TO DO
# - Get number of colors via grep
# - Possibly make an array of colors via grep before that, and use the array for color value write operations)


# =============
# BEGIN SETUP GLOBAL VARIABLES
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source hexplt format file) passed to script. Exit."; exit 1; else paletteFile=$1; fi

renderTargetFile=${1%.*}.ppm

# Search current path for $1; if it exists set hexColorSrcFullPath to just $1 (we don't need the full path). If it doesn't exist in the local path, search the path in palettesRootDir.txt and make decisions based on that result:
if [ -e ./$1 ]
then
	hexColorSrcFullPath=$1
else	# Search for specified palette file in palettesRootDir (if that dir exists; if it doesn't, exit with an error) :
	if [ -e ~/palettesRootDir.txt ]
	then
		palettesRootDir=$(< ~/palettesRootDir.txt)
				echo palettesRootDir.txt found\;
				echo searching in path $palettesRootDir --
				echo for file $paletteFile . . .
						# FAIL:
						# hexColorSrcFullPath=$(find "$palettesRootDir" -iname *$paletteFile)
		hexColorSrcFullPath=$(find $palettesRootDir -iname "$paletteFile")
		echo -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
		if [ "$hexColorSrcFullPath" == "" ]
			then
				echo No file of name $paletteFile found in the path this script was run from OR in path \"$palettesRootDir\" \! ABORTING script.
				exit
			else
				echo File name $paletteFile found in the path this script was run from OR in path \"$palettesRootDir\" \! PROCEEDING. IN ALL CAPS.
		fi
	else
		echo !--------------------------------------------------------!
		echo file ~/palettesRootDir.txt \(in your root user path\) not found. This file should exist and have one line, being the path of your palette text files e.g.:
		echo
		echo /cygdrive/c/_ebdev/scripts/imgAndVideo/palettes
		echo
		echo ABORTING script.
		echo !--------------------------------------------------------!
		exit
	fi
fi

# get array of colors from file by extracting all matches of a pattern of six hex digits preceded by a #:
colorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $hexColorSrcFullPath | tr -d '#') )		# tr command removes pound symbol, and surrounding () makes it an actual array
# Get number of colors (from array):
numColors=${#colorsArray[@]}

# WHETHER NUM tiles across (and down) is specified; if so, use as specified, if not so, do some math to figure for a 2:1 aspect;
# $2 is across. If $2 is not specified, do some math. Otherwise use $2:
if [ ! "$2" ]
then
	sqrtOfColorCount=$(echo "sqrt ($numColors)" | bc)
	# echo sqrtOfColorCount is $sqrtOfColorCount \(first check\)
	tilesAcross=$(( $sqrtOfColorCount * 2 ))
else
	tilesAcross=$2
fi
echo tilesAcross is $tilesAcross\.

# $3 is down. If $3 is not specified, do some math. Otherwise use $3.
if [ ! "$3" ]
then
	sqrtOfColorCount=$(echo "sqrt ($numColors)" | bc)
	# the following math and logic is much simpler than in a previous iteration of the script :/ and more to the point, it always produces the result I want:
	tilesDown=$(( $numColors / $tilesAcross ))
	# if this modulo returns nonzero, we need to add a row; do so:
	modulo=$(( $numColors % $tilesAcross ))
	if [ $modulo != "0" ]
	then
		tilesDown=$(( $tilesDown + 1 ))
	fi
else
	tilesDown=$3
fi
# echo tilesDown is $tilesDown\.
# END SETUP GLOBAL VARIABLES
# =============

# IF RENDER TARGET already exists, abort script. Otherwise continue.
if [ -f ./$renderTargetFile ]
then
	echo Render target $renderTargetFile already exists\; SKIPPING render.
	exit
else
	echo Render target $renderTargetFile does not exist\; WILL RENDER.
	echo Palette will be rendered with $tilesAcross tiles across and $tilesDown tiles down.
	# Make P3 PPM format header:
	echo "P3" > PPMheader.txt
	echo "# P3 means text file, $tilesAcross $tilesDown is cols x rows, 255 is max color, triplets of RGB vals per row." >> PPMheader.txt
	echo $tilesAcross $tilesDown >> PPMheader.txt
	echo "255" >> PPMheader.txt

	# TO DO: this simpler conversion method for sRGB hex code to decimal: https://stackoverflow.com/a/7254022/1397555
	# create superstring from array (all hex values, no spaces) :
	# print array re: https://stackoverflow.com/a/15692004/1397555
	# deleting any Windows newline(s) in that also with | tr -d '\15\32' :
	ppmBodyValues=$(printf '%s' "${colorsArray[@]}" | tr -d '\15\32')
	# Split that superstring with spaces every two hex chars:
	ppmBodyValues=$(echo $ppmBodyValues | sed 's/../& /g' | tr -d '\15\32')
	# ppmBodyValues=$(echo $((16#"$thisHexString")) $((16#"$thatHexString")))
	ppmBodyValues=$(echo $ppmBodyValues | sed 's/[a-zA-Z0-9]\{2\}/$((16#&))/g' | tr -d '\15\32')
	# If I echo that\, it prints it literally instead of interpretively. Ach! Workaround: make a temp shell script that echoes it interpretively (and assign the result to a variable) :
	printf "echo $ppmBodyValues" > tmp_hsmwzuF64fEWmcZ2.sh
	chmod +x tmp_hsmwzuF64fEWmcZ2.sh
	ppmBodyValues=$(./tmp_hsmwzuF64fEWmcZ2.sh)
	rm tmp_hsmwzuF64fEWmcZ2.sh
	echo $ppmBodyValues > ppmBody.txt
	# Because each pixel is three values, each tile (tilesAcross) will be * 3 numeric values:
	splitAtCount=$(( $tilesAcross * 3 ))
	echo $ppmBodyValues | sed "s/\( \{0,1\}[0-9]\{1,\}\)\{$splitAtCount\}/&\n/g" > ppmBody.txt
	# Strip resultant leading spaces off that, in place (in file):
	sed -i 's/^ \(.*\)/\1/g' ppmBody.txt
	echo Padding any empty columns on last row of .ppm file with middle gray pixels . . .
	# Because AGAIN windows line endings created by one ported gnu utility are conflicting with Unix line endings created by another ported gnu utility:
	dos2unix ppmBody.txt
	lastLineString=`tail -1 ppmBody.txt`
	lastLineValuesCount=`echo $lastLineString | grep -o '[0-9]\{1,\}' | wc -l | tr -d ' '`
	#  - Divide that result by 3 because each pixel is three numeric values (RGB) :
	lastLineTilesCount=$(( $lastLineValuesCount / 3))
			# echo lastLineTilesCount is\: $lastLineTilesCount
	#  - Which gives is our value to subtract from tilesAcross as described above:
	tilesToAdd=$(( $tilesAcross * $tilesDown - $numColors ))
			# echo tilesToAdd is\: $tilesToAdd
	valuesToAdd=$(( $tilesToAdd * 3))
			# echo valuesToAdd is\: $valuesToAdd
	#  - Alas this can't be done as elegantly as printf "ha "%.0s {1..5} with a variable in the range, re https://stackoverflow.com/questions/19432753/brace-expansion-with-variable :
	for i in $(seq 1 $valuesToAdd)
	do
		# 145, not 127, is neutral gray (as far as sRGB range is concerned), according to color-sciency analysis:
		lastLineValuesPadString="$lastLineValuesPadString 145"
	done
	lastLineValuesPadString="$lastLineString $lastLineValuesPadString"
	# remove last line from ppmBody.txt, then append the replacement line to it:
	sed -i '$ d' ppmBody.txt
	echo $lastLineValuesPadString >> ppmBody.txt
	# concatenate the header and body to create the final ppm file:
	cat PPMheader.txt ppmBody.txt > $renderTargetFile
	# remove temp files:
	rm PPMheader.txt ppmBody.txt
fi