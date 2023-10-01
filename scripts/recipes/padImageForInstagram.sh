# DESCRIPTION
# Using other scripts, pads an image to fit Instagram's blasted aspect constraints (if need be), writing to a new file, using a padding (background) color which is one randomly selected color from a dynamically made palette (quantization) inspired of the image.

# DEPENDENCIES
# getDoesIMGinstagram.sh, color-thief-jimp-palette.js, padImage.py, getFullPathToFile.sh, and their various dependencies. (Yeesh, this is a frankenassembly that uses three different scripting languages.)

# USAGE
# Run with these parameters:
# - $1 REQUIRED source image file name to check any need to pad, and if it's needed, make a padded version of.
# For example: 
#    padImageForInstagram.sh _EXPORTED_2023-07-19zb_v03.tif


# CODE
if [ "$1" ]; then sourceFilename=$1; else printf "\nNo parameter \$1 (source file name) passed to script. Exit."; exit 1; fi

# Determine if source file meets aspect requirements; calling with `source` to set env variables from script; see documentation in it:
source getDoesIMGinstagram.sh $sourceFilename

if [ "$doesInstagram" != "0" ]
then
	echo "Will not do any padding, as source image meets aspect requirements."
else
	echo "Image does not fit aspect requirements. Will pad to x $targetXpix y $targetYpix."
	# computationally wasteful extraction of 1 background color from a quantized pallete:
	paletteExtractorScriptPath=$(getFullPathToFile.sh color-thief-jimp-palette.js)
	# make an array which is an extracted palette:
	genPadColors=($(node $paletteExtractorScriptPath $sourceFilename 8))
	# pick a random color from that by shuffling the order and picking the first:
	OIFS="$IFS"
	IFS=$'\n'
	genPadColors=($(shuf <<<"${genPadColors[*]}"))
	IFS="$OIFS"
	genPadColor=${genPadColors[0]}
	# make new padded image from $targetXpix	$targetYpix set via `source` call of getDoesIMGinstagram.sh earlier, using that $genPadColor:
	padImageScriptPath=$(getFullPathToFile.sh padImage.py)
	python $padImageScriptPath $sourceFilename $targetXpix $targetYpix $genPadColor
fi