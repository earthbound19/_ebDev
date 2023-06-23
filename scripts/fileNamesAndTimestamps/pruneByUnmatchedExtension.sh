# DESCRIPTION
# Helps sort files in the current folder (non-recursive) with a given extension that have no companion file of the same name but a different extension. Does this by moving the identified files into a temp folder for review (for example either to delete them or files that didn't match their sort criteria). See NOTES.

# WARNING
# If you use this on files with unintended dissimilar base file names such as thisFractalRenderFlame.flame.png (two periods in the file extension), you will lose work!

# USAGE
# See the above WARNING!
# Run with these parameters:
# - $1 REQUIRED. File type to move (every one of) into a sorting folder if no pair with the same filename but different extension is found.
# - $2 REQUIRED. Extension of pair files to look for.
# - OPTIONAL. Any word, such as FRONPL, which will cause the script to repeat the operation through every subfolder (in every subfolder, it will search for files with unmatched extensions and move them into a new randomly named sorting subfolder). If this is omitted, work will only be done (and one sorting sub-folder made) in the current folder, and not in subfolders.
# So, the parameter format more concisely described is:
#    pruneByUnmatchedExtension.sh FileTypeToMove ifNoMatchedFileOfThisType
# For example, suppose you have a set of render source or configuration files (in my case it might be files of extension .cgp, or .hexplt) for which you have rendered targets (e.g. .png images of color growth script settings or palettes). You may then go through and delete the .png results you don't like, and run this script to move all the associated .cgp or .hexplt files into a temp folder. You can then review the files in the temp folder to be sure you want to manually delete them.
# The following example will find with the extension .hexplt for which no file with the same base file name but with a .png extension, and move those .hexplt format files into a temporary folder for review (and possible delete or recovery):
#    pruneByUnmatchedExtension.sh hexplt png
# To do the same in every subfolder (making sorting sub-sub-folders along the way), run:
#    pruneByUnmatchedExtension.sh hexplt png FRONPL
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
# Then run this script with ppm for $1 (source file extension to search for file pairs of), and png for $2, where all $1 will be deleted if no pair with extension $2 is found:
#    pruneByUnmatchedExtension.sh ppm png
# When this script is run, these ppm files that had no png with the same base file name will be sorted into a folder with a name that includes some random characters, like ___file_sorting_tmp__BB01BF75857DDFE0:
#    img_02.ppm
#    img_02.png
#    img_03.ppm
#    img_03.png
# You may then manually check them and delete them after you are sure you don't want them.
# Or alternately, this may be used to isolate files that don't meet that sort criteria (files that are _not_ in the ___file_sorting_tmp__~ folder).

# KEYWORDS
# orphan, unmatched, unpaired, no pair, extension, prune, delete, not found, pair, sort, filter


# CODE
if ! [ "$1" ]; then	echo "No parameter \$1 (source file type) passed to script. Exit."; exit 1; fi
if ! [ "$2" ]; then	echo "No parameter \$2 (extension of matches to search for and move $1 if no match) passed to script. Exit."; exit 2; fi
# Make an array which has only one item: "." for the current directory (if using the command `cd`). If parameter 3 passed to script, add to that array all subfolder relative paths. In both cases, iterating over all directories will iterate over every directory we want to:
allSubfolderNames=()
allSubfolderNames+='.'
if [ "$3" ]
then
	allSubfolderNames+=($(find . -type d -printf "%P\n"))
fi

baseDir=$(pwd)
for folderName in ${allSubfolderNames[@]}
do
	# change to the subfolder, redirecting print output to nowhere:
	cd $folderName &>/dev/null
	echo "Working in folder $folderName."
	list=$(find . -maxdepth 1 -type f -iname \*.$1 -printf '%f\n' | tr -d '\15\32')

	RND16HEX=`cat /dev/urandom | tr -dc '0-9A-F' | head -c 16`
	sort_folder_name=___file_sorting_tmp__"$RND16HEX"
	mkdir $sort_folder_name

	for element in ${list[@]}
	do
		fileNameNoExt=${element%.*}
		searchFileName="$fileNameNoExt"."$2"
				# echo searchFileName is\: $searchFileName
		if ! [ -f $searchFileName ]
		then
			echo "File matching source file name $element but with $2"
			echo " extension NOT FOUND\: SORTING into folder"
			echo " $sort_folder_name"
			mv $element ./$sort_folder_name
		fi
	done

	echo ""
	echo "DONE working un folder $folderName. All files proposed for deletion have"
	echo "been moved to the folder $sort_folder_name."
	echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo " WARNING: please be very sure you have not renamed any"
	echo " associated e.g. render or target files to something"
	echo " that does not match a source/configuration file before"
	echo " you delete them!"
	echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
	# change back to the original base foldere from which the next relative directory change (next loop iteration) will be correct:
	cd $baseDir &>/dev/null
done