# DESCRIPTION
# Lists pairs of images that are visually similar to each other below a threshold, $1. Operates on a file created by imgsGetSimilar.sh, which must be run before this, and creates a list of all image pairs in a directory ranked by nearness of similarity to each other. This script filters results from that _below_ float parameter $1. See USAGE for notes on similarity rank float.

# USAGE
# First, run imgsGetSimilar.sh as instructed in its comments. This is necessary to create the file imageDifferenceRankings.txt, which this script relies on. Then run this, with one parameter, being a float value between 0 and 1. Image pairs that have a comparison value _below_ that float will be written to a new file: imageDifferencesBelowThreshold.txt
# Example invocation that will list every pair where the nearness value is 0.065 or lower (meaning the computation for how _different_ the images are is 0.065; or in other words, they are 1 minus 0.065 or 0.935 (93.5 percent) _or more_ similar) :
#  listIMGsMostSimilarBelowThreshold.sh 0.065
# NOTES:
# - Rankings in the list imageDifferenceRankings.txt are by how _different_ images are, on a float scale of 0 to 1, where 0 means two images are identical, and 1 means they are completely different (probably an inverse image would produce that result). Consequently to filter for more identical images, you want to pass _lower_ values for parameter $1. Everything below and at that value will be printed.
# - After you have examined image pairs of a given nearness resulting from this filter, you may delete the second of every pair that is below that nearness threshold by running deleteImagesDifferentBelowThreshold.sh.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (similarity threshold float between 0 and 1) passed to script. Exit."; exit; else threshold=$1; fi

# blank result list if it exists/create new one before writing values in the following loop:
printf "" > imageDifferencesBelowThreshold.txt
# Make array from list in file and parse it in a loop:
files=$(<imageDifferenceRankings.txt)

for element in ${files[@]}
do
	compareVal=`echo $element | sed "s/^\([^|]*\).*/\1/"`
	if (( $(echo "$compareVal <= $threshold" | bc -l) ));
	then
		printf "$element\n" >> imageDifferencesBelowThreshold.txt
	fi
done

printf "\nDONE. Examine imageDifferencesBelowThreshold.txt, and if you're willing to delete every second image (for every pair) in it, run deleteImagesDifferentBelowThreshold.sh."