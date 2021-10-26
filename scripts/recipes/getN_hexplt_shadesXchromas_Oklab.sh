# DESCRIPTION
# Calls `get_color_gradient_culori.js` repeatedly to construct palettes from files in a source .hexplt file ($1), such that:
# - There is a perceptually uniform gradient of M ($2) tints from white to the color, then the color, then M ($2) shades
# - Every color in that resulting tint <-> shades palette is taken, and a perceptually uniform gradient of N ($3) grays made from each to near desaturated (no chroma, or gray) for that color
# In other words, this script obtains and lists a gamut of tints, shades and saturated and unsaturated colors for every color in a palette. Results will be in palette files named after each color in the source palette. Also, this calls a script to render the result palettes in a layout that shows the tint, shade and chroma gradients' relationships.

# DEPENDENCIES:
# getFullPathToFile.sh, get_color_gradient_culori.sh

# USAGE
# Run with these parameters:
# - $1 source file name of palette in .hexplt format (a list of RGB color hex codes)
# - $2 how many tints and shades to obtain for each color
# - $3 how many chromacities to get (toward gray) for every one of those resultant tints and shades
# - $4 OPTIONAL. How many tints to remove from the start of the tints gradient (which begins nearest white).
# - $5 OPTIONAL. How many shades to remove from the end of the shades gradient (which ends nearest black).
# - $6 OPTIONAL. Any other arbitrary switches (with their optional values) that you want to pass to `get_color_gradient_culori.js`. If there are spaces in these switches, surround all the switches and their values with single or double quote marks. To not use any arbitrary (additional) switches, but use $7, pass the word NULL for this parameter.
# - $7 OPTIONAL. Anything, such as the word FLOOFARF, which will cause the palette renders stage of the script to be skipped.
# Example that will get 3 tints, 3 shades, and 4 chromacities for every tint and shade, for every color in 16_max_chroma_med_light_hues.hexplt:
#    getN_hexplt_shadesXchromas_Oklab.sh 16_max_chroma_med_light_hues.hexplt 3 4
# NOTES
# - The result count of tints and shades is ($2 * 2) + 1, because it is $2 tints + $2 shades + the original color
# - The result count of chromas is that many + (chromas * those tints and shades), because those tints and shades are included unmodified (you get the original tints and shades plus chroma variants).
# - See the optional `extraParams` variable to pass additional arguments in calls to `get_color_gradient_culori.js`

# CODE
# START MAIN SETUP AND CHECKS
# Via another script, check for existence of dependency script (fullPathToCuloriScript will be path to it if it exists) :
fullPathToCuloriScript=$(getFullPathToFile.sh get_color_gradient_culori.js)
if [ "$fullPathToCuloriScript" == "" ]; then printf "\n~\nERROR: dependency script get_color_gradient_culori.js not found in your \$PATH. Will exit."; exit 1; fi

if [ ! "$1" ]; then printf "\nNo parameter \$1 (source .hexplt file name) passed to script. Exit."; exit 1; else sourceHexpltFile=$1; fi; if [ ! -e $sourceHexpltFile ]; then printf "\n~\nERROR: file $sourceHexpltFile not found. Will exit."; exit 1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (how many tints and shades to get for each color in palette) passed to script. Exit."; exit 1; else nShades=$2; fi
if [ ! "$3" ]; then printf "\nNo parameter \$3 (how many chroma to get per tint and shade) passed to script. Exit."; exit 1; else nChroma=$3; fi
nColorsRemoved=0
if [ "$4" ]; then tintsRemoveSwitch="-f $4"; nColorsRemoved=$(($nColorsRemoved + $4)); fi
if [ "$5" ]; then shadesRemoveSwitch="-l $5"; nColorsRemoved=$(($nColorsRemoved + $5)); fi
if [ "$6" ] && [ "$6" != "NULL" ]; then extraParameters=$7; fi
		# DEV / DEBUG PRINTS; in production, comment out everthing here at this indent:
		# echo sourceHexpltFile $sourceHexpltFile
		# echo nShades $nShades
		# echo nChroma $nChroma
		# echo tintsRemoveSwitch $tintsRemoveSwitch
		# echo shadesRemoveSwitch $shadesRemoveSwitch
		# echo nColorsRemoved $nColorsRemoved
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
	# write tints to palette files, whiter first; also doing nShades + 1 else we get fewer than wanted; we want tints not including orig. color:
	node $fullPathToCuloriScript -s ffffff -e $colorNoHashSign -n $(($nShades +1)) $tintsRemoveSwitch $extraParameters >> $destFileName
	# write lower luminance toward black to palette files, luminance nearer original color first;
	# removing first color here, even though user switch doesn't say so, else the original color will be duplicated;
	# same addition applies here:
	node $fullPathToCuloriScript -s $colorNoHashSign -e $colorNoHashSign -n $(($nShades + 1)) -b 0 -f 1 $shadesRemoveSwitch $extraParameters >> $destFileName
	# META! :
	# Read that result file into an array:
	chromaSourceColorsArray=($(<$destFileName))
	# Empty the result file because we're going to write the same colors (with additional colors) back to it:
	printf "" > $destFileName
	for chromaSource in ${chromaSourceColorsArray[@]}
	do
		chromaSourceNoHashSign=$(echo ${chromaSource:1})
		# UNCOMMENT ONLY ONE of the following options; if you use the first, you must -1 in the later calc. renderColumns=$nChroma to renderColumns=$(($nChroma - 1)) :
		# OPTION THAT REMOVES LAST GRAY:
		node $fullPathToCuloriScript -s $chromaSourceNoHashSign -e $chromaSourceNoHashSign -n $nChroma -c 0 -l 1 $extraParameters >> $destFileName
		# OPTION THAT KEEPS LAST GRAY:
		# node $fullPathToCuloriScript -s $chromaSourceNoHashSign -e $chromaSourceNoHashSign -n $nChroma -c 0 $extraParameters >> $destFileName
	done
done

if [ ! "$7" ]
then
	renderColumns=$(($nChroma - 1))
	renderRows=$(( ($nShades * 2) + 1 - $nColorsRemoved))
	renderAllHexPalettes.sh YORP 260 NULL $renderColumns $renderRows
fi

printf "\n~\nDONE generating and (if told to) rendering palettes from source file $sourceHexpltFile."