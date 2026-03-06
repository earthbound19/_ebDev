# DESCRIPTION
# Creates a CSV For every .hexplt file in the current directory, and optionally all subdirectories, comprised of:
# - a CSV header, which is: count,palette_file_name
# - on rows beneath that, the number of colors for a palette, and respective palette file name

# USAGE
# Run without any parameters:
# - $1 OPTIONAL. Anything, for example the word SHRIOUSLY, which will cause the script to search for .hexplt files in all subdirectories (as well as the current directory). If omitted, the script searches only the current directory.
# - $2 OPTIONAL. Anything, for example the word SHROISULY, which will cause any subdirectory filenames to be printed without the parent path to them (file name only, no path).
# For example, to search and print .hexplt results from only the current directory, run:
#    printColorCountsAllHexplts.sh
# To search and print .hexplt results from the current directory and all subdirectories, run:
#    printColorCountsAllHexplts.sh SHRIOUSLY
# To do the same and print only file names in subdirectories (no paths), run:
#    printColorCountsAllHexplts.sh SHRIOUSLY SHROISULY


# CODE
# If no parameter one, maxdepthParameter will be left at default, which causes find to search only the current directory:
maxdepthParameter='-maxdepth 1'
# If parameter one is passed to script, that changes to nothing, and find's default recursive search will be used (as no maxdepth switch will be passed) :
if [ "$1" ]; then maxdepthParameter=''; fi

palettes=($(find ./ $maxdepthParameter -iname \*.hexplt -printf '%P\n')) 
for paletteFileName in ${palettes[@]}
do
	colorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $paletteFileName) )
	arrayLength=${#colorsArray[@]}
	# strip path from filename if paramater $2 was passed:
	if [ "$2" ]
	then
		paletteFileName="${paletteFileName##*/}"
	fi
	printf "$arrayLength,$paletteFileName\n"
done