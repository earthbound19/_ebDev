# DESCRIPTION
# Reverses the lines of all files of type $1 in the current directory, in place. Overwrites the original files. TAC in this script name is a keyword: it's after GNU's tac command, which is cat (for concatenate) backward.

# USAGE
# Run with these parameters:
# - $1 type of file to operate on
# For example, to reverse the lines of all .hexplt format files in the current directory, run:
#    reverseLinesTACinPlace.sh hexplt


# CODE
if [ "$1" ]; then srcFileType=$1; else printf "\nNo parameter \$1 (file type to operate on) passed to script. Exit."; exit 1; fi

sourceFiles=($(find . -type f -iname \*.$srcFileType -printf "%P\n"))

for fileName in ${sourceFiles[@]}
do
	contents=$(tac $fileName)
	printf "$contents" > $fileName
done