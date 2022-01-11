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
# Example that will replace the string "dGSUyfhH" with "Murky_Forest" in all files:
#    everythingRename.sh dGSUyfhH Murky_Forest YOINK
# Example that will delete the string SNAIRFU from all found files:
#    everythingRename.sh SNAIRFU -_-SNIP-_- YOINK
# DON'T DO THIS UNLESS:
# - You're very sure you know what you're doing
# - You've tested it on disposable files with radically long and complex (will not be any duplicate filenames!) first
# - You're also looking at files found from a search string using Everything, to verify renames and to be able to undo any breaks.
# - You know and can see that there's no funky crap (like terminal-unfriendly characters) in file and folder names you operate on.
# NOTES
# - Renames are logged to a text file named after the date and time the renames were done.
# - Spaces in file names are supported; surround the appropriate parameter with single or double quotes to use spaces.

# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source string) passed to script. Exit."; exit 1; else srcString=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (destination string) passed to script. Exit."; exit 2; else destString=$2; fi
	if [ "$destString" == "-_-SNIP-_-" ]; then destString=""; fi
if [ ! "$3" == "YOINK" ]; then printf "\nParameter 3 incorrect. See USAGE comments in script."; exit 3; fi

# build array of file names from search output from everything search ("es" is everything search) :

# IFS trickery to stop spaces in files from mucking with es search; saved by a genius breath yonder -- https://unix.stackexchange.com/a/9500/110338 :
OIFS="$IFS"
IFS=$'\n'
foundPaths=( $(es $1) )

# build file name for log, and create the log:
dateTimeString=$(date +"%Y_%m_%d__%H_%M_%S")
renameLog=_everythingRename_log_"$dateTimeString".txt
printf "" > $renameLog

# iterate over found paths and do rename operation on each, logging each rename to log file, and also printing feedback:
for path in ${foundPaths[@]}
do
	nixyPath=$(cygpath $path)
	renameTarget=$(echo $nixyPath | sed "s/$srcString/$destString/g")
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