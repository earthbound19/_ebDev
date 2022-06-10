# DESCRIPTION
# Calls augmentPalette.sh for every .hexplt file in the current directory, with a new file but the same augment (interpolation) parameter for every call. Writes each result to a new file named <originalPaletteBaseFileName>_gradient.hexplt

# USAGE
# Run with these parameters:
# - $1 how many linearly interpolated colors to insert between each color in each palette.
# - $2 OPTIONAL. Anything, such as the word FULFAR, which will cause this script to pass parameter $3 in augmentPalette.sh (which causes any repeat colors right next to each other to be removed, so that a color shows only once, never twice or more).
# An example that will cause 32 colors to be interpolated between every color in every palette in the current directory:
#    augmentAndRenderAllPalettes.sh 32
# An example that will cause 100 colors to be interpolated between every color, but also remove any repeat colors:
#    augmentAndRenderAllPalettes.sh 100 CHOOFY
# NOTES
# An excellent way to destroy (or nurture!) your soul with frustrated impatience is to run this repeatedly in the same directory where . . . you just augmented a palette. This is also known as Recursive Waiting Despair. It really doesn't take a terrible lot for this multiplication, either. 80 * 80 = waiting for 6,400 interpolated colors to calculate and write . . .


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (how many linearly interpolated colors to insert between each color in palette file \$1.) passed to script. Exit."; exit 1; else interpolationSteps=$1; fi
# set deduplicateAdjacentSamplesParameter as '' (which will do nothing, and it will be overrided in next check if parameter $2 passed to script) :
if [ "$2" ]; then deduplicateAdjacentSamplesParameter=$2; fi

hexpltFileNamesArray=( $(find . -maxdepth 1 -type f -iname "*.hexplt" -printf "%P\n") )

# set environment var that will make calls to augmentPalette.sh go much faster (skips path lookup on all runs after only doing it once here) :
scriptName=get_color_gradient_OKLAB.js
fullPathToOKLABAugmentationScript=$(getFullPathToFile.sh get_color_gradient_OKLAB.js)

for fileName in ${hexpltFileNamesArray[@]}
do
	paletteRenderTargetFileName=${fileName%.*}_gradient.hexplt
	# only do render work if the target file does not exist:
	if [ ! -f $paletteRenderTargetFileName ]
	then
		echo "Creating augmented palette (gradient) for file $fileName . . ."
		augmentedPaletteArray=( $(source augmentPalette.sh $fileName $interpolationSteps $deduplicateAdjacentSamplesParameter) )
		# print augmented palette, one line per color:
		printf '%s\n' "${augmentedPaletteArray[@]}" > $paletteRenderTargetFileName
		# get length of augmented palette:
		augmentedPaletteArrayLength=${#augmentedPaletteArray[@]}
		echo "Length of augmented palette is $augmentedPaletteArrayLength colors. Rendering palette . . ."
	#	renderHexPalette.sh $paletteRenderTargetFileName 'NULL' 'NULL' $augmentedPaletteArrayLength 1
	else
		printf "Render target $paletteRenderTargetFileName already exists; will not clobber. To recreate it, delete it and run this script the same way again.\n\n"
	fi
done
