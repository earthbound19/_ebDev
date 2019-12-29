# DESCRIPTION
# Finds the path to a .hexplt file by searching the current path, then (if necessary) all paths under the path given in ~/palettesRootDir.txt, returning an error file name if nothing is found.

# USAGE
# NOTE that `source` isn't working right now. This script only works for me called directly from the shell, not from another script. EXCEPT MAYBE THAT DOESN'T EVEN WORK.
# Invoke this script via `source` (to keep an environment variable it creates), and pass one parameter, being the name of a .hexplt file to find. Example:
# source ./thisScript.sh turtleGreenTetradicEtcHex.hexplt
# NOTE Sets an environment variable hexColorSrcFullPath which is either the full path to the .hexplt file searched for or a bogus file name (with a warning printed to the terminal before), depending on whether the intended .hexplt file is found.


# CODE
paletteFileName=$1

# Search current path for $1; if it exists set hexColorSrcFullPath to just $1 (we don't need the full path). If it doesn't exist in the local path, search the path in palettesRootDir.txt and make decisions based on that result:
if [ -e ./$1 ]
then
	echo found palette file $paletteFileName in the current directory. Script will use that file.
	hexColorSrcFullPath=$1
else	# Search for specified palette file in palettesRootDir (if that dir exists; if it doesn't, display a warning and set a bogus .hexplt file name variable with a strong ERROR hint:
	if [ -e ~/palettesRootDir.txt ]
	then
		palettesRootDir=$(< ~/palettesRootDir.txt)
				echo palettesRootDir.txt found\;
				echo searching in path $palettesRootDir --
				echo for file $paletteFileName . . .
						# FAIL:
						# hexColorSrcFullPath=`gfind "$palettesRootDir" -iname *$paletteFileName`
		hexColorSrcFullPath=`gfind $palettesRootDir -iname "$paletteFileName"`
		echo -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~
		if [ "$hexColorSrcFullPath" == "" ]
			then
					echo WARNING\: no file of name $paletteFileName found in the path this script was invoked from OR in path \"$palettesRootDir\" \! Setting a bogus file name which will give you errors\!
				hexColorSrcFullPath=BOGUS_HEXPALETTE_FILE_NAME_qwcUMANpceH22b.hexplt
			else
					echo File name $paletteFileName found via path \"$hexColorSrcFullPath\"\. This script will use that file. PROCEEDING. IN ALL CAPS.
		fi
	else
			echo !--------------------------------------------------------!
			echo WARNING\: File ~/palettesRootDir.txt \(in your root user path\) not found. This file should exist and have one line, being the path of your palette text files e.g.:
			echo
			echo /cygdrive/c/_ebdev/scripts/imgAndVideo/palettes
			echo
			echo Setting a bogus file name which will give you errors!
			echo !--------------------------------------------------------!
		hexColorSrcFullPath=BOGUS_HEXPALETTE_FILE_NAME_qwcUMANpceH22b.hexplt
	fi
fi