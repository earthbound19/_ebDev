# DESCRIPTION
# Retrieves a random palette from the /palettes subdirectory of the _ebPalettes repository, and prints the file name of it. Optionally copies the file to the current directory.

# TO DO: the same from a GitHub API call against the remote _ebPalettes repository, see `printContentsOfRandomPalette_GitHubAPI.sh`. If it can't find the palette directory, it doesn't say so, and prints nothing.

# DEPENDENCIES
# An environment variable export of EB_PALETTES_ROOT_DIR set in `~/.bashrc` (in your home folder) which contains one line, set with a Unix-style path to the folder where you keep hex palette (`.hexplt`) files (for example /some_path/_ebPalettes/palettes). See _ebPalettes/setEBpalettesEnvVars.sh.

# USAGE
# Run with the following paramters:
# - $1 OPTIONAL. Anything, such as the word BRICKSLORF, which will cause the script to copy the randomly selected palette file from the /palettes subdirectory of the _ebPalettes repository to the current directory. If omitted, only the palette file name (without any path) will be printed, and no file will be copied.
# For example, to only print a random palette file name, run:
#    getRandomPaletteFileName.sh
# To print a random palette file name and also copy it into the current directory, run e.g.:
#    getRandomPaletteFileName.sh BRICKSLORF
# To assign the file name of the retrieved pallete to a variable available in a calling shell, run this script via `source`, this way:
# source getRandomPaletteFileName.sh
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
		# copy that palette file (by using that full path to it!) into the current directory if parameter $1 was passed to the script; else don't:
		if [ "$1" ]; then cp $RNDpaletteFileName . ; fi 
		# modify that to file name only, no path:
		RNDpaletteFileNameNoPath="${RNDpaletteFileName##*/}"
		# print that palette file name:
		printf $RNDpaletteFileNameNoPath
		# dev reference print of path to file:
		retrievedPaletteFileName=$RNDpaletteFileName
	fi
fi