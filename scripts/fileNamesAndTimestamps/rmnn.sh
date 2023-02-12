# DESCRIPTION
# Deletes (`rm`) all files of type `$1` in number range `$2` to `$3` (N1 to N2), in the current directory. Prompts to type a displayed password to confirm you wish to do so. Sorts by default of `find` command.

# USAGE
# Run with these parameters:
# - $1 file type to delete count after N of.
# - $2 start count of files to delete.
# - $3 OPTIONAL. End count of files to delete. If omitted, all files of type $1 after count $2 are deleted (and so is file at count $2). If you wish to use $4 but not this parameter, pass this parameter as the word 'NULL'.
# - $4 OPTIONAL. The word BLUBARG, which if you pass it, will bypass warning prompt and delete the files without asking. Useful for using this script from other scripts.
# EXAMPLES
# To delete all files of type png which are listed by the `find` command from the 51st to the last found png:
#    rmn.sh png 51
# To delete all files of type png from the 1st to the 29th found:
#    rmn.sh png 1 29


# CODE
# Parameter parsing and globals setup:
if [ ! "$1" ]; then printf "\nNo parameter \$1 (file type to delete) passed to script. Exit."; exit 1; else fileType=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (start count of type $fileType) passed to script. Exit."; exit 1; else startCount=$2; fi
array=($(find . -maxdepth 1 -type f -iname \*.$fileType))
array_length=${#array[@]}
# conditional exit without print but with error code if practical:
if (( array_length == "0" )); then exit 1; fi
if [ ! "$3" ] || [ "$3" == 'NULL' ]; then endCount=$array_length; else endCount=$3; fi

if [ ! "$4" ] || [[ "$4" != "BLUBARG" ]];
then
	echo ""
	echo "WARNING: This script will delete all files of type $fileType found at"
	echo "list count $startCount and ending at list count $endCount."
	echo "If this is not what you want to do, press ENTER or RETURN, or"
	echo "CTRL+C or CTRL+Z. If this _is_ what you want to do, type"
	echo "BLUBARG and then press ENTER or RETURN."
	read -p "TYPE HERE: " SILLYWORD

	if [ ! "$SILLYWORD" == "BLUBARG" ]
	then
		echo ""
		echo Typing mismatch\; exit.
		exit 2
	fi
fi

# adjust those counts inline by -1 for zero-based indexing:
seqStart=$(($startCount - 1))
seqEnd=$(($endCount - 1))
for idx in $(seq $seqStart $seqEnd)
do
	fileNameToDelete="${array[$idx]}"
	echo "DELETING file idx $idx, file name $fileNameToDelete . . ."
	rm $fileNameToDelete
done
