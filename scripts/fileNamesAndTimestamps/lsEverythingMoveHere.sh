# DESCRIPTION
# Dangerous deduplication. Lists all files in the current directory (or optionally reads from a file list), then moves all copies of those files that have the same file name, which Everything search engine (voidtools) finds, everywhere else on the computer, into the current directory. A potentially false assumption here is that the other files are the same file. If you know that they are not the same; if they are changed; if you copied them elsewhere and modified them, and want to move them back, this would be an advanced "move these changed files back" auto-thingie. You would probably only want to use this script if moving files back becomes complicated; for example if you split them into various revision/sorting folders before changing the copies. USE WITH EXTREME CAUTION, knucklehead.

# WARNING
# Moves and overwrites from this script are permanent and immediate, but it prompts to type a confirmation password first. See details in the "echo" code statement in this script.

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. File name of a text file in the current directory which lists files to be moved here from everywhere else that Everything CLI (es.exe) finds them. Only files listed in this text file will be so moved. For example, if you have a file named `filesToMoveHere.txt`, with contents like this:
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
# -- then all copies of those files (from the list) which Everything CLI finds elsewhere on the computer will be moved into this directory (whichever directory your terminal is in when you call this script), each one overwriting the last until the last is moved.
# - $2 OPTIONAL. Anything, for example the phrase 'I UNDERSTAND THE DANGER' surrounded by single quote marks, which will cause the script to recurse through subdirectories and perform naive deduplication (move all other found files everywhere on the computer into the current folder) in each directory. If you want to use this parameter ($2) but not a file list ($1), pass the word 'NULL' for parameter 1.
# Example that will do naive deduplication of every file found in the current directory:
#    lsEverythingMoveHere.sh
# Without any paramter, that way, all files in the the current directory will be listed and all copies of them found from everywhere else on the computer will be moved to this directory.
# Example that will do naive deduplication of all files from a file list:
#    lsEverythingMoveHere.sh filesToMoveHere.txt
# Example that will recurse through all subdirectories and move all files into that directory (which are found elsewhere on the computer that have the same file name as files in that directory):
#    lsEverythingMoveHere.sh NULL YORFPLERION
# NOTES
# - To do naive copy-over (clobbering files in the current directory with the last found copy of the same file name elsewhere), hack this script this way: find the `mv` command and change it to `cp`.
# - If you specify a file name for $1 (and don't pass 'NULL'), but also pass parameter $2, parameter $1 is ignored (the file list is not used). This is because that would lead to duplicate work (it would recurse through subdirectories and repeatedly move all files from the file list, and on all subsequent directory changes it would find and move all those files again).
# - Any list of file names you provide via $1 must contain file names without paths. Paths may screw things up and lead to results you don't expect!
# - This skips all moves of any files named README.md and README.txt.


# CODE
echo "WARNING: this script will list every file in the current directory, and then move every file of the same name that Everything search engine (CLI) finds ON THE ENTIRE COMPUTER to this same folder. This can be extremely and irreversibly destructive; if any of those files that have the same file name but different content, whichever it copies here last becomes the only copy of the file with that same name on the entire computer (other, different copies would be destroyed via overwrite--naive deduplication). If you know what you are doing, and you are certain you want to do this, type GOCLOBBER. Otherwise, press CTRL+C, or CTRL+Z, or close this terminal window."
read -p "TYPE HERE: " USERINPUT

if [ $USERINPUT != "GOCLOBBER" ]
then
	echo "User input does not equal $PASS_STRING. Script will exit without doing anything."
	exit 1
else
	printf "\nWill move all files of the same name that Everything finds (everywhere that it searches on the computer) which have the same file name into the current directory.\n"
	# store current directory in a variable for reference:

	# if $1 present, make directory array from all subdirectories under the current directory:
	if [ "$2" ]
	then
		directories=( $(find ~+ -type d) )
	# otherwise, put only the current directory in the "array;" it can still be "iterated" over -- but it's just a variable:
	else
		directories=$(pwd)
	fi

	for directory in ${directories[@]}
	do
		printf "\n - - - working in directory $directory . . ."
		cd $directory
		currDir=$(pwd)
		if [ $1 ] && [ "$1" != "NULL" ] && [ ! "$2" ]		# if paramater $1 passed to script and not keyword NULL, AND parameter $2 was not passed to script:
		then
			if [ -f $1 ]	# check if that file exists
			then
				# check file list for backward or forward slashes, and exit with error if found:
				grep -q '[\\/]' $1
				if [ $? == 0 ]
				then
					printf "!----\nPROBLEM: file list $1 includes character '/' and/or '\' (path delimiters). Those will cause problems. File should only include file names, no paths. Exit.\n\n"
					exit 2
				fi
				echo "Will move all copies of files found in list $1 (which are found everywhere else on the computer) to directory $currDir."
				allFileNamesToMove=( $(<$1) )		# -- and import every line (which should each be one file name!) into an array.
			else
				echo "ERROR: file list $1 not found. Exit."		# Otherwise, exit with error code.
				exit 3
			fi
		else
			# make array of all file names in the current directory; IFS trickery to stop spaces in files from mucking with es search; saved by a genius breath yonder -- https://unix.stackexchange.com/a/9500/110338 :
			OIFS="$IFS"
			IFS=$'\n'
			allFileNamesToMove=( $(find . -maxdepth 1 -type f -printf "%P\n") )
		fi

		# iterate over the array of file names, searching Everything for each file:
		for fileName in ${allFileNamesToMove[@]}
		do
			# the -a-d switch restricts results to files only (no folders) ; the tr statement deletes windows-style newlines, which throw win-ported GNU tools out of whack:
			# just in case we can end up with a blank array item? -- which would cause es to return ALL FILES ON THE COMPUTER -- AND LEAD TO TRYING TO MOVE EVERYTHING HERE:
			if [ $fileName != "" ] && [ $fileName != "README.md" ] && [ $fileName != "README.txt" ]
			then
				everythingFound=( $(es -a-d $fileName | tr -d '\15\32') )
				for found in ${everythingFound[@]}
				do
					nixyPath=$(cygpath $found)
						# printf "\nChecking path $nixyPath . . ."
					pathNoFileName="${nixyPath%\/*}"
					# if the path to the file is *different*, move it here:
					if [ ! "$pathNoFileName" == "$currDir" ]
					then
						printf "\nMOVING HERE: $nixyPath"
						mv -f $nixyPath .
					fi
				done
			fi
		done
		IFS="$OIFS"
	done
fi