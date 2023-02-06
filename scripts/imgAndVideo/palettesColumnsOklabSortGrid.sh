# DESCRIPTION
# Creates a sort of "pixel sort" palette from all palettes in a directory, this way:
# - collates them all to one palette. Assumes that they all have the same number of colors which will evenly divide over $1 columns (and things may go wonky if they don't).
# - sorts colors in columns by next-nearest perceptual, either to the first color (top of column) by default, or optionally compares starting with an arbitrary sRGB hex format color $2, and sorts them in the column in that order. The comparisons to sort are done in the Oklab color space.
# - writes that result to a new palette in a subdirectory, named partly after the directory you run this script from, arranged in $1 columns and with a layout comment so that render scripts that make use of the comment will lay out colors in a grid such that the color sorting by column will hopefully be visually apparent.
# - renders the result palette with a renderer that will make use of the layout comment

# USAGE
# Run with these parameters:
# - $1 REQUIRED. number of columns that all the palettes in this directory will evenly divide into. This is expected to be the same for every palette, and things may go wonky if they are not. Palettes are also expected to all have the same number of colors (no tests without that have been done).
# - $2 OPTIONAL. Any parameter(s) usable by allRGBhexColorSortInOkLab.sh, surrounded by quote marks. This gets hairy, because that script passes it on to rgbHexColorSortInOkLab.js, and while it's technically one parameter it can be a group of parameters surrounded by quote marks. (I even internally named the variable that receives this parameter parametricHairball.) See the parameter documentation comments in allRGBhexColorSortInOkLab.sh and maybe the script it calls.
# Example with 5 columns for every palette in the directory, and default keeping any duplicate colors (no parameters for $2 / allRGBhexColorSortInOkLab.sh):
#    palettesColumnsOklabSortGrid.sh 5
# Example with 5 columns for every palette in the directory, keeping any duplicate colors, and starting sort on a vivid brick red sRGB color (via an available parameter -f for allRGBhexColorSortInOkLab.sh at this writing) :
#    palettesColumnsOklabSortGrid.sh 5 '-k -f BE1405'
# NOTE
# The path and name of the result file is in the format: ./_palettesColumnsOklabSortGrids/_<host_directory_name>_palettesColumnsOklabSortGrid_<a few random characters>.hexplt


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (number of columns that palettes are organized into) passed to script. Exit."; exit 1; else columns=$1; fi
parametricHairball='-k'
if [ "$2" ]; then parametricHairball=$2; fi
# Override that to nothing if the keyword NULL was passed:
if [ "$parametricHairball" == 'NULL' ]; then parametricHairball= ; fi
# echo columns is $columns, parametricHairball is $parametricHairball

# get directory name without path:
currentDirNoPath=$(basename $(pwd))
# build target file name from that; randomize it a bit to avoid file clobber in case of re-runs of this script:
rndSTRfileNamePart=$(cat /dev/urandom | tr -dc 'a-hj-km-np-zA-HJ-KM-NP-Z2-9' | head -c 4)
outputFileName="$currentDirNoPath"_palettesColumnsOklabSortGrid_"$rndSTRfileNamePart".hexplt

# delete any temp files from any previous interrupted or otherwise erred run:
rm -rf _palettesColumnsGrid_temp*
mkdir _palettesColumnsGrid_temp

# write first temp file of reformatted temp palettes collated into one, into temp dir:
reformatAllHexPalettes.sh "-c"$columns" -n -p" > ./_palettesColumnsGrid_temp/temp1.txt

# cd to that temp dir for remaining operations:
cd _palettesColumnsGrid_temp
# transpose that result to new file:
datamash transpose --field-separator=' ' < temp1.txt > temp2.txt

# delete trailing whitespace/lines from that result (which would otherwise result in empty split files, maybe augment errors:
sed -i -e :a -e '/[^[:blank:]]/,$!d; /^[[:space:]]*$/{ $d; N; ba' -e '}' temp2.txt

# split temp file into one line palettes:
split --additional-suffix='.hexplt' -l 1 temp2.txt augment_

# Call script with parametric hairball; NOTE: surrounding that parametricHairball parameter use with double quote marks was the key to getting the group of parameters in the variable to work with the called script:
allRGBhexColorSortInOkLab.sh "$parametricHairball"

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
