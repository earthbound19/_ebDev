# DESCRIPTION
# Prints count of file type $1 in current directory (CASE-SENSITIVE search), and optionally in all subdirectories.

# USAGE
# Run with these parameters:
# - $1 file type (without the . in the extension) to print count of.
# - $2 OPTIONAL. Pass anything for this parameter (e.g. 'foo') to count all files of type $1 in the current directory and also all subdirectories.
# Example that prints the count of all files that end with .png in the current directory:
#    count.sh png
# Example that prints the count of all .hexplt files in the current directory and all subdirectories:
#    count.sh hexplt FLAERGHBLOR
# NOTE
# Search is CASE-SENSITIVE: if you give it cr2 it will only find lowercase cr2 extensions. Conversely if you give it CR2 it will only find uppercase. If you want case-insenstive search, hack the script to use the -iname switch with find (instead of -name).


# CODE
# START PARAMETER PARSING and globals setup
if ! [ "$1" ]; then printf "\nNo parameter \$1 (file type to count) passed to script. Exit."; exit 1; else fileTypeToCount=$1; fi

searchSubDirs=False
if [ "$2" ]; then searchSubDirs=True; fi
# END PARAMETER PARSING and globals setup

# MAIN FUNCTIONALITY
if [ "$searchSubDirs" == "False" ]
then
	find . -maxdepth 1 -type f -name \*.$fileTypeToCount | wc -l
else
	find . -type f -name \*.$fileTypeToCount | wc -l
fi
