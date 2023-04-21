# DESCRIPTION
# Lists pairs of palettes that are visually similar to each other below a threshold, $1. Operates on a file created by allPalettesCompareCIECAM02.sh, which must be run before this, and creates a list of all image pairs in a directory ranked by dissimilarity from each other. This script filters results from that _below_ float parameter $1. See USAGE for notes on similarity rank float.

# USAGE
# First, run allPalettesCompareCIECAM02.sh as instructed in its comments. This is necessary to create the file paletteDifferenceRankings.txt, which this script relies on. Then, run with one parameter:
# - $1 A float value between 0 and 1. Image pairs that have a comparison value _below_ that float will be written to a new file: paletteDifferencesBelowThreshold.txt
# Example run that will list every palette pair where the difference value is _below_ 0.065:
#    listPaletteDifferencesBelowThreshold.sh 0.065
# NOTES
# - Rankings in the list paletteDifferenceRankings.txt are by how _different_ palettes are, on a float scale of 0 to 1, where 0 means two palettes are identical, and 1 means they are completely different (probably an inverse palette would produce that result). Consequently to filter for more identical palettes, you want to pass _lower_ values for parameter $1. Everything below and at that value will be printed.
# - To explain that another way, a lower difference value means a pair of palettes is more similar. To think of it in terms of a similarity value, if a pair is 0.065 percent different, it is (1 - 0.065) percent or 0.935 percent similar.
# - As this filters values _below_ $1, if you pass 0.065, images with a difference ranking _at_ 0.065 will be excluded. Images below it with values such as 0.06499 or 0.063 or 0.2 etc. will be included. Not the number $1 itself.
# - After you have examined palettes of a given nearness resulting from this filter, you may sort one from every pair of palettes below that nearness threshold into a temp folder for examination (and possibly to delete) by running deletePalettesDifferentBelowThreshold.sh.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (similarity threshold float between 0 and 1) passed to script. Exit."; exit; else threshold=$1; fi

# blank result list if it exists/create new one before writing values in the following loop:
printf "" > paletteDifferencesBelowThreshold.txt

# START CRAZY but sort of amazing text filtration of all values blatantly above $threshold before we work with bc (as it is much slower calling bc so many times) :
# pad number a bit, else we filter numbers we want:
filterNumOne=`echo $threshold .1 | awk '{print $1 + $2}'`
# count up by 0.1 increments from number until we reach 1, and with each increment, remove all lines from the list that start with that number:
cp paletteDifferenceRankings.txt tmp_p6WtTVackrvH.txt
while [ `echo "$filterNumOne < 1" | bc` -eq 1 ]
do
	# round that to 1 decimal via printf:
	filterNumTwo=`printf "%.*f\n" 1 $filterNumOne`
	sed -i -n "/^$filterNumTwo/!p" tmp_p6WtTVackrvH.txt
	# add $filterNumOne and 0.1 with awk's print command:
	filterNumOne=`echo $filterNumOne .1 | awk '{print $1 + $2}'`
done
# END CRAZY but sort of amazing text filtration~

# create rankings array from that filtered file, and remove the temp file; then use bc math to more finely filter the array:
rankings=$(<tmp_p6WtTVackrvH.txt)
rm ./tmp_p6WtTVackrvH.txt
			counter=0		# code associated with this variable is to print updates every 15 loops.
for element in ${rankings[@]}
do
			counter=$((counter + 1)); mod=$((counter % 15)); if [[ $mod -eq 0 ]]; then printf "Examining $element . . .\n"; fi
	compareVal=`echo $element | sed "s/^\([^|]*\).*/\1/"`
	if (( $(echo "$compareVal <= $threshold" | bc -l) ));
	then
		printf "$element\n" >> paletteDifferencesBelowThreshold.txt
	fi
done

printf "\nDONE. Examine paletteDifferencesBelowThreshold.txt, and if you're willing to delete every second image (for every pair) in it, run deleteImagesDifferentBelowThreshold.sh."