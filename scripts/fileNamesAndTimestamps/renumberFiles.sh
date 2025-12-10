# DESCRIPTION
# Renames all files of a given extension (via parameter) in the path from which this script is called--renames them to zero-padded numbers matching the number of digit columns of the count of all said files. By default sorts files by `find` command's default option before renumbering (which it seems does well for maintaining the sort order of numbered files). Can be overriden to sort by oldest file first before renumbering, so that for example the oldest file would be numbered 01, the next-oldest would be 02, the next-oldest 03, and so on.

# WARNINGS
# - Use this only in directories where you actually want _all_ files of the given extension renamed by numbers.
# - If any of your file names are numeric-only (e.g. 005.png) *before* you run this script against them, files may disappear via overwrite, effectively erasing that file by replacing it with new content. For example, a file named 005.png may be overwritten when a file named someOtherFile.png is renamed to 005.png, overwriting the original file named 005.png.

# USAGE
# Run with these parameters:
# - -e --extension of files you wish for it to operate on, e.g. 'png'.
# - -r --recurse OPTIONAL. Recurse into all subdirectories of the current directory and renumber files in every subdirectory. Meaning, it repeats the operation in every subdirectory. So for example `dir01` would end up with files inside it renamed `001.png`, `002.png`, `003.png`, and `dir02` would also end up with files named `001.png`, `002.png`, `003.png`, etc. If omitted, only files of type -e --extension in the current directory are renamed (and files of that type in any subdirectories are _not_ renamed).
# - -s --start-number OPTIONAL. Start file renumbering at this number. Must be rammed right on to the s with no trailing space, e.g. a start number of 42 would be expressed as -s42. Must be an integer. If omitted defaults to 0 (zero).
# - -o --oldest-file-first OPTIONAL. Sort by oldest file first before renumbering. If omitted, uses the `find` command's default sort (which seems to do well for maintaining the ordering of numbered files in renumbering).
# - -d digits-to-pad-to OPTIONAL. Pad to this many digits, e.g. if 3 and counting starts at 1 then files will be named 001, 002, 003 etc. If omitted, defaults to however many leading zeros are required to for all file names to have as many digits as the count of type -e --extension in the directory.
# - -p --prefix-string OPTIONAL. String to insert before number in filename.
# - -x --postfix-string OPTIONAL. String to insert after number in filename. This will end up at the end of the basename and before the file extension.
# EXAMPLES
# Renumber all png format files in the current directory:
#    renumberFiles.sh -e png
# Renumber all png format files in the current directory, and start at the number 42:
#    renumberFiles.sh -e png -s42
# Renumber all png format files in the current directory and all subdirectories:
#    renumberFiles.sh --extension png -r
# Renumber all png format files in the current directory and all subdirectories, but override default sort (before rename) of oldest file first to number-oriented sort of `find` command:
#    renumberFiles.sh -e png -r -o
# Do the same thing and start renumbering at 50 in each subfolder:
#    renumberFiles.sh -e png -r -o -s50
# Do the same thing but not over subfolders, padding leading zeros in file names to 7 digits:
#    renumberFiles.sh -e png -o -s50 -d7
# Renumber all hexplt format files in the current directory, inserting the string 'rnd_select_' before the number and '_from_final' after the number (and before the file extension), and starting with number 1:
#    renumberFiles.sh -e hexplt --prefix-string='rnd_sel_' --postfix-string='_from_final' -s 1
# -- which will result in file names like:
#    rnd_sel_00_from_final.hexplt
#    rnd_sel_02_from_final.hexplt
#    rnd_sel_03_from_final.hexplt
# NOTES:
# - this will choke on file names with console-unfriendly characters e.g. spaces, parenthesis and probably others.


# CODE
# TO DO
# - Mitigate what is warned about (in the WARNINGS section) of overwrite clobbers. Or error out or skip if it would happen in a given directory?


function print_halp {
	echo u need halp k read doc in comments at start of script. kthxbai.
}

