# DESCRIPTION
# Takes a list of files and searches for all files with the same file name (found everywhere on the computer that the Everything search engine searches), and copies the first found file with the same name into the current directory. Skips if the file name already exists in the current directory.

# DEPENDENCIES
# - Voidtools "Everything" search engine, working and showing files you search for correctly, and accompanying es (CLI tool for it) in you PATH
# - A bash environment such as MSYS2

# USAGE
# Run with these parameters:
# - $1 file name of text file which is only a list of file names without paths, one file per line.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (name of text file with a list of file names) passed to script. Exit."; exit 1; else srcFileList=$1; fi

# build array of file names from source file:
OIFS="$IFS"
IFS=$'\n'
srcFiles=( $(<$srcFileList) )

# iterate over array doing Everything search for each file name and copying the first found file to the current directory, no-clobber (don't overwrite existing files) :
for srcFile in ${srcFiles[@]}
do
		echo "  Working with '$srcFile' . . ."
	# make an array of file names found from an Everything search for it;
	# the -a-d switch restricts results to files only (no folders) ; the tr statement deletes windows-style newlines, which throw win-ported GNU tools out of whack:
# IF USED: the -double-quote switch would be to try to work around problems of terminal-unfriendly characters like spaces in file names; but I seem to have gotten it working well without that:
	foundFiles=( $(es -a-d $srcFile | tr -d '\15\32') )
	# get the full path to the first found file name from the array:
	fullPath="${foundFiles[0]}"
		# echo "      fullPath $fullPath"
	# get only the file name with no path from that, adding single quote marks around it:
	fileNameNoPath=\'${foundFiles[0]##*\\}\'
		# echo fileNameNoPath $fileNameNoPath
	# use that file name without path to see if the same file name exists in the current directory; if it does not, copy it here and print feedback of that, otherwise do nothing:
	if [ ! -f ./$fileNameNoPath ]
	then
		echo "----------file $fileNameNoPath from $fileNameNoPath not found in current directory; copying here . . ."
		cp $fullPath .
	fi
done
IFS="$OIFS"