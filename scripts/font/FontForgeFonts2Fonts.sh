# DESCRIPTION
# Converts all FontForge-compatible files in the current directory of type $1 to type $2.

# DEPENDENCIES
# - FontForge installed and in your PATH
# - for Windows, cygpath (which comes with both Cygwin and MSYS2)

# USAGE
# Run with these parameters:
# - $1 Source type to convert from
# - $2 Target type to convert from
# Example that converts all .sfd files to .otf:
#    FontForgeFonts2Fonts.sh sfd otf


# CODE
if [ ! "$1" ]
	then echo no source format parameter \$1 passed to script\; will exit\.
	exit
else
	sourceFormat=$1
	echo source format passed to script\: $1;
fi

if [ ! "$2" ]
	then echo no target format parameter \$2 passed to script\; will exit\.
	exit
else
	destFormat=$2
	echo target format passed to script\: $2;
fi

# get full path to FontForge:
fullPathToFFscript=$(getFullPathToFile.sh FontForgeConvert.pe)
# convert to windows path format if Windows:
if [ $OS == "Windows_NT" ]
then
	# cygpath is also shipped with MSYS2, so this works with cygwin and MSYS2! :
	fullPathToFFscript=$(cygpath -w "$fullPathToFFscript" | tr -d '\15\32')
fi

currDir=$(pwd)
source_files=($(find . -maxdepth 1 -type f -iname \*.$sourceFormat -printf '%f\n'))
for element in ${source_files[@]}
do
	# If we're running Windows, build a Windows-style path (backslashes); otherwise leave path as-is:
	if [ $OS == "Windows_NT" ]
	then
		# escaping \:
		fullPathToSourceFile="$currDir"\\"$element"
		fullPathToSourceFile=$(cygpath -w $fullPathToSourceFile)
	else
		# oy with the need to escape \:
		fullPathToSourceFile="$currDir"/"$element"
	fi

	fullPathMinusExt=${fullPathToSourceFile%.*}
	fullPathToTargetFile="$fullPathMinusExt"."$destFormat"
	# THIS IS INSANITY: I can't get it to run the command in-line; but it will if run from a variable with the same string?! Is something weird with double-quote marks and/or spaces in paths going on? I can only get it to work if I create and execute a temp script! :
	echo "FontForge -script \"$fullPathToFFscript\" \"$fullPathToSourceFile\" .$destFormat" > gs42BeyT_tmpScript.sh
	chmod +x ./gs42BeyT_tmpScript.sh
	source ./gs42BeyT_tmpScript.sh
	rm ./gs42BeyT_tmpScript.sh
done


# DEV HISTORY:
# 2020-11-15 Updated to use better array creation and command substitution. Re-tested on windows. Corrected some documentation errors.
# 2020-08-29 Revamped to use simpler script. 
# 2020-04-30 Rewrote as bash script, parameterizing source and dest format.
# 2020-04-30 Pulled my hair out with problems of spaces in file name and arrays, made "array" with text file and iterated over lines of it instead.