# print help and exit if no paramers passed:
if [ ${#@} == 0 ]; then print_halp; exit 0; fi

PROGNAME=$(basename $0)
OPTS=`getopt -o he:rs::od::p::x:: --long help,extension:,recurse,start-number::,oldest-file-first,digits-to-pad-to::,prefix-string::,postfix-string:: -n $PROGNAME -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

# set default:
startCountingFrom=0
while true; do
  case "$1" in
    -h | --help ) print_halp; exit 0 ;;
    -e | --extension ) fileTypeToRenumber=$2; shift; shift ;;
    -r | --recurse ) do_recurse=true; shift ;;
    -s | --start-number ) startCountingFrom=$2; shift; shift ;;
	# the next two variables will be checked whether they even exist (are set) to control logic:
    -o | --oldest-file-first ) sort_by_oldest_first=true; shift ;;
    -d | --digits-to-pad-to ) digitsToPadTo=$2; shift; shift ;;
	-p | --prefix-string ) prefixString=$2; shift; shift ;;
	-x | --postfix-string ) postfixString=$2; shift; shift ;;
   -- ) shift; break ;;
    * ) break ;;
  esac
done

# Throw error and exit if mandatory arguments missing:
if [ ! $fileTypeToRenumber ]; then echo "No -e --extension argument passed to script. Exit."; exit 3; fi
# check if $startCountingFrom is numeric; throw an error and exit if it is not:
echo $startCountingFrom | grep -E '^[0-9]{1,}$' &>/dev/null
if [ ! "$?" == "0" ]
then
	echo "-s --start-number parameter ($startCountingFrom) not an interger. Exit."; exit 4
fi
# check that digits-to-pad-to is numeric and exit with error if not:
if [ $digitsToPadTo ]
then
	echo $digitsToPadTo | grep -E '^[0-9]{1,}$' &>/dev/null
	if [ ! "$?" == "0" ]
	then
		echo "-d --digits-to-pad-to parameter ($digitsToPadTo) not an interger. Exit."; exit 5
	fi
fi
# dev debug prints:
# echo fileTypeToRenumber is $fileTypeToRenumber
# echo do_recurse is $do_recurse
# echo startCountingFrom is $startCountingFrom
# echo sort_by_oldest_first is $sort_by_oldest_first
# echo digitsToPadTo is $digitsToPadTo

# if recursion variable (flag) set, make array of all subdirectory paths; otherwise make array of only the current directory:
if [ $do_recurse ]
then
	# if $2 was passed to script, put folder names of all subdirectories into an array:
	directories=($(find -type d))
	# uncomment to remove the first element ('.', or this folder) :
	# directories=(${directories[@]:1})
else
	# otherwise put one element, the current directory, into an array:
	directories=($(pwd))
fi

echo "Hi persnonzez!!!!!!!!!!!!!!! HI!! -Nem"

# set counter before loop:
fileRenumberingCounter=$startCountingFrom
for directory in ${directories[@]}
do
	pushd . &>/dev/null
	cd $directory
	echo in directory $directory . . .
	# Create array to use to loop over files.
	# if sort_by_oldest_first flag was set, do custom sort, otherwise use `find` command's custom sort:
	if [ $sort_by_oldest_first ]
	then
		# previous version of command; doesn't sort by file date:
		# filesArray=`find . -maxdepth 1 -iname "*.$fileTypeToRenumber" | sort`
		# new command; sorts by file date (oldest first); re: https://superuser.com/a/546900/130772
		filesArray=( $(find . -maxdepth 1 -type f -iname "*.$fileTypeToRenumber" -printf "%T@ %Tc %p\n" | sort -n | sed 's/.* \.\///g') )
	else
		filesArray=( $(find . -maxdepth 1 -type f -iname "*.$fileTypeToRenumber" -printf "%P\n") )
	fi
	
	# Get digits to pad to from length of array, IF no custom digits to pad to were passed.
	if [ ! $digitsToPadTo ]
	then
		digitsToPadTo=${#filesArray[@]}; digitsToPadTo=${#digitsToPadTo}
	fi

	for filename in ${filesArray[@]}
	do
		countString=$(printf "%0""$digitsToPadTo""d\n" $fileRenumberingCounter)
		fileRenumberingCounter=$((fileRenumberingCounter + 1))
		renameTarget="$prefixString""$countString""$postfixString".$fileTypeToRenumber
		# conditional feedback print of every 20th renumbering:
		if [[ $(($fileRenumberingCounter % 20)) == 0 ]]
		then
			echo "renaming $filename to $renameTarget . . "
		fi
		mv $filename $renameTarget
	done
	fileRenumberingCounter=$startCountingFrom
	popd &>/dev/null
done

# DEVELOPMENT HISTORY
# 2022/10/25 refactored to use getopt to admit many options, adding option to specify how many digits to pad numbers to, and simulataneous (not alternate) option for start count number.
# 2022-10-09 added numeric option for parameter $2 that will set the start number for numbering
# (Also added paramter 3 (to sort by oldest date file first) on or after that 2022-07-25 log)
# 2022-07-25 add option ($2) to iterate over subdirectories and run renumbering command in each
# 2021-02-21 change sed parsing command that isn't working in whatever changed situation broke it.
# 2020-09-11 simplify script logic, require parameter 1 and print error if absent, true array creation, better command substitution
# 2020/05/22 update array sort to sort by found file date
# 2018/04/19 Take `mapfile` out (fails on Mac) and create array in-memory. Wrangle how to get digitsToPadTo value meanwhile. (Do it before.)
# 2016/07/17 I wish it hadn't taken me a silly half hour (more?) to write this. It used to be it would take much longer, so there's that. -RAH
# 2016/10/12 7:16 PM Fixed bug (via workaround) for echo bug that throws in extra \r character in some situations.