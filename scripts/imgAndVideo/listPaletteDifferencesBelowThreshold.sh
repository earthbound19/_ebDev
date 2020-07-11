# DESCRIPTION
# Lists pairs of palettes that are visually similar to each other below a threshold, $1. Operates on a file created by allPaletteCompareCIECAM02.sh, which must be run before this, and creates a list of all image pairs in a directory ranked by dissimilarity from each other. This script filters results from that _below_ float parameter $1. See USAGE for notes on similarity rank float.

# USAGE
# First, run allPaletteCompareCIECAM02.sh as instructed in its comments. This is necessary to create the file paletteDifferenceRankings.txt, which this script relies on. Then run this, with one parameter, being a float value between 0 and 1. Image pairs that have a comparison value _below_ that float will be written to a new file: paletteDifferencesBelowThreshold.txt
# Example invocation that will list every palette pair where the nearness value is 0.065 or lower (meaning the computation for how _different_ the palettes are is 0.065; or in other words, they are 1 minus 0.065 or 0.935 (93.5 percent) _or more_ similar) :
#  listPaletteDifferencesBelowThreshold.sh 0.065
# NOTES:
# - Rankings in the list paletteDifferenceRankings.txt are by how _different_ palettes are, on a float scale of 0 to 1, where 0 means two palettes are identical, and 1 means they are completely different (probably an inverse palette would produce that result). Consequently to filter for more identical palettes, you want to pass _lower_ values for parameter $1. Everything below and at that value will be printed.
# - After you have examined palettes of a given nearness resulting from this filter, you may delete the second of every pair that is below that nearness threshold by running deletePalettesDifferentBelowThreshold.sh.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (similarity threshold float between 0 and 1) passed to script. Exit."; exit; else threshold=$1; fi

# blank result list if it exists/create new one before writing values in the following loop:
printf "" > paletteDifferencesBelowThreshold.txt
# Make array from list in file and parse it in a loop:
files=$(<paletteDifferenceRankings.txt)

for element in ${files[@]}
do
	compareVal=`echo $element | sed "s/^\([^|]*\).*/\1/"`
	if (( $(echo "$compareVal <= $threshold" | bc -l) ));
	then
		printf "$element\n" >> paletteDifferencesBelowThreshold.txt
	fi
done

printf "\nDONE. Examine paletteDifferencesBelowThreshold.txt, and if you're willing to delete every second image (for every pair) in it, run deleteImagesDifferentBelowThreshold.sh."