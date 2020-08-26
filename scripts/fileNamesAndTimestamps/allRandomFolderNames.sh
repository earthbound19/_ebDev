# DESCRIPTION
# Renames all folders in the current directory (but not subfolders; non-recursive) with random characters to length $1.

# USAGE
# Run with one parameter:
# - $1 OPTIONAL. how many random characters to have in the random strings which folders will be renamed to. If not provided, a default number is used.
# Example that will will rename all folders (non-recursive) with 34 random characters:
#    allRandomFolderNames.sh 34


# CODE
# GLOBAL VAR SET; if numeric parameter $1 is passed to script, set $getNrandChars to that; otherwise default it to 4:
if [ "$1" ]; then getNrandChars="$1"; echo parameter passed to script\; will set getNrandChars to passed value of $getNrandChars.; else getNrandChars=6; echo no parameter passed to script\; using default value of $getNrandChars for getNrandChars.; fi

find ./* -type d > allDirs.txt
mapfile -t array < allDirs.txt
rm allDirs.txt

arrSize=${#array[@]}

	# Pregenerate random characters to pull shorter random character strings from:
	# re: http://stackoverflow.com/a/1405641
	numRandomCharsToGet=`echo $(( arrSize * getNrandChars ))`
		# echo numRandomCharsToGet val is $numRandomCharsToGet
	randomCharsString=`cat /dev/urandom | tr -cd 'a-km-np-zA-KM-NP-Z2-9' | head -c $numRandomCharsToGet`
		# echo randomCharsString val is $randomCharsString
# Initialize counter at negative the number of getNrandChars, so that the first iteration in the following loop will set it to 0, which is where we need it to start:
multCounter=-$getNrandChars
for folderName in ${array[@]}
do
			# echo folderName is $folderName
		multCounter=$(($multCounter + $getNrandChars))
		newFolderName=${randomCharsString:$multCounter:$getNrandChars}
	mv $folderName $newFolderName
done