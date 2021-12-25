# DESCRIPTION
# Lists all files in the current directory, then deletes all copies of those files *that have the same base file name* (meaning no extension), which Everything search engine (voidtools) finds everywhere on the computer. USE WITH EXTREME CAUTION, knucklehead.

# WARNING
# Deletes from this script are permanent and immediate, but it prompts to type a confirmation password first.

# USAGE
#    lsEverythingDelete.sh


# CODE
echo "WARNING: this script will list every file in the current directory, extract the base file name for each (remove any extension), and then delete every file that the Everything search engine (CLI) finds ON THE ENTIRE COMPUTER which has that same base file name. This can be extremely and irreversibly destructive. If you know what you are doing and you wish to to this, type GONUKE. Otherwise, press CTRL+C, or CTRL+Z, or close this terminal window."
read -p "TYPE HERE: " USERINPUT


if [ $USERINPUT != "GONUKE" ]
then
	echo "User input does not equal $PASS_STRING. Script will exit without doing anything."
	exit 1
else
	echo "Will destroy all files that Everything finds (everywhere that it searches on the computer) which match all base file names in the current directory."
	
	# make arrey of all file names in the current directory
	allFileNamesInThisDirectory=( $(find . -maxdepth 1 -type f -printf "%P\n") )
	# iterate over it, extracting base file name for each and adding them to a new array:
	allBaseFileNamesInThisDirectory=()
	for fileName in ${allFileNamesInThisDirectory[@]}
	do
		fileNameNoExt=${fileName%.*}
		allBaseFileNamesInThisDirectory+=($fileNameNoExt)
	done
	# remove any duplicate base file names by sorting and uniqifying array:
	IFS=$'\n'
	allBaseFileNamesInThisDirectory=($(sort <<<"${allBaseFileNamesInThisDirectory[*]}"))
	allBaseFileNamesInThisDirectory=($(uniq <<<"${allBaseFileNamesInThisDirectory[*]}"))
	unset IFS
	# iterate over those base file names, get an array of Everything CLI results searching for each, and then delete all of the file names (will be full paths) that Everything gives as results:
	for baseFileName in ${allBaseFileNamesInThisDirectory[@]}
	do
		# the -a-d switch restricts results to files only (no folders) :
		foundPaths=($(es -a-d $baseFileName | tr -d '\15\32'))		# the tr statement deletes windows-style newlines, which throw win-ported GNU tools out of whack.
		# echo ""
		# echo "MATCHES for $baseFileName EVERYWHERE that Everything finds them:"
		for path in ${foundPaths[@]}
		do
			# echo $path
			nixyPath=$(cygpath $path)
			rm $nixyPath
		done
	done
fi