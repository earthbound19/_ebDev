# DESCRIPTION
# DANGEROUS. Renames all files and folders found on a system such that a search string is substituted with a replace string, WITHOUT PROMPT OR WARNING, but requiring a password parameter. Logs renames to a text file. See "DON'T DO THIS UNLESS" under USAGE.

# WARNING
# THIS CAN BREAK STUFF HARD AND FAST AND PERMANENTLY IF MISUSED. See "DON'T DO THIS UNLESS" section under "USAGE."

# REQUIREMENTS
# Voidtools "Everything" search engine, working and showing files you search for correctly, and accompanying es (CLI tool for it) in you PATH, probably MSYS2 bash environment.

# USAGE
# Run with these parameters:
# - $1 search string
# - $2 replace string. If provided as the syntax-phrase combination "-_-SNIP-_-" (with or without quote marks), the search string will be deleted from all found files; or in other words it will be replaced with nothing, or that word or phrase will be deleted from the file name.
# - $3 the word YOINK
# - $4 OPTIONAL. Any additional switches that will work with es (Everything Search Engine CLI), surrounded by single or double quote marks. As an example, to restrict Everything Search to only files and subfolders within a given folder (or path) F:\testFiles, you could pass "-path 'F:\testFiles'" for $4. The single quote marks around 'F:\testFiles' aren't strictly necessary there, but they would be if the path had a space in the name such as 'F:\test files'. The double quote marks are necessary for parsing to treat everything including the spaces between the double quote marks as part of the same parameter $4. (The effect of restricting search to only files and subfolders within a given folder that way would be that renames resulting from this script are also only happen to files in that folder and subfolders.) As another example, to make search case-sensitive, pass "-i" for $4.
# Example that will replace the string "dGSUyfhH" with "Murky_Forest" in all files:
#    everythingRename.sh dGSUyfhH Murky_Forest YOINK
# Example that will delete the string SNAIRFU from all found files:
#    everythingRename.sh SNAIRFU -_-SNIP-_- YOINK
# Example that will change the string "_Palette." (including that period ".") to just "." (a period only), effectively removing the string "_Palette" but keeping the period after it, and only for files within the folder and subfolders of "F:\_ebPalettes\":
#    everythingRename.sh _Palette. . "-path 'F:\_ebPalettes\'"
# ~ ONLY USE THIS SCRIPT IF:
# - You're very sure you know what you're doing
# - You've tested it on disposable files with radically long and complex (will not be any duplicate filenames!) first
# - You're also looking at files found from a search string using Everything, to verify renames and to be able to undo any breaks.
# - You know and can see that there's no funky crap (like terminal-unfriendly characters) in file and folder names you operate on which would cause problems.
# NOTES
# - Renames are logged to a text file named after the date and time the renames were done.
# - Spaces in file names are supported; surround the appropriate parameter with single or double quotes to use spaces.
# - It may rename folders first, which could change the path to any found files that match the search string, causing rename of those files to fail (as the path has changed and the rename command won't find them). In that case, re-running this script with the same search and replace parameters will find them in the new path and rename them.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (search string) passed to script. Exit."; exit 1; else srcString=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (replace string) passed to script. Exit."; exit 2; else destString=$2; fi
	if [ "$destString" == "-_-SNIP-_-" ]; then destString=""; fi
if [ ! "$3" == "YOINK" ]; then printf "\nParameter 3 incorrect. See USAGE comments in script."; exit 3; fi
if [ "$4" ]; then extraSwitches=$4; fi

# build array of file names from search output from everything search ("es" is everything search) :

# IFS trickery to stop spaces in files from mucking with es search; saved by a genius breath yonder -- https://unix.stackexchange.com/a/9500/110338 :
OIFS="$IFS"
IFS=$'\n'

	# print command to a script and run it, as a workaround for these problems:
	# - Without IFS set to a newline, I can use extra switches in the command via $4 surrounded by quote marks (for example "-path 'F:\testFiles'", to restrict search to a specific folder and subfolders).
	# - However, without IFS as a newline I get incorrect array elements if there are spaces in the file names, as it sees the spaces as extra array element delimiters.
	# - But, for whatever reason, even with IFS set to a newline, adding an extra switch via $4 works if I write the command to a temp script and then run the script (and then delete the temp script).
	# That last is a kludge, but it works. SO:
	echo "es $extraSwitches $1" > tmp_everythingRenameScript_neno36mfi.sh
	foundPaths=($(./tmp_everythingRenameScript_neno36mfi.sh))
	rm tmp_everythingRenameScript_neno36mfi.sh

foundPathsArrayLength=${#foundPaths[@]}

if [ $foundPathsArrayLength -gt 0 ]
then
	# build file name for log, and create the log:
	dateTimeString=$(date +"%Y_%m_%d__%H_%M_%S")
	renameLog=_everythingRename_log_"$dateTimeString".txt
	printf "" > $renameLog
else
	printf "\nNo return from Everything search (empty). Write no log. Exit."; exit 4
fi

# iterate over found paths and do rename operation on each, logging each rename to log file, and also printing feedback:
counter=0
for path in ${foundPaths[@]}
do
	counter=$((counter + 1))
	printf "\nWorking on file $counter of $foundPathsArrayLength . . ."
	nixyPath=$(cygpath "$path")
	renameTarget=$(echo "$nixyPath" | sed "s/$srcString/$destString/g")
	mv "$nixyPath" "$renameTarget"
	
	# capture error level and report rename success or fail, depending:
	errorLevelCapture=$(echo $?)
	if [ $errorLevelCapture -eq 0 ]
	then
		printf "\nRENAMED ->\n'$nixyPath'\n  ->\n'$renameTarget'\n<- (logging . . .)\n "
		printf "\nRENAMED ->\n'$nixyPath'\n  ->\n'$renameTarget'\n<-\n" >> $renameLog
	else
		printf "\n ! ERROR attempting rename ->\n'$nixyPath'\n   ->\n'$renameTarget'\n<-\n "
		printf "\n ! ERROR attempting rename ->\n$'nixyPath'\n   ->\n'$renameTarget'\n<-\n" >> $renameLog
	fi
done

IFS="$OIFS"

printf "\nDONE with everythingRename.sh run. Logged in file $renameLog."