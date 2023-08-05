# DESCRIPTION
# Retrieves a random palette from the /palettes subdirectory of the _ebPalettes repository, and prints the colors from it, one per line. To do the same from a GitHub API call against the remote _ebPalettes repository, see `printContentsOfRandomPalette_GitHubAPI.sh`. If it can't find the palette directory, it doesn't say so, and prints nothing.

# DEPENDENCIES
# An environment variable export of EB_PALETTES_ROOT_DIR set in `~/.bashrc` (in your home folder) which contains one line, set with a Unix-style path to the folder where you keep hex palette (`.hexplt`) files (for example /some_path/_ebPalettes/palettes). See _ebPalettes/setEBpalettesEnvVars.sh.

# USAGE
# Run without any parameters:
#    printContentsOfRandomPalette_ls.sh
# To assign the file name of the retrieved pallete to a variable available in a calling shell, run this script via `source`, this way:
# source printContentsOfRandomPalette_ls.sh
# -- and the file name of the retrieved palette will be available as $RNDpaletteFileName in the calling shell.


# CODE
if [ "$EB_PALETTES_ROOT_DIR" ]
then
	if [ -e $EB_PALETTES_ROOT_DIR ]
	then
		allPaletteFiles=( $(find $EB_PALETTES_ROOT_DIR/ -iname '*.hexplt') )
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
		# dev reference print of path to file:
		retrievedPaletteFileName=$RNDpaletteFileName
	fi
fi