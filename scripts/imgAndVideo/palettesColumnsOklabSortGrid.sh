# DESCRIPTION
# Creates a sort of "pixel sort" palette from all palettes in a directory:
# - collates them all to one palette. Assumes that they all have the same number of colors evenly divided over $1 columns (and things may go wonky if they don't).
# - compares all colors in every column by next-nearest either to the first color (default) or optionally to arbitrary sRGB hex format color $2, and sorts them in that order
# - writes that result to a new palette in a subdirectory, named partly after the directory you run this script from
# - renders the result palette

# USAGE
# Run with these parameters:
# - $1 REQUIRED. number of columns that palettes in this directory are organized into. They are expected to all be the same, and things may go wonky if they are not and/or if the number of colors in the palette do not evenly divide into $1 columns.
# - $2 OPTIONAL. sRGB hex color code to start comparisons on in each column (via `allRGBhexColorSortInOkLab.sh`), which is six hex digits, with no starting pound/hex symbol. If not provided, defaults to black (000000).
# Example with 5 columns for every palette in the directory:
#    palettesColumnsOklabSortGrid.sh 5
# Example with 5 columns for every palette in the directory and starting sort on a vivid btick red color:
#    palettesColumnsOklabSortGrid.sh 5 BE1405
# NOTE
# The path and name of the result file is in the format: ./_palettesColumnsOklabSortGrids/_<host_directory_name>_palettesColumnsOklabSortGrid.hexplt


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (number of columns that palettes are organized into) passed to script. Exit."; exit 1; else columns=$1; fi
if [ "$2" ]; then firstCompareColor=$2; fi
# echo columns is $columns and firstCompareColor is $firstCompareColor

# get directory name without path:
currentDirNoPath=$(basename $(pwd))
# build target file name from that:
outputFileName="$currentDirNoPath"_palettesColumnsOklabSortGrid.hexplt

# delete any temp files from any previous interrupted or otherwise erred run:
rm -rf _palettesColumnsGrid_temp*
mkdir _palettesColumnsGrid_temp

# write first temp file of reformatted temp palettes collated into one, into temp dir:
reformatAllHexPalettes.sh '-c5 -n -p' > ./_palettesColumnsGrid_temp/temp1.txt
# cd to that temp dir for remaining operations:
cd _palettesColumnsGrid_temp
# transpose that result to new file:
datamash transpose --field-separator=' ' < temp1.txt > temp2.txt

# delete trailing whitespace/lines from that result (which would otherwise result in empty split files, maybe augment errors:
sed -i -e :a -e '/[^[:blank:]]/,$!d; /^[[:space:]]*$/{ $d; N; ba' -e '}' temp2.txt

# split temp file into one line palettes:
split --additional-suffix='.hexplt' -l 1 temp2.txt augment_

# sort all those palettes in okLab space starting on firstCompareColor:
allRGBhexColorSortInOkLab.sh $firstCompareColor

# rejoin those to a semi-semi-final palette handily in one script run and pipe!
reformatAllHexPalettes.sh '-a -n -p' > temp1.txt

# transpose those to semi-final palette!
datamash transpose --field-separator=' ' < temp1.txt > ../$outputFileName

# cd to final dir and reformat final file to include layout comment:
cd ..
reformatHexPalette.sh -i $outputFileName -c"$columns"

# move it into its own final subfolder (creating it if necessary), to avoid a problem of re-using it should this script be run again:
if [ ! -d _palettesColumnsOklabSortGrids ]; then mkdir _palettesColumnsOklabSortGrids; fi
mv $outputFileName ./_palettesColumnsOklabSortGrids/
# cd into that and render the palette:
cd _palettesColumnsOklabSortGrids
renderAllHexPalettes.sh

# cd out of that and remove temp files:
cd ..
rm -rf _palettesColumnsGrid_temp*

echo "DONE. Final file destination folder and file is ./_palettesColumnsOklabSortGrids/$outputFileName."
