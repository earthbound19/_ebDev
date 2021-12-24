# DESCRIPTION
# Takes an .svg file and fills all regions of one color (default ffffff, white) with randomly generated colors (not recommended -- random colors can be garish), OR from colors randomly selected from a .hexplt color list (recommended, optional).

# WARNING
# Changes (overwrites) input svg file without warning. You may wish to only operate on a copy of the svg file, or make many copies and alter them by calling this script from another script, such as `SVGrandomColorReplaceCopies.sh`.

# USAGE
# Run with these parameters:
# - $1 the file name of an .svg file in the current directory, which this script will directly modify (overwrite with changes).
# - $2 OPTIONAL. A flat text file list of hexadecimal RGB color codes, one per line, from which to choose random colors for this fill. NOTE: each hex color must be preceded by #. This script makes a copy of the .svg with a name being a time stamp. If $2 is omitted, the script will produce random colors fills. If you want to use $2 but not specify any pallette file (and have it generate random colors), pass the word RANDOM for $2.
# - $3 OPTIONAL. RGB hex color code in format f800fc (six hex digits, no starting # symbol) to search and replace with random colors from $2. If omitted, defaults to ffffff.
# Example that will replace every color fill of ffffff (white) in input.svg with randomly generated sRGB colors:
#    SVGrandomColorReplace.sh input.svg
# Example that will replace every color fill of ffffff (white) in input.svg with randomly selected colors from `eb_favorites_v2.hexplt`:
#    SVGrandomColorReplace.sh input.svg eb_favorites_v2.hexplt
# Example that will replace every color fill of 000000 (black) in input.svg with randomly selected colors from `earth_pigments_dark.hexplt`:
#    SVGrandomColorReplace.sh input.svg earth_pigments_dark.hexplt 000000
# NOTES
# - This expects rgb hex color codes in six digits in your SVGs; ex. f800fc -- never abridged hex forms like fff. (To save *three bytes,* programmers confused the world and added a requirement of more complicated parsers.) If your svg is not this way, use potrace to scan the original black bitmap using BMPs2SVGs.sh, or use the SVGOMG service (convert your SVG file online) at: https://jakearchibald.github.io/svgomg/ -- or use SVGO re https://github.com/svg/svgo and https://web-design-weekly.com/2014/10/22/optimizing-svg-web/ -- It converts RGB values to hex by default. BUT NOTE: for our purposes, do not use the "minify colors" option (which can result in abridged hex codes). 
# - a previous version of this script had this parameter order: $1 source svg file, $2 how many copies of the file to make (this parameter has been removed in the current version, and is now available via `SVGrandomColorReplaceCopies.sh`), $3 palette file to use (or the word RANDOM). This version of the script adds $4 color to replace.
# - this script was renamed from BWsvgRandomColorFill.sh to SVGrandomColorReplace.sh.


# CODE
# TO DO:
# ? - implement an optional buffer memory of the last three colors used, and if the current picked color is among them, pick another color until it is not among them.

# PARAMETER CHECKING:
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source SVG file name) passed to script. Exit."; exit 1; else svgFileName=$1; fi
if [ "$2" ] && [ "$2" != "RANDOM" ]
then
	paletteFile=$2
fi
# Set a default that will be overriden in the next check if $4 was passed to script:
replaceThisHexColor='ffffff'
if [ "$3" ]
then
	# check that $3 is in hex color code format; if so use it, if not exit with error.
	echo ''
	echo 'Attempt RGB hex color code from parameter \$3, $3 . . .'
	replaceThisHexColor=$(echo $3 | grep -i -o "[0-9a-f]\{6\}")
	# The result of that operation will be that $replaceThisHexColor will be empty if no match was found, and not empty if a match was found. This check uses that fact:
	if [ "$replaceThisHexColor" != "" ]
	then
		echo "Will attempt to replace color $replaceThisHexColor in copies of $svgFileName."
	fi
fi

# PALETTE FILE SEARCH if applicable:
if [ -e $paletteFile ]
then
	echo Source pallete file $paletteFile found in the current directory. Will use that.
	rndHexColors=( $(grep -i -o '#[0-9a-f]\{6\}' $paletteFile) )
else
	paletteFileNotFound='true'
fi

if [ "$paletteFileNotFound" == 'true' ]
then
	echo "Specified palette file name not found in current path. Will search for palettesRootDir.txt and search those pathes for palette . . ."
	# Search for specified palette file in palettesRootDir (if that dir exists; if it doesn't, exit with an error) :
	if [ -e ~/palettesRootDir.txt ]
	then
		palettesRootDir=$(< ~/palettesRootDir.txt)
				echo palettesRootDir.txt found\;
				echo searching in path $palettesRootDir
				echo -- for file $paletteFile . . .
		hexColorSrcFullPath=$(find $palettesRootDir -iname "$paletteFile")
		echo -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
		if [ "$hexColorSrcFullPath" == "" ]
		then
			echo File of name $paletteFile NOT FOUND in the path this script was run from OR in path \"$palettesRootDir\" \! ABORTING script.
			exit 3
		else
			echo File name $paletteFile FOUND in the path this script was run from OR in path \"$palettesRootDir\" \!
			echo File is at\:
			echo $hexColorSrcFullPath
			echo PROCEEDING. IN ALL CAPS.
			rndHexColors=( $(grep -i -o '#[0-9a-f]\{6\}' $hexColorSrcFullPath) )
		fi
	else
		echo !--------------------------------------------------------!
		echo "file ~/palettesRootDir.txt \(in your root user path\) not found. If you wish to use your intended palette from a directory within a global path containing palettes, this file should exist and have one line, being the root directory that contains palettes (which may be in subfolders of that directory), e.g.:"
		echo
		echo /c/Users/YourUserName/Documents/_ebPalettes/palettes
		echo
		echo see the _ebPalettes repo with its createPalettesRootDirTXT.sh script.
		echo ABORTING script.
		echo !--------------------------------------------------------!
		exit
	fi
fi

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

# If no $paletteFile set (no parameter $3 passed to script), create an array of 9 random hex RGB color values. Otherwise, create the array from the list in the filename specified in $3.
if [ -z "$paletteFile" ]
then
	echo "no parameter \$3 passed to script, OR passed as RANDOM; generating random hex colors array . . ."
	rndHexColors=()
	for i in $(seq 9);
	do
		# TO DO: make this work faster with one pre-generated string in memory that you bite six bytes off in increments?
		rndHexColor=$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 6)
			echo Generated random RGB hex color "$rndHexColor" . . .
		rndHexColors+=($rndHexColor)
	done
fi

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