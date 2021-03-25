# DESCRIPTION
# Calls `get_color_gradient_culori.js` repeatedly to construct palettes from files in a source .hexplt file ($1), such that:
# - There is a perceptually uniform gradient of M ($2) tints from white to the color, then the color, then M ($2) shades
# - Every color in that resulting tint <-> shades palette is taken, and a perceptually uniform gradient of N ($3) grays made from each to near desaturated (no chroma, or gray) for that color
# In other words, this script obtains and lists a gamut of tints, shades and saturated and unsaturated colors for every color in a palette. Results will be in palette files named after each color in the source palette. Also, this calls a script to render the result palettes in a layout that shows the tint, shade and chroma gradients' relationships.

# USAGE
# Run with these parameters:
# - $1 source file name of palette in .hexplt format (a list of RGB color hex codes)
# - $2 how many tints and shades to obtain for each color
# - $3 how many chromacities to get (toward gray) for every one of those resultant tints and shades
# Example that will get 3 tints, 3 shades, and 4 chromacities for every tint and shade, for every color in 16_max_chroma_med_light_hues.hexplt:
#    getN_hexplt_shadesXchromas_Oklab.sh 16_max_chroma_med_light_hues.hexplt 3 4
# NOTE
# The result count of tints and shades is ($2 * 2) + 1, because it is $2 tints + $2 shades + the original color
# The result count of chromas is that many + (chromas * those tints and shades), because those tints and shades are included unmodified (you get the original tints and shades plus chroma variants).


# CODE
# START MAIN SETUP AND CHECKS
# Via another script, check for existence of dependency script (fullPathToCuloriScript will be path to it if it exists) :
fullPathToCuloriScript=$(getFullPathToFile.sh get_color_gradient_culori.js)
if [ "$fullPathToCuloriScript" == "" ]; then printf "\n~\nERROR: dependency script get_color_gradient_culori.js not found in your \$PATH. Will exit."; exit 1; fi

if [ ! "$1" ]; then printf "\nNo parameter \$1 (source .hexplt file name) passed to script. Exit."; exit 1; else sourceHexpltFile=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (how many tints and shades to get for each color in palette) passed to script. Exit."; exit 1; else nShades=$2; nShades2moar=$(($nShades + 2)); fi		# +2 because this script removes the start and end of gradients (-f and -l switches to get_color_gradient_culori.js)
if [ ! "$3" ]; then printf "\nNo parameter \$3 (how many chroma to get per tint and shade) passed to script. Exit."; exit 1; else nChroma=$3; nChroma2moar=$(($nChroma + 2));fi
# END MAIN SETUP AND CHECKS

# create array of RGB hex color codes from source palette:
sourceHexpltFileColorsArray=( $(<$sourceHexpltFile) )
# Before we loop, create a palette counting variable:
counter=0
# -- which, with a padding size, we will number the created palettes so that image viewers / file systems will present them in the sort order of the colors in the original palette:
sizeOfArray=${#sourceHexpltFileColorsArray[@]}
digitsToPadTo=${#sizeOfArray}
for color in ${sourceHexpltFileColorsArray[@]}
do
	counter=$(($counter + 1))
	paddedCounterString=$(printf "%0""$digitsToPadTo""d\n" $counter)
	colorNoHashSign=$(echo ${color:1})
	destFileName="$paddedCounterString"__x"$colorNoHashSign"_"$nShades"tints_"$nShades"shades_times"$nChroma"chromas.hexplt
	printf "" > $destFileName
	# write tints to palette files, whiter first:
	node $fullPathToCuloriScript -s $colorNoHashSign -e ffffff -n $nShades2moar -r -f -l >> $destFileName
	# write original color to palette file next:
	echo $color >> $destFileName
	# write lower luminance toward black to palette files, luminance nearer original color first:
	node $fullPathToCuloriScript -s $colorNoHashSign -e $colorNoHashSign -n $nShades2moar -b 0 -f -l >> $destFileName
	# META! :
	# Read that result file into an array:
	chromaSourceColorsArray=$(<$destFileName)
	# Empty the result file because we're going to write the same colors (with additional colors) back to it:
	printf "" > $destFileName
	for chromaSource in ${chromaSourceColorsArray[@]}
	do
		chromaSourceNoHashSign=$(echo ${chromaSource:1})
		node $fullPathToCuloriScript -s $chromaSourceNoHashSign -e $chromaSourceNoHashSign -n $nChroma2moar -c 0 -l >> $destFileName
	done
done

renderColumns=$(($nChroma + 1))
renderRows=$((($nShades * 2) + 1))
renderAllHexPalettes.sh YORP 260 NULL $renderColumns $renderRows

printf "\n~\nDONE generating and rendering palettes from source file $sourceHexpltFile."