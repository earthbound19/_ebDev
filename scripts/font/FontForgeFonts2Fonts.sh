# DESCRIPTION
# Converts all FontForge-compatible files in the current directory of type $1 to type $2.

# DEPENDENCIES
# FontForge installed and in your PATH.

# USAGE
# Run with these parameters:
# - $1 Source type to convert from.
# - $2 Target type to convert from.
# Example that converts all .sfd files to .otf:
#    FontForgeFont2Font.sh sfd otf


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
	echo source format passed to script\: $2;
fi

# get full path to FontForge:
fullPathToFFscript=`whereis FontForgeConvert.pe | sed 's/.*: \(.*\)/\1/g' | tr -d '\15\32'`
# conver to windows path format if Windows:
if [ $OS == "Windows_NT" ]
then
	fullPathToFFscript=`cygpath -w "$fullPathToFFscript" | tr -d '\15\32'`
fi

currDir=`pwd`
IFS=""
find . -maxdepth 1 -type f -iname \*.$sourceFormat -printf '%f\n' > all_"$sourceFormat"s.txt
while IFS= read -r element || [ -n "$element" ]
do
	# If we're running Windows, assume Cygwin and convert to windows path.
	# otherwise leave path as-is:
	if [ $OS == "Windows_NT" ]
	then
		# escaping \:
		fullPathToSourceFile="$currDir"\\"$element"
		fullPathToSourceFile=`cygpath -w $fullPathToSourceFile`
	else
		# oy with the need to escape \:
		fullPathToSourceFile="$currDir"/"$element"
	fi
	fullPathMinusExt=${fullPathToSourceFile%.*}
	fullPathToTargetFile="$fullPathMinusExt"."$destFormat"
	# THIS IS INSANITY: I can't get it to run the command
	# in-line; but it will if run from a variable with
	# the same string?! Is something weird with
	# double-quote marks and/or spaces in paths going on? :
	# AMENDED: no, I can only get it to work if I create and execute a temp
	# script! :
	echo "FontForge -script \"$fullPathToFFscript\" \"$fullPathToSourceFile\" .$destFormat" > gs42BeyT_tmpScript.sh
	chmod +x ./gs42BeyT_tmpScript.sh
	source ./gs42BeyT_tmpScript.sh
done < all_"$sourceFormat"s.txt
rm all_"$sourceFormat"s.txt ./gs42BeyT_tmpScript.sh


# DEV HISTORY:
# 2020-08-29 Revamped to use simpler script. 
# 2020-04-30 Rewrote as bash script, parameterizing source and dest format.
# 2020-04-30 Pulled my hair out with problems of spaces in file name and arrays, made "array" with text file and iterated over lines of it instead.