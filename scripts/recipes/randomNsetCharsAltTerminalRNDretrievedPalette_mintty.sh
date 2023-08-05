# DESCRIPTION
# I know, the script name is ridiculously long. To print random two-color block etc. character art. Runs `randomNsetCharsAlt.sh` repeatedly, interspersed with calls to `printContentsOfRandomPalette_ls.sh`, to print the contents of a randomly chosen palette), and custom code, to get two random colors from the randomly retrieved palette, and set the mintty terminal foreground and background color to those two random colors.

# DEPENDENCIES
# `printContentsOfRandomPalette_ls.sh` in your PATH, the `_ebPalettes` repository, and `~/palettesRootDir.txt` created via `createPalettesRootDirTXT.sh` of that same repository. Probably the mintty terminal; maybe compatible things would work.

# USAGE
# Run without any parameters:
#    randomNsetCharsAltTerminalRNDretrievedPalette_mintty.sh

# if EB_PALETTES_ROOT_DIR undefined found, notify and exit.
if [ ! "$EB_PALETTES_ROOT_DIR" ] || [ ! -e $EB_PALETTES_ROOT_DIR ]
then
	echo "EB_PALETTES_ROOT_DIR undefined, or path defined by that string (\"$EB_PALETTES_ROOT_DIR\") does not exist, or is inaccessible. Needed by printContentsOfRandomPalette_ls.sh (see). Exit."
	exit 1
fi

# infinite loop
while :
do
	# get three random palette colors (shuffling result as we get it) :
	randomColors=( $(printContentsOfRandomPalette_ls.sh | shuf) )
	# only do anything if the retrieved palette has at least 2 colors; otherwise skip this loop iteration:
	arrayLength=${#randomColors[@]}
	if [ $arrayLength -ge 2 ]
	then
		# 1st color of that shuffle will be background, 2nd will be foreground and cursor; only use them if there are at least 2 colors in the palette though:
		BGcolor=${randomColors[0]}
		FGcolor=${randomColors[1]}
		# cursorColor=${randomColors[2]}
		# set colors from those; 11 is bg, 10 is fg, 12 is cursor:
		echo -ne "\e]11;$BGcolor\a"
		echo -ne "\e]10;$FGcolor\a"
		echo -ne "\e]12;$FGcolor\a"
		randomNsetCharsAlt.sh 12 CHALPUR 1
	fi
done