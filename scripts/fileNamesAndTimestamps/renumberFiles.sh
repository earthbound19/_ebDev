# DESCRIPTION
# Renames all files of a given extension (via parameter) in the path from which this script is called--renames them to zero-padded numbers matching the number of digit columns of the count of all said files. WARNINGS: 1) use this only in directories where you actually want _all_ files of the given extension renamed by numbers. 2) If any of your file names are numeric-only (e.g. 005.png) *before* you run this script against them, files may disappear via overwrite, effectively erasing that file by replacing it with new content. For example, a file named 005.png may be overwritten when a file named someOtherFile.png is renamed to 005.png, overwriting the original file named 005.png.

# USAGE
# Run with these parameters:
# - $1 the file extension you wish for it to operate on, for example png
# - $2 OPTIONAL. Anything, such as the word FLUBNOR, which will cause the script to 
#    renumberFiles.sh png
# NOTE: this will choke on file names with console-unfriendly characters e.g. spaces, parenthesis and probably others.

# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (file extension (type) to renumber) passed to script. Exit."; exit 1; else fileTypeToRenumber=$1; fi

if [ "$2" ]
then
	# if $2 was passed to script, put folder names of all subdirectories into an array, and remove the first element ('.', or this folder) :
	directories=($(find -type d))
	directories=(${directories[@]:1})
else
	# otherwise put one element, the current directory, into an array:
	directories=($(pwd))
fi

echo "Hi persnonzez!!!!!!!!!!!!!!! HI!! -Nem"

for directory in ${directories[@]}
do
	pushd . &>/dev/null
	cd $directory
	# Create array to use to loop over files.
	# previous version of command; doesn't sort by file date:
	# filesArray=`find . -maxdepth 1 -iname "*.$fileTypeToRenumber" | sort`
	# new command; sorts by file date (oldest first); re: https://superuser.com/a/546900/130772
	filesArray=( $(find . -maxdepth 1 -type f -iname "*.$fileTypeToRenumber" -printf "%T@ %Tc %p\n" | sort -n | sed 's/.* \.\///g') )
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
	popd &>/dev/null
done

# DEVELOPMENT HISTORY
# 2022-07-25 add option ($2) to iterate over subdirectories and run renumbering command in each
# 2021-02-21 change sed parsing command that isn't working in whatever changed situation broke it.
# 2020-09-11 simplify script logic, require parameter 1 and print error if absent, true array creation, better command substitution
# 2020/05/22 update array sort to sort by found file date
# 2018/04/19 Take `mapfile` out (fails on Mac) and create array in-memory. Wrangle how to get digitsToPadTo value meanwhile. (Do it before.)
# 2016/07/17 I wish it hadn't taken me a silly half hour (more?) to write this. It used to be it would take much longer, so there's that. -RAH
# 2016/10/12 7:16 PM Fixed bug (via workaround) for echo bug that throws in extra \r character in some situations.