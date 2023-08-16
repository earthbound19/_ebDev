# DESCRIPTION
# Reformats a .hexplt file (a list of sRGB colors in hex format) to remove all comments and arrange colors on an $1 column by $2 rows grid, then add back a comment that tells the grid dimension (appended to the first row).

# USAGE
function print_halp {
	echo "
Options:
    -i, --input-file <source hexplt format file name> REQUIRED
    -c<integer or keyword>, --columns=<integer or keyword> OPTIONAL number of columns. If omitted, defaults to 1.
    -a, --all-columns OPTIONAL flag to set number of columns to all colors. Overrides any value of -c, --columns.
    -n, --no-comment OPTIONAL flag: No \"columns: <n> rows: <n>\" comment in reformatted file. Default set true.
    -p, --print-to-stdout OPTIONAL flag: Do not overwrite palette file, only print reformatting result to stdtout (with none of the other progress print otherwise done without -p)
For example, to reformat a .hexplt file with defaults, run:
    reformatHexPalette.sh -i hobby_art_0001-0003.hexplt
"
}


# CODE
# START PARAMETER PARSING AND GLOBALS SETUP
if [ ${#@} == 0 ]; then print_halp; exit 1; fi
PROGNAME=$(basename $0)
OPTS=`getopt -o hi:c::anp --long help,input-file:,columns::,all-columns,no-comment,--print-to-stdout -n $PROGNAME -- "$@"`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi
eval set -- "$OPTS"
# --- END PARSING STUFF ---

# Global function takes number of specified columns and calculates number of rows to fit all colors: ASSUMES AND OPERATES ON GLOBAL VARIABLES:
calculateRowsToFitColors() {
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
    -i | --inputfile ) srcHexplt=$2; if [ ! -f $srcHexplt ]; then echo "WARNING: source file $srcHexplt not found. Specify an existing file. Exit."; exit 2; fi; shift; shift ;;
    -c | --columns ) if [ "$2" == "" ]; then echo "WARNING: No value or a space (resulting in empty value) after optional parameter -c --columns. Pass a value without any space after -c (for example: -c5), or else don't pass -c and a default value will be used for it. Exit."; exit 2; fi; columns=$2; shift; shift ;;
	-a | --all-columns ) columnForEveryColor=true; shift; ;;
	-n | --no-comment ) noLayoutComment=true; shift; ;;
	-p | --print-to-stdout ) printToStdout=true; shift; ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [ ! $srcHexplt ]; then print_halp; exit 1; fi

# info print if no flag saying print to standard out (if writing to original .hexplt file) :
if [ ! $printToStdout ]; then echo "Loading source .hexplt file $srcHexplt . . ."; fi
# get array of colors from file by extracting all matches of a pattern of six hex digits preceded by a #:
colorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $srcHexplt) )
# Get number of colors (from array):
howManyColors=${#colorsArray[@]}

# WHOPAS; you have to create a new flag for this case; do -a --allcolumns:
if [ "$columnForEveryColor" ]; then columns=$howManyColors; fi

# Function call:
calculateRowsToFitColors
# END PARAMETER PARSING AND GLOBALS SETUP

# MAIN WORK
# info print if no flag saying print to standard out (if writing to original .hexplt file) :
if [ ! $printToStdout ]; then echo "Reformatting palette . . ."; fi

# create layoutComment variable only if $noLayoutComment flag was not set (I know, I set up the logic with a confusing double negative) :
if [ ! "$noLayoutComment" ];then layoutComment="  columns: $columns rows: $rows"; fi

# build '- - -' - style parameter, $pasteColumnDashes, for paste command:
for i in $(seq $columns)
do
	pasteColumnDashes="$pasteColumnDashes -"
done

# info print if no flag saying print to standard out (if writing to original .hexplt file) ; note that in both these cases $layoutComment will only print anything if that variable (and any value for it) was set at all; otherwise it will not print any layout comment:
if [ ! $printToStdout ]
then
	printf '%s\n' "${colorsArray[@]}" | paste $pasteColumnDashes | sed "1s/\(.*\)/\1$layoutComment/" > $srcHexplt
else
	printf '%s\n' "${colorsArray[@]}" | paste $pasteColumnDashes | sed "1s/\(.*\)/\1$layoutComment/"
fi

# info print if no flag saying print to standard out (if writing to original .hexplt file) :
if [ ! $printToStdout ]
then
	echo "DONE reformatting $srcHexplt."
	echo ""
fi