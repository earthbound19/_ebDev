# DESCRIPTION
# I know, the script name is ridiculously long. To print random two-color block etc. character art. Runs `randomNsetCharsAlt.sh` repeatedly, interspersed with calls to `printContentsOfRandomlyChosenPalette.sh`, to print the contents of a randomly chosen palette), and custom code, to get two random colors from the randomly retrieved palette, and set the mintty terminal foreground and background color to those two random colors.

# DEPENDENCIES
# `printContentsOfRandomlyChosenPalette.sh` in your PATH, the `_ebPalettes` repository, and `~/palettesRootDir.txt` created via `createPalettesRootDirTXT.sh` of that same repository. Probably the mintty terminal; maybe compatible things would work.

# USAGE
# Run without any parameters:
#    randomNsetCharsAltTerminalRNDretrievedPalette_mintty.sh

# if ~/palettesRootDir.txt not found, notify and exit.
if [ ! -f ~/palettesRootDir.txt ]; then echo "No ~/palettesRootDir.txt file found (needed by printContentsOfRandomlyChosenPalette.sh). Exit."; exit 1; fi
# (effectively) else continue:

# infinite loop
while :
do
	# get three random palette colors (shuffling result as we get it) :
	randomColors=( $(printContentsOfRandomlyChosenPalette.sh | shuf) )
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