# DESCRIPTION
# Solves a problem of file system views that sort by date not displaying related files of the same base file name near each other. For every file of type $1 in the current directory, finds all files with the same base file name and updates thier creation/modification date to match.

# DEPENDENCIES
# `listMatchedFileNames.sh`

# USAGE
# Run with these parameters:
# - $1 source file type (extension) to find and update timestamps of all corresponding files with the same base file name for any given file of this extension.
# For example, if you have source art files like this:
#    woodcut_inspired_by_choral_00c8c538.png
#    woodcut_inspired_by_choral_00c8c538.txt
#    woodcut_inspired_by_choral_013973d3.png
#    woodcut_inspired_by_choral_013973d3.txt
# -- and you want to follow this process for them, run:
#    touchMatchedFiles.sh png
# -- and the script will update e.g. `woodcut_inspired_by_choral_00c8c538.txt` with the same time stamp as `woodcut_inspired_by_choral_00c8c538.png`, and `woodcut_inspired_by_choral_013973d3.txt` with the same time stamp as `woodcut_inspired_by_choral_013973d3.png`, and so on, for every png/txt file pair where they have the same file name.
# This process will also work where files of multiple extensions have the same base file names as any types $1.


# CODE
if [ "$1" ]; then sourceExtension=$1; else printf "\nNo parameter \$1 (source file type to find matches of) passed to script. Exit."; exit 1; fi

# I tried this more elegant solution; re: https://stackoverflow.com/a/28574445
# for f in *.$sourceExtension; do touch -r "$f" "${f%.a}".*; done
# -- but it produced mangled file names newly created by touch; I haven't got that working. Meanwhile the below works:
for i in *.$sourceExtension
do
	echo "working on updating files with the same basename as $i to have matching datestamps.."
	files=($(listMatchedFileNames.sh $i))
	for j in ${files[@]}
	do
		echo working on related file $j . . .
		touch $j -r $i
	done
done