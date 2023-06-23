# DESCRIPTION
# Wonky special purpose multi-purpose recipe script that uses other scripts. Takes NxN color samples from every supported image file type in the current directory, and creates .hexplt format palettes without duplicate colors from them, via other scripts. (It may make wreck the result of a sample grid by removing duplicate colors.) Then sorts all the result palettes into subfolders by similar. Wonky, because at least one script it calls calls another script that calls another . . .

# DEPENDENCIES
# `get_color_sample_grids_sRGB_assistant.sh`, and everything that relies on, `allRGBhexColorSortInOkLab.sh`, `renderAllHexPalettes,sh`, `pruneByUnmatchedExtension.sh`, and `paletteRenamedCopiesByNextMostSimilar.sh`.

# USAGE
# Run with these parameters:
# - $1 grid dimensions to sample, in the format 'cols <space> rows'. See get_color_sample_grids_sRGB_assistant.sh
# For example:
#    get_color_sample_grids_unique_and_compare_palettes.sh '40 x 40'


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

# sort and uniqify all resultant palettes:
allRGBhexColorSortInOkLab.sh '-s ffffff'

# render them:
renderAllHexPalettes.sh

read -p "Examine all the resulting *palette.png files, modify their corresponding .hexplt sources to your liking (and maybe re-render them), and delete any of the palette images for palettes you don't like. Then enter any input to continue with pruning corresponding .hexplt files, and to rename palettes by next most similar."

pruneByUnmatchedExtension.sh hexplt png

paletteRenamedCopiesByNextMostSimilar.sh