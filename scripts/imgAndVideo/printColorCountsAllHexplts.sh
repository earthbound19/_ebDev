# DESCRIPTION
# For every .hexplt file in the current directory, prints the number of colors in the palette, a tab, the palette name, and a newline.

# USAGE
# Run without any parameters:
#    printColorCountsAllHexplts.sh


# CODE
palettes=($(find ./ -maxdepth 1 -iname \*.hexplt -printf '%P\n')) 
for palette in ${palettes[@]}
do
	colorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $palette) )
	arrayLength=${#colorsArray[@]}
	printf "count: $arrayLength\tpalette: $palette\n"
done