# DESCRIPTION
# Solves a problem of file names that are too long, while avoiding duplicate file names in renaming. For all files in the current directory of type $1, renames the file to be $2 characters long, or a default length. Checks for filen name conflict and if it finds one adds 8 random characters to the base file name to avoid overwrite (clobber) of existing file. Optionally does renamign this through all subdirectories also. Renames preserve the left-hand side of a name (the right is truncated). To maintain file name pairs (other files with different extensions but the same file name), use shortenMatchedFileNames.sh instead. Also note that while that can do what this does, this will do it faster.

# WARNING
# Does not check for duplicate file names, but designs around that by sufficient file rename entropy. Still, there's a vanishingly small chance it can clobber other files by override of duplicate generated file name.

# USAGE
# Run with these parameters:
# - $1 file type to operate on (e.g. png)
# - $2 OPTIONAL. How many characters to shorten source and match file names to. Minimum 25 strongly recommended. If not provided, a default is used. If $2 is not provided, a default will be used. To use the default (for example if you use $3 so that you must provide $2), pass the word DEFAULT.
# - $3 OPTIONAL. Anything, such as the word FLORGBUAR, which will cause the script to recurse through all subdirectories and perform these operations in each. If you use this ($3) you must use $2.
# For example, to rename all png files in the current directory, run:
#    shortenMatchedFileNames.sh png
# To do the same and specify shortened file length of 50, run:
#    shortenMatchedFileNames.sh png 50
# To do the same and also do so in all subdirectories, run:
#    shortenMatchedFileNames.sh png 50 FLORGBUAR
# To do the same but use the default shorten length, run:
#    shortenMatchedFileNames.sh png DEFAULT FLORGBUAR
# NOTE: logic that avoids clobbering file names can lead to file names longer than what you instruct, because it adds random characters to the end of the base file name. While there could be logic to avoid that case, this script doesn't bother with it.


# CODE
if [ "$1" ]; then fileTypeToMatch=$1; else printf "\nNo parameter \$1 (file type to find matches of.) passed to script. Exit."; exit 1; fi
if [ ! "$2" ] || [ "$2" == "DEFAULT" ]; then shortenToNchars=36; else shortenToNchars=$2; fi

# Function that sets a global RNDstr variable with a new random 9-character string
setRNDstr () {
	RNDstr=$(cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 9)
}

# make a paths array which is of all subdirectories if $3 was passed, or only the current directory if $3 was _not_ passed:
if [ "$3" ]
then
	paths=($(find . -type d))
else
	paths=$(pwd)
fi

thisRootDir=$(pwd)
for path in ${paths[@]}
do
	# in the case of paths only having the current path; this is a tiny waste of changing to the same directory:
	cd $path

	filesToMatch=($(find . -maxdepth 1 -iname \*.$fileTypeToMatch -printf "%P\n"))
	for fileToMatch in ${filesToMatch[@]}
	do
		echo ~ Checking characters length of $fileToMatch . . .
		# only shorten the file if its name is longer than $shortenToNchars; otherwise do nothing but notify:
		fileToMatchLength=${#fileToMatch}
		if [[ $fileToMatchLength > $shortenToNchars ]]
		then
			echo "File $fileToMatch basename length ($fileToMatchLength) is longer than $shortenToNchars. Will shorten."
			# rename fileToMatch (because it will not be included in the list fileMatches) ;
			# construct new file name for fileToMatch:
			fileNameNoExt=${fileToMatch%.*}
			fileExt=${fileToMatch##*.}
			fileToMatchNewName="${fileToMatch:0:$shortenToNchars}".$fileExt
			# do the actual rename:
			if [ ! -f $fileToMatchNewName ]
			then
				mv $fileToMatch $fileToMatchNewName
			else
				setRNDstr
				fileToMatchNewNameTwo="${fileToMatch:0:$shortenToNchars}"__$RNDstr.$fileExt
				printf "\nRename target $fileToMatchNewName would clobber existing file! Renaming to $fileToMatchNewNameTwo . . ."
				mv $fileToMatch $fileToMatchNewNameTwo
			fi
		else
			echo "File $fileToMatch basename length ($fileToMatchLength) is equal to or shorter than $shortenToNchars. Will _not_ shorten."
		fi

	done

	cd $thisRootDir
done

echo DONE.