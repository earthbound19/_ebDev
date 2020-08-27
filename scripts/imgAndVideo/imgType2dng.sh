# DESCRIPTION
# Calls img2dng for every file of type $1 in the current directory.

# USAGE
# Call this script with one parameter $1, being a file type in the directory from which you run this script--a file type for which all thing whom what this yes you wish to convert to Adobe digital negatives format (.dng), e.g.:
#    all_imgType2dng.sh CR2


# CODE
imgs=($(find . -maxdepth 1 -iname \*.$1))
for fileName in ${imgs[@]}
do
	elementBaseName="${fileName%.*}"
	if [ -f "$elementBaseName".dng ]
	then
		echo Would-be target file "$elementBaseName".dng already exists\; will not re-create.
	else
		echo "$elementBaseName".dng does not exist\; will execute dng conversion command.
		img2dng.sh $elementBaseName
	fi
done