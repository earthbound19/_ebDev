# DESCRIPTION
# Renames files with random character strings of length n (per paramater passed to script or default 4), preserving file extension.
# TO DO--DONE: make this keep extensions. this is quick and drity for flam3 files. 06/12/2016 09:15:44 AM -RAH -- DONE 2016-07-16 6:33 PM -RAH

# USAGE
# Put this script in your $PATH. From a directory in which you wish to rename all file names with n random characters (per optional parameter), invoke this script thusly:
# thisScriptName.sh 34
# --where you can change that number to specify how many random characters you want in the new file name. If you don't specify any number, it defaults to 4

# GLOBAL VAR SET; if numeric parameter $1 is passed to script, set $getNrandChars to that; otherwise default it to 4:
if ! [ -z ${1+x} ]; then echo parameter passed to script\; will set getNrandChars to passed value of $1.; getNrandChars="$1"; else getNrandChars=4; echo no parameter passed to script\; using default value of \4 for getNrandChars.; fi
		# echo val of 1 is $1.

ls > allFiles.txt
mapfile -t array < allFiles.txt
rm allFiles.txt

arrSize=${#array[@]}
# echo arrSize val is $arrSize

	# Pregenerate random characters to pull shorter random character strings from:
	# re: http://stackoverflow.com/a/1405641
	numRandomCharsToGet=`echo $(( arrSize * getNrandChars ))`
		# echo numRandomCharsToGet val is $numRandomCharsToGet
	randomCharsString=`cat /dev/urandom | tr -cd 'a-km-np-zA-KM-NP-Z2-9' | head -c $numRandomCharsToGet`
		# echo randomCharsString val is $randomCharsString

# TO DO: check if the following math is right. I think it isn't, and effectively sets it to $(( getNrandChars * (-1) )) ; although it probably works out for the same intended effect; ALSO SEE rndHexColorsGen.sh for a possibly more elegant way to do this:
# Initialize counter at negative the number of getNrandChars, so that the first iteration in the following loop will set it to 0, which is where we need it to start:
multCounter=-$getNrandChars
	# echo multCounter val is $multCounter
for filename in ${array[@]}
do
		# Get file extension, re: http://stackoverflow.com/a/30863119/1397555
		# Extension (all) : '1.0.1.tar.gz'
			# DEPRECATED; apparently less portable:
			# fileExt=`echo "$filename" | awk '\{sub(/[^.]*[.]/, "", $0)\} 1'`
		fileExt=`echo "$filename" | sed 's/.*\.\([^\.]*\)/\1/g'`
			# echo fileExt val is $fileExt
		# For file renaming, grab next n random characters from pre-generated randomCharsString:
		# num=$(($multCounter + $num2))
			# echo multCounter val is $multCounter
			# echo getNrandChars vlas is $getNrandChars
		multCounter=$(($multCounter + $getNrandChars))
			# echo getNrandChars val is $getNrandChars
		newFileBaseName=${randomCharsString:$multCounter:$getNrandChars}
			# echo ~----- "renaming $filename to $newFileBaseName"."$fileExt"
	mv ./$filename ./$newFileBaseName.$fileExt
done


# DEVELOPMENT HISTORY
# Prior to now: script that was inefficient by reading 4 bytes from /dev/urandom with every single file rename.
# 2016-07-16 Made script much more efficient by prefetching necessary number of random characters into a variable, and fetching iterative groups of chars from said variable. -RAH