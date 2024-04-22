# DESCRIPTION
# Retrieves and prints _all_ palette file names from the /palettes subdirectory (and all directories below it) in the _ebPalettes repository. Optionally copies all of them to the current directory as well. Also optionally prints the full path of each palette (by default only prints the file name).

# TO DO: the same from a GitHub API call against the remote _ebPalettes repository, see `printContentsOfRandomPalette_GitHubAPI.sh`. If it can't find the palette directory, it doesn't say so, and prints nothing.

# DEPENDENCIES
# An environment variable export of EB_PALETTES_ROOT_DIR set in `~/.bashrc` (in your home folder) which contains one line, set with a Unix-style path to the folder where you keep hex palette (`.hexplt`) files (for example /some_path/_ebPalettes/palettes). See _ebPalettes/setEBpalettesEnvVars.sh.

# USAGE
# Run with the following parameters:
# - OPTIONAL:    -c OR --copy    Causes the script to copy every palette file from the /palettes subdirectory of the _ebPalettes repository to the current directory. Without this palette names are only printed
# - OPTIONAL:    -f OR --fullpaths    Causes the script to print the full path to every palette file. Without this, only the pallete file name (and no path) is printed.
# EXAMPLES
# To print all palette file names without their path (file name only), run it without any parameters:
#    printAllPaletteFileNames.sh
# To print all palette file names and also copy them to the current directory, run:
#    printAllPaletteFileNames.sh -c
# To print all palette file names including the full path to each, run:
#    printAllPaletteFileNames.sh --fullpaths
# Or combine -c and -f to print full paths and copy palettes:
#    printAllPaletteFileNames.sh -c -f
# NOTES
# - If the variable $EB_PALETTES_ROOT_DIR is not set, this script returns without printing anything. See DEPENDENCIES
# - To store all of the printed palettes in a bash array, do something like this:
#    allPaletteFileNames=($(printAllPaletteFileNames.sh))
# - If you use the -c switch and an identical palette file name (for a given palette) already exists in the current directory, it will clobber (overwrite) the file without warning. This includes if if there are duplicate palette names in the source repository!


# CODE
PROGNAME=$(basename $0)
OPTS=`getopt -o cf --long copy,fullpaths -n $PROGNAME -- "$@"`
eval set -- "$OPTS"
while true; do
  case "$1" in
    -c | --copy ) COPY_FILES="copy_files_flag_set"; shift ;;
    -f | --fullpaths ) FULL_PATHS="print_full_paths_flag_set"; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [ "$EB_PALETTES_ROOT_DIR" ]
then
	if [ -e $EB_PALETTES_ROOT_DIR ]
	then
		allPaletteFileNames=( $(find $EB_PALETTES_ROOT_DIR/ -iname '*.hexplt') )
		for paletteFileName in ${allPaletteFileNames[@]}
		do
		if [ ! "$FULL_PATHS" ]
		then
			# print palette file name with path stripped:
			echo "${paletteFileName##*/}"
		else
			# print that as-is with the full path:
			echo $paletteFileName
		fi
		# if told to do so via flag, copy that palette file (by using that full path to it!) into the current directory if parameter $1 was passed to the script; else don't:
		if [ "$COPY_FILES" ]; then cp $paletteFileName . ; fi 
		done
	fi
fi