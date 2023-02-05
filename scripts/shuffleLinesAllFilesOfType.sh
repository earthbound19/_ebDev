# DESCRIPTION
# For every file of type $1 in the current directory, randomly rearranges (shuffles) all lines of the file. Prompts for a given password to verify that you actually want to do this, because the action is irreversible. Optionally in all subdirectories also. 

# USAGE
# Run with these parameters:
# - $1 file extension (without any period) for which you want to randomly shuffle all lines in every file of that type, in the current directory.
# - $2 OPTIONAL. Anything, such as the word FLEURGBORT, which will cause the script to operate on all files of type $1 in all subdirectories also.
# For example, to shuffle all lines of every .hexplt file in the current directory, run:
#    shuffleLinesAllFilesOfType.sh hexplt
# To do the same for all files of type .hexplt in all subdirectories also, run:
#    shuffleLinesAllFilesOfType.sh hexplt FOO


# CODE
if [ "$1" ]; then sourceFileType=$1; else printf "\nNo parameter \$1 passed to script (file extension (without any period) for which you want to randomly shuffle all lines in every file of that type, in the current directory). Exit."; exit 1; fi

# override default maxdepth parameter of any depth with only 1 if parameter $2 is *not* passed to script; otherwise maxdepthParameter will be undefined, which will result in default behavior that searches any depth:
if [ ! "$2" ]
then
	maxdepthParameter='-maxdepth 1'
else
	maxdepthInfoPrintSentenceFragment=" and all subdirectories"
fi

echo ""
echo "WARNING: This will modify all files of type $sourceFileType in the current directory"$maxdepthInfoPrintSentenceFragment" in place by randomly shuffling their lines. This action is irreversible (destructive of the current state of the files). If you wish to continue, type FLORFN. If you do not wish to do this, type anything else and press ENTER."
read -p "TYPE HERE: " SILLYWORD

if ! [ "$SILLYWORD" == "FLORFN" ]
then
	echo ""
	echo Typing mismatch\; exit.
	exit
else
	echo continuing . .
fi

files=($(find ./ $maxdepthParameter -type f -iname "*.$sourceFileType" -printf "%P\n"))

for file in ${files[@]}
do
	echo working on file $file . . .
	lines=($(<$file))
	# print array re: https://stackoverflow.com/a/15692004/1397555; manipulate it with shuffle and recreate array in-place:
	# lines=($(printf '%s\n' "${lines[@]}" | shuf))
	shuffledLines=($(printf '%s\n' "${lines[@]}" | shuf))
	# write it back to original file by printing shuffled array to file:
	printf '%s\n' "${shuffledLines[@]}" > $file
done

echo "DONE. All files of type $sourceFileType in the current directory"$maxdepthInfoPrintSentenceFragment" had all lines in the randomly shuffled in place."