# DESCRIPTION
# Collates documentation comments from all code/script files in the current directory and subdirectories into one file: _ebDevDocumentation.txt. For easier documentation reference. Uses a custom but dead simple documentation convention. See USAGE.

# USAGE
# In so many code/script files in this directory and subdirectories, document each file respectively about itself, for example with comments headed DESCRIPTION, USAGE, WARNINGS, DEPENDENCIES, NOTES, etc.--or however else you want to document them--up to a line which must have only the word CODE on it, with nothing else besides whitespace and the comment delimiter before or after that word (no punctuation, either). Then, from this directory, invoke this script:
#  makeDocumentation.sh
# It searches all code/script files in this directory and subdirectories for documentation comments, and collates all such comments into one large file (referenceing the source file for each comment), with the domment delimiters stripped. Results are in _ebDevDocumentation.txt
# NOTE: that file is expected to be large and freuntly changing, so is is not stored in the repository. Periodic updates of it may be posted to s.earthbound.io/_ebDevDoc.

# CODE
currentDir=`pwd`
currentDirBasename=`basename $currentDir`
# create array of all source code / script file names of given types in this directory and subdirectories; -printf "%P\n" removes the ./ from the front; re: https://unix.stackexchange.com/a/215236/110338 -- ALSO NOTE: if I use any printf command, it only lists findings for that associated -o option; so printf must be used for every -o; ALSO, the gsord and sed pipes sort scripts by time stamp, newest first:
sourceCodeFilesArray=(` find . -type f -name '*.sh' -printf "%P\n" -o -name '*.py' -printf "%P\n" | gsort -n | sed 's/.*[AM|PM] \.\/\(.*\)/\1/g'`)

# BEGIN check all files for CODE comment, and warn and exit on first one that doesn't:
errorFiles=()
foundErrorFile=0
printf "" > log_SrKw5ECDBXvyQ4M7zAeb8kVC_files_without_CODE_delimiter.txt
for fileNameWithPath in ${sourceCodeFilesArray[@]}
do
	# re: https://stackoverflow.com/a/35900771/1397555
	# prints 0 (from $?) if the word CODE is in the file; 1 if not:
	# grep -q CODE test.txt
	# echo $?
	# Works as hoped! :
	grep -q "^#[[:blank:]]*CODE$" $fileNameWithPath
	error_level=`echo $?`
	if [ $error_level -eq 1 ]
	then foundErrorFile=1
		echo "PROBLEM! $fileNameWithPath does not have a CODE section delimiter! Will log . . ."
		fileNameToLog=`basename $fileNameWithPath`
		printf "$fileNameToLog\n" >> log_SrKw5ECDBXvyQ4M7zAeb8kVC_files_without_CODE_delimiter.txt
	fi
done
if [ $foundErrorFile -eq 1 ]
then
	printf "!!------------!!\n\nPROBLEM: One or more files was found without a CODE section delimiter comment. List is in log_SrKw5ECDBXvyQ4M7zAeb8kVC_files_without_CODE_delimiter.txt. Put this comment on the appropriate line (where working code begins) in each of those files:\n\n# CODE\n\n--and run this script again when those are all fixed. If you want paths with those files, comment out the line of code that invokes basename in variable assignment to fileNameToLog, and run this script again.\n\nExiting script.\n\n"
	exit
else
	# no need for log file (and it will be empty); so delete it:
	rm log_SrKw5ECDBXvyQ4M7zAeb8kVC_files_without_CODE_delimiter.txt
fi
# END check all files for CODE comment
echo "WILL CONTINUE coding when I hae all good files to work with . . ."
exit

for fileNameWithPath in ${sourceCodeFilesArray[@]}
do
	printf "## $fileNameWithPath\n\n" > tmp_making_documentation_CVxfP4qT_scriptTitleSection.txt
	# Find line number of CODE comment:
	scriptFile="imgAndVideo/color_growth.py"
	lineNumber=`awk -v search="^#[[:blank:]]*CODE$" '$0~search{print NR; exit}' $fileNameWithPath`
	# use that line number minus one to print everything up to it to a temp file:
	lineNumber=$(($lineNumber - 1))
	head -$lineNumber $fileNameWithPath > tmp_making_documentation_CVxfP4qT.txt
	# clear trailing multiple newlines (blank lines):
	sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' tmp_making_documentation_CVxfP4qT.txt
	# strip #-style comments (bash, Python) delimiter and whitespace character (only one each if they appear, not all of them) from start of line:
	sed -i 's/^[# ].//g' tmp_making_documentation_CVxfP4qT.txt
	# strip """ docstring delimiters (Python) from start of lines:
	sed -i 's/^"""//g' tmp_making_documentation_CVxfP4qT.txt
done
