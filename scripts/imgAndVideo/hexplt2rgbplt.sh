# DESCRIPTION
# Converts a .hexplt format palette (a list of RGB colors in hex format) to a list of RGB values. See also rgbplt2hexplt.sh.

# USAGE
# Run this script with one parameter, which is the .hexplt format file to convert, e.g.:
#    hexplt2RGBplt.sh RAHfavoriteColorsHex.hexplt
# NOTE
# If you have an environment variable export of EB_PALETTES_ROOT_DIR set in `~/.bashrc` (in your home folder) which contains one line, set with a Unix-style path to the folder where you keep hex palette (`.hexplt`) files (for example /some_path/_ebPalettes/palettes), this script will search all paths below that root folder for the file, IF the file is not in the same directory you run this script from. If the file is in the same directory, it uses it from the same directory. See _ebPalettes/setEBpalettesEnvVars.sh.


# CODE
if [ ! "$1" ]; then printf "No .hexplt file name passed to script. Expected as parameter \$1."; exit 1; else paletteFile=$1; fi
renderTargetFile=${paletteFile%.*}.rgbplt

# Search for palette with utility script; exit with error if it returns nothing:
hexColorSrcFullPath=$(findPalette.sh $paletteFile)
if [ "$hexColorSrcFullPath" == "" ]
then
	echo "!---------------------------------------------------------------!"
	echo "No file of name $paletteFile found. Consult findPalette.sh. Exit."
	echo "!---------------------------------------------------------------!"
	exit 1
fi
echo "File name $paletteFile found at $hexColorSrcFullPath! PROCEEDING. IN ALL CAPS."

# get array of colors from file by extracting all matches of a pattern of six hex digits preceded by a #:
colorsArray=( $(grep -i -o '#[0-9a-f]\{6\}' $hexColorSrcFullPath | tr -d '#') )		# tr command removes pound symbol, and surrounding () makes it an actual array

# wipe / create target file before printing to:
printf "" > $renderTargetFile
for color in ${colorsArray[@]}
do
	# nesting hex conversion echo 0x<value> with substring ${variable:startcolumn:endcolumn} :
	echo $((0x${color:0:2})) $((0x${color:2:2})) $((0x${color:4:2})) >> $renderTargetFile
done