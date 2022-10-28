# DESCRIPTION
# Searches the operating system PATH for a script file name $1 (parameter 1) and prints the full path to it if found. First tries `which`, which is a lot faster, and if that fails, searches every directory in $PATH. Can help other scripts find the full path to a script they rely on and use, if they capture and utilize the printed output from this.

# USAGE
# Suppose you have a script that calls other scripts which you know are in your PATH, but it's inconvenient and/or impractical to hard-code the full path to those other scripts in your script. On top of that, the `which` and `realpath` commands fail to find a file which you know exists in your $PATH on MSYS2 (and maybe other emulated Unix-like environments).
# Run this script with these parameters:
# - $1 the file name of a script you want the full path to
# For example, if the script you want the full path to is color_growth.py, run this script with only that, like this:
#    getFullPathToScript.sh color_growth.py
# If this script finds the full path to it, it will print it, e.g.:
#    /c/_ebDev/scripts/imgAndVideo/color_growth.py
# You may exploit this print from any other script that wants that full path, by assigning it to a variable. For example, in another script, you might do this:
#    pathToScript=$(getFullPathToScript.sh color_growth.py)
#    python $pathToScript $colorGrowthPyParameters
# NOTES
# - this script was created because the `which` command apparently doesn't actually search every directory in the $PATH on MSYS2, or if it does, something with it is broken on my setup for some files I try to find with it.
# - ther may be many possible solutions for utility path searching and command information lookup (or something like that??) for shells, some of which (ha) may better address the problem than the way this script did, re: https://unix.stackexchange.com/questions/85249/why-not-use-which-what-to-use-then


# CODE
if ! [ "$1" ]; then printf "\nNo parameter \$1 (script file name to find the full path to) passed to script. Exit."; exit; else fileNameToFind=$1; fi
# If `which` works, it is _much_ faster, so try it first:

# Note to self: 2>/dev/null redirects stderror if there are errors; if there are not errors it will not redirect, but will print to stdout:
fullPathToFile=$(which $fileNameToFind 2>/dev/null)
# The preceding command will cause $fullPathToFile to be blank if no useful result was found, but if the result was useful it will be non-blank. So, if non-blank, print and exit. Otherwise do nothing and fall through to the remainder of the script that uses a slower search method than `which`:
if [ "$fullPathToFile" != "" ]
then
	echo $fullPathToFile
	# no need to do anything further with script in this case, so exit:
	exit 0
fi

# If `which` failed, use full manual path search:
OIFS="$IFS"
IFS=':'
for directory in $PATH
do
	if [ -d $directory ]
	then
		# This searches for an exact name and prints nothing if it fails; we can therefore check an empty variable for failure and non-empty variable for success:
		fullPathToFile=$(find $directory -maxdepth 1 -name $fileNameToFind)
		if [ "$fullPathToFile" != "" ]
		then
			echo $fullPathToFile
			break
		fi
	fi
done
IFS="$OIFS"