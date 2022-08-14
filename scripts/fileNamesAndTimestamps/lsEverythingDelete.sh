# DESCRIPTION
# Finds all files in the current directory, and all subdirectories, then deletes all copies of those files *that have the same base file name* (meaning no extension), which Everything search engine (voidtools) finds everywhere on the computer. THAT MEANS all of the files found in this folder and its subfolders, too (for whichever folder you run this script from). USE WITH EXTREME CAUTION, knucklehead.

# WARNINGS
# - Deletes from this script are permanent and immediate, and all files in the current folder you run this from are part of that deletion. It prompts to type a confirmation password first.
# - If the base file name of any files in this folder has words that even appear as *part* of other file names, all those files will be destroyed, also.

# USAGE
#    lsEverythingDelete.sh


# CODE
echo "WARNING: this script will list every file in the current directory, extract the base file name for each (remove any extension), and then delete every file that the Everything search engine (CLI) finds ON THE ENTIRE COMPUTER which has that contains that base file name. This can be extremely and irreversibly destructive. As an example, if any file in the current directory has the word 'installer' in it, *all files on the computer that contain that word in their file name will be destroyed.* So only use this if you're very sure that the base names of all files in this directory are unique such that no unintended deletes from partial base name matches elsewhere on the computer will be deleted. If you know what you are doing and you wish to to this, type GONUKE. Otherwise, press CTRL+C, or CTRL+Z, or close this terminal window."
read -p "TYPE HERE: " USERINPUT

echo "Will destroy all files that Everything finds (everywhere that it searches on the computer) which match all base file names in the current directory. If parameter \$1 was passed, will go through all subdirectories and do this also."

if [ $USERINPUT != "GONUKE" ]
then
	echo "User input does not equal $PASS_STRING. Script will exit without doing anything."
	exit 1
else
	# if $1 present, make directory array from all subdirectories under the current directory:
	if [ "$1" ]
	then
		directories=( $(find ~+ -type d) )
	# otherwise, put only the current directory in the "array;" it can still be "iterated" over -- but it's just a variable:
	else
		directories=$(pwd)
	fi

	for directory in ${directories[@]}
	do
		cd $directory
		echo --
		echo working in directory $directory . . .
		# make arrey of all file names in the current directory; IFS trickery to stop spaces in files from mucking with es search; saved by a genius breath yonder -- https://unix.stackexchange.com/a/9500/110338 :
		OIFS="$IFS"
		IFS=$'\n'
		allFileNamesInThisDirectory=( $(find . -maxdepth 1 -type f -printf "%P\n") )
		# iterate over it, extracting base file name for each and adding them to a new array:
		allBaseFileNamesInThisDirectory=()
		for fileName in ${allFileNamesInThisDirectory[@]}
		do
			fileNameNoExt=${fileName%.*}
			allBaseFileNamesInThisDirectory+=($fileNameNoExt)
		done
		# remove any duplicate base file names by sorting and uniqifying array:
		allBaseFileNamesInThisDirectory=($(sort <<<"${allBaseFileNamesInThisDirectory[*]}"))
		allBaseFileNamesInThisDirectory=($(uniq <<<"${allBaseFileNamesInThisDirectory[*]}"))

		# iterate over those base file names, get an array of Everything CLI results searching for each, and then delete all of the file names (will be full paths) that Everything gives as results:
		for baseFileName in ${allBaseFileNamesInThisDirectory[@]}
		do
			# the -a-d switch restricts results to files only (no folders) :
			foundPaths=($(es -a-d $baseFileName | tr -d '\15\32'))		# the tr statement deletes windows-style newlines, which throw win-ported GNU tools out of whack.
			# echo ""
			# echo "MATCHES for $baseFileName EVERYWHERE that Everything finds them:"
			for path in ${foundPaths[@]}
			do
				nixyPath=$(cygpath $path)
				echo Deleting $nixyPath . . .
				rm $nixyPath
			done
		done
		IFS="$OIFS"
	done
fi