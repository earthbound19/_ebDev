# DESCRIPTION
# Replaces terminal-unfriendly characters in all files of a given type (parameter 1) in the current directory, via rename.pl. If $1 is not provided, does this to ALL files in the current directory. Why ftun.sh? FTUN stands for "Fix Terminal Unfriendly [folder and file] Names." Terminal-unfriendly characters in file names are any character that may make a script choke if you attempt to pass a file name (or folder name) containing them to a script. See NOTES under USAGE.

# DEPENDENCIES
# Perl, and `rename.pl` (from http://plasmasturm.org/code/rename/rename) in your PATH, and a Unix or emulated Unix environment.

# USAGE
# From a terminal, in a folder with terminal-unfriendly file or folder names, execute with these parameters:
# - $1 OPTIONAL. File extension without . in it, for example png. Causes script to rename all file names with that extension. To rename all files of every type (`.txt`, `.png`, `.hexplt`, `.ttf`, or whatever -- everything found), pass the keyword 'ALL'.
# - $2 OPTIONAL. Anything (for example the word 'SNORFBLARN'). Causes script to rename all files of type $1 in all subdirectories also.
# Example that would rename all files with the .png extension to terminal-friendly names:
#    ftun.sh png
# Example that would rename all files (regardless of extension):
#    ftun.sh ALL
# Example that would operate on all png files in the current directory and all subdirectories:
#    ftun.sh png SNORFBLARN
# Example that would operate on all files of every type found in the current directory and all subdirectories:
#    ftun.sh ALL SNORFBLARN
# NOTES
# - Characters I consider unfriendly (but which may not all actually cause problems) are (with maybe more problematic ones first) : ``@=\`~!#$%^&()+[{]}; ,-``
# - Also, in my opinion it is undesirable to have a . character in the middle of a file name (a file extension with two or more dots in it).


# CODE
# DEV NOTES:
# How to figure out which characters need escaping for a script of a given type: type them into your text editor, and save the file with the intended batch script extension. The characters not recognized as part of a string show in a non-string-highlight color, e.g. :
# \`\~\!\@#\$\%\^\&\*\(\)\-\=\+\[\{\]\}\;\'\,\ \.

# Example command that WORKS as far as demonstrating replacing characters:
# echo A\`\~\!\@#\$\%\^\&\*\(\)\-\=\+\[\{\]\}\;\'\,\ \.B | tr \`\~\!\@#\$\%\^\&\*\(\)\-\=\+\[\{\]\}\;\'\,\ \. _
if [ "$1" ] && [ "$1" != "ALL" ]
then
	extension=\*\.$1
else
	extension=\*
fi

PASS_STRING="YARSH"

echo ""
echo "WARNING: this script will rename every file in the current"
echo " directory, and which has the extension:"
echo ""
echo "$extension"
echo ""
echo " --so that the file name only contains alphanumeric characters,"
echo " periods . and dashes - (if the file name originally contains"
echo " any periods or dashes). If the extension this printout"
echo " reported is an asterisk * it will ALSO do this to folder"
echo " names in this directory. If this is what you want, type:"
echo ""
echo "$PASS_STRING"
echo ""
echo "--and then press ENTER (or return, as the case may be)."
echo "If that is NOT what you want to do, press CTRL+z or CTRL+c,"
echo " or type something else and press ENTER, to terminate this"
echo "script."

read -p "TYPE HERE: " USERINPUT

if [ $USERINPUT != $PASS_STRING ]
then
	echo "User input does not equal $PASS_STRING. Script will exit without doing anything."
	exit 1
fi

echo "User input equals pass string. Will proceed."
pathToRenamePerl=$(getFullPathToFile.sh rename.pl)
# echo $pathToRenamePerl
# exit
# TO DO: make this work with all these characters, if it doesn't:
# '@=`~!#$%^&()+[{]};. ,-
perl $pathToRenamePerl -g -e 's/[^\w.-]+/_/g' \"$extension\"

# If $2 was passed to script, recurse through subdirectories and also rename all files of type $extension:
if [ "$2" ]
then
	directories=( $(find . -type d) )
	# remove the first element in that array by reassigning to itself without that:
	directories=(${directories[@]:1})

	for element in ${directories[@]}
	do
		pushd . >/dev/null
		cd $element
		echo "Working in directory: $element . . ."
# TO DO: make this work with all these characters, if it doesn't:
# '@=`~!#$%^&()+[{]}; ,-
		perl $pathToRenamePerl -g -e 's/[^\w.-]+/_/g' \"$extension\"
		popd >/dev/null
	done
fi