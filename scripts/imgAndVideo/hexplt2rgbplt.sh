# DESCRIPTION
# Converts a .hexplt format palette (a list of RGB colors in hex format) to a list of RGB values. See also rgbplt2hexplt.sh.

# USAGE
# Run this script with one parameter, which is the .hexplt format file to convert, e.g.:
#    hexplt2RGBplt.sh RAHfavoriteColorsHex.hexplt
# NOTE
# If you have a file ~/palettesRootDir.txt with a root path to search for .hexplt files in it, this script will search all paths below that root folder for the file, IF the file is not in the same directory you run this script from. If the file is in the same directory, it uses it from the same directory.


# CODE
# DEV NOTE
# Much of the code in this was adapted from hexplt2ppm.sh; see the file for revelation on what all this convoluted mess is.
# Use Python instead? But then I'd have to fuss with getting Python the full path to the script.. But, re: https://stackoverflow.com/questions/9210525/how-do-i-convert-hex-to-decimal-in-python
# =============
# BEGIN SETUP GLOBAL VARIABLES
if [ ! "$1" ]; then printf "No .hexplt file name passed to script. Expected as parameter \$1."; exit 1; else paletteFile=$1; fi
renderTargetFile=${paletteFile%.*}.rgbplt

# IF RENDER TARGET already exists, abort script. Otherwise continue.
if [ -f ./$renderTargetFile ]
then
	echo Converted color palette target $renderTargetFile already exists\; SKIPPING conversion.
	exit
else
	if [ -e ./$1 ]
	then
		hexColorSrcFullPath=$1
	else
		echo Converted color palette target $renderTargetFile does not exist\; WILL CONVERT.
		if [ -e ~/palettesRootDir.txt ]
		then
			palettesRootDir=$(< ~/palettesRootDir.txt)
					echo palettesRootDir.txt found\;
					echo searching in path $palettesRootDir --
					echo for file $paletteFile . . .
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

	sed -n -e "s/^\s\{1,\}//g" -n -e "s/#\([0-9a-fA-F]\{6\}\).*/\L\1/p" $hexColorSrcFullPath > tmp_d44WYq2HHQ.hexplt
	hexColorSrcTMPpath=tmp_d44WYq2HHQ.hexplt
	ppmBodyValues=$(tr -d '\n' < $hexColorSrcTMPpath)
	rm tmp_d44WYq2HHQ.hexplt
	ppmBodyValues=$(echo $ppmBodyValues | sed 's/../& /g' | tr -d '\15\32')
	ppmBodyValues=$(echo $ppmBodyValues | sed 's/[a-zA-Z0-9]\{2\}/$((16#&))/g' | tr -d '\15\32')
	printf "echo $ppmBodyValues" > tmp_hsmwzuF64fEWmcZ2.sh
	chmod +x tmp_hsmwzuF64fEWmcZ2.sh
	ppmBodyValues=$(./tmp_hsmwzuF64fEWmcZ2.sh)
	rm tmp_hsmwzuF64fEWmcZ2.sh
	# echo $ppmBodyValues > tmp_ykSp296krZ6X.txt
	echo $ppmBodyValues | sed "s/\( \{0,1\}[0-9]\{1,\}\)\{3\}/&\n/g" > tmp_ykSp296krZ6X.txt
	sed -i 's/^ \(.*\)/\1/g' tmp_ykSp296krZ6X.txt
	# removes any resulting trailing double-newlines:
	sed '/^$/d' tmp_ykSp296krZ6X.txt > $renderTargetFile
	rm tmp_ykSp296krZ6X.txt
fi
