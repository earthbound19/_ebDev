# DESCRIPTION
# Lists all files of type $1 in the current directory for which there are NOT file type $2 pairs (files with the same file name base). Can also search for unmatched _directory_ names for $1 or $2 (see USAGE). May help for e.g. manually re-starting renders from source configuration files (by identifying render configuration files which have no corresponding render target file, and/or missing intended directory target names).

# USAGE
# Run with these parameters:
#    listUnmatchedExtensions.sh sourceFileType missingPairFileTypeToList
# For example, if you are rendering so many images from `color_growth.py` preset files (which have the `.cgp` extension), and want to list all `.cgp` files that have no corresponding `.png` file of the same name, you would run:
#    listUnmatchedExtensions.sh cgp png
# To count how many unmatched extensions there are, pipe it to wc with a flag:
#    listUnmatchedExtensions.sh cgp png | wc -l
# NOTES
# - You may pass the word DIRECTORY as either the sourceFileType OR missingPairFileTypeToList, and the script will search for and print what is not matched to source or target directories with the same base file name, respectively.
# - SEE ALSO `listMatchedFileNames.sh` and `listMatchedFileNamesOfType.sh`.

# KEYWORDS
# orphan, unmatched, unpaired, no pair, extension, not found, pair


# CODE
# DEVELOPER NOTES:
# To test every possible type of combination of parameters to this script, these are the parameter pairs:
# cgp cgp
# cgp png
# DIRECTORY cgp
# cgp DIRECTORY

# PARAMETER CHECKING / ASSIGNMENT
if ! [ "$1" ]
then
	echo "No parameter \$1 passed to script. Exit."
	exit
else
	srcFileType=$1
fi
if ! [ "$2" ]
then
	echo "No parameter \$2 passed to script. Exit."
	exit
else
	targetType=$2
fi

if [ "$srcFileType" == "$targetType" ]			# ex. case cgp cgp, or DIRECTORY DIRECTORY
then
	echo "I don't think you meant those inputs (both source and target types are $srcFileType). Exit";
	exit 1
fi

# MAIN LOGIC
if [ "$srcFileType" == "DIRECTORY" ]
then
	sourceTypes=($(find . -type d -printf '%f\n'))
	# slice off the first element of that resulting array, which is `.`:
	sourceTypes=(${sourceTypes[@]:1})
else
	sourceTypes=($(find . -maxdepth 1 -name "*.$srcFileType" -printf '%f\n'))
fi

if [ ! "$srcFileType" == "DIRECTORY" ]
then
	for element in ${sourceTypes[@]}
	do
		fileNameNoExt=${element%.*}
		if [ "$targetType" == "DIRECTORY" ]		# ex. case cgp DIRECTORY
		then
			if [ ! -d $fileNameNoExt ]
			then
				echo $element
			fi
		else									# ex. case cgp png
			searchFileName="$fileNameNoExt"."$targetType"
			if [ ! -f $searchFileName ]
			then
				echo $element
			fi
		fi
	done
# NOTE: logical equivalent here is "if $srcFileType is DIRECTORY:"
else											# ex. case DIRECTORY cgp
	for element in ${sourceTypes[@]}
	do
		# echo $element
		fileNameWithTargetTypeAdded="$element"."$targetType"
		# printf "\nChecking for NON-EXISTENCE of $fileNameWithTargetTypeAdded . . ."
		if [ ! -e $fileNameWithTargetTypeAdded ]
		then
			echo $fileNameWithTargetTypeAdded
		fi
	done
fi