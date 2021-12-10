# DESCRIPTION
# For all files of a given type (parameter $1) in the current directory (and optionally all subdirectories), moves them into a new subdirectory (in the immediate folder) named after that type. Creates that subfolder only if it does not already exist, and moves files to them only if they do not already exist. SEE ALSO `allToTypeFolders.sh`.

# USAGE
# Run with these parameters:
# - $1 file type to sort into a subfolder named after it, for example 'png'.
# - $2 OPTIONAL. Any string (for example 'EKTHELPOI'), which will cause the script to search subfolders also for files of type $1.
# Example that will sort all files with the extension .png into a new subfolder named png/ :
#    toTypeFolder.sh png
# Example that will sort all file with the extension .hexplt in the current folder and all subfolders into a new directory named /hexplt:
#    toTypeFolder.sh hexplt EKTHELPOI


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (type of file to sort into subdirectory named after file type) passed to script. Exit."; exit 1; else fileType=$1; fi

subDirSearchParam='-maxdepth 1'
if [ "$2" ]; then subDirSearchParam=''; fi

# Previously I've been concerned about encountering a "parameter list too long" or similar error, but I'm not seeing that now, and not concerned with it since I bypass inline expansion by surrounding the search string in double quotes; re: https://unix.stackexchange.com/a/421699/110338
fileNamesArray=( $(find . $subDirSearchParam -iname "*.$fileType" -printf "%P\n") )
# check if array is not empty (array length is not zero); only do work if it is not (because if it is empty, no file of type $fileType is in the current directory, so we don't want to make an empty directory that this script won't populate) :
if [ ${#fileNamesArray[@]} -ne 0 ]
then
	if [ ! -e $fileType ]; then mkdir $fileType; fi

	for file in ${fileNamesArray[@]}
	do
		if [ -e "$fileType/$file" ]
		then
			printf "\nTARGET EXISTS already for command mv $fileType/$file. Skipping."
		else
			mv $file "$fileType/"
			printf "\nMoved file $file to folder '/$fileType'."
		fi
	done
fi