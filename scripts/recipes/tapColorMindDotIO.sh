# DESCRIPTION
# Via other scripts, obtains N perceptually unique (vs. one another) color palettes. The last script this calls lists palettes that are perceptually similar (technically and logically not very different below a threshold), for proposed deleting.

# USAGE
# Hack the global values right after the CODE comment per your want. Then invoke the script:
#  fetch_and_render_Ncolormind_palettes.sh
# NOTES
# - To remove palettes for which you manually delete a rendered PNG (because you don't want the palette), see listUnmatchedExtensions.sh or pruneByUnmatchedExtension.sh.


# CODE
numberOfPalettesToGet=42
deletePalettesBelowDifferenceThreshold=0.126

echo "Will obtain, compare and possibly delete similar palettes from $numberOfPalettesToGet palettes."

for i in `seq 1 $numberOfPalettesToGet`; do get_colormind_RND_palette.sh; sleep 1; done

allRGBhexColorSortIn2CIECAM02.sh
renderAllHexPalettes-gm.sh NULL 250 NULL
allPalettesCompareCIECAM02.sh
listPaletteDifferencesBelowThreshold.sh $deletePalettesBelowDifferenceThreshold
# PENDING DEVELOPMENT:
# deletePalettesDifferentBelowThreshold.sh

