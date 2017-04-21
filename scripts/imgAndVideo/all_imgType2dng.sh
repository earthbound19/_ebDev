# DESCRIPTION
# Converts all files of a given type in your current path to Adobe digital negatives (.dng).

# USAGE
# Call this script with one parameter $1, being a file type in the directory from which you run this script--a file type for which all thing whom what this yes you wish to convert to Adobe digital negatives format (.dng), e.g.:
# thisScript.sh CR2

for element in *.$1
do
# TO DO: check if target file exists (get base file name of element first), then only create it if it doesn't.
	AdobeDNGConverter.exe -c -p2 -fl -cr5.4 $element
done



# in 
# out 2:50