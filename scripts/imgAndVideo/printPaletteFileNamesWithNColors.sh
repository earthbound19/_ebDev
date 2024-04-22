# DESCRIPTION
# For every palette in the /palettes subfolder of the _ebPalettes repository, tests whether the palette has exactly N ($1) colors, and prints the full path to the palette if so.

# DEPENDENCIES
# `printAllPaletteFileNames.sh` and its dependencies

# USAGE
# Run with the following parameters:
# - $1 REQUIRED. A positive integer, which is the number of colors to look for in a palette (among all palettes this script scans), and then print the palette name if that many colors is found in it.
# - $2 OPTIONAL. Anything, such as the word FLUBOR, which will cause the script to print the full path to a palette instead of only the palette file name.
# For example, to find and print the names of all palettes which only have one color, run:
#    printPaletteFileNamesWithNColors.sh 1
# Or to find and print the names of all palettes which have three colors, run:
#    printPaletteFileNamesWithNColors.sh 3
# NOTES
# - If this finds no palette with the given number of colors, it prints nothing.
# - To store all of the printed palettes in a bash array, do something like this:
#    foundPaletteFileNames=($(printAllPaletteFileNames.sh))


# CODE
if [ "$1" ]; then nColors=$1; else printf "\nNo parameter \$1 (number of colors to search for in palettes) passed to script. Exit."; exit 1; fi
# Because we're going to use the -f flag with printAllPaletteFileNames.sh to get full paths, we'll want to _remove_ paths if the user passed $2, and set a flag here saying to do so:
if [ ! "$2" ]; then FLAG_PRINT_NO_PATH="true"; fi

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
	if test $(grep -i -o '#[0-9a-f]\{6\}' $paletteFileName | wc -l) -eq $nColors
	then
		# if FLAG_PRINT_NO_PATH was set, strip path from print; otherwise print full path:
		if [ "$FLAG_PRINT_NO_PATH" ]
		then
			# echo that with the path stripped off:
			echo "${paletteFileName##*/}"
		else
			echo $paletteFileName
		fi
	fi
done