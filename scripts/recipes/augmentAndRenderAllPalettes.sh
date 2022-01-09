# DESCRIPTION
# Calls augmentPalette.sh for every .hexplt file in the current directory, with a new file but the same augment (interpolation) parameter for every call. Writes each result to a new file named <originalPaletteBaseFileName>_gradient.hexplt

# USAGE
# Run with these parameters:
# - $1 how many linearly interpolated colors to insert between each color in each palette.
# For example:
#    augmentAndRenderAllPalettes.sh 32


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (how many linearly interpolated colors to insert between each color in palette file \$1.) passed to script. Exit."; exit 1; else interpolationSteps=$1; fi

hexpltFileNamesArray=( $(find . -maxdepth 1 -type f -iname "*.hexplt" -printf "%P\n") )

# set environment var that will make calls to augmentPalette.sh go much faster (skips path lookup on all runs after only doing it once here) :
scriptName=get_color_gradient_OKLAB.js
fullPathToOKLABAugmentationScript=$(getFullPathToFile.sh get_color_gradient_OKLAB.js)

for fileName in ${hexpltFileNamesArray[@]}
do
	echo "Creating augmented palette (gradient) for file $fileName . . ."
	augmentedPaletteArray=( $(source augmentPalette.sh $fileName $interpolationSteps) )
	paletteRenderTargetFileName=${fileName%.*}_gradient.hexplt
	echo "${augmentedPaletteArray[@]}" > $paletteRenderTargetFileName
	# get length of augmented palette:
	augmentedPaletteArrayLength=${#augmentedPaletteArray[@]}
	echo "Length of augmented palette is $augmentedPaletteArrayLength colors. Rendering palette . . ."
	renderHexPalette.sh $paletteRenderTargetFileName 'NULL' 'NULL' $augmentedPaletteArrayLength 1
done
