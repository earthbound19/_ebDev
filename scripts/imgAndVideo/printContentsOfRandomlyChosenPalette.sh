# DESCRIPTION
# Retrieves a random palette from the /palettes subdirectory of the _ebPalettes repository, and prints the colors from it, one per line.

# DEPENDENCIES
# The _ebPalettes repository, with the ~/palettesRootDir.txt file created from the createPalettesRootDirTXT.sh in it.

# USAGE
# Run without any parameters:
#    printContentsOfRandomlyChosenPalette.sh


# CODE
if [ -e ~/palettesRootDir.txt ]
then
	# get path from that file:
	palettesRootDir=$(< ~/palettesRootDir.txt)
	# check if that path is valid and proceed only if so:
	if [ -e $palettesRootDir ]
	then
		allPaletteFiles=( $(find $palettesRootDir/ -iname '*.hexplt') )
		# get length of array:
		arrayLength=${#allPaletteFiles[@]}
		# subtract 1 from that for zero-based indexing:
		arrayMaxIDX=$((arrayLength - 1))
		# get random index in range 0-$arrayMaxIDX:
		arrayRNDidx=$(seq 0 $arrayMaxIDX | shuf | head -n 1)
		# get file name of palette at that index:
		RNDpaletteFileName=${allPaletteFiles[$arrayRNDidx]}
		# get contents of that palette file, as array (excluding any other words beside sRGB color codes in the file) :
		colorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $RNDpaletteFileName) )
		# print that array:
		printf '%s\n' "${colorsArray[@]}"
	fi
fi