# DESCRIPTION
# Converts an .rgbplt format palette (a list of RGB values, in decimal) to a list of RGB colors in hex format. This script adapted from hexplt2rgbplt.sh (see also).

# USAGE
# Run this script with one parameter, which is the .rgbplt format file to convert, e.g.:
#    hexplt2RGBplt.sh RAHfavoriteColorsHex.rgbplt
# NOTE
# If you have a file ~/palettesRootDir.txt with a root path to search for .hexplt files in it, this script will search all paths below that root folder for the file, IF the file is not in the same directory you run this script from. If the file is in the same directory, it uses it from the same directory.


# CODE
# BEGIN SETUP GLOBAL VARIABLES
if [ ! "$1" ]; then printf "No .rgbplt file name passed to script. Expected as parameter \$1."; exit 1; else paletteFile=$1; fi
paletteFileNoExt=$(echo "${1%.*}")
renderTargetFile=$paletteFileNoExt.hexplt

# IF RENDER TARGET already exists, abort script. Otherwise continue.
if [ -f ./$renderTargetFile ]
then
	echo Converted color palette target $renderTargetFile already exists\; SKIPPING conversion.
	exit
else
	if [ -e ./$1 ]
	then
		rgbColorSrcFullPath=$1
	else
		echo Converted color palette target $renderTargetFile does not exist\; WILL CONVERT.
		if [ -e ~/palettesRootDir.txt ]
		then
			palettesRootDir=$(< ~/palettesRootDir.txt)
					echo palettesRootDir.txt found\;
					echo searching in path $palettesRootDir --
					echo for file $paletteFile . . .
			rgbColorSrcFullPath=$(find $palettesRootDir -iname "$paletteFile")
			echo -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
			if [ "$rgbColorSrcFullPath" == "" ]
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

	paletteFileLines=$(tr ' ' ',' < $paletteFile)		# replace spaces with commas on add to array to bypass IFS confusion of space/newline as separator..
	for line in ${paletteFileLines[@]}
	do
		# .. and replace it with a space here:
		line=$(echo $line | tr ',' ' ')
		line=$(printf %02x $line)
		echo \#$line >> $renderTargetFile
	done
fi