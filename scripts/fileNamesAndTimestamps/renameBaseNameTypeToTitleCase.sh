# DESCRIPTION
# Renames all files in the current directory of type $1 such that their base file name is in Title Case. This could possibly theoretically be done via rename.pl, but I didn't figure out how.

# USAGE
# Run with these parameters:
# - $1 extension of files to rename
# For example, if you have files with these names in the current directory (and these are only horrible random example file names) :
#    winter_sunrise_260ft.hexplt
#    soil_pigments.hexplt
#    soil_pigments_2-combo_001.hexplt
# -- and you wish to capitalize the first letter of every word in their base file name (meaning before the .hexplt file extenison), run this command, where $1 is hexplt:
#    renameBaseNameTypeToTitleCase.sh hexplt
# -- and it will rename those files to:
#    Winter_Sunrise_260Ft.hexplt
#    Soil_Pigments.hexplt
#    Soil_Pigments_2-Combo_001.hexplt
# Note that in this case, you'll want to manually then repair ~Ft (for feet) to ~ft.


# CODE
if [ "$1" ]; then fileTypeToRename=$1; else printf "\nNo parameter \$1 (extension of files to rename) passed to script. Exit."; exit 1; fi

filesToRename=($(find . -maxdepth 1 -iname "*.$fileTypeToRename" -printf '%P\n'))

for filename in ${filesToRename[@]}
do
	echo renaming $filename . . .
	fileNameNoExt=${filename%.*}
	fileExt=${filename##*.}
	newFileNameNoExt=$(echo "$fileNameNoExt" | sed 's/\<.\|_./\U&/g')
	# echo was $fileNameNoExt
	# echo now $newFileNameNoExt
	mv $filename $newFileNameNoExt.$fileExt
done