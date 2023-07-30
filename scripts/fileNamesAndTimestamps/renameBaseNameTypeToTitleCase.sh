# DESCRIPTION
# Renames all files in the current directory of type $1 such that their base file name is in Title Case. (This could possibly theoretically be done via rename.pl, but I didn't figure out how.) Optionally does so through all subdirectories also.

# USAGE
# Run with these parameters:
# - $1 extension of files to rename
# - $2 OPTIONAL. Anything, for example the word YOOZ, which will cause search and rename operations to be performed in all subdirectories also. If omitted, defaults to only work in the current directory.
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
# Example that will do the same through all subdirectories also:
#    renameBaseNameTypeToTitleCase.sh hexplt YOOZ
# KNOWN ISSUE
# Fails on file names with spaces in them, which you probably don't want in an environment where you manipulate them with scripts anyway.


# CODE
if [ "$1" ]; then fileTypeToRename=$1; else printf "\nNo parameter \$1 (extension of files to rename) passed to script. Exit."; exit 1; fi
# if no parameter $2 passed to script, set a variable used to pass the maxdepth switch setting it to 1 (search the current directory only). This way if no parameter $2 is passed, only the current directory will be searched, and if parameter $2 _is_ passed, maxdepthParameter will be effectively nothing (undefined), which will cause a default of searching all subfolders.
if [ ! "$2" ]; then maxdepthParameter='-maxdepth 1'; fi

filesToRename=($(find . $maxdepthParameter -iname "*.$fileTypeToRename" -printf '%P\n'))

for filename in ${filesToRename[@]}
do
	echo renaming $filename . . .
	fileNameNoExt=${filename%.*}
	fileExt=${filename##*.}
	newFileNameNoExt=$(echo "$fileNameNoExt" | sed 's/\<.\|_./\U&/g')
	mv $filename $newFileNameNoExt.$fileExt
done