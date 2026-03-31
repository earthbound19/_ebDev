# DESCRIPTION
# calls uniformFillColorImage.sh repeatedly to create color swatch images (uniform color images) for every color in a source .hexplt file.

# DEPENDENCIES
# findPalette.sh, uniformFillColorImage.sh

# USAGE
# Run with these parameters:
# - $1 input .hexplt file name. Can be either a palette file in the current path or locatable from the _ebPalettes repository via findPalette.sh.
# - $2 OPTIONAL; The dimensions of color swatch images to create in format NxN, for example 400x400 or 200x100. If not provided, or if provided as the word DEFAULT, a default image size is used. (uniformFillColorImage.sh parameter $1). Smallish resolution strongly recommended.
# Example that will create 200x200 color swatches for every color from source file `plum_tree_in_bloom_reduced_03.hexplt`:
#    hexplt2swatches.sh plum_tree_in_bloom_reduced_03.hexplt 200x200
# Example that will do the same using a default resolution:
#    hexplt2swatches.sh plum_tree_in_bloom_reduced_03.hexplt
# NOTE
# This script supplies uniformFillColorImage.sh with parameter $2 for that script for every time it calls it, using a different color from the source .hexplt file. It assumes full opacity, so per that script's requirement of specifying that in the hex color code, this script appends ff to each color. (The .hexplt format uses six hex digits, not eight; .hexplts also assume full opacity and don't use the 7th and 8th opacity digits in a hex color code.)


# CODE
if [ "$1" ]; then srcHexpltFile=$1; else printf "\nNo parameter \$1 (input .hexplt file) passed to script. Exit."; exit 1; fi

# this may be overriden by logic on the line after it:
imageResolution=250x250
if [ "$2" ] && [ "$2" != "DEFAULT" ]; then imageResolution=$2; fi

pathToSourcePalette=$(findPalette.sh $srcHexpltFile)
if [ "$pathToSourcePalette" == "" ]; then echo "ERROR: source palette file $srcHexpltFile not found. Exit."; exit 1; fi

# get array of colors from file by extracting all matches of a pattern of six hex digits preceded by a #:
colorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $pathToSourcePalette | tr -d '#') )		# tr command removes pound symbol, and surrounding () makes it an actual array

# for count (n of n) print feedback:
colorsArrayLength=${#colorsArray[@]}
i=0
for color in ${colorsArray[@]}
do
	i=$((i + 1))
	echo "creating swatch $i of $colorsArrayLength . ."
	uniformFillColorImage.sh $imageResolution "$color"ff
done