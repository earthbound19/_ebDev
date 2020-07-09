# DESCRIPTION
# Via other scripts, obtains N perceptually unique (vs. one another) color palettes, and deletes every palette that was found against another palette above a threshold.

# USAGE
# Hack the global values right after the CODE comment per your want. Then invoke the script:
#  fetch_and_render_Ncolormind_palettes.sh
# NOTES
# To remove palettes for which you manually delete a rendered PNG (because you don't want the palette), see listUnmatchedExtensions.sh or pruneByUnmatchedExtension.sh.


# CODE
numberOfPalettesToGet=42
# deletePalettesAboveSimilarityThreshhold 0.43		# for ~1,000 palettes
deletePalettesAboveSimilarityThreshhold=0.31		# for ~40 palettes

echo "Will obtain, compare and possibly delete similar palettes from $numberOfPalettesToGet palettes."

for i in `seq 1 $numberOfPalettesToGet`; do get_colormind_RND_palette.sh; sleep 1; done

allRGBhexColorSortIn2CIECAM02.sh

renderAllHexPalettes-gm.sh NULL 250 NULL 5

imgsGetSimilar.sh png

listIMGsMostSimilarAboveThreshold.sh $deletePalettesAboveSimilarityThreshhold

arrayOfFilesToDelete=(`sed 's/.*|\(.*\)/\1/g' IMGlistSimilarComparisonsAboveThreshold.txt`)

NumberOfFilesInArray=${#arrayOfFilesToDelete[@]}

mkdir tmp_colorMindSort_AYXqmYHefxMYzD
for element in ${arrayOfFilesToDelete[@]}
do
	mv ./$element ./tmp_colorMindSort_AYXqmYHefxMYzD/
	fileNameNoExtension=${element%.*}
	mv ./$fileNameNoExtension.hexplt ./tmp_colorMindSort_AYXqmYHefxMYzD
done

rm IMGlistSimilarComparisonsAboveThreshold.txt

echo "DONE. Have moved $NumberOfFilesInArray palettes and coressponding PNG palette renders above similarity threshhold $deletePalettesAboveSimilarityThreshhold into temp dir tmp_colorMindSort_AYXqmYHefxMYzD. Examine them and if you wish delete them. Also, you may wish to manually run imgsGetSimilar.sh, because the file it created, IMGlistByMostSimilar.txt, would be outdated with those files gone."