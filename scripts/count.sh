# DESCRIPTION
# Prints count of file type $1 in current directory, and optionally in all subdirectories.

# USAGE
# Run with these parameters:
# - $1 file type (without the . in the extension) to print count of.
# - $2 OPTIONAL. Pass anything for this parameter (e.g. 'foo') to count all files of type $1 in the current directory and also all subdirectories.
# Example that prints the count of all files that end with .png in the current directory:
#    count.sh png
# Example that prints the count of all .hexplt files in the current directory and all subdirectories:
#    count.sh hexplt FLAERGHBLOR


# CODE
# START PARAMETER PARSING and globals setup
if ! [ "$1" ]; then printf "\nNo parameter \$1 (file type to count) passed to script. Exit."; exit 1; else fileTypeToCount=$1; fi

searchSubDirs=False
if [ "$2" ]; then searchSubDirs=True; fi
# END PARAMETER PARSING and globals setup

# MAIN FUNCTIONALITY
if [ "$searchSubDirs" == "False" ]
then
	ls *.$fileTypeToCount | wc -l
else
	find . -type f -iname \*.$fileTypeToCount -printf '%f\n' | wc -l
fi
