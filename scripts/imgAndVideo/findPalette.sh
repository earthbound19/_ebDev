# DESCRIPTION
# Prints the full path to a `.hexplt` file if found, else prints nothing.

# DEPENDENCIES
# A file `~/palettesRootDir.txt` (and in that location--the root of the home dir), which has the path to a repository of palettes (see the `_ebPalettes` repository and its script, `createPalettesRootDirTXT.sh`).

# USAGE
# With this script in your PATH, run it with one parameter, which is the file name of a palette (such as a .hexplt file name, which is a list of RGB color codes in hex format, one color per line) you wish to locate. For example:
#    findPalette.sh turtleGreenTetradicEtcHex.hexplt
# NOTES
# - You can utilize the printout from this script in other scripts by using command substitution to assign the result to a variable, this way:
#
#    fullPathToHexplt=$(findPalette.sh turtleGreenTetradicEtcHex.hexplt)
#
# -- which results in the full path to `turtleGreenTetradicEtcHex.hexplt` being stored in the variable `$fullPathToHexplt`.
# - This script searches for an exact file name match. If you are looking for `turtleGreenTetradicEtcHex.hexplt` but pass `turtleGreenTetradicEtcHex` or `turtleGreen`, it will fail.
# - Because this script only prints the full path to a palette file if it finds it, scripts that call this script may be coded to exit with an error if it prints nothing (if a variable assigned via command substitution which calls this script turn out to be empty). That is suggested as best practice (otherwise, things could not work as expected and the reason could be a mystery).
# - If this script fails to find `~/palettesRootDir.txt`, it doesn't let you know. You have to figure that out for yourself, but a clue is that this script prints nothing.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (file name of palette to find the full path to) passed to script. Exit."; exit 1; else paletteFileName=$1; fi

# Search current path for $1; if it exists set hexColorSrcFullPath to just $1 (we don't need the full path and will use a relative one). If it doesn't exist in the local path, search the path in ~/palettesRootDir.txt and make decisions based on that result:
if [ -e ./$paletteFileName ]
then
	echo $paletteFileName
else	# Search for specified palette file in palettesRootDir (if that dir exists; if it doesn't, display a warning and set a bogus .hexplt file name variable with a strong ERROR hint:
	if [ -e ~/palettesRootDir.txt ]
	then
		palettesRootDir=$(< ~/palettesRootDir.txt)
		hexColorSrcFullPath=$(find $palettesRootDir -name "$paletteFileName")
		if [ "$hexColorSrcFullPath" != "" ]
			then
				printf "$hexColorSrcFullPath"
		fi
	fi
fi