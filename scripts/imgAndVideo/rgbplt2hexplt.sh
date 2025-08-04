# DESCRIPTION
# Converts an .rgbplt format palette (a list of RGB values, in decimal) to a list of RGB colors in hex format. See also hexplt2rgbplt.sh.

# USAGE
# Run this script with one parameter, which is the .rgbplt format file to convert, e.g.:
#    hexplt2RGBplt.sh RAHfavoriteColorsHex.rgbplt
# NOTE
# If you have a file ~/palettesRootDir.txt with a root path to search for .hexplt files in it, this script will search all paths below that root folder for the file, IF the file is not in the same directory you run this script from. If the file is in the same directory, it uses it from the same directory.


# CODE
# BEGIN SETUP GLOBAL VARIABLES
if [ ! "$1" ]; then printf "No .rgbplt file name passed to script. Expected as parameter \$1."; exit 1; else paletteFile=$1; fi
renderTargetFile=${paletteFile%.*}.hexplt

# Search for palette with utility script; exit with error if it returns nothing:
rgbColorSrcFullPath=$(findPalette.sh $paletteFile)
if [ "$rgbColorSrcFullPath" == "" ]
then
	echo "!---------------------------------------------------------------!"
	echo "No file of name $paletteFile found. Consult findPalette.sh. Exit."
	echo "!---------------------------------------------------------------!"
	exit 1
fi
echo "File name $paletteFile found at $hexColorSrcFullPath! PROCEEDING. IN ALL CAPS."

paletteFileLines=( $(tr ' ' ',' < $rgbColorSrcFullPath) )		# replace spaces with commas on add to array to bypass IFS confusion of space/newline as separator..
for line in ${paletteFileLines[@]}
do
	# .. and replace it with a space here:
	line=$(echo $line | tr ',' ' ')
	line=$(printf %02x $line)
	echo \#$line >> $renderTargetFile
done