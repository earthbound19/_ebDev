# DESCRIPTION
# Renames all files of type $1 to numbers by reverse sort of file modification date (one use case is this script helping make anims of modifications to files over time).

# USAGE
# Run with this parameter:
# - $1 the file extension (type) to renumber, without the . in the extension.
# Example:
#    renumberFilesByModificationDates.sh png


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (file extension (type) to renumber) passed to script. Exit."; exit 1; else fileTypeToRenumber=$1; fi

echo "Hi persnonzez!!!!!!!!!!!!!!! HI!! -Nem"

# Create array to use to loop over files. Sort by modified date stamp re genius breath yon: https://superuser.com/a/294164
# filesArray=`find . -maxdepth 1 -iname "*.$fileTypeToRenumber" | sort -zk 1n | sed -z 's/^[^ ]* //' | tr '\0' '\n'`
# NOPE, that dunna work, but this does:
filesArray=($(ls --sort=time --reverse *."$fileTypeToRenumber" | tr '\0' '\n'))
# Get digits to pad to from length of array.
digitsToPadTo=${#filesArray[@]}; digitsToPadTo=${#digitsToPadTo}

counter=0
for filename in ${filesArray[@]}
do
	counter=$((counter + 1))
	countString=$(printf "%0""$digitsToPadTo""d\n" $counter)
			# echo old file name is\: $filename
			# echo new file name is\: $countString.$fileTypeToRenumber
	mv $filename $countString.$fileTypeToRenumber
done