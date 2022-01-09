# DESCRIPTION
# Dangerous deduplication. Lists all files in the current directory (or optionally reads from a file list), then moves all copies of those files that have the same file name, which Everything search engine (voidtools) finds, everywhere else on the computer, into the current directory. A potentially false assumption here is that the other files are the same file. If you know that they are not the same; if they are changed; if you copied them elsewhere and modified them, and want to move them back, this would be an advanced "move these changed files back" auto-thingie. You would probably only want to use this script if moving files back becomes complicated; for example if you split them into various revision/sorting folders before changing the copies. USE WITH EXTREME CAUTION, knucklehead.

# WARNING
# Moves and overwrites from this script are permanent and immediate, but it prompts to type a confirmation password first. See details in the "echo" code statement in this script.

# USAGE
# Run optionally with a parameter:
# - $1 file name of a text file in the current directory which lists files to be moved here from everywhere else that Everything CLI (es.exe) finds them. Only files in listed in this text file will be so moved. For example, if you have a file named `filesToMoveHere.txt`, with contents like this:
#
#    Hfwuzjuz.hexplt
#    Hfwuzjuz.png
#    RSImFGzg.hexplt
#    RSImFGzg.png
#    SPhNATb4.hexplt
#    SPhNATb4.png
#    YWgZmFP3.hexplt
#    YWgZmFP3.png
#    fu5jGjvP.hexplt
#    fu5jGjvP.png
#
# -- then all copies of those files which Everything CLI finds elsewhere on the computer will be moved into this directory (whichever directory your terminal is in when you call this script), each one overwriting the last until the last is moved.
# If you omit $1:
#    lsEverythingMoveHere.sh
# -- then all files in the the current directory will be listed and all copies of them found from everywhere else on the computer will be moved to this directory, in the same way.


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

	if [ $1 ]	# if paramater $1 passed to script,
	then
		if [ -f $1 ]	# check if that file exists
		then
			allFileNamesInThisDirectory=( $(<$1) )		# -- and import every line (which should each be one file name!) into an array.
		else
			echo "ERROR: file list $1 not found. Exit."		# Otherwise, error out and exit.
			exit 1
		fi
	else
		# make array of all file names in the current directory
		allFileNamesInThisDirectory=( $(find . -maxdepth 1 -type f -printf "%P\n") )
	fi

	# iterate over the array of file names, searching Everything for each file:
	for fileName in ${allFileNamesInThisDirectory[@]}
	do
		# the -a-d switch restricts results to files only (no folders) ; the tr statement deletes windows-style newlines, which throw win-ported GNU tools out of whack:
		everythingFound=( $(es -a-d $fileName | tr -d '\15\32') )
		for found in ${everythingFound[@]}
		do
				printf "\n\nChecking path \`$nixyPath\` . . ."
			nixyPath=$(cygpath $found)
			pathNoFileName="${nixyPath%\/*}"
			# if the path to the file is *different*, move it here:
			if [ ! "$pathNoFileName" == "$currDir" ]
			then
				printf "\nMOVING HERE: $nixyPath"
				mv -f $nixyPath .
			fi
		done
	done
fi