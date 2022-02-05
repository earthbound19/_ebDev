# DESCRIPTION
# Calls img2dng.sh for every file of type $1 in the current directory. But that script is DEPRECATED; the functional code of it is commented out and you'll accomplish nothing by calling that script from this one unless you uncomment the functional code in that one.

# USAGE
# Call with on parameter, which is:
# - $1 file extension for which you wish to pass every file of that type in this directory to img2dng.sh. For example:
#    imgType2dng.sh CR2
# -- will cause this script to call img2dng.sh once for every file of type .CR2 in the current directory.


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