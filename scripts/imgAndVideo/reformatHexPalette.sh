# DESCRIPTION
# Reformats a .hexplt file (a list of sRGB colors in hex format) to remove all comments and arrange colors on an $1 column by $2 rows grid, then add back a comment that tells the grid dimension (appended to the first row).

# USAGE
function print_halp {
	echo "
Options:
    -i, --input-file <source hexplt format file name>
    -c<integer or keyword>, --columns=<integer or keyword> Number of columns. OPTIONAL. If omitted, defaults to 1.
    -a, --all-columns OPTIONAL flag to set number of columns to all colors. Overrides any value of -c, --columns.
	-n, --no-comment OPTIONAL flag: No \"columns: <n> rows: <n>\" comment in reformatted file
For example, to reformat a .hexplt file with defaults, run:
    reformatHexPalette.sh -i hobby_art_0001-0003.hexplt
"
}


# CODE
# START PARAMETER PARSING AND GLOBALS SETUP
if [ ${#@} == 0 ]; then print_halp; exit 1; fi
PROGNAME=$(basename $0)
OPTS=`getopt -o hi:c::an --long help,input-file:,columns::,all-columns,no-comment -n $PROGNAME -- "$@"`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi
eval set -- "$OPTS"
# --- END PARSING STUFF ---

# Global function takes number of specified columns and calculates number of rows to fit all colors: ASSUMES AND OPERATES ON GLOBAL VARIABLES:
setRowsToFitColors() {
	rows=$(($howManyColors / $columns))
	# check if there's a remainder from the division (if columns * rows less than howManyColors); if so, add another row:
	if [[ $(($columns * $rows)) < $howManyColors ]]
	then
		# echo adding an extra row to fit all colors into columns * row print.
		rows=$(($rows + 1))
	fi
}

# SET ANY DEFAULTS that would be overriden by optional arguments here:
columns=1
while true; do
  case "$1" in
    -h | --help ) print_halp; exit 0 ;;
    -i | --inputfile ) srcHexplt=$2; if [ ! -f $srcHexplt ]; then echo "WARNING: source file $srcHexplt not found. Specify an existing file. Exit."; exit 1; fi; shift; shift ;;
    -c | --columns ) if [ "$2" == "" ]; then echo "WARNING: No value or a space (resulting in empty value) after optional parameter -c --columns. Pass a value without any space after -c (for example: -c5), or else don't pass -c and a default value will be used for it. Exit."; exit 2; fi; columns=$2; shift; shift ;;
	-a | --all-columns ) columnForEveryColor=true; shift; ;;
	-n | --no-comment ) noLayoutComment=true; shift; ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

echo Loading source .hexplt file $srcHexplt . . .
# get array of colors from file by extracting all matches of a pattern of six hex digits preceded by a #:
colorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $srcHexplt) )
# Get number of colors (from array):
howManyColors=${#colorsArray[@]}

# WHOPAS; you have to create a new flag for this case; do -a --allcolumns:
if [ "$columnForEveryColor" ]; then columns=$howManyColors; fi

# Function call:
setRowsToFitColors
# END PARAMETER PARSING AND GLOBALS SETUP

# MAIN WORK
echo Reformatting palette in memory . . .
echo noLayoutComment $noLayoutComment
colorPrintCounter=0
rowsArray=()
OIFS="$IFS"
IFS=$'\n'
for r in $(seq 1 $rows)
do
	rowSTR=""
	for q in $(seq 1 $columns)
	do
		rowSTR="$rowSTR ${colorsArray[$colorPrintCounter]}"
		colorPrintCounter=$((colorPrintCounter + 1))
	done
	
	# if we are at number of columns for color count; we are at the end of the first row;
	# if that is the case and there is no flag to not write a columns and rows layout comment, write one:
	if [[ $colorPrintCounter == $columns ]] && [[ ! "$noLayoutComment" ]]
	then
		rowSTR="$rowSTR  columns: $columns rows: $rows"
	fi
	# trim resultant leading space off string:
	rowSTR="${rowSTR:1}"
	rowsArray+=($rowSTR)
done

# wipe source hexplt to prep for rewriting to it:
printf "" > $srcHexplt
# write reformatted contents back to it:
echo Writing reformatted .hexplt file . . .

# either of these print options works; uncomment one (I'm guessing the first is faster) :
printf "${rowsArray[*]}" > $srcHexplt
# printf '%s\n' "${rowsArray[@]}" > $srcHexplts

IFS="$OIFS"

printf "\nDONE reformatting $srcHexplt.\n"