# DESCRIPTION
# Wonky special purpose multi-purpose recipe script that uses other scripts. Takes NxN color samples from every supported image file type in the current directory, and creates .hexplt format palettes from them, via other scripts. Optionally removes duplicate colors from palettes, which is not advised as it may break palette comparisons (it will also wreck the result of a sample grid). Then sorts all the result palettes into subfolders by similar. I say this is wonky because at least one script it calls calls another script that calls another.

# DEPENDENCIES
# `get_color_sample_grids_sRGB_assistant.sh`, and everything that relies on, `allRGBhexColorSortInOkLab.sh`, `renderAllHexPalettes,sh`, `pruneByUnmatchedExtension.sh`, and `paletteRenamedCopiesByNextMostSimilar.sh`.

# USAGE
# Run with these parameters:
# - $1 grid dimensions to sample, in the format '<cols> <rows>', replacing <cols> and <rows> with integers. See get_color_sample_grids_sRGB_assistant.sh. Note this parameter is surrounded by quote marks. See examples.
# - OPTIONAL. $2, anything, such as the word FNEUR, which will cause duplicate colors to be removed from the resultant palettes.
# For example, to do all this without deduplicating colors from resultant palettes (the default), sampling 24 rows and 48 columns, run:
#    get_color_sample_grids_unique_and_compare_palettes.sh '24 48'
# Or to deduplicate colors (overriding the default), run:
#    get_color_sample_grids_unique_and_compare_palettes.sh '24 48' SNURFY


# CODE
if [ "$1" ]; then gridDimensionsParameter=$1; else printf "\nNo parameter \$1 (grid dimensions in format 'cols <space> rows' passed to script. See get_color_sample_grids_sRGB_assistant.sh. Exit."; exit 1; fi

# calling the following script with `source` so it will set the variable $sampleDirectoryName, which has the subdirectory name of palette samples:
source get_color_sample_grids_sRGB_assistant.sh "$gridDimensionsParameter" 0.5 0.5
cd $sampleDirectoryName

# do some rearranging I want to undo arranging necessary for a called script to work.
mv * ..

# erase now empty temp working subdirectory
cd ..
rm -rf $sampleDirectoryName

# move original (potentially interesting and useful) original palette sample grid render noun noun out of the way into an archive:
mkdir _original_grid_sample

mv *palette*.png ./_original_grid_sample

if [ "$2" ]
then
	# sort and uniqify all resultant palettes:
	printf "\nParameter \$2 (remove duplicate colors from palettes) passed to script. Will not pass any switch related to that to allRGBhexColorSortInOkLab (default)";
	allRGBhexColorSortInOkLab.sh '--startComparisonColor ffffff'
else
	# sort without uniqifying all resultant palettes:
	printf "\nNo parameter \$2 (which would remove duplicate colors from palettes) passed to script. Will pass switch --keepDuplicateColors to allRGBhexColorSortInOkLab (overrides default duplicate removal)";
	allRGBhexColorSortInOkLab.sh '--keepDuplicateColors ffffff'
fi

# render them:
renderAllHexPalettes.sh

read -p "Examine all the resulting *palette.png files, modify their corresponding .hexplt sources to your liking (and maybe re-render them), and delete any of the palette images for palettes you don't like. Then enter any input to continue with pruning corresponding .hexplt files, and to rename palettes by next most similar."

pruneByUnmatchedExtension.sh hexplt png

paletteRenamedCopiesByNextMostSimilar.sh