# DESCRIPTION
# Solves a problem of source and associated file names that are far too long and make file systems choke.* For all files in the current directory of type $1, finds all other files that have the same base file name, and renames the file with its matches to have the shortened base file name, $2 characters long (plus 8 random chracters to avoid file name conflicts). Does this via original logic and another script. Renames preserve the left-hand side of a name (the right is truncated).

# WARNING
# Does not check for duplicate file names, but designs around that by sufficient file rename entropy. Still, there's a vanishingly small chance it can clobber other files by override of duplicate generated file name.

# DEPENDENCIES
# `listMatchedFileNames.sh`

# USAGE
# Run with these parameters:
# - $1 file type to find matches of via `listMatchedFileNames.sh`.
# - $2 OPTIONAL. How many chracters to shorten source and match file names to. Minimum 25 strongly recommended. If not provided, default of 36 is used.
#    scriptFileName.sh parameterOne
# NOTE
# *This script was made by necessity of renaming files that a renderer made way, way too long: 146+ characters! Nobody needs that. Around 30 to 40 characters can be plenty. File or path names that are excessively long can cause weird, mystifying errors in Windows. Instead of complaining that paths are too long, for example, in some contexts Windows simply fails to read files, or gives weird ill-conceived security warning popups.

# CODE
if [ "$1" ]; then fileTypeToMatch=$1; else printf "\nNo parameter \$1 (file type to find matches of.) passed to script. Exit."; exit 1; fi
if [ "$2" ]; then shortenToNchars=$2; else shortenToNchars=36; fi

filesToMatch=($(find . -maxdepth 1 -iname \*.$fileTypeToMatch -printf "%P\n"))
for fileToMatch in ${filesToMatch[@]}
do
	echo ----
	echo working on $fileToMatch and finding any matches and renaming them also . . .
	# get RND string that will be used in renaming original file and matches:
	RNDstr=$(cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 9)

	# rename fileToMatch (because it will not be included in the list fileMatches) ;
	# construct new file name for fileToMatch:
	fileNameNoExt=${fileToMatch%.*}
	fileExt=${fileToMatch##*.}
	fileToMatchNewName="${fileToMatch:0:$shortenToNchars}"__$RNDstr.$fileExt
	# do the actual rename:
	mv $fileToMatch $fileToMatchNewName

	# get list of matched files to rename:
	fileMatches=($(listMatchedFileNames.sh $fileToMatch))
	# $ rename those matched files:
	for fileMatch in ${fileMatches[@]}
	do
		echo fileMatch is $fileMatch
		# construct new file name for fileMatch:
		fileNameNoExt=${fileMatch%.*}
		fileExt=${fileMatch##*.}
		newFileName="${fileNameNoExt:0:$shortenToNchars}"__$RNDstr.$fileExt
		# echo fileNameNoExt is $fileNameNoExt
		# echo fileExt is $fileExt
		# echo newFileName is $newFileName
		echo RENAMING $fileMatch to $newFileName . . .
		mv $fileMatch $newFileName
	done
done

echo DONE.