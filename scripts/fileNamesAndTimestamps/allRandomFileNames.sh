# DESCRIPTION
# Renames all files in the current directory with random character strings of length n (parameter $1, and a default is used if not provided), but with the same file extension.

# WARNINGS
# - Depending on how you use this, it can randomly rename _all_ files in the current directory (non-recursive; it will not rename files in subfolders). It will keep the same file extensions (a file with a .png or .hexplt or any extension will still have that; it will just have a randomly different base file name).
# - Very bad things might happen (e.g. permanent data loss!) if you do not pass parameters as instructed here under USAGE. The script errors out for known scenarios that can lead to that, but I make no guarantees that this script is safe if misused (or even if properly used for that matter).

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. How many random characters to have in each file name (length of file name). If not provided, a default is used.
# - $2 OPTIONAL. Extension of files to randomly rename. Only files with this extension will be renamed. If not provided, or if provided as keyword 'ALL', files of all extensions in the current directory will be randomly renamed.
# - $3 OPTIONAL. Anything, or the word 'NULL.' If provided as anything else (for example the word 'SNAULHORF'), search and random rename is done in all subfolders in the current directory as well. If provided as the word NULL, search and random rename is only done in the current directory.
# - $4 OPTIONAL. Keyword to bypass warnings and do destructive work without warning. ONLY USE THIS in a controlled script after testing on files you can afford to destroy (files that have secure backup somewhere else). If used, it must be the word 'SNEERFBLURN'.
# Example command to rename all files with the extension .hexplt to 20-character random strings:
#    allRandomFileNames.sh 20 hexplt


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

# depthParameter defaults to only the current directory:
depthParameter='-maxdepth 1'
# But if any parameter is passed to this script, it is set to nothing, which will cause "find" to search all subdirectories also:
if [ "$3" ] && [ "$3" != "NULL" ]; then depthParameter=''; fi

if [ ! "$2" ] || [ "$2" == "ALL" ]
then
	fileNamesArray=($(find . $depthParameter -type f -iname "*"))
	fileTypesToRename="*"
fi
if [ "$2" ] && [ "$2" != "ALL" ]
then
	fileNamesArray=($(find . $depthParameter -type f -iname "*.$2"))
	fileTypesToRename=$2
fi

if [ ! "$4" ] || [ "$4" != "SNEERFBLURN" ]
then
	echo ""
	echo "WARNING: This script renames all files of type '*.$fileTypesToRename' with $1"
	echo "random characters. See comments in script for details. If this is not"
	echo "what you want to do, press ENTER or RETURN, or CTRL+C or CTRL+Z. If this"
	echo "_is_ what you want to do, type SNEERFBLURN and then press ENTER or RETURN."
	read -p "TYPE HERE: " SILLYWORD

	if [ ! "$SILLYWORD" == "SNEERFBLURN" ]
	then
		echo ""
		echo Typing mismatch\; exit.
		exit 2
	fi
fi

echo "Keyword "$4" passed to script as parameter 3 OR as password on prompt; continuing . . ."
echo "Will rename all files of type "$fileTypesToRename" in the current directory . . ."
echo "PRESS CONTROL+C OR CTRL+Z to cancel within the next 8 seconds if that is not what you mean to do . . ."
sleep 8

arrSize=${#fileNamesArray[@]}
	# Pregenerate random characters to pull shorter random character strings from:
	# re: http://stackoverflow.com/a/1405641
numRandomCharsToGet=$(( arrSize * getNrandChars ))
	echo numRandomCharsToGet val is $numRandomCharsToGet
export LC_CTYPE=C
randomCharsString=$(cat /dev/urandom | tr -cd 'a-km-np-z2-9' | head -c $numRandomCharsToGet)
	# echo "$randomCharsString . . . that was the value of randomCharsString."

# TO DO: check if the following math is right. I think it isn't, and effectively sets it to $(( getNrandChars * (-1) )) ; although it probably works out for the same intended effect; ALSO SEE rndHexColorsGen.sh for a possibly more elegant way to do this:
# Initialize counter at negative the number of getNrandChars, so that the first iteration in the following loop will set it to 0, which is where we need it to start:
multCounter=-$getNrandChars
	# echo multCounter val is $multCounter
for filename in ${fileNamesArray[@]}
do
	fileExt=${filename##*.}
	# For file renaming, grab next n random characters from pre-generated randomCharsString:
	num=$((multCounter + num2))
		# echo multCounter val is $multCounter
		# echo getNrandChars vlas is $getNrandChars
		multCounter=$(($multCounter + $getNrandChars))
		# echo getNrandChars val is $getNrandChars
		newFileBaseName=${randomCharsString:$multCounter:$getNrandChars}
		pathNoFileName="${filename%\/*}"
		echo "~ Renaming $filename to $pathNoFileName/$newFileBaseName.$fileExt . . ."
	mv $filename $pathNoFileName/$newFileBaseName.$fileExt
done


# DEVELOPMENT HISTORY
# 2021-12-03 Added optional parameter $3 to do search and rename in all subdirectories, and repositioned previous parameter $3 (prompt bypass) to $4. I searched for uses of this script from other scripts, and it shouldn't break anything.
# 2020-09-10 Added optional parameter $3 password to bypass prompts and force destructive work. Upgraded to better command substitution + true arrays.
# 2020-07-09 12:22 Throw errors if non-numeric first parameter and exit. Change default rnd chars retrieved to 8.
# ????-??-?? Made this keep extensions. this is quick and dirty for flam3 files. 06/12/2016 09:15:44 AM -RAH -- DONE 2016-07-16 6:33 PM -RAH
# 2016-07-16 Made script much more efficient by prefetching necessary number of random characters into a variable, and fetching iterative groups of chars from said variable (in memory, instead of using a file on disk). -RAH
# 2018-12-01 11:33 PM Generate file list (fileNamesArray) in memory (skip writing temp files), layout niggles, delete some comments