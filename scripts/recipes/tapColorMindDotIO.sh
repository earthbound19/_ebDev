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

deletePalettesDifferentBelowThreshold.sh

