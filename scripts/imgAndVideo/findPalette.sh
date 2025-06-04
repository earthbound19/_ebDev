# DESCRIPTION
# Prints the full path to a `.hexplt` file if found, else prints nothing.

# DEPENDENCIES
# An environment variable export of EB_PALETTES_ROOT_DIR set in `~/.bashrc` (in your home folder) which contains one line, set with a Unix-style path to the folder (and optionally subfolders within it) where you keep hex palette (`.hexplt`) files (for example /some_path/_ebPalettes/palettes). See _ebPalettes/setEBpalettesEnvVars.sh.

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
# - If the environment variable $EB_PALETTES_ROOT_DIR is a path which doesn't exist or is unreadable, this script doesn't let you know. You have to figure that out for yourself, but a clue is that this script prints nothing.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (file name of palette to find the full path to) passed to script. Exit."; exit 1; else paletteFileName=$1; fi

# Search current path for $1; if it exists set hexColorSrcFullPath to just $1 (we don't need the full path and will use a relative one). If it doesn't exist in the local path, search the path in $EB_PALETTES_ROOT_DIR and make decisions based on that result:
if [ -e ./$paletteFileName ]
then
# TO DO: ascertain if this ever breaks anything as I think it has no path? :
	echo $paletteFileName
else	# if variable $EB_PALETTES_ROOT_DIR is set, search for specified palette file in $EB_PALETTES_ROOT_DIR if that dir exists; if it doesn't, do nothing:
	if [ "$EB_PALETTES_ROOT_DIR" ]
	then
		if [ -e $EB_PALETTES_ROOT_DIR ]
		then
			hexColorSrcFullPath=$(find $EB_PALETTES_ROOT_DIR -iname "$paletteFileName")
			if [ "$hexColorSrcFullPath" != "" ]
			then
				printf "$hexColorSrcFullPath"
			fi
		fi
	fi
fi