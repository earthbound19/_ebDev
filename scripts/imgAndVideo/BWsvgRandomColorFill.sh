# DESCRIPTION
# Takes an .svg file and fills all regions of one color (default ffffff, white) with randomly generated colors (not recommended -- random colors can be garish), N times, OR from colors randomly selected from a .hexplt color list (recommended, optional).

# USAGE
# Run with these parameters:
# - $1 an .svg file name
# - $2 how many random color fill variations of that file to create, and
# - $3 OPTIONAL. A flat text file list of hexadecimal RGB color codes, one per line, from which to choose random colors for this fill. NOTE: each hex color must be preceded by #. This script makes a copy of the .svg with a name being a time stamp. If $3 is omitted, the script will produce random colors fills. If you want to use $4 but not specify any pallette file (and have it generate random colors), pass the word RANDOM for $3.
# - $4 OPTIONAL. RGB hex color code in format e.g. f800fc (no starting # symbol) to search and replace with random colors from $3. If omitted, defaults to ffffff.
# Example that will create 12 randomly colored variations of input.svg:
#    BWsvgRandomColorFill.sh input.svg 12
# Example that will create 12 variations of input.svg with colors randomly selected from `RAHfavoriteColorsHex.hexplt`:
#    BWsvgRandomColorFill.sh input.svg 12 RAHfavoriteColorsHex.hexplt:
# NOTES
# - This expects rgb hex color codes in six digits in your SVGs; ex. f800fc -- never abridged hex forms like fff. (To save *three bytes,* programmers confused the world and added a requirement of more complicated parsers.) If your svg is not this way, use potrace to scan the original black bitmap using BMPs2SVGs.sh, or use the SVGOMG service (convert your SVG file online) at: https://jakearchibald.github.io/svgomg/ -- or use SVGO re https://github.com/svg/svgo and https://web-design-weekly.com/2014/10/22/optimizing-svg-web/ -- It converts RGB values to hex by default. BUT NOTE: for our purposes, do not use the "minify colors" option (which can result in abridged hex codes). 


# CODE
# TO DO
# - Items listed in comments that read TO DO
# - make it use an optional global hex color schemes dir tree (search path), otherwise search in path script is run from.
# - make it name the target file after the color scheme.
# ? - implement an optional buffer memory of the last three colors used, and if the current picked color is among them, pick another color until it is not among them.
# ? - replace all this functionality with a script that works with a nodejs svg library, if possible? It could be run from a CLI on any local nodejs (node) install.

# PARAMETER CHECKING:
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source SVG file name) passed to script. Exit."; exit 1; else svgFileName=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (how many variations to make) passed to script. Exit."; exit 2; else generateThisMany=$2; fi
if [ "$3" ] && [ "$3" != "RANDOM" ]
then
	paletteFile=$3
fi
# Set a default that will be overrided in the next check if $4 was passed to script:
replaceThisHexColor='ffffff'
if [ "$4" ]
then
	# check that $4 is in hex color code format; if so use it, if not exit with error.
	# need to print to  2>/dev/null  ? :
	echo ''
	echo 'Attempt RGB hex color code from parameter $4 . . .'
	echo $4
	replaceThisHexColor=$(echo $4 | grep -i -o "[0-9a-f]\{6\}")
	# The result of that operation will be that $replaceThisHexColor will be empty if no match was found, and not empty if a match was found. This check uses that fact:
	if [ "$replaceThisHexColor" != "" ]
	then
		echo "Will attempt to replace color $replaceThisHexColor in copies of $svgFileName."
	else
		echo ''
		echo 'No six-digit RGB hex color code found in parameter $4. Exit.'
		exit 4
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

# If no $paletteFile set (no parameter $3 passed to script), create an array of 18 random hex RGB color values. Otherwise, create the array from the list in the filename specified in $3.
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
# TO DO: make this save the generated hex color scheme to a plain text file (just generate an RND name and rename it to that instead of the following delete) :
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
for i in $(seq $generateThisMany)
do
	echo Generating variant $i of $generateThisMany . . .
	timestamp=$(date +"%Y%m%d_%H%M%S_%N")
	newFile="$timestamp"rndColorFill__$svgFileName
	cp $svgFileName $newFile
	# NOTE: previously I had attempted to match "#[hexdigits], but we don't want to do that because SVGs can have fills defined as 'style="fill:[hexdigits]". (Also, maybe they can be defined as '#[hexdigits (starting with single quote mark). Just match six hex digits.
# IN PROGRESS: make use of replaceThisHexColor and ~ $(echo $4 | grep -i -o "[0-9a-f]\{6\}")
	numColorsToReplaceInFile=$(grep -i -c "$replaceThisHexColor" $newFile)
	for j in $(seq $numColorsToReplaceInFile)
	do
		pick=$(shuf -i 0-"$sizeOf_rndHexColors" -n 1)
		rndHexColor="${rndHexColors[$pick]}"
				# echo pick is $pick
				echo Randomly picked hex color "$rndHexColor" for fill . . .
			# HORRIBLE KLUDGE for problem mixing ' and " in a sed command; NOTE that the $ is escaped--in some insane way that for some reason the shell insists! :
			# NOTE: I was at first using $j instead of 1 to delimit which instance should be replaced, but D'OH! : that Nth instance changes (for the next replace by count operation) after any inline replace!
			# Changing Nth instance of string re: http://stackoverflow.com/a/13818063/1397555
					# test command that worked [by replacing 5th instance of the string?] :
					# sed -i ':a;N;$!ba;s/ffffff/3f2aff/5' test.svg
			# -- expanding on that pattern, the following command changes the first instance of [fF]\{6\} in the file (I think?) ;
			# the i after /1i is for case-insensitive search (will find a or A) :
echo ''
echo RUNNING COMMAND\:
# TO DO: run this -- IT WORKS -- without escaping, as printed this way:
echo "sed -i ':a;N;\$!ba;s/$replaceThisHexColor/$rndHexColor/1i' $newFile"
# IN DEVELOPMENT; not working now:
sedCommand=`echo sed -i ':a;N;\$!ba;s/$replaceThisHexColor/$rndHexColor/1i' $newFile`
		# PREVIOUS version:
		# 2021-12-20: I don't know why I used backticks here? They work? Or is that command substitution and it actually just runs the command?! :
		# sedCommand=`echo sed -i \'":a;N;\\$!ba;s/[fF]\{3,\}/$rndHexColor/1i"\' $newFile`
		echo $sedCommand > tempCommand.sh
		./tempCommand.sh
	done
	rm ./tempCommand.sh
done