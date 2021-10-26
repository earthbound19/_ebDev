# DESCRIPTION
# For all files of a given type (parameter $1) in the current directory (and optionally all subdirectories), moves them into a new subdirectory (in the immediate folder) named after that type. Creates that subfolder only if it does not already exist, and moves files to them only if they do not already exist. SEE ALSO `allToTypeFolders.sh`.

# USAGE
# Run with these parameters:
# - $1 file type to sort into a subfolder named after it, for example 'png'.
# - $2 OPTIONAL. Any string (for example 'EKTHELPOI'), which will cause the script to search subfolders also for files of type $1.
# - $3 OPTIONAL. Any string (for example 'EKTHELPOI ON THE FLORF', which will bypass the prompt to type a password 
# Example that will sort all files with the extension .png into a new subfolder named png/ :
#    moveToTypeFolder.sh png
# Example that will sort all file with the extension .hexplt in the current folder and all subfolders into a new directory named /hexplt:
#    moveToTypeFolder.sh hexplt EKTHELPOI


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (type of file to sort into subdirectory named after file type) passed to script. Exit."; exit 1; else fileType=$1; fi

if [ ! -e $fileType ]; then mkdir $fileType; fi

subDirSearchParam='-maxdepth 1'
if [ "$2" ]; then subDirSearchParam=''; fi

# If this operates on a super duper long list of files, and I store that all in an array, it will probably throw an error about something being too long, unless I print the results to a file and scan it line by line. So use a file:
find . $subDirSearchParam -iname \*.$fileType -printf "%P\n" > filesOfTypeList_tmp_kPRvCkMt
while read file
do
	if [ -e "$fileType/$file" ]
	then
		printf "\nTARGET EXISTS already for move $fileType/$file. Skipping."
	else
		mv $file "$fileType/"
		printf "\nMoved file $file to folder '/$fileType'."
	fi
done < filesOfTypeList_tmp_kPRvCkMt

rm ./filesOfTypeList_tmp_kPRvCkMt