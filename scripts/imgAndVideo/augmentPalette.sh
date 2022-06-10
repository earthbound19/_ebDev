# DESCRIPTION
# Does linear interpolation in N ($2) steps between each color in a .hexplt palette ($1), in okLab color space (using CHL coordinates). Prints the result to stdout.

# DEPENDENCIES
# `get_color_gradient_OKLAB.js` (and nodeJS and the packages that script requires), `getFullPathToFile.sh`

# USAGE
# Run with these parameters:
# - $1 file name of source .hexplt format file to augment. Must be in the same directory you call this script from.
# - $2 how many linearly interpolated colors to insert between each color in palette file $1.
# - $3 OPTIONAL. Anything, such as the word SNALFOO, which will cause this script to pass a parameter to get_color_gradient_OKLAB.js telling it to deduplicate any adjacent colors from interpolations. In other words, don't ever have the same color repeat. Note that this may effectively override $2 if that results in fewer interpolations between each color. If you have a high number for $2, I strongly recommend using this adjecent deduplication parameter.
# For example, to interpolate 13 colors in between each color in the file Firebird.hexplt, run:
#    augmentPalette.sh Firebird.hexplt 13
# To do the same thing but interpolate 70 colors but also remove duplicate adjacent colors, run:
#    augmentPalette.sh Firebird.hexplt 70 CHELPIGOR
# The result file for this example would be `Firebird_augmented_13.hexplt`.
# NOTES
# - This script checks for a local environment variable $fullPathToOKLABAugmentationScript, which is the full path to the dependency script `get_color_gradient_OKLAB.js`. If that environment variable is not set, it will look for the path to the dependency script via `getFullPathToFile.sh`, and set that variable to what `getFullPathToFile.sh` finds. If you call this script via `source`, that newly set variable will still exist in your shell when this script returns. This will save a call to `getFullPathToFile.sh` if you call this script (`augmentPalette.sh`) again, which can save a lot of time, as that path finding script can run very slow. (It saves time because after the first call, the variable is set and so on the second call, it checks and sees it's already set and doesn't look for it again.) So, if you call this script repeatedly from another script, call it with `source` this way, where `<palette_file_name>` and/or `<N>` change with each call:
#    source augmentPalette.sh <palette_file_name> <N>
# - To write the printed result to a file, redirect it like so:
#    augmentPalette.sh Firebird.hexplt 13 > Firebird_augmented_13.hexplt


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source .hexplt format file) passed to script. Return."; return 1; else sourceHexplt=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (how many steps to interpolate between each color in the source palette) passed to script. Return."; return 1; else interpolationSteps=$2; fi
# set deduplicateAdjacentSamplesParameter as '' (which will do nothing, and it will be overriden in next check if parameter $3 passed to script) :
if [ "$3" ]; then deduplicateAdjacentSamplesParameter='-d'; fi

# Because each new interpolation iteration will start with the same color as the end color of the previous interpolation, we're going to remove the tail color of each interpolation (iteration) via the `-l 1` switch. That means $((N - 1)). ALSO, the understood literal intent of interpolation in this documentation is _how many additional colors in between), which means (start color + inserted colors + end color), which means $((N + 2)). Summing that, it's $((N - 1 + 2)) = $((N + 3)). SO:
interpolationSteps=$(($interpolationSteps + 2))
# (This process will need to tack that last removed color back on after everything is removed.)

# if local environment variable fullPathToOKLABAugmentationScript is not set, set it. If it is set, assume it correct and don't alter it:
if [ ! "$fullPathToOKLABAugmentationScript" ]
then
	scriptName=get_color_gradient_OKLAB.js
	fullPathToOKLABAugmentationScript=$(getFullPathToFile.sh $scriptName)
	# return with error if that's empty:
	if [[ "$fullPathToOKLABAugmentationScript" == "" ]]; then echo "ERROR: could not find script $scriptName in \$PATH. Return."; return 3; fi
fi
# echo "Found $scriptName at $fullPathToOKLABAugmentationScript -- will use that."

# get array of colors from file by extracting all matches of a pattern of six hex digits preceded by a #:
colorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $sourceHexplt | tr -d '#') )		# tr command removes pound symbol, and surrounding () makes it an actual array
# Get number of colors (from array),
numColors=${#colorsArray[@]}
# which we will use with a loop counter to stop at second to last element:
stopLoopAt=$(($numColors -1))
# -- as we'll be getting the last element then, and if we tried to get a last element (N+1) at the last element, we'd go out of bounds of the array index:
counter=0
augmentedPalette=()
for color in ${colorsArray[@]}
do
	thisElement=${colorsArray[$counter]}
	nextElement=${colorsArray[$(($counter + 1))]}
		# optional debug print:
		# echo "idx $counter, element \$color $color\: $thisElement, +1 element $nextElement"
	# get the interpolated color list via call of interpolation script -- note the -l 1 parameter, which remove the last color of the augmentation! -- and put it in an array:
	augmentedPaletteSegment=(
	$(node $fullPathToOKLABAugmentationScript \
	-s $thisElement \
	-e $nextElement \
	-n $interpolationSteps \
	$deduplicateAdjacentSamplesParameter \
	-l 1 \
	)
	)
	# add those to master augmented palette:
	for augmentedColor in ${augmentedPaletteSegment[@]}
	do
		augmentedPalette+=($augmentedColor)
	done
	# increment tracking counter:
	counter=$(($counter + 1))
	# break if counter at array size - 1, or stopLoopAt:
	if [ $counter == $stopLoopAt ]; then break; fi
done

# tack last color of original palette on to that which would otherwise be missing:
augmentedPalette+=("#""${colorsArray[-1]}")
# print completed augmented palette:
for color in ${augmentedPalette[@]}
do
	echo $color
done