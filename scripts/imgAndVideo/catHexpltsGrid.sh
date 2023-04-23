# DESCRIPTION
# concatenates all .hexplt files in the current directory into one hexplt named after the directory, and reformats the result to include only one comment, if any. May be useful after a run of `paletteRenamedCopiesByNextMostSimilar.sh`, as the files created by that and concatenated to a new palette by this will give a palette that visually lays out next most similar colors (from the palettes it was made of).

# DEPENDENCIES
# `reformatHexPalette.sh`

# USAGE
# From a directory in which all .hexplt files have the same number of columns in their layout _or_ have a number of colors that will evenly divide into N columns, run without these parameters:
# - $1 OPTIONAL, but strongly recommended, as you may get unexpected results without it, depending on commenting and/or layout of the source files: the number of columns that source hexplts have in their layout. This parameters causes result reformatting via a call to `reformatHexPalette.sh` with a parameter for this many coluns of layout.
# For example:
#    catHexpltsGrid.sh 5


# CODE
# The variable in the following conditional will only exist if the conditional evaluates to true; effectively if it evaluates to false we will have a null variable (no columns parameter will be used) :
if [ "$1" ]; then columnsParameter="-c$1"; fi

# get directory name without path:
currentDirNoPath=$(basename $(pwd))
# build target file name from that; add script parameter details to it:
outputFileName="$currentDirNoPath"_palettes_grid.hexplt
# warn and exit if output file already exists, which could result in redundant concatenation:
if [ -f $outputFileName ]; then echo "WARNING: would-be result file name $outputFileName already exists. To re-create it delete it and run this script again. Exit."; exit 1; fi

# concatenate palettes only if there are any; if there are not print error an exit:
# get list of file names separated by spaces, excluding ones with *_grid* (concatendated or augmented) in the name:
paletteFileNamesList=$(find . -maxdepth 1 -not -iname "*_grid*" -iname "*.hexplt" -printf "%P ")
if [ $paletteFileNamesList == "" ]
then
	thisDir=$(pwd)
	echo "NOTE: No .hexplt files found in directory $thisDir. Exit."; exit 2;
else
	cat $paletteFileNamesList > $outputFileName
	# reformat it if $columnsParameter variable was set (by passing $1) :
	if [ "$columnsParameter" ]
	then
		reformatHexPalette.sh -i $outputFileName $columnsParameter
	fi
	echo "DONE. Resulting palette file is $outputFileName."
fi
