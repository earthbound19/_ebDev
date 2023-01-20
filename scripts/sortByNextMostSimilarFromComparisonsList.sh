# DESCRIPTION
# Takes a list of item comparisons $1, finds all unique elements in the list, arranges them by next most similar, and prints the result. (Does not modify the original list.) For use by imgsGetSimilar.sh, paletteRenamedCopiesByNextMostSimilar.sh, or any other purpose you might have for it. Another script must first produce the comparison list this script uses. For details see USAGE.

# USAGE
# Prepare a list formatted like this, where comparisons are expressed as a percent decimal in dissimilarity from 0 to 1, where 0 is identical and 1 is totally dissimilar; this example list is of palettes that were compared by perceptual similarity of the sum of similarity of all colors in the palettes to all other palettes in the list:
#    0.22618782372855256|4ysAxxby.hexplt|50s_Machine_Shop.hexplt
#    0.34378066577305355|4ysAxxby.hexplt|bKHvfxxS.hexplt
#    0.23935503857984508|4ysAxxby.hexplt|D5J6TggD.hexplt
#    0.19837715891125776|4ysAxxby.hexplt|Erb8M4uS.hexplt
#    0.24001237539379658|4ysAxxby.hexplt|fB7ITB9E.hexplt
#    etc. . . .
# Suppose that list is named paletteDifferenceRankings.txt, then from the directory with that list, and with this script in your PATH, run this script with the file name of that list as parameter $1:
#    sortByNextMostSimilarFromComparisonsList.sh paletteDifferenceRankings.txt
# The result will be printed to stdout, one item per line, like this:
#    HKdyXxHf.hexplt
#    X6gMvY8A.hexplt
#    Scvkqypu.hexplt
#    50s_Machine_Shop.hexplt
# To save the result to a file, pipe it like this:
#    sortByNextMostSimilarFromComparisonsList.sh paletteDifferenceRankings.txt > palettesListByMostSimilar.txt


# CODE
if [ "$1" ]; then sourceFile=$1; else printf "\nNo parameter \$1 (source file of comparisons) passed to script. Exit."; exit 1; fi

# Function that sets a global RNDstr variable with a new random 9-character string
setRNDstr () {
	RNDstr=$(cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 9)
}

# copy source to temp file:
# function call:
setRNDstr
tmpSortingFileName=tmpSortByNextMostSimilar_"$RNDstr".temp_sort
cp $sourceFile ./$tmpSortingFileName

# MAIN ALGORITHM described in numbered comments.
# 1. sort entire list of comparisons from lowest decimal to highest
# Sort results by rank of most similar (nearest to zero) first, which is on the first bar "|" separated key:
# function call:
setRNDstr
tmpSortingFileName2=tmpSortByNextMostSimilar_"$RNDstr".temp2_sort
sort -n -b -t\| -k1 $tmpSortingFileName > $tmpSortingFileName2
# Strip the numeric column so we can work up a file list of said ordering for animation;
sed -i 's/[^|]*|\(.*\)/\1/g' $tmpSortingFileName2

# get unique list item names from that in the order they appear; grep to get them:
grep -o '[^|]\{1,\}' $tmpSortingFileName2 > $tmpSortingFileName

# reduce that to unique file names (words) :
getUniqueWords.sh $tmpSortingFileName FLOURBALF THREUSK
uniqueListItemsCount=$(wc -l < $tmpSortingFileName)

# 2. find first pair in sort list
# it will be the first of the first pair in the list; get that:
firstListItem=$(sed '1q;d' $tmpSortingFileName)
secondListItem=$(sed '2q;d' $tmpSortingFileName)

# 3. add them to final list in order they appear
finalList=()
finalList+=($firstListItem)
finalList+=($secondListItem)

# 4. assign them to A and B search vals
searchA=$firstListItem
searchB=$secondListItem

# 5. find and delete all search list pairs that contain A (including first).
sed -i "/.*$firstListItem.*/d" $tmpSortingFileName2
#    5b. make B the search value
searchVal=$searchB
# LOOP to obtain remaining list items in the preferred sort order:
for i in $(seq 0 $uniqueListItemsCount)
do
	# 6. find in search list first pair that matches search value
	matchPair=$(grep "$searchVal" $tmpSortingFileName2 | head -n 1)
	#    6b. add non-match pair from that to final list
	#    -- by extracting it from the pair, by subtracting the match and any '|' characters before or after it:
	nonMatchPair=$(echo $matchPair | sed "s/[\|]\{0,\}$searchVal[\|]\{0,\}//g")
	# -- the actual adding it:
	finalList+=($nonMatchPair)
	# 7. find and delete all search list pairs that contain search value (including first).
	sed -i "/.*$searchVal.*/d" $tmpSortingFileName2
	#    7b make non-match pair the new search value
	searchVal=$nonMatchPair
done
# 8. repeat steps 6-8 until no more pairs remain

# 9. print list
for item in ${finalList[@]}
do
	echo $item
done

# delete temp files:
rm $tmpSortingFileName $tmpSortingFileName2