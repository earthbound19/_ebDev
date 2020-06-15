# DESCRIPTION
# Lists all files of type $1 in the current directory for which there
# is no file type $2 with the same file name base. May help for e.g.
# manually re-starting renders from source configuration files (by
# identifying render configuration files which have no corresponding
# render target file). See USAGE notes.

# USAGE
# With this script in your PATH:
# listUnmatchedExtensions.sh sourceExtensionFormat targetExtensionFormat
# For example, if you are rendering so many images from color_growth.py-
# compatible .cgp files, and want to list all .cgp files that have no
# corresponding .png file of the same name:
# listUnmatchedExtensions.sh cgp png

# KEYWORDS
# orphan, unmatched, unpaired, no pair, extension, not found, pair

# CODE
if ! [ "$1" ]
then
	echo "No parameter \$1 passed to script. Exit."
	exit
else
	srcExtension=$1
fi
if ! [ "$2" ]
then
	echo "No parameter \$2 passed to script. Exit."
	exit
else
	targetExtension=$2
fi

sourceExtensions=(`gfind . -name "*.cgp" -printf '%f\n'`)

echo "List of files of type $1 for which there is no corresponding file of type $2:"
for element in ${sourceExtensions[@]}
do
	# echo $element
	fileNameNoExt=${element%.*}
	searchFileName="$fileNameNoExt"."$2"
	if ! [ -f $searchFileName ]
	then
		echo $element
	fi
done