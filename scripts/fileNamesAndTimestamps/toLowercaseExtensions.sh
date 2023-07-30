# DESCRIPTION
# Renames all extensions of all files of type $1 in the current directory, which have any uppercase letters in them (such as PNG), to lowercase (png). Optionally does this to all files of every type, also optionally to all subdirectories of the current folder.

# USAGE
# Run with these parameters:
# - $1 File type to make all found files lowercase. You may type this in any letter case or combinations of them, such as png, PNG, or Png, and it will search case-insensitive (it will find extensions of any case combination), and replace extensions with lowercase. To work on all file extensions, pass this as the keyword 'ALL_EXTENSIONS'.
# - $2 OPTIONAL. Any string (such as 'foo'), which will cause the script to search and rename in all subfolders also.
# EXAMPLES
# To rename all PNG files in the current directory which have have uppercase letters in their extensions to all lowercase in their extensions, run:
#    toLowercaseExtensions.sh png
# To rename all files with every extension that has uppercase letters in them to lowercase, run:
#    toLowercaseExtensions.sh ALL_EXTENSIONS
# To rename all MOV files in the current directory and all subdirectories which have any uppercase letters in their extension to lowercase, run:
#    toLowercaseExtensions.sh mov foo
# To rename all extensions with uppercase letters in all file types in the current directory and all subdirectories (to all be lowercase), run:
#    toLowercaseExtensions.sh ALL_EXTENSIONS foo


# CODE
if ! [ "$1" ]
then
	echo "No parameter \$1 passed to script (file extension to search for, or keyword 'ALL'). Exit."
	exit 1
else
	fileExt=$1
fi
if [ "$1" == "all_extensions" ] || [ "$1" == "ALL_EXTENSIONS" ]
then
	fileExt=*
fi

subDirSearchFlag='-maxdepth 1'
if [ "$2" ]
	then
	subDirSearchFlag=''
fi

fileMatches=( $(find ~+ $subDirSearchFlag -iname "*.$fileExt" -type f) )
for filename in ${fileMatches[@]}
do
	# check if extension is all-lowercase, and if not, rename it to so:
	# - get extension
	originalFileExt=${filename##*.}
	# - convert it to lowercase (a wasted operation if it already is) :
	lowerCasedFileExt=$(echo "$originalFileExt" | tr '[:upper:]' '[:lower:]')
	# if those don't match, we know the original has uppercase letters, so rename the file:
	if [ "$originalFileExt" != "$lowerCasedFileExt" ]
	then
		fileNameNoExt=${filename%.*}
		newFileName=$fileNameNoExt.$lowerCasedFileExt
		echo RENAMING $filename to $newFileName . . .
		mv $filename $newFileName
	fi
done
