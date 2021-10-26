# DESCRIPTION
# Counts all files of type $1 in the current directory, then deletes every one that is not a multiple of $2 minus one.

# USAGE
# With this script in your PATH, run it with these parameters:
# - $1 the file type to search for (in the current directory only).
# - $2 the multiple of those files to _keep_ when counting and deleting them. All files of type $1 which are _not_ multiples of $2 will be deleted. (Actually $2 minus 1; see DESCRIPTION.)
# Example which will delete every png image in the current directory that is not a multiple of 3:
#    decimateFileType.sh png 3
# NOTES
# - You may wish, after running this script, to run renumberFiles.sh (see the USAGE comment in that script) to make e.g. animation frame numbers in files contiguous again.
# - The script sorts listed files by create date before deleting, so that e.g. animation frames will stay in order.
# - The formula for listed file numbers to delete is $2 minus one because this preserves the first frame.


# CODE
if ! [ "$1" ]; then echo "No parameter \$1. Exit."; exit; else fileTypeToDelete=$1; fi
if ! [ "$2" ]; then echo "No parameter \$2. Exit."; exit; else divisor=$2; fi
if [[ "$divisor" -eq 1 ]]; then echo "The value of 1 passed for \$2 will delete every file. Nope. Exit."; exit; fi

read -p "WARNING: all files of type $fileTypeToDelete, listed and counted, and which are not a multiple of ($divisor - 1) will be deleted! If this is what you intend, type YORFEL and <enter> (or <return>). Otherwise, type anything else and <enter>/<return>, or CTRL+Z or CTRL+C. TYPE: " florf

if [[ "$florf" != "YORFEL" ]]; then echo "No input match. Exit."; exit; else echo "Input match; continuing . . ."; fi

# Sorts by time stamp:
array=( $(find . -maxdepth 1 -name "*.$fileTypeToDelete" -print0 -printf "%T@ %Tc %p\n" | sort -n | sed 's/.* [0-9]\{3,\} \.\/\(.*\)/\1/g') )

counter=-1
for element in ${array[@]}
do
	counter=$((counter + 1))
	result=$((counter % $divisor))
	if [[ ! result -eq 0 ]]
	then
		echo "DELETING $element . . ."
		rm $element
		echo " . . . DELETED!"
	fi
done