# DESCRIPTION
# Renames files with random character strings of length n (per paramater passed to script or default 4), preserving file extension.
# TO DO--DONE: make this keep extensions. this is quick and dirty for flam3 files. 06/12/2016 09:15:44 AM -RAH -- DONE 2016-07-16 6:33 PM -RAH

# USAGE
# WARNING: if you do not pass this the correct parameters, it may DELETE files instead of renaming them. RT#M! WARNING: This will randomly rename *all files in a tree* (including subfolders) and move the renamed files to the root folder this script is invoked from.
# Put this script in your $PATH, with these parameters:
# $1 : The length of random characters to rename the file with. If you don't specify any number for the first parameter, it defaults to 4.
# $2 : Optional: a file extension (without any . in it) to restrict random renames to. It will not rename any other file types. If this is not provided, it will rename all file types in the current path.
# NOTE: if you pass parameter 2, you must also pass parameter 1. IF YOU DO NOT DO THIS, IT WILL TRUNCATE ALL FILES OF INTENDED PARAMETER 2 TO TO SIMPLY .[extension], THEREBY DELETING ALL BUT ONE OF THEM (overwriting the same stupid file name with all the other files of that extension).

# TO DO
# Make $2 actually non-optional--it tries operating on all files as ././.. if no param $2.
# Throw an error and exit if non-numeric first parameter passed.
# Throw an error and exit if no files of type parameter 2 found.

# GLOBAL VAR SET; if numeric parameter $1 is passed to script, set $getNrandChars to that; otherwise default it to 4:
if ! [ -z ${1+x} ]
	then
		getNrandChars="$1"
				echo parameter passed to script\; will set getNrandChars to passed value of $1.
	else
		getNrandChars=4
				echo no parameter passed to script\; using default value of \4 for getNrandChars.
fi
		# echo val of 1 is $1.

if ! [ -z ${2+x} ]
	then
		find ./*.$2 > files_list.txt
	else
		find ./* > files_list.txt
fi

mapfile -t array < files_list.txt
rm files_list.txt

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
# 2016-07-16 Made script much more efficient by prefetching necessary number of random characters into a variable, and fetching iterative groups of chars from said variable (in memory, instead of using a file on disk). -RAH