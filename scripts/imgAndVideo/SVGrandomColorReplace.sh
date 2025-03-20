# DESCRIPTION
# Takes an .svg file and fills all regions of one color (default ffffff, white) with randomly generated colors (not recommended -- random colors can be garish), OR from colors randomly selected from a .hexplt color list (recommended, optional). SEE ALSO SVGrandomColorReplaceCopies.sh AND SVGsRandomColorReplace.sh.

# WARNING
# Changes (overwrites) input svg file without warning. You may wish to only operate on a copy of the svg file, or make many copies and alter them by calling this script from another script, such as `SVGrandomColorReplaceCopies.sh`.

# DEPENDENCIES
# If you use random palette selection, you need a local install of the _ebPalettes repository, and working copy of the the printContentsOfRandomPalette_ls.sh script, with its dependencies.

# USAGE
# Run with these parameters:
# - $1 REQUIRED. The file name of an .svg file in the current directory, which this script will directly modify (overwrite with changes).
# - $2 REQUIRED. A flat text file list of hexadecimal RGB color codes, one per line, from which to choose random colors for this fill. NOTE: each hex color in the file must be preceded by #.
# - $3 OPTIONAL. RGB hex color code in format f800fc (six hex digits, no starting # symbol) to search and replace with random colors from $2. If omitted, defaults to ffffff. If you use this parameter, you must use $2.
# Example that will replace every color fill of ffffff (white) in input.svg with randomly generated sRGB colors:
#    SVGrandomColorReplace.sh input.svg
# Example that will replace every color fill of ffffff (white) in input.svg with randomly selected colors from `eb_favorites_v2.hexplt`:
#    SVGrandomColorReplace.sh input.svg eb_favorites_v2.hexplt
# Example that will replace every color fill of 000000 (black) in input.svg with randomly selected colors from `earth_pigments_dark.hexplt`:
#    SVGrandomColorReplace.sh input.svg earth_pigments_dark.hexplt 000000
# NOTES
# - This expects rgb hex color codes in six digits in your SVGs; ex. f800fc -- never abridged hex forms like fff. (To save *three bytes,* programmers confused the world and added a requirement of more complicated parsers.) If your svg is not this way, use potrace to scan the original black bitmap using BMPs2SVGs.sh, or use the SVGOMG service (convert your SVG file online) at: https://jakearchibald.github.io/svgomg/ -- or use SVGO re https://github.com/svg/svgo and https://web-design-weekly.com/2014/10/22/optimizing-svg-web/ -- It converts RGB values to hex by default. BUT NOTE: for our purposes, do not use the "minify colors" option (which can result in abridged hex codes). 
# - a previous version of this script had this parameter order: $1 source svg file, $2 how many copies of the file to make (this parameter has been removed in the current version, and is now available via `SVGrandomColorReplaceCopies.sh`), $3 palette file to use (or the word RANDOM). This version of the script adds $4 color to replace.
# - this script was renamed from BWsvgRandomColorFill.sh to SVGrandomColorReplace.sh. (Also a vestigal copy of the former accidentally hung around this repository for a long time.)


# CODE
# TO DO:
# ? - implement an optional buffer memory of the last three colors used, and if the current picked color is among them, pick another color until it is not among them.

# START PARAMETER CHECKING AND GLOBALS SETTING
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source SVG file name) passed to script. Exit."; exit 1; else svgFileName=$1; fi
if [ ! "$2" ]
then
	echo "\nNo parameter \$2 (source .hexplt file name) passed to script. Exit."; exit 2
else
	# Search for palette with utility script; exit with error if it returns nothing:
	paletteFile=$(findPalette.sh $2)
	if [ "$paletteFile" == "" ]
	then
		echo "!---------------------------------------------------------------!"
		echo "No file of name $2 found. Consult findPalette.sh. Exit."
		echo "!---------------------------------------------------------------!"
		exit 1
	fi
	echo "File name $paletteFile found! PROCEEDING. IN ALL CAPS."
	rndHexColors=( $(grep -i -o '#[0-9a-f]\{6\}' $paletteFile) )
	# assign retrievedPaletteFileName with just the file name of without the path:
	retrievedPaletteFileName="${paletteFile##*/}"
fi

# Set a default that will be overriden in the next check if $3 was passed to script:
replaceThisHexColor='ffffff'
if [ "$3" ]
then
	# check that $3 is in hex color code format; if so use it, if not exit with error.
	echo ""
	echo "Attempt RGB hex color code from parameter \$3, $3 . . ."
	replaceThisHexColor=$(echo $3 | grep -i -o "[0-9a-f]\{6\}")
	# The result of that operation will be that $replaceThisHexColor will be empty if no match was found, and not empty if a match was found. This check uses that fact:
	if [ "$replaceThisHexColor" != "" ]
	then
		echo "Will attempt to replace color $replaceThisHexColor in copies of $svgFileName."
	else
		echo "PROBLEM: parameter \$3 nonconformant to sRGB hex color code format. Exit."
		exit 2
	fi
fi
# END PARAMETER CHECKING AND GLOBALS SETTING

# dev test prints -- comment out in production:
# for element in ${rndHexColors[@]}
# do
	# echo test $element
# done
# echo retrievedPaletteFileName is $retrievedPaletteFileName.

# MAIN FUNCTIONALITY
# remove # from start of every element of hex array:
counter=0
replArr=()
# build new array then copy it to old one, because my attempt to modify by index failed:
for element in ${rndHexColors[@]}
do
	newSTR="${element/\#/}"
	replArr+=($newSTR)
done
rndHexColors=("${replArr[@]}")

sizeOf_rndHexColors=${#rndHexColors[@]}
sizeOf_rndHexColors=$(($sizeOf_rndHexColors - 1))		# Else we get an out of range error for the zero-based index of arrays.
	# echo val of sizeOf_rndHexColors is $sizeOf_rndHexColors
	# Dev test to assure no picks are out of range (with the first seq command in this script changed to 3):
	# for i in $( seq 50 )
	# do
		# pick=$(shuf -i 0-"$sizeOf_rndHexColors" -n 1)
		# echo sizeOf_rndHexColors val \(\*zero-based\*\) is $sizeOf_rndHexColors
		# echo rnd pick is $pick
	# done

# NOTE: previously I had attempted to match "#[hexdigits], but we don't want that because SVGs can have fills defined as 'style="fill:[hexdigits]". (Also, maybe they can be defined as '#[hexdigits (starting with single quote mark). Just match six hex digits.
numColorsToReplaceInFile=$(grep -i -c "$replaceThisHexColor" $svgFileName)
for j in $(seq $numColorsToReplaceInFile)
do
	pick=$(shuf -i 0-"$sizeOf_rndHexColors" -n 1)
	rndHexColor="${rndHexColors[$pick]}"
		echo Randomly picked hex color "$rndHexColor" for fill . . .
		# NOTE: I was at first using $j instead of 1 to delimit which instance should be replaced, but D'OH! : that Nth instance changes (for the next replace by count operation) after any inline replace!
		# Changing Nth instance of string re: http://stackoverflow.com/a/13818063/1397555
		# test command that worked [by replacing 5th instance of the string?] :
		# sed -i ':a;N;$!ba;s/ffffff/3f2aff/5' test.svg
		# -- expanding on that pattern, the following command changes the first instance of [fF]\{6\} in the file (I think?) ;
		# further adapting for variable use, and the i after /1i is for case-insensitive search (will find a or A) :
	sed -i ":a;N;\$!ba;s/$replaceThisHexColor/$rndHexColor/1i" $svgFileName
done