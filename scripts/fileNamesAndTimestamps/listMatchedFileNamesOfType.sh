# DESCRIPTION
# Calls listMatchedFileNames.sh for every file with extension (or file type) $1 in the current directory.

# USAGE
# Run with these parameters:
# - $1 The extension of the file for which you want every file of that type to be passed to listMatchedFileNames.sh.
# - $2 OPTIONAL. A string declaring one of three modes: 'mode=1', 'mode=2', or 'mode=3'. (Parameter can be with or without surrounding quote marks.) If omitted, defaults to 'mode=1'. Mode 2 causes the script to only list file names and how many matches were found, like this:
#
#    fBnhR9Ar.hexplt 8
#    YWgZmFP3.hexplt 5
#
# Mode 3 causes the script only to print notifications when a file has no match.
# EXAMPLES
# To run listMatchedFileNames.sh for every filename in the current directory that ends with .hexplt, run:
#    listMatchedFileNamesOfType.sh hexplt
# To run for every hexplt file in mode 2, run:
#    listMatchedFileNamesOfType.sh hexplt mode=2


# CODE
if ! [ "$1" ]
then
	echo "No parameter \$1 passed to script (file extension (or type) to call listMatchedFileNames.sh for every one of). Exit."
	exit 1
else
	fileExt=$1
fi

# set default mode:
mode='mode=1'
# --which may be overriden by $2 as follows:
if [ "$2" ]
then
	case "$2" in
		'mode=1') 
			mode=$2
			;;
		'mode=2') 
			mode=$2
			;;
		'mode=3') 
			mode=$2
			;;
		*)
			printf "\nD'oh! Form of parameter 2 (mode) wrong, or mode unsupported. Script will exit. See USAGE in documentation comments at start of script.\n"
			exit 2;
			;;
	esac
fi

srcFileTypesArray=($(find . -maxdepth 1 -iname \*.$fileExt -printf "%P\n"))

printf "\nWill search for pairs for files of type $fileExt . . .\n"
for file in ${srcFileTypesArray[@]}
do
	if [ "$mode" == "mode=1" ]
	then
		listMatchedFileNames.sh $file
	fi
	if [ "$mode" == "mode=2" ]
	then
		len=$(listMatchedFileNames.sh $file | wc -l)
		echo $file: $len
	fi
	if [ "$mode" == "mode=3" ]
	then
		blrugfh='blarg'
		len=$(listMatchedFileNames.sh $file | wc -l)
		if [ "$len" == "0" ]
		then
			echo "$file: 0 (no pair)"
		fi
	fi
done
