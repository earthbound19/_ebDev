# DESCRIPTION
# Moves all files in all subfolders of type $1 (parameter 1, e.g. png) to the current folder.

# USAGE
# thisScript.sh fileTypeToMoveHere
# e.g.:
# thisScript.sh png
# -- will move all files with the extension .png in all subfolders up into the path from which you execute this script.

# From reading the manual and with help from https://stackoverflow.com/a/25111885 :
gfind -iname "*.$1" -exec mv {} . \;