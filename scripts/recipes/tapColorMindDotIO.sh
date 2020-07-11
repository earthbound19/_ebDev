# DESCRIPTION
# Via other scripts, obtains N perceptually unique (vs. one another) color palettes, and deletes every palette that was found against another palette above a threshold.

# USAGE
# Hack the global values right after the CODE comment per your want. Then invoke the script:
#  fetch_and_render_Ncolormind_palettes.sh
# NOTES
# - For palette comparison that uses an advanced color model, see paletteCompareCIECAM02.py.
# - To remove palettes for which you manually delete a rendered PNG (because you don't want the palette), see listUnmatchedExtensions.sh or pruneByUnmatchedExtension.sh.


# CODE
numberOfPalettesToGet=42
deletePalettesBelowDifferenceThreshold=0.126

echo "Will obtain, compare and possibly delete similar palettes from $numberOfPalettesToGet palettes."

for i in `seq 1 $numberOfPalettesToGet`; do get_colormind_RND_palette.sh; sleep 1; done

allRGBhexColorSortIn2CIECAM02.sh

renderAllHexPalettes-gm.sh NULL 250 NULL 5

allPalettesCompareCIECAM02.sh

listPaletteDifferencesBelowThreshold.sh $deletePalettesBelowDifferenceThreshold

arrayOfFilesToDelete=(`sed 's/.*|\(.*\)/\1/g' paletteDifferencesBelowThreshold.txt`)

NumberOfFilesInArray=${#arrayOfFilesToDelete[@]}

if [ ! -d tmp_colorMindSort_AYXqmYHefxMYzD ]; then mkdir tmp_colorMindSort_AYXqmYHefxMYzD; fi

for element in ${arrayOfFilesToDelete[@]}
do
	# echo element $element
	fileNameNoExtension=${element%.*}
	# only move to target dir if file does not exist there:
	if [ ! -e "./tmp_colorMindSort_AYXqmYHefxMYzD/$element" ]
	then
		mv ./$element ./tmp_colorMindSort_AYXqmYHefxMYzD/
	fi
	if [ ! -e "./tmp_colorMindSort_AYXqmYHefxMYzD/$fileNameNoExtension.png" ]
	then
		mv ./$fileNameNoExtension.png ./tmp_colorMindSort_AYXqmYHefxMYzD
	fi
done

echo "DONE. Have moved $NumberOfFilesInArray palettes and coressponding PNG palette renders below similarity threshhold $deletePalettesBelowDifferenceThreshold into temp dir tmp_colorMindSort_AYXqmYHefxMYzD. Examine them, and if you wish to, delete them. (If you delete them, you may also want to delete paletteDifferencesBelowThreshold.txt, as that would be outdated after the delete. Also, you may wish to manually run allPalettesCompareCIECAM02.sh again, because the file it created, paletteDifferenceRankings.txt, would be outdated with those files gone."