# DESCRIPTION
# For all files of type $1 in the current directory, searches for files of type $2 that have the same base file name (file minus extension) which reside up to $3 directories up from the current directory, and moves them into the current directory. Checks for and will not move files to the current directory that would clobber (overwrite) files, and logs those duplicates to a file it notifies of at end of script run.

# USAGE
# Run with these parameters:
# - $1 extension of file types in current directory to find file pairs for, such that they are:
# - $2 extension of file types that have the same base name as any file $1 plus this extension.
# - $3 how many directories up to search for files $2 and move them into the current directory.
# - $4 OPTIONAL. Any word, for example KRIDTALB, which will cause the script to force overwrite existing files in the current directory, by moving found matches from any directory up to $3 levels up over them.
# EXAMPLE
# Suppose you've got some files named `rnd_43aB.png` and `rnd43Cd.png` in the current path, which you rendered from source files `rnd_43aB.flame` and `rnd43Cd.flame`, which are two directories up from the current directory, and you want to move those matching `.flame` files into the current directory. To move those matching `.flame` files from up to two parent directories down to the current directory, run this script with these parameters:
#    getFilePairs4Up.sh png flame 2
# This will result in all those matching `.flame` file names being moved from up to two directories above into this directory.
# NOTES
# - The script will not overwrite existing files in the current directory with identically named files from any parent directory. If it finds duplicate file names, it will log the full paths to the duplicates to a file named something like this: `getFilePairs4Up_run_EB213A_log.txt`
# - To override that safe behavior and force overwrite existing files, pass anything for parameter $4. Adapting the example to that purpose, the command to do that would be:
#
#    moveDownFilePairsFromNdirectoriesUp.sh png flame 2 KRIDTALB


# CODE
# START PARAMETERS CHECK and globals set
if ! [ "$1" ]
then
	printf "\nNo parameter \$1 passed (file type to search for files that have the same base file name). Exit."
	exit 1
else
	findPairsForType=$1
fi

if ! [ "$2" ]
then
	printf "\nNo parameter \$2 passed (type of files to search for that have the same base file name as any given file of type $1). Exit"
	exit 1
else
	fileTypeToMoveFoundPairsOf=$2
fi

if ! [ "$3" ]
then
	printf "\nNo parameter \$3 (how many directories up to search). Exit."
	exit 1
else
	searchThisManyDirectoriesUp=$3
fi

clobberExistingFiles='False'
# Override that with 'True' if parameter given such that we should:
if [ "$4" ]; then clobberExistingFiles='True'; fi
# END PARAMETERS CHECK and globals set


# MAIN FUNCTIONALITY
# for mv target, and to move back to after moving up N directories:
currentDirectory=$(pwd)

filesToFindPairsFor=($(find . -maxdepth 1 -type f -iname \*.$findPairsForType -printf '%f\n'))

# create unique log file name and initialize log:
rndHexString=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c 6)
logFileName="$currentDirectory"/getFilePairs4Up_run_"$rndHexString"_log.txt
echo "Duplicate file names in different paths found from run of command: 'getFilePairs4Up.sh $1 $2 $3', separated by bars | :" > $logFileName
echo "" >> $logFileName

duplicateFileNamesFoundInCurrentAndParentDirectories='False'
for i in $(seq 1 $searchThisManyDirectoriesUp)
do
	cd ..
	tmpDirectory=$(pwd)
	printf "\nWorking in directory $tmpDirectory . . ."
	for element in ${filesToFindPairsFor[@]}
	do
		isThisApair=${element%.*}.$fileTypeToMoveFoundPairsOf
		fullPathToMoveTo="$currentDirectory"/"$isThisApair"
		# BEGIN STATE MACHINE "Megergeberg 5,000."
		if [ -e "$isThisApair" ]
		then
			if [[ -e "$fullPathToMoveTo" && "$clobberExistingFiles" == "True" ]]
			then
				printf "\n~\n Move target already exists for match $isThisApair in $fullPathToMoveTo, AND a parameter was passed to the script instructing to move matching files to existing destination anyway. Will move it there."
				mv -f $tmpDirectory/$isThisApair $fullPathToMoveTo
			fi
			if [[ -e "$fullPathToMoveTo" && "$clobberExistingFiles" == "False" ]]
			then
				duplicateFileNamesFoundInCurrentAndParentDirectories='True'
				printf "\n~\n Move target already exists for match $isThisApair in $fullPathToMoveTo, BUT no parameter was passed to script instructing to move matching files to existing destination. Will NOT move it there, but will log the full paths to both files."
				printf "$tmpDirectory/$isThisApair | $fullPathToMoveTo\n" >> $logFileName
			fi
			if [ ! -e "$fullPathToMoveTo" ]
			then
				echo
				printf "\n~\n Move target does not exist for match $isThisApair in $fullPathToMoveTo. Will move it there."
				mv $tmpDirectory/$isThisApair $fullPathToMoveTo
			fi
		fi
	done
done

cd $currentDirectory

printf "\n\nDONE."
if [ "$duplicateFileNamesFoundInCurrentAndParentDirectories" == "True" ]
then
	printf "\nDuplicate file names were found between current directory and at least one parent directory. The information is logged to $logFileName."
else
	# Delete the log file; we don't need it:
	rm $logFileName
fi