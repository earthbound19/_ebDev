# DESCRIPTION
# Variant of `paletteRenamedCopiesByNextMostSimilar.sh` that outright renames palette files instead of creating renamed copies. Via other scripts, compares all .hexplt palettes in the current directory, creates a list of them ordered by next most similar, and renames them by numbering prefix in that order, plus random characters, in the current directory. Intended prep script for further use by augmentPalettesGrid.sh, but useful for visual comparisons or whatever other uses you might imagine for examining similar palettes.

# WARNING
# This script by design permanently changes data (renames). Only use on data in a revision control system or data which you can afford to permanently renamed very differently with no trace of the original name.

# DEPENDENCIES
# `allPalettesCompareColoraide.sh' and `sortByNextMostSimilarFromComparisonsList.sh` and their dependencies.
# ALTERNATE DEPENDENCY
# `allPalettesCompareCIECAM02.sh` and its dependencies.

# USAGE
# Run without any parameters:
#    palettesRenameByNextMostSimilar.sh
# NOTES
# hard-coded to use allPalettesCompareColoraide.sh. Alternately can use allPalettesCompareCIECAM02.sh; consult ALTERNATE comment to that effect (which must be uncommented and 

# CODE
if [ ! -f paletteDifferenceRankings.txt ]
then
	echo "paletteDifferenceRankings.txt does not exist; will generate via call of allPalettesCompareColoraide.sh."
	allPalettesCompareColoraide.sh
	# ALTERNATE: to use the following, comment out the previous line and uncomment the next:
	# allPalettesCompareCIECAM02.sh
else
	echo "paletteDifferenceRankings.txt exists; will attempt to make use of it."
fi

sortByNextMostSimilarFromComparisonsList.sh paletteDifferenceRankings.txt > palettesListByMostSimilar.txt

echo ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-
echo "A result list is in palettesListByMostSimilar.txt, which is a list of all .hexplt files in this directory sorted by approximately nearest most perceptually similar."
echo ""

# read result back into an array:
finalList=($(<palettesListByMostSimilar.txt))

# iterate over final list, renaming files by rank of next most similar:
arraySize=${#finalList[@]}
numDigitsOf_arraySize=${#arraySize}
count=0
for fileName in ${finalList[@]}
do
	count=$((count + 1))
	digitPad=$(printf "%0"$numDigitsOf_arraySize"d" $count)
	# get new random string
	RNDstr=$(cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 8)
	newFileName="$digitPad"_"$RNDstr".hexplt
		# these indendent echo statements are for dev testing; comment out in production:
		# echo ----
		# echo "proposed new name for $fileName: $newFileName"
	newPaletteRenderedFileName="$digitPad"_"$RNDstr".png
		# echo "proposed new name for companion rendered palette file name: $newPaletteRenderedFileName"
	# check for companion palette file and rename it also if it exists:
	oldPaletteRenderedFileName=${fileName%.*}.png
		# echo "old palette file name and companion rendered palette file names:"
		# echo $fileName
		# echo $oldPaletteRenderedFileName
	mv $fileName $newFileName
	if [ -e $oldPaletteRenderedFileName ]
	then
		mv $oldPaletteRenderedFileName $newPaletteRenderedFileName
	fi
	digitPad=
done

echo DONE renaming palette files by next most similar.