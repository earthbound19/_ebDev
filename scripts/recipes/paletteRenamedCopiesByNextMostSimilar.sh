# DESCRIPTION
# Via other scripts, compares all .hexplt palettes in the current directory, creates a list of them ordered by next most similar, and makes numbered copies of them in that order in a subfolder. Intended prep script for further use by augmentPalettesGrid.sh, but useful for visual comparisons or whatever other uses you might imagine for examining similar palettes.

# DEPENDENCIES
# `allPalettesCompareCIECAM02.sh` and its dependencies, `sortByNextMostSimilarFromComparisonsList.sh` and its dependencies.

# USAGE
# Run without any parameters:
#    paletteRenamedCopiesByNextMostSimilar.sh


# CODE
if [ ! -f paletteDifferenceRankings.txt ]
then
	echo "paletteDifferenceRankings.txt does not exist; will generate via call of allPalettesCompareCIECAM02.sh."
	allPalettesCompareCIECAM02.sh
else
	echo "paletteDifferenceRankings.txt exists; will attempt to make use of it."
fi

sortByNextMostSimilarFromComparisonsList.sh paletteDifferenceRankings.txt > palettesListByMostSimilar.txt

echo ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-
echo "A result list is in palettesListByMostSimilar.txt, which is a list of all .hexplt files in this directory sorted by approximately nearest most perceptually similar."
echo ""

# read result back into an array:
finalList=($(<palettesListByMostSimilar.txt))

# make randomly named numbered copies folder name:
RNDstr=$(cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 8)
targetDirRNDname=_paletteRenamedCopiesByNextMostSimilar_"$RNDstr"
mkdir $targetDirRNDname
# iterate over final list placing numbered copies into that folder:

arraySize=${#finalList[@]}
numDigitsOf_arraySize=${#arraySize}
count=0
for fileName in ${finalList[@]}
do
	count=$((count + 1))
	digitPad=$(printf "%0"$numDigitsOf_arraySize"d" $count)
	cp $fileName ./"$targetDirRNDname"/"$digitPad"_$fileName
	# copy matching palette file into that folder also, renaming it to match the new .hexplt pair:
	originalPaletteFileName=${fileName%.*}.png
	newMatchedFileName="$digitPad"_${fileName%.*}.png
	cp $originalPaletteFileName ./"$targetDirRNDname"/$newMatchedFileName
	digitPad=
done

echo DONE making copies numbered by next most similar. They are in the folder $targetDirRNDname. Renamed renders of the palettes have also been copied into that folder.