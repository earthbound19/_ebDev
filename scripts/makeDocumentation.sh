# DESCRIPTION
# Collates documentation comments from all code/script files in the current directory and subdirectories into one file: _ebDevDocumentation.txt. For easier documentation reference. Uses a custom but dead simple documentation convention. See USAGE.

# USAGE
# In so many code/script files in this directory and subdirectories, document each file respectively about itself, for example with comments headed DESCRIPTION, USAGE, WARNINGS, DEPENDENCIES, NOTES, etc.--or however else you want to document them--up to a line which must have only the word CODE on it, with nothing else besides whitespace and the comment delimiter before or after that word (no punctuation, either). Then, from this directory, invoke this script:
#  makeDocumentation.sh
# It searches all code/script files in this directory and subdirectories for documentation comments, and collates all such comments into one large file (referenceing the source file for each comment), with the domment delimiters stripped. Results are in _ebDevDocumentation.txt
# NOTE: that file is expected to be large and freuntly changing, so is is not stored in the repository. Periodic updates of it may be posted to s.earthbound.io/_ebDevDoc.

# CODE
#currentDir=`pwd`
#currentDirBasename=`basename $currentDir`
# create array of all source code / script file names of given types in this directory and subdirectories; -printf "%P\n" removes the ./ from the front; re: https://unix.stackexchange.com/a/215236/110338 -- ALSO NOTE: if I use any printf command, it only lists findings for that associated -o option; so printf must be used for every -o:
#sourceCodeFilesArray=(` gfind . -type f -name '*.sh' -printf "%P\n" -o -name '*.py' -printf "%P\n"`)
#for fileNameWithPath in ${sourceCodeFilesArray[@]}
#do
#	echo "fileNameWithPath: $fileNameWithPath"
#done

# Find line number of CODE comment:
lineNumber=`awk -v search="^#[[:blank:]]*CODE$" '$0~search{print NR; exit}' imgAndVideo/ffmpegAnim.sh`
# use that line number minus one to print everything up to it to a temp file:
lineNumber=$(($lineNumber - 1))
head -$lineNumber imgAndVideo/ffmpegAnim.sh > tmp_making_documentation_CVxfP4qT.txt
# clear trailing multiple newlines (blank lines):
sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' tmp_making_documentation_CVxfP4qT.txt
# strip comments delimiter and whitespace character (only one each if they appear, not all of them) from start of line:
sed -i 's/^[# ].//g' tmp_making_documentation_CVxfP4qT.txt