# DESCRIPTION
# For all files of type $1 in the current directory for which a file of type $2 with the same base name (but different extension $2) exists, deletes the file match of type $2. DESTRUCTIVE; deletion is permanent. Prompts to be sure you want to do so.

# DEPENDENCIES
# `listMatchedFileNames.sh`

# USAGE
# Run with these parameters:
# - $1 source file type (extension) to find corresponding files with the same base file name but extension $2
# - $2 search file type (extension) to delete if matches (same base file name) found for type $1.
# - $3 OPTIONAL. Any string (such as 'foo'), which will cause the script to search through subfolders for matches and delete them also.
# For example, if you have source art files like this:
#    BSaST_v1.4.6_seed_443511296_cols_14_bgHex_F0CCC4_frame_893.png
#    BSaST_v1.4.6_seed_443511296_cols_14_bgHex_F0CCC4_frame_893.svg
#    BSaST_v1.4.6_seed_596689152_cols_4_bgHex_91BACB_frame_1304.png
#    BSaST_v1.4.6_seed_596689152_cols_4_bgHex_91BACB_frame_1304.svg
#    BSaST_v1.4.6_seed_657348608_cols_7_bgHex_C97B8E_frame_423__user_interacted.png
#    BSaST_v1.4.6_seed_657348608_cols_7_bgHex_C97B8E_frame_423__user_interacted.svg
#    BSaST_v1.4.6_seed_657348608_cols_7_bgHex_C97B8E_frame_4312__user_interacted.png
#    BSaST_v1.4.6_seed_657348608_cols_7_bgHex_C97B8E_frame_4312__user_interacted.svg
# -- and you want to delete all of the png file pairs (which are renders from the svg files, taking up more space, being raster images), run:
#    deleteMatchedFiles.sh svg png
# -- and the script will delete all of those png files which are matches (have the same base file name as the svg files), after prompting to confirm you want to delete all such png files.


# CODE
if [ "$1" ]; then sourceExtension=$1; else printf "\nNo parameter \$1 (source extension type to find matches of) passed to script. Exit."; exit 1; fi
if [ "$2" ]; then extensionToDelete=$2; else printf "\nNo parameter \$2 (extension type to delete base file name matches of type \$1) passed to script. Exit."; exit 2; fi

# PROMPT AND GIVEN PASSWORD CHECK; EXIT ON PASSWORD FAIL
if [ "$3" ]; then recursiveString=" ALSO, it will do this recursively (through all subdirectories under the current directory)."; fi
read -p "NOTE: For all files of type $sourceExtension in the current directory for which a file of type $extensionToDelete with the same base name (but different extension $extensionToDelete) exists, this script will delete the file match of type $extensionToDelete.$recursiveString THIS IS DESTRUCTIVE AND IRREVIRSIBLE; deletion is permanent. To continue, type the word SNURFL. To cancel, type anything else or press ENTER: " SILLYWORD
if [ "$SILLYWORD" != "SNURFL" ]; then echo "Word entered did not match; exit."; exit 3; fi

# Make an array which has only one item: "." for the current directory (if using the command `cd`). If parameter $3 passed to script, add to that array all subfolder relative paths. In both cases, iterating over all directories will iterate over every directory we want to:
allSubfolderNames=()
allSubfolderNames+='.'
if [ "$3" ]; then allSubfolderNames+=($(find . -type d -printf "%P\n")); fi

baseDir=$(pwd)
for folderName in ${allSubfolderNames[@]}
do
	# change to the subfolder, redirecting print output to nowhere:
	cd $folderName &>/dev/null
	currDir=$(pwd)
	echo "~"
	echo "in dir $currDir"
	allFilesType=( $(find . -maxdepth 1 -iname "*.$sourceExtension" -printf "%P\n") )
	for file in ${allFilesType[@]}
	do
		echo --
		echo checking for matches of $file with extension $extensionToDelete . . .
		files=($(listMatchedFileNames.sh $file))
		for j in ${files[@]}
		do
			# check if extension is same as $extensionToDelete; if so, DELETE! -- as we know it exists, because listMatchedFileNames.sh listed it among existing files!
			if [ ${j##*.} == $extensionToDelete ]
			then
				echo "MATCH:                  $j; will delete!"
				rm $j
			fi
		done
	done
	# change back to the original base foldere from which the next relative directory change (next loop iteration) will be correct:
	cd $baseDir &>/dev/null
done