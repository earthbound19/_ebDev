# DESCRIPTION
# Retrieves and prints _all_ palette file names from the /palettes subdirectory (and all directories below it) in the _ebPalettes repository. Optionally copies all of them to the current directory as well.

# TO DO: the same from a GitHub API call against the remote _ebPalettes repository, see `printContentsOfRandomPalette_GitHubAPI.sh`. If it can't find the palette directory, it doesn't say so, and prints nothing.

# DEPENDENCIES
# An environment variable export of EB_PALETTES_ROOT_DIR set in `~/.bashrc` (in your home folder) which contains one line, set with a Unix-style path to the folder where you keep hex palette (`.hexplt`) files (for example /some_path/_ebPalettes/palettes). See _ebPalettes/setEBpalettesEnvVars.sh.

# USAGE
# Run with the following paramters:
# - $1 OPTIONAL. Anything, such as the word SNURFHEAP, which will cause the script to copy every palette file from the /palettes subdirectory of the _ebPalettes repository to the current directory. If omitted, only the palette file names (without any paths) will be printed, and no files will be copied.
# For example, to print all palette file names, run:
#    printAllPaletteFileNames.sh
# To print all palette file names and also copy them to the current directory, run e.g.:
#    printAllPaletteFileNames.sh SNURFHEAP
# NOTES
# - To store all of the printed palettes in a bash array, do something like this:
#    allPaletteFileNames=($(printAllPaletteFileNames.sh))
# - If the same palette file name already exists in the current directory (including if there are duplicate palette names in the source repository!) it will clobber (overwrite) the file without warning.

# CODE
if [ "$EB_PALETTES_ROOT_DIR" ]
then
	if [ -e $EB_PALETTES_ROOT_DIR ]
	then
		allPaletteFileNames=( $(find $EB_PALETTES_ROOT_DIR/ -iname '*.hexplt') )
		for paletteFileName in ${allPaletteFileNames[@]}
		do
		paletteFileNameNoPath="${paletteFileName##*/}"
		# print that palette file name:
		echo $paletteFileNameNoPath
		# copy that palette file (by using that full path to it!) into the current directory if parameter $1 was passed to the script; else don't:
		if [ "$1" ]; then cp $paletteFileName . ; fi 
		done
	fi
fi