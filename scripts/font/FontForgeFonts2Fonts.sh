# DESCRIPTION
# Converts all files of type $1 in a directory to type $2.

# USAGE
# Open a cmd terminal using fontforge-console.bat
# (which comes with the fontforge win distribution), then
# type the name of this batch file, the type you want to
# convert from (withuot a . for the extension), the type you
# want to convert to (also without a .), then ENTER.
# EXAMPLE command that converts all .sfd files to .otf:
# FontForgeFont2Font.sh sfd otf


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

# get full path to fontforge:
fullPathToFFscript=`whereis FontForgeConvert.pe | gsed 's/.*: \(.*\)/\1/g' | tr -d '\15\32'`
# conver to windows path format if Windows:
if [ $OS == "Windows_NT" ]
then
	fullPathToFFscript=`cygpath -w "$fullPathToFFscript" | tr -d '\15\32'`
fi

currDir=`pwd`
array=`gfind *.$sourceFormat | tr -d '\15\32'`
for element in ${array[@]}
do
	# If we're running Windows, assume cygwin and convert to windows path.
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
	command="fontforge -script $fullPathToFFscript $fullPathToSourceFile .$destFormat"
	$command
done

# DEV HISTORY:
# - revamped to use simpler script. 08/29/2014 12:49:24 PM -RAH
# - rewrote as bash script, parameterizing source and dest format.
#   2020-04-30 -RAH