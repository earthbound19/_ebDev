# DESCRIPTION
# Dangerous deduplication. Lists all files in the current directory, then moves all copies of those files that have the same file name, which Everything search engine (voidtools) finds, everywhere else on the computer, into the current directory. A potentially false assumption here is that the other files are the same file (that this would deduplicate, or be an advanced "move these changed files back" auto-thingie). USE WITH EXTREME CAUTION, knucklehead.

# WARNING
# Moves and overwrites from this script are permanent and immediate, but it prompts to type a confirmation password first. See details in the "echo" code statement in this script.

# USAGE
#    lsEverythingMoveHere.sh


# CODE
echo "WARNING: this script will list every file in the current directory, and then move every file of the same name that Everything search engine (CLI) finds ON THE ENTIRE COMPUTER to this same folder. This can be extremely and irreversibly destructive; if any of those files that have the same file name but different content, whichever it copies here last becomes the only copy of the file with that same name on the entire computer (other, different copies would be destroyed via overwrite--naive deduplication). If you know what you are doing, and you are certain you want to do this, type GOCLOBBER. Otherwise, press CTRL+C, or CTRL+Z, or close this terminal window."
read -p "TYPE HERE: " USERINPUT


if [ $USERINPUT != "GOCLOBBER" ]
then
	echo "User input does not equal $PASS_STRING. Script will exit without doing anything."
	exit 1
else
	echo "Will move all files of the same name that Everything finds (everywhere that it searches on the computer) which have the same file name into the current directory."

	# store current directory in a variable for reference:
	currDir=$(pwd)
	# make arrey of all file names in the current directory
	allFileNamesInThisDirectory=( $(find . -maxdepth 1 -type f -printf "%P\n") )
	# iterate over it, searching Everything for each file:
	for fileName in ${allFileNamesInThisDirectory[@]}
	do
		# the -a-d switch restricts results to files only (no folders) ; the tr statement deletes windows-style newlines, which throw win-ported GNU tools out of whack:
		everythingFound=( $(es -a-d $fileName | tr -d '\15\32') )
		for found in ${everythingFound[@]}
		do
				echo "Checking $nixyPath . . ."
			nixyPath=$(cygpath $found)
			pathNoFileName="${nixyPath%\/*}"
			# if the path to the file is *different*, move it here:
			if [ ! "$pathNoFileName" == "$currDir" ]
			then
				echo "MOVING HERE: $nixyPath"
				mv -f $nixyPath .
			fi
		done
	done
fi