# DESCRIPTION
# For all files of a given type (parameter $1) in the current directory (and optionally all subdirectories), moves them into a new subdirectory (in the immediate folder) named after the base file name, an underscore, and the file extension. Creates such subfolders only if they do not already exist, and moves files to them only if they do not already exist (will not clobber pre-existing files). SEE ALSO `moveToTypeFolder.sh`.

# USAGE
# Run with these parameters:
# - $1 file type to sort (every one of) into a subfolder named after the base of the file, for example 'hexplt'.
# - $2 OPTIONAL. Any string (for example 'EKTHELPOI'), which will cause the script to operate also on subfolders which contain type $1.
# Example that will sort all files with the extension .hexplt into new subfolders named after the files:
#    moveTypeToBasenamedFolder.sh hexplt
# Example that will sort all files with the extension .hexplt in the current folder and all subfolders into a new director(ies) named after the files:
#    moveTypeToBasenamedFolder.sh hexplt EKTHELPOI


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (type of file to sort into subdirectories named after every file of that type) passed to script. Exit."; exit 1; else fileType=$1; fi

subDirSearchParam='-maxdepth 1'
if [ "$2" ]; then subDirSearchParam=''; fi

# If this operates on a super duper long list of files, and I store that all in an array, it will probably throw an error about something being too long, unless I print the results to a file and scan it line by line. So use a file:
find . $subDirSearchParam -iname \*.$fileType -printf "%P\n" > filesOfTypeList_tmp_fZagq34GD
while read file
do
	fileNameNoExt=${file%.*}
	fileExt=${file##*.}
	subfolderName="$fileNameNoExt"_"$fileExt"
	if [ ! -e $subfolderName ] && [ ! -e $subfolderName/$file ]
	then
		mkdir $subfolderName
		mv $file ./$subfolderName
	else
		printf "\nSUBFOLDER $subfolderName OR MOVE TARGET $subfolderName/$file already exists; will not clobber."
	fi
done < filesOfTypeList_tmp_fZagq34GD

rm ./filesOfTypeList_tmp_fZagq34GD