# DESCRIPTION
# Takes the first and last color from input .hexplt file $1 and makes a gradient of N ($2) colors from the first to the last color, by interpolating through oklab color space, via `interpolateTwoSRGBColors_coloraide.py`. Prints the result to stdout.

# DEPENDENCIES
# - `interpolateTwoSRGBColors_coloraide.py` and its dependencies.
# - previously `get_color_gradient_OKLAB.js` and its dependencies (nodejs and a package), `getFullPathToFile.sh`

# USAGE
# Call with the following parameters:
# - $1 REQUIRED. Input .hexplt format file name
# - $2 REQUIRED. How many colors to interpolate between the first and last color in that .hexplt file.
# - $3 OPTIONAL. Any other flags that may be passed to `interpolateTwoSRGBColors_coloraide.py`, for example '-c oklab' to do interpolation in the oklab color space, or '-c oklch' to do interpolation in the oklch color space. The called script has a default of '-c hct' if this is omitted.
# For example, to print a gradient of 7 colors interpolated between the first and last colors of the file 2ag7_palette.hexplt in the default (hct) space, run:
#    gradientFirstAndLastHexpaletteColors.sh 2ag7_palette.hexplt 5
# NOTE
# To do the same but in oklch space, run:
#    gradientFirstAndLastHexpaletteColors.sh 2ag7_palette.hexplt 5 '-c oklch'
# - The number of colors interpolated includes the first and last color. Asking for 5 colors will give you the start color, three colors between it and the end color, and the end color: start + 3 + end = 5.
# - To call the script `get_color_gradient_OKLAB.js` instead, uncomment line for that after the DEPRECATED comments, and comment out the line after it. It will work because that .js script uses the same switches. However, as noted above, you can interpolate in oklab space by passing '-c oklab' as a third parameter in this script.

# CODE
if [ "$1" ]; then inputFile=$1; else printf "\nNo parameter \$1 (input .hexplt format file) passed to script. Exit."; exit 1; fi
if [ "$2" ]; then nColorsToInterpolate=$2; else printf "\nNo parameter \$2 (how many colors to interpolate between the first and last color in input file $1) passed to script. Exit."; exit 2; fi

# get array of colors from file by extracting all matches of a pattern of six hex digits preceded by a #:
colorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $inputFile) )
# Get number of colors (from array):
howManyColors=${#colorsArray[@]}

# get first colors from source palette:
firstColor=${colorsArray[0]}
# get last color from source palette: - 1 index because of zero-based indexing:
lastColor=${colorsArray[$(($howManyColors - 1))]}

# locate script to call, via another script:
	# DEPRECATED option:
	# scriptToFind="get_color_gradient_OKLAB.js"
scriptToFind="interpolateTwoSRGBColors_coloraide.py"
pathToScript=$(getFullPathToFile.sh $scriptToFind)
if [ "$pathToScript" == "" ]; then echo "ERROR: script to call $scriptToFind apparently not found. Exit."; exit 3; fi

	# DEPRECATED option: create and print gradient via nodejs and script call
	# node $pathToScript -s $firstColor -e $lastColor -n $nColorsToInterpolate
python $pathToScript -s $firstColor -e $lastColor -n $nColorsToInterpolate
