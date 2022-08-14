# DESCRIPTION
# Moves all files of type $1 (png, jpg etc. -- configurable by first parameter) from all directories one level down up to the current directory. Optionally copies from all subdirectories (recursive). See USAGE. Will not move files from lower directories already found in the current directory. SEE ALSO `copyTypeUp.sh` (identical except it copies files).

# USAGE
# Run with these parameters:
# - $1 The extension of files you wish to move from subdirectories into the current directory.
# - $2 OPTIONAL. Any word (such as 'FALSNARF'), which will cause the script also to search and move files up from all subdirectories (all levels down, not just 1 level).
# Example that will move all files of type .hexplt from directories one level down (subdirectories, but not their sub-directories) to the current directory:
#    moveTypeUp.sh hexplt
# Example that will move all files of type .png from all subdirectories (recursive) do this directory:
#    moveTypeUp.sh hexplt FALSNARF


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (type of file to search for in subdirectories) passed to script. Exit."; exit 1; else searchFileType=$1; fi

subDirSearchParam='-maxdepth 2'
if [ "$2" ]; then subDirSearchParam=''; fi

currentDir=$(pwd)

echo ""
echo "WARNING: this script is about to move all files with extension $searchFileType, from all subfolders, up into the folder $currentDir. If this is not what you want, press CTRL+C or ENTER. If this _is_ what you want, type GLOR and then press ENTER or RETURN."
read -p "TYPE HERE: " SILLYWORD

if ! [ "$SILLYWORD" == "GLOR" ]
then
	echo ""
	echo Typing mismatch\; exit.
	exit
else
	echo continuing . .
fi

filesList=( $(find . $subDirSearchParam -iname \*.$searchFileType -printf "%P\n") )
for fileNameWithPath in ${filesList[@]}
do
	fileNameNoPath="${fileNameWithPath##*/}"
	# If the target file already exists, print a notice and skip move. Otherwise move the source file here:
	if [ $fileNameWithPath == $fileNameNoPath ]
	then
		printf "$fileNameNoPath exists here already. Will not move.\n"
	else
		mv $fileNameWithPath .
	fi
done