# DESCRIPTION
# Via other scripts, compares all .hexplt palettes in the current directory, creates a list of them ordered by next most similar, and makes numbered copies of them in that order in a subfolder. Intended prep script for further use by augmentPalettesGrid.sh, but useful for visual comparisons or whatever else you might imagine uses for examining similar palettes. NOTE: at this writing an algorithm rewrite is intended, which will produce better results. See comments after CODE comment.

# DEPENDENCIES
# `allPalettesCompareCIECAM02.sh` and its dependencies, `getUniqueWords.sh` and its dependencies, grep

# USAGE
# Run without any parameters:
#    paletteRenamedCopiesByNextMostSimilar.sh


# CODE
# TO DO:
# rewrite sort with this algorithm; ALSO DO THIS for imgsGetSimilar.sh:
# - sort entire list of comparisons from lowest decimal to highest
# - fetch first pair; add them to sorted list
# - find all other pairs that contain pair A and eliminate them
# - find first pair that contains B; add them to list
# - that B becomes A; repeat until no more pairs remain

# sets/changes a global variable rndStr:
function setRNDstr {
   RNDstr=$(cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 8)
}

if [ ! -f paletteDifferenceRankings.txt ]
then
	echo "paletteDifferenceRankings.txt does not exist; will generate via call of allPalettesCompareCIECAM02.sh."
	allPalettesCompareCIECAM02.sh
else
	echo "paletteDifferenceRankings.txt exists; will attempt to make use of it."
fi

# Sort results by rank of most similar (nearest to zero) first, which is on the first bar "|" separated key:
sort -n -b -t\| -k1 paletteDifferenceRankings.txt > _tmp_afXRPJwpE.txt

# Strip the numeric column so we can work up a file list of said ordering for animation;
sed -i 's/[^|]*|\(.*\)/\1/g' _tmp_afXRPJwpE.txt

# get unique palette names from that in the order they appear; grep to get them:
grep -o '[^|]\{1,\}' _tmp_afXRPJwpE.txt > palettesListByMostSimilar.txt
# delete temp file:
rm *_tmp_afXRPJwpE.txt

# reduce that to unique file names (words), in place:, and store it in an array:
getUniqueWords.sh palettesListByMostSimilar.txt FLOURBALP

echo ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-
echo "A result list is in palettesListByMostSimilar.txt, which is a list of all .hexplt files in this directory sorted by approximately nearest most perceptually similar."
echo ""

# read result back into an array:
finalList=($(<palettesListByMostSimilar.txt))

# make randomly named numbered copies folder name:
setRNDstr
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

echo DONE making copies numbered by next most similar are in the folder $targetDirRNDname. Renamed renders of the palettes have also been copied into that folder.