# DESCRIPTION
# concatenates all .hexplt files in the current directory into one hexplt named after the directory, and reformats it to include only one comment if any. May be useful after a run of 

# DEPENDENCIES
# `reformatHexPalette.sh`

# USAGE
# From a directory in which all .hexplt files have the same number of columns in their layout _or_ have a number of colors that will evenly divide into N columns, run without these parameters:
# - $1 the number of columns that source hexplts have in their layout.
# For example:
#    catHexpltsGrid.sh 5


# CODE
# The variable in the following conditional will only exist if the conditional evaluates to true; effectively if it evaluates to false we will have a null variable (no columns parameter will be used) :
if [ "$1" ]; then columnsParameter="-c$1"; fi

# get directory name without path:
currentDirNoPath=$(basename $(pwd))
# build target file name from that; add script parameter details to it:
outputFileName="$currentDirNoPath"_palettesGrid.hexplt
# warn and exit if output file already exists, which could result in redundant concatenation:
if [ -f $outputFileName ]; then echo "WARNING: would-be result file name $outputFileName already exists. To re-create it delete it and run this script again. Exit."; exit 1; fi

# concatenate palettes to output file:
cat *.hexplt > $outputFileName

# reformat it if $columns variable was set (by passing $1) :
reformatHexPalette.sh -i $outputFileName $columnsParameter

echo "DONE. Resulting palette file is $outputFileName."
