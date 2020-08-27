# DESCRIPTION
# Helps discard files in the current folder (non-recursive) with a given extension that have no companion file with the same file but a different extension. Does this by moving the identified files into a temp folder for review before permanent and manual deletion. See NOTES.

# WARNING
# If you use this on files with unintended dissimilar base file names such as thisFractalRenderFlame.flame.png (two periods in the file extension), you will lose work!

# USAGE
# See the above WARNING!
# Scenario: suppose you have a set of render source or configuration files (in my case it might be files of extension .cgp, or .hexplt) for which you have rendered targets (e.g. .png images of color growth script settings or palettes). You may then go through and delete the .png results you don't like, and run this script to move all the associated .cgp or .hexplt files into a temp folder. You can then review the files in the temp folder and manually delete them. The parameter format in more of a sentence form is:
#    pruneByUnmatchedExtension.sh FileTypeToMove ifNoMatchedFileOfThisType
# For example, this command will sort every file with the extension .hexplt that has no same-named file (same basename) with a .png extension into a temporary folder for manual analysis and deletion or recovery:
#    pruneByUnmatchedExtension.sh hexplt png
# Here is a more detailed example. Suppose you have so many .ppm files which you have converted to .png:
#    img_01.ppm
#    img_01.png
#    img_02.ppm
#    img_02.png
#    img_03.ppm
#    img_03.png
#    img_04.ppm
#    img_04.png
# Suppose you want to delete some of the source .ppm files because you viewed the pngs resulting from converting them, and you don't like them. First delete the rendered pngs you don't like, so that you have these files left: 
#    img_01.ppm
#    img_02.ppm
#    img_02.png
#    img_03.ppm
#    img_03.png
#    img_04.ppm
# Then run this script with parameters that tell this script $1 the source file extension to search for matching file names with extension $2, where $1 will be deleted if no file with extension $2 is found.
# Example command:
#    pruneByUnmatchedExtension.sh ppm png
# When this script is run, these ppm files that had no png with the same base file name will be sorted into a folder with a name that includes some random characters, like ___delete_candidates_tmp__BB01BF75857DDFE0:
#    img_02.ppm
#    img_02.png
#    img_03.ppm
#    img_03.png
# You may then manually check them and delete them after you are sure you don't want them.

# KEYWORDS
# orphan, unmatched, unpaired, no pair, extension, prune, delete, not found, pair


# CODE
# TO DO: handle and use DIRECTORY parameters in this (with folder _moves_) also, as in listUnmatchedExtensions.sh. Be careful in development; figure out how to move directories into subdirectories correctly (dunnae how at this writing).
if ! [ "$1" ]
then
	echo "No parameter \$1 passed to script. Exit."
	exit
fi
if ! [ "$2" ]
then
	echo "No parameter \$2 passed to script. Exit."
	exit
fi

list=$(find . -maxdepth 1 -type f -iname \*.$1 -printf '%f\n' | tr -d '\15\32')

RND16HEX=`cat /dev/urandom | tr -dc '0-9A-F' | head -c 16`
delete_candidates_temp_folder=___delete_candidates_tmp__"$RND16HEX"
mkdir $delete_candidates_temp_folder

for element in ${list[@]}
do
	fileNameNoExt=${element%.*}
	searchFileName="$fileNameNoExt"."$2"
			# echo searchFileName is\: $searchFileName
	if ! [ -f $searchFileName ]
	then
		echo "File matching source file name $element but with $2"
		echo " extension NOT FOUND\: SORTING into folder"
		echo " $delete_candidates_temp_folder"
		mv $element ./$delete_candidates_temp_folder
	fi
done

echo ""
echo "DONE. All files proposed for deletion have been moved"
echo " to the folder $delete_candidates_temp_folder."
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo " WARNING: please be very sure you have not renamed any"
echo " associated e.g. render or target files to something"
echo " that does not match a source/configuration file before"
echo " you delete them!"
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"