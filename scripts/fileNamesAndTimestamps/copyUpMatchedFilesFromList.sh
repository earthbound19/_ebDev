# DESCRIPTION
# Finds all files (recursively) with a name containing the same base file name as all files listed in file $1, and copies them up from subfolders into the current directory. Uses include copying preset files that accompany copied (favorite) renders. Will not clobber files in the current directory that already exist.

# USAGE
# Run with these parameters:
# - $1 the file name of the list of files to find pairs or matches for in subdirectories (and copy them up to this directory).
# For example:
#    copyUpMatchedFilesFromList.sh possible_color_pairs_from_RAH_favorite_colors_2_combos.txt
# EXAMPLE USAGE SCENARIO
# - Render so many png images from presets
# - Open all result renders in a thumbnail image navigator like IrfanView
# - Copy favorites to the project parent folder via IrfanView functionality that allows that (sorry, not detailing that)
# - Run a command like this to list all those copied renders to a text file:
#        ls *.png > favorites.txt
# - Run the following command (assuming this script is in your PATH) to copy associated render configuration etc. files up from the subfolders:
#    copyUpMatchedFilesFromList.sh favorites.txt
# - Sort all those copied files into another folder for further work

# KEYWORDS
# pair, matched, copy, up, file list


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (file name of the list of files to find pairs or matches for in subdirectories (and copy them up to this directory)) passed to script. Exit."; exit 1; else fileList=$1; fi

arrayOfFileNames=($(<$fileList))
for fileName in ${arrayOfFileNames[@]}
do
	fileNameNoExt=${fileName%.*}
	echo "Searching for matches for $fileNameNoExt . . ."
	matchedFiles=$(find . -iname "*$fileNameNoExt*" -type f)
	for match in ${matchedFiles[@]}
	do
		# construct file name without path for found match . . .
		fileNameNoPath="${match##*/}"
		echo $fileNameNoPath
		# . . . and check if it already exists here, and if so, don't copy it:
		if [ -e $fileNameNoPath ]
		then
			echo "File $fileNameNoPath already exists here. Will not clobber; skipping . . ."
		else
			echo "Copying match file $match here . . ."
			cp $match .
		fi
	done
done
