# DESCRIPTION
# Renames folders with random character strings of length n (per paramater passed to script or default 4), preserving file extension.

# USAGE
# Put this script in your $PATH. From a directory in which you wish to rename all directories (in the current directory--this is not recursive) with n random characters (per optional parameter), invoke this script thusly:
#  allRandomFolderNames.sh 34
# --where you can change that number to specify how many random characters you want in the new file name. If you don't specify any number, it defaults to 4.

# GLOBAL VAR SET; if numeric parameter $1 is passed to script, set $getNrandChars to that; otherwise default it to 4:
if [ "$1" ]; then echo parameter passed to script\; will set getNrandChars to passed value of $1.; getNrandChars="$1"; else getNrandChars=4; echo no parameter passed to script\; using default value of \4 for getNrandChars.; fi
		# echo val of 1 is $1.

gfind ./* -type d > allDirs.txt
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