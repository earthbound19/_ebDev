# DESCRIPTION
# Converts all files of a given type in your current path to Adobe digital negatives (.dng).

# USAGE
# Call this script with one parameter $1, being a file type in the directory from which you run this script--a file type for which all thing whom what this yes you wish to convert to Adobe digital negatives format (.dng), e.g.:
#  ./all_imgType2dng.sh CR2


gfind . -iname \*.$1 > all_wut.txt
while read element
do
# TO DO: check if target file exists (get base file name of element first), then only create it if it doesn't.
	elementBaseName="${element%.*}"
	if [ ! -f "$elementBaseName".dng ]
	then
		echo "$elementBaseName".dng does not exist\; will execute dng conversion command.
		# NOTE if you add the -e switch it will embed the original raw (/CR2 etc) file in the dng.
		command="AdobeDNGConverter.exe -c -fl -cr5.4 $element"
		echo running command\: $command
		echo . . .
		$command
	else
		echo Would-be target file "$elementBaseName".dng already exists\; will not re-create.
	fi
done < all_wut.txt

rm ./all_wut.txt