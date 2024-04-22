# DESCRIPTION
# For every palette in the /palettes subfolder of the _ebPalettes repository, tests whether the palette has exactly N ($1) colors, and prints the full path to the palette if so. Optionally prints the full path to the file (instead of the default file name only) and/or copies the file to the current directory.

# DEPENDENCIES
# `printAllPaletteFileNames.sh` and its dependencies

# USAGE
# Run with the following parameters:
# - REQUIRED:    -n OR --number		A positive integer, which is the number of colors to look for in a palette (among all palettes this script scans), and then print the palette name if that many colors is found in it.
# - OPTIONAL:    -c OR --copy    Causes the script to copy every palette file from the /palettes subdirectory of the _ebPalettes repository to the current directory. Without this palette names are only printed
# - OPTIONAL:    -f OR --fullpaths    Causes the script to print the full path to every palette file. Without this, only the pallete file name (and no path) is printed.
# EXAMPLES
# To print all palette file names of palettes that have 2 colors, run:
#    printPaletteFileNamesWithNColors.sh -n 2
# To print all palette file names with 3 colors and also copy them to the current directory, run:
#    printPaletteFileNamesWithNColors.sh -n 3 -c
# To print all palette file names with 2 colors including the full path to each, run:
#    printPaletteFileNamesWithNColors.sh.sh -n 2 --fullpaths
# Or combine -c and -f to print full paths and copy palettes, for every palette with 5 colors:
#    printPaletteFileNamesWithNColors.sh.sh -c -f --number 5
# NOTES
# - If the variable $EB_PALETTES_ROOT_DIR is not set, this script returns without printing anything. See DEPENDENCIES.
# - This may also print nothing if it finds no palette with the given number of -n colors.
# - To store all of the printed palette file names in a bash array, do something like this:
#    foundPaletteFileNames=($(printPaletteFileNamesWithNColors.sh -n 2))
# - If you use the -c switch and an identical palette file name (for a given palette) already exists in the current directory, it will clobber (overwrite) the file without warning. This includes if if there are duplicate palette names in the source repository!


# CODE
# print help and exit if no paramers passed:
PROGNAME=$(basename $0)
OPTS=`getopt -o cfn: --long copy,fullpaths,number -n $PROGNAME -- "$@"`
eval set -- "$OPTS"
while true; do
  case "$1" in
    -n | --number ) NUMBER_OF_COLORS="$2"; shift; shift ;;
    -c | --copy ) COPY_FILES="copy_files_flag_set"; shift ;;
    -f | --fullpaths ) FULL_PATHS="print_full_paths_flag_set"; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [ ! $NUMBER_OF_COLORS ]
then
	echo "no required parameter [-n|--number] (with a positive integer value) passed to script. Exit."
	exit 1
fi

allPaletteFileNames=($(printAllPaletteFileNames.sh -f))

allPaletteFileNamesLength=${#allPaletteFileNames[@]}
counter=1
for paletteFileName in ${allPaletteFileNames[@]}
do
	# echo "WORKING ON:"
	# echo "$counter of $allPaletteFileNamesLength palettes: $paletteFileName ($0) . . ."
	# echo
	# printf "  Checking for render targets related to $paletteFileName _or_ that the palette only has one color . . . "

	# Check if the palette only has one color. If so, skip renders (which would only do a lot of work to do a solid color fill).
	# Test statement found via a genius breath yonder: https://stackoverflow.com/a/7702334
	# In the test statement: get array of colors from file by extracting all matches of a pattern of six hex digits preceded by a #, and then count via wc:
	if test $(grep -i -o '#[0-9a-f]\{6\}' $paletteFileName | wc -l) -eq $NUMBER_OF_COLORS
	then
		# if FLAG_PRINT_NO_PATH was set, strip path from print; otherwise print full path:
		if [ ! "$FULL_PATHS" ]
		then
			# echo that with the path stripped off:
			echo "${paletteFileName##*/}"
		else
			echo $paletteFileName
		fi
		if [ "$COPY_FILES" ]
		then
			cp $paletteFileName .
		fi
	fi
done