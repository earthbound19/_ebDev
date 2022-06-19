# DESCRIPTION
# For every pair of colors in a palette, creates a new gradient palette by repeat calls of augmentPalette.sh.

# DEPENDENCIES
# `get_color_gradient_OKLAB.js` (and nodeJS and the packages that script requires), `getFullPathToFile.sh`

# USAGE
# Run with these parameters:
# - $1 the source palette file name
# - $2 OPTIONAL. How many linearly interpolated colors to insert between each color pair in palette file $1. If omitted, a default is used.
# For example, to create a new augmented (gradient) palette for every pair of colors in some_favorite_colors.hexplt, with 16 colors from the start to end color in each pair, run:
#    augmentPalette.sh some_favorite_colors.hexplt 16
# NOTE that this passes the -d (removed duplicate colors from output) switch to get_color_gradient_OKLAB.js. If you don't want that, hack this to remove that switch from the command.



# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source palette file name) passed to script. Exit."; exit 1; else srcHexplt=$1; fi

nColorsAugment=33
if [ ! "$2" ]; then printf "\nNOTE: no parameter \$2 (number of colors to interpolate) passed to script. Defaulting to $nColorsAugment."; else nColorsAugment=$2; fi

# construct directory name to put augmented palettes in
augmentedPalettesOutputDir=${srcHexplt%.*}__augmented_palettes
# create that output directory if it does not exist
if [ ! -d $augmentedPalettesOutputDir ]
then
	mkdir $augmentedPalettesOutputDir
fi

# get full path to nodejs script we will use
fullPathToScript=$(getFullPathToFile.sh get_color_gradient_OKLAB.js)

colorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $srcHexplt | tr -d '#') )
outerLoopArraySliceIDX=0
for outerLoopColor in ${colorsArray[@]}
do
	outerLoopArraySliceIDX=$((outerLoopArraySliceIDX + 1))
	slicedArray=(${colorsArray[@]:$outerLoopArraySliceIDX})
	for innerLoopColor in ${slicedArray[@]}
	do
		outputFileName="$outerLoopColor"_to_"$innerLoopColor"_gradient_"$nColorsAugment"_okLab.hexplt
		# invoke the script we want to use with parameters, and pipe the result to file for this invocation:
		node $fullPathToScript -s $outerLoopColor -e $innerLoopColor -n $nColorsAugment -d > $augmentedPalettesOutputDir/$outputFileName
	done
done