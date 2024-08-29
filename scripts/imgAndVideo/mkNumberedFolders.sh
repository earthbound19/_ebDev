# DESCRIPTION
# Creates N numbered subdirectories zero-padded by however many digits there are in N.

# USAGE
# Run this script with these parameters:
# - -n --number REQUIRED. How many directories (folders) to make.
# - [-s | --start-number] OPTIONAL. Start folder numbering at this number. Must be rammed right on to the s with no trailing space, e.g. -s42. If omitted defaults to 1.
# - -p --prefix-string OPTIONAL. String to insert before number in folder name. If omitted no prefix is on folder names.
# - -x --postfix-string OPTIONAL. String to insert after number in folder name. If omitted no postfix is on folder names.
# EXAMPLES
# Create 42 directories, zero-padded so that directories 1-9 are named 01, 02, 03, etc.:
#    mkNumberedFolders.sh -n 42
# Do the same but start the numbering at 20:
#    mkNumberedFolders.sh -n 42 -s20
# Make 35 folders and prefix the folder number with 'palette_subset_':
#    mkNumberedFolders.sh -n 35 --prefix-string=palette_subset_
# Do the same and also postix the number with '_rnd':
#    mkNumberedFolders.sh -n 35 --prefix-string=palette_subset_ -x'_rnd'


# CODE
function print_halp {
	echo u need halp k read doc in comments at start of script. kthxbai.
}

# print help and exit if no paramers passed:
if [ ${#@} == 0 ]; then print_halp; exit 0; fi

PROGNAME=$(basename $0)
OPTS=`getopt -o hn:s::p::x:: --long help,number:,start-number::,prefix-string::,postfix-string:: -n $PROGNAME -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

# set default:
startCountingFrom=0
while true; do
  case "$1" in
    -h | --help ) print_halp; exit 0 ;;
    -n | --number ) nFoldersToMake=$2; shift; shift ;;
    -s | --start-number ) startCountingFrom=$2; shift; shift ;;
	-p | --prefix-string ) prefixString=$2; shift; shift ;;
	-x | --postfix-string ) postfixString=$2; shift; shift ;;
   -- ) shift; break ;;
    * ) break ;;
  esac
done

# Throw error and exit if mandatory arguments missing:
if [ ! $nFoldersToMake ]; then echo "No -n --number argument passed to script. Exit."; exit 3; fi

# add $startCountingFrom to $nFoldersToMake or else nothing will be made by counting from $startCountingFrom is $nFoldersToMake < $startCountingFrom; store it in a new variable name for clarity:
countTo=$(($startCountingFrom + $nFoldersToMake))

# echo nFoldersToMake is $nFoldersToMake
# echo startCountingFrom is $startCountingFrom
# echo countTo is $countTo
# echo prefixString is $prefixString
# echo postfixString is $postfixString

echo "Hi persnonzez!!!!!!!!!!!!!!! HI!! -Nem"

digitsToPadTo=${#nFoldersToMake};
for i in $(seq $startCountingFrom $countTo)
do
	countString=$(printf "%0""$digitsToPadTo""d\n" $i)
	# echo countString is $countString
	folderName="$prefixString""$countString""$postfixString"
	# echo folderName is $folderName
	if [[ $(($i % 18)) == 1 ]]
	then
		echo "creating folder $folderName . . "
	fi
	mkdir $folderName
done