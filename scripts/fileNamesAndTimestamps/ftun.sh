# DESCRIPTION
# Replaces terminal-unfriendly characters in all files of type $1
# in the current directory. If $1 is not provided, does this to
# ALL files in the current directory.
# Why ftun.sh? FTUN stands for "Fix Terminal Unfriendly [folder
# and file] Names." Terminal-unfriendly charactrers in file names
# are any character that may make a script choke if you attempt
# to pass a file name (or folder name) containing them to a script.
# Characters I consider unfriendly (but which may not all actually
# cause problems) are (with maybe more problematic ones first) :
# '@=`~!#$%^&()+[{]};. ,-
# In my opinion it is also undesirable to have a . character
# in the middle of a file name.

# DEPENDENCIES
# Perl, and rename.pl from http://plasmasturm.org/code/rename/rename
# in your PATH, and a 'nixy environment.

# USAGE
#  The following assumes this script is in you PATH.
#   From a terminal, in a folder with terminal-processing-unfriendly
#   names, execute this script, optionally with one parameter, being
#   the extension of every file you wish to rename. For example,
#   for all png images, run:
# ftun.sh png
#  To operate on ALL files (regardless of extension), run this
#   script withuot any parameter:
# ftun.sh


if [ "$1" ]
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

if [ $USERINPUT == $PASS_STRING ]
then
	echo "User input equals pass string; proceeding."
	pathToRenamePerl=`which rename.pl`
		# Option that removes dashes also:
		# perl $pathToRenamePerl -e 's/[^\w.]+/_/g' $extension
	perl $pathToRenamePerl -e 's/[^\w.-]+/_/g' $extension
else
	echo "User input does not equal $PASS_STRING."
	echo "script will exit without doing anything."
fi



# DEV NOTES:
# How to figure out which characters need escaping for a script of
# a given type: type them into your text editor, and save the file
# with the intended batch script extension. The characters not
# recognized as part of a string show in a non-string-highlight color,
# e.g. :
# \`\~\!\@#\$\%\^\&\*\(\)\-\=\+\[\{\]\}\;\'\,\ \.

# Example command that WORKS as far as demonstrating replacing characters:
# echo A\`\~\!\@#\$\%\^\&\*\(\)\-\=\+\[\{\]\}\;\'\,\ \.B | tr \`\~\!\@#\$\%\^\&\*\(\)\-\=\+\[\{\]\}\;\'\,\ \. _