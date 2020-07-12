# DESCRIPTION
# Renames files with random character strings of length n (per paramater passed to script or default 4), preserving file extension.

# USAGE
# WARNING: This will randomly rename all files in the current directory (non-recursive; it will not rename files in subfolders). It will keep the same file extensions (a file with a .png or .hexplt or any extension will still have that; it will just have a randomly different base file name).
# Invoke with these parameters:
# - $1 OPTIONAL. How many random characters to have in each file name (length of file name). If not provided, a default is used.
# - $2 OPTIONAL. Extension of files to randomly rename. Only files with this extension will be renamed. If not provided, files of all extensions in the current directory will be randomly renamed.
# WARNING: very bad things might happen (e.g. permanent data loss!) if you do not pass parameters as instructed here under USAGE. The script errors out for at least some scenarios to prevent that though.
# Example command to rename all files with the extension .hexplt to 20-character random strings:
#  allRandomFileNames.sh 20 hexplt


# CODE
# GLOBAL VARS SET:
# if positional parameter 1 is passed to script, check if it is not numeric and throw an error if it is. If it is numeric, use it. If no parameter $1 is passed at all, use a default value and continue.
if [ "$1" ]
then
	# Throw an error and exit if $1 is not numeric; re: https://stackoverflow.com/a/806923
	re='^[0-9]+$'
	if ! [[ $1 =~ $re ]] ; then
	   echo "Error: parameter \$1 not a number. Pass a numer value (number of random characters to rename files to) for first parameter."
	   exit 1
	else
		getNrandChars="$1"
		echo "Parameter passed to script; will set getNrandChars to passed value of \$1 ($1)."
	fi
else
	getNrandChars=4
		echo "No parameter \$1 passed to script\; using default value of 8 for getNrandChars."
fi
if [ "$2" ]
	then
		array=(`find . -maxdepth 1 -type f -iname \*.$2 -printf '%f\n'`)
		fileTypesToRename=$2
	else
		array=(`find . -maxdepth 1 -type f -iname \* -printf '%f\n'`)
		fileTypesToRename="*"
fi


# CODE
echo ""
echo "WARNING: This script renames all files of type '*.$fileTypesToRename' with $1"
echo "random characters. See comments in script for details. If this is not"
echo "what you want to do, press ENTER or RETURN, or CTRL+C or CTRL+Z. If this"
echo "_is_ what you want to do, type SNEERFBLURN and then press ENTER or RETURN."
read -p "TYPE HERE: " SILLYWORD

if ! [ "$SILLYWORD" == "SNEERFBLURN" ]
then
	echo ""
	echo Typing mismatch\; exit.
	exit
else
	echo continuing . .
fi

arrSize=${#array[@]}

	# Pregenerate random characters to pull shorter random character strings from:
	# re: http://stackoverflow.com/a/1405641
numRandomCharsToGet=`echo $(( arrSize * getNrandChars ))`
	# echo numRandomCharsToGet val is $numRandomCharsToGet
export LC_CTYPE=C
randomCharsString=`cat /dev/urandom | tr -cd 'a-km-np-zA-KM-NP-Z2-9' | head -c $numRandomCharsToGet`
	# echo randomCharsString val is $randomCharsString

# TO DO: check if the following math is right. I think it isn't, and effectively sets it to $(( getNrandChars * (-1) )) ; although it probably works out for the same intended effect; ALSO SEE rndHexColorsGen.sh for a possibly more elegant way to do this:
# Initialize counter at negative the number of getNrandChars, so that the first iteration in the following loop will set it to 0, which is where we need it to start:
multCounter=-$getNrandChars
	# echo multCounter val is $multCounter
for filename in ${array[@]}
do
	fileExt=${filename##*.}
	# For file renaming, grab next n random characters from pre-generated randomCharsString:
	num=$((multCounter + num2))
		# echo multCounter val is $multCounter
		# echo getNrandChars vlas is $getNrandChars
		multCounter=$(($multCounter + $getNrandChars))
		# echo getNrandChars val is $getNrandChars
		newFileBaseName=${randomCharsString:$multCounter:$getNrandChars}
		echo "~ Renaming $filename to $newFileBaseName"."$fileExt . . ."
	mv ./$filename ./$newFileBaseName.$fileExt
done


# DEVELOPMENT HISTORY
# 2020-07-09 12:22 Throw errors if non-numeric first parameter and exit. Change default rnd chars retrieved to 8.
# ????-??-?? Made this keep extensions. this is quick and dirty for flam3 files. 06/12/2016 09:15:44 AM -RAH -- DONE 2016-07-16 6:33 PM -RAH
# 2016-07-16 Made script much more efficient by prefetching necessary number of random characters into a variable, and fetching iterative groups of chars from said variable (in memory, instead of using a file on disk). -RAH
# 2018-12-01 11:33 PM Generate file list (array) in memory (skip writing temp files), layout niggles, delete some comments