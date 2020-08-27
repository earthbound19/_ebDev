# DESCRIPTION
# Copies all files of type $1 (png, jpg etc. -- configurable by first parameter) from all directories one level down up to the current directory. Optionally copies from all subdirectories (recursive). See USAGE. Will not copy files from lower directories already found in the current directory. SEE ALSO `moveTypeUp.sh` (identical except it moves files).

# USAGE
# Run with these parameters:
# - $1 The extension of files you wish to copy from subdirectories into the current directory.
# - $2 OPTIONAL. Any word (such as 'FALSNARF'), which will cause the script also to search and copy files up from all subdirectories (all levels down, not just 1 level).
# Example that will copy all files of type .hexplt from directories one level down (subdirectories, but not their sub-directories) to the current directory:
#    copyTypeUp.sh hexplt
# Example that will copy all files of type .png from all subdirectories (recursive) do this directory:
#    copyTypeUp.sh hexplt FALSNARF


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (type of file to search for in subdirectories) passed to script. Exit."; exit 1; else searchFileType=$1; fi

subDirSearchParam='-maxdepth 2'
if [ "$2" ]; then subDirSearchParam=''; fi

# If this operates on a super duper long list of files, and I store that all in an array, it will probably throw an error about something being too long, unless I print the results to a file and scan it line by line. So use a file:
find . $subDirSearchParam -iname \*.$searchFileType -printf "%P\n" > filesOfTypeList_tmp_ut9NaYAH.txt
while read fileNameWithPath
do
	fileNameNoPath="${fileNameWithPath##*/}"
	# If the target file already exists, print a notice and skip copy. Otherwise copy the source file here:
	if [ $fileNameWithPath == $fileNameNoPath ]
	then
		printf "$fileNameNoPath exists here already. Will not copy.\n"
	else
		cp $fileNameWithPath .
	fi
done < filesOfTypeList_tmp_ut9NaYAH.txt

rm filesOfTypeList_tmp_ut9NaYAH.txt