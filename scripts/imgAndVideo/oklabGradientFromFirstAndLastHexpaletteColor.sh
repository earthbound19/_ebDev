# DESCRIPTION
# Takes the first and last color from input .hexplt file $1 and makes a gradient of N ($2) colors from the first to the last color, by interpolating through oklab color space, via `get_color_gradient_OKLAB.js`. Prints the result to stdout.

# DEPENDENCIES
# `get_color_gradient_OKLAB.js` and its dependencies (nodejs and a package), `getFullPathToFile.sh`

# USAGE
# Call with the following parameters:
# - $1 REQUIRED. Input .hexplt format file name
# - $2 REQUIRED. How many colors to interpolate between the first and last color in that .hexplt file.
# For example, to print a gradient of 7 colors interpolated between the first and last colors of the file 2ag7_palette.hexplt, run:
#    oklabGradientFromFirstAndLastHexpaletteColor.sh 2ag7_palette.hexplt 5
# NOTE
# The number of colors interpolated includes the first and last color. Asking for 5 colors will give you the start color, three colors between it and the end color, and the end color: start + 3 + end = 5.

# CODE

if [ "$1" ]; then inputFile=$1; else printf "\nNo parameter \$1 (input .hexplt format file) passed to script. Exit."; exit 1; fi
if [ "$2" ]; then nColorsToInterpolate=$2; else printf "\nNo parameter \$2 (how many colors to interpolate between the first and last color in input file $1) passed to script. Exit."; exit 2; fi
# define a variable overwriteOriginalFile if parameter $3 passed to script
if [ "$3" ]; then overwriteOriginalFile=; fi

# get array of colors from file by extracting all matches of a pattern of six hex digits preceded by a #:
colorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $inputFile) )
# Get number of colors (from array):
howManyColors=${#colorsArray[@]}

# get first and last colors from source palette:
firstColor=${colorsArray[0]}
# - 1 on the following because of zero-based indexing:
lastColor=${colorsArray[$(($howManyColors - 1))]}

# locate script to call, via another script:
scriptToFind="get_color_gradient_OKLAB.js"
pathToScript=$(getFullPathToFile.sh $scriptToFind)
if [ "$pathToScript" == "" ]; then echo "ERROR: script to call $scriptToFind apparently not found. Exit."; exit 3; fi

# create and print gradient via nodejs and script call
node $pathToScript -s $firstColor -e $lastColor -n $nColorsToInterpolate
