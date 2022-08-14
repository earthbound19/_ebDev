# DESCRIPTION
# Copies all files of type $1 (png, jpg etc. -- configurable by first parameter) from all directories one level down up to the current directory. Optionally copies from all subdirectories (recursive). Alternately optionally copies only the first file listed from each subdirectory. See USAGE. Will not copy files from lower directories already found in the current directory. SEE ALSO `moveTypeUp.sh` (identical except it moves files).

# USAGE
# Run with these parameters:
# - $1 The extension of files you wish to copy from subdirectories into the current directory.
# - $2 OPTIONAL. Any word (such as 'FALSNARF'), which will cause the script also to search and copy files up from all subdirectories (all levels down, not just 1 level). To use $3 but not use $2, pass 'NULL' for $2.
# - $3 OPTIONAL. A number, which will cause the script to only copy the Nth ($3) found file from each subdirectory. For example, if you pass 2, it will only copy the 2nd found file from each subdirectory. If omitted, all will be copied.
# Example that will copy all files of type .hexplt from directories one level down (subdirectories, but not their sub-directories) to the current directory:
#    copyTypeUp.sh hexplt
# Example that will copy all files of type .png from all subdirectories (recursive) do this directory:
#    copyTypeUp.sh hexplt FALSNARF
# Example that will copy only the 3rd (3) .png file from the first subdirectory (as it only searches the first subdirectory):
#    copyTypeUp.sh hexplt NULL 3
# Example that will copy the 1st (1) .png file from all subdirectories:
#    copyTypeUp.sh hexplt FALSNARF 1
# NOTES
# - it will not clobber an already existing file. If a file of the same name already exists in the destination (root folder you run this from), that fill will remain and *not* be overwritten from any copy (and possibly different version of the file) found in a subfolder).
# - if you pass something non-numeric for $3, it won't work.
# - if you specify a file number that doesn't exist for $4 (because there are not that many files in a given subfolder), it will fail to copy anything.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (type of file to search for in subdirectories) passed to script. Exit."; exit 1; else searchFileType=$1; fi

subDirSearchParam='-maxdepth 2'
if [ "$2" ] && [ "$2" != "NULL" ]; then subDirSearchParam=''; fi

originalDirectory=$(pwd)
directoriesList=( $(find . $subDirSearchParam -type d -printf "%P\n") )

for directory in ${directoriesList[@]}
do
	pushd . &>/dev/null
	cd $directory
	echo "in: $directory"

	if [ "$3" ]
	then
		filesList=( $(find . -maxdepth 1 -iname \*.$searchFileType -printf "%P\n") )
		cp -n ${filesList[$3]} $originalDirectory
	else
	cp -n *.$searchFileType $originalDirectory
	fi
	
	popd &>/dev/null
done