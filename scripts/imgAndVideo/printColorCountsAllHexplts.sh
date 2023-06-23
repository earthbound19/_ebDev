# DESCRIPTION
# For every .hexplt file in the current directory, prints the number of colors in the palette, a tab, the palette name, and a newline. Optionally searches and prints .hexplt results from subdirectories also.

# USAGE
# Run without any parameters:
# - $1 OPTIONAL. Anything, for example the word SHRIOUSLY, which will cause the script to search for .hexplt files in all subdirectories (as well as the current directory). If omitted, the script searches only the current directory.
# For example, to search and print .hexplt results from only the current directory, run:
#    printColorCountsAllHexplts.sh
# To search and print .hexplt results from the current directory and all subdirectories, run:
#    printColorCountsAllHexplts.sh SHRIOUSLY


# CODE
# If no parameter one, maxdepthParameter will be left at default, which causes find to search only the current directory:
maxdepthParameter='-maxdepth 1'
# If parameter one is passed to script, that changes to nothing, and find's default recursive search will be used (as no maxdepth switch will be passed) :
if [ "$1" ]; then maxdepthParameter=''; fi

palettes=($(find ./ $maxdepthParameter -iname \*.hexplt -printf '%P\n')) 
for palette in ${palettes[@]}
do
	colorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $palette) )
	arrayLength=${#colorsArray[@]}
	printf "count: $arrayLength\tpalette: $palette\n"
done