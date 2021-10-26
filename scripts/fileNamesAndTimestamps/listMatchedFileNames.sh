# DESCRIPTION
# For file $1 (parameter to script), prints all other files _and directories_ in the current directory which have the basename of $1 as part of their file name. Optionally recursive, also. For example, if $1 is `fBnhR9Ar.hexplt`, this script will list all other files and/or folders that contain the string `fBnhR9Ar`. May be used for example to identify whether render configuration or source files have matched targets derived of their file name (if your process makes render targets have file names that indicate their source). If this script prints anything, there is a match. If it doesn't print anything, there is no match.

# USAGE
# Run with these parameters:
# - $1 File type to search for matches of.
# - $2 OPTIONAL. Any string (such as 'foo'), which will cause the script to search through subfolders for matches also.
# EXAMPLES
# To print files and folders in the current directory that include the base name of r8e9E62z.hexplt (which is r8e9E62z) in their file name, run:
#    listMatchedFilenames.sh r8e9E62z.hexplt
# To print files and folders in the current directory and subdirectories that include the base name of YWgZmFP3.hexplt (which is YWgZmFP3) in their file name, run:
#    listMatchedFilenames.sh YWgZmFP3.hexplt foo

# KEYWORDS
# match, pair, target, orphan, unmatched, unpaired, extension, found


# CODE
if ! [ "$1" ]
then
	echo "No parameter \$1 passed to script (file name to find matches for or identify that there are no matches). Exit."
	exit 1
else
	srcFile=$1
fi

subDirSearchFlag='-maxdepth 1'
if [ "$2" ]
	then
	subDirSearchFlag=''
fi

fileNameNoExt=${srcFile%.*}

fileMatches=( $(find . $subDirSearchFlag -iname "*$fileNameNoExt*" -printf "%P\n") )

# Print all elements except for the one which is the source file name (which ends up in that array):
for file in ${fileMatches[@]}
do
	if [ "$file" != "$srcFile" ]
	then
		echo $file
	fi
done
