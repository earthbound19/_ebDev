# DESCRIPTION
# Reformats a .hexplt file (a list of sRGB colors in hex format) to remove all comments and arrange colors on an $1 column by $2 rows grid, then add back a comment that tells the grid dimension (appended to the first row).

# USAGE
# Run with these parameters:
# - $1 source hexplt format file name.
# - $2 OPTIONAL. Number of columns. If omitted, defaults to 1.
# - $3 OPTIONAL. Number of rows. If omitted, defaults to however many rows will fit specified number of columns (including if the last row has empty remainder columns). If specified and the number of rows will not fit all colors, the script overrides what you specify to give enough rows to fit them.
# For example, to reformat a .hexplt file with defaults, run:
#    reformatHexPalette.sh hobby_art_0001-0003.hexplt
# To reformat the same with 


# CODE
# Global function takes number of specified columns and calculates number of rows to fit all colors: ASSUMES AND OPERATES ON GLOBAL VARIABLES:
setRowsToFitColors() {
	rows=$(($howManyColors / $cols))
	# check if there's a remainder from the division (if cols * rows less than howManyColors); if so, add another row:
	if [[ $(($cols * $rows)) < $howManyColors ]]
	then
		# echo adding an extra row to fit all colors into cols * row print.
		rows=$(($rows + 1))
	fi
}

# START PARAMETER PARSING AND GLOBALS SETUP
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source .hexplt format file name) passed to script. Exit."; exit 1; else srcHexplt=$1; fi
# check that source hexplt exists; exit with error if it does not.
if [ ! -f $srcHexplt ]
then
	echo "ERROR: source file $srcHexplt not found in this directory. Exit."
	exit 1
else
	echo Loading source .hexplt file . . .
	# get array of colors from file by extracting all matches of a pattern of six hex digits preceded by a #:
	colorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $srcHexplt) )		# tr command removes pound symbol, and surrounding () makes it an actual array
	# Get number of colors (from array):
	howManyColors=${#colorsArray[@]}
	if [ ! "$2" ]; then cols=1; else cols=$2; fi
	if [ ! "$3" ]
	then
		# Function call:
		setRowsToFitColors
	else
		rows=$3
		# Function call:
		setRowsToFitColors
	fi
fi
# END PARAMETER PARSING AND GLOBALS SETUP

# MAIN WORK
echo Reformatting palette in memory . . .

colorPrintCounter=0
rowsArray=()
OIFS="$IFS"
IFS=$'\n'
for r in $(seq 1 $rows)
do
	rowSTR=""
	for q in $(seq 1 $cols)
	do
		rowSTR="$rowSTR ${colorsArray[$colorPrintCounter]}"
		colorPrintCounter=$((colorPrintCounter + 1))
	done
	
	if [[ $colorPrintCounter == $cols ]]
	then
		rowSTR="$rowSTR  columns: $cols rows: $rows"
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

printf "\nDONE reformatting $srcHexplt."