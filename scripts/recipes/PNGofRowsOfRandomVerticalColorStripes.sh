# DESCRIPTION
# Uses other scripts to make many rows of various numbers of vertical color stripes from a randomly chosen palette (from _ebPalettes). Alternately can use a specified palette name ($1). It does these things admittedly relatively extremely inefficiently.

# DEPENDENCIES
# `findPalette.sh`, `getRandomPaletteFileName.sh`, `printAllPaletteFileNames.sh`, `randomVerticalColorStripes.sh`, `imgs2imgsNN.sh`, `renumberFiles.sh`, everything they may rely on, and 7z CLI to archive source .ppm files. Also bc command line calculator if you do use the -v --variantspercent switch.

# USAGE
# Run this script with the -h or --help switch for parameters and usage examples:
#    PNGofRowsOfRandomVerticalColorStripes.sh -h

# OTHER NOTES
# Not enough room for this in printed help anymore really, but:
# A few palettes to try for --sourcepalettefilename that may be great are:
   # 08_Faded_Lavender_to_Faded_Yellow_Yellow_Orange_Flower.hexplt
   # 07_Dusty_Periwinkle_Blue_to_Yellow_Orange_Flower.hexplt
   # Banana_Split.hexplt
   # The_Mystic.hexplt

# CODE
# TO DO
# Make multiplier parameter for variant rows with math supporting something like the second randomVerticalColorStripes.sh call here:
    # second ppm batch variant parameters with math supporting this:
    # REFERENCE FOR PARAMETERS THAT WERE HARD-CODED:
    # randomVerticalColorStripes.sh 3 22 26 $sourcePaletteFileName
    # randomVerticalColorStripes.sh 23 111 12 $sourcePaletteFileName
function print_halp {
echo "
USAGE
Run with these parameters, all of optional:
    [-h|--help] overrides all other script parameters to print usage help text and exit the script.
    [-s|--sourcepalettefilename] file name of a .hexplt palette to use (from the _ebPalettes repository /palettes subfolder). If not provided, a random one will be chosen. If provided as the keyword ALL, images will be made with the provided parameters from every palette from that subfolder.
    [-m|--minstripes] integer. Minimum random number of vertical stripes (columns) per row. If omitted a default will be used.
    [-n|--maxstripes] integer. Maximum random number of vertical stripes (columns) per row. If omitted a default will be used.
    [-r|--rows] integer. Number of rows. If omitted a default will be used.
    [-x|--xdimension] integer. Number of pixels across of result PNG (x dimension). If omitted a default will be used.
    [-y|--ydimension] integer. Number of pixels down of result PNG (y dimension). If omitted a default will be used.
    [-v|--variantspercent] percent expressed as decimal. Percent to vary the -m -n -r parameters by for a second run of vertical strips before compositing. Unused if omitted. May be e.g. 0.4 for 40% or 1.3 for 130%. Calculation results will be rounded to the nearest integer.

EXAMPLES
To generate an image using a randomly selected palette and all other defaults, run:
    PNGofRowsOfRandomVerticalColorStripes.sh
Or to generate an image from colors in the palette The_Mystic.hexplt, run:
   PNGofRowsOfRandomVerticalColorStripes.sh -sThe_Mystic.hexplt
Note that it requires no space between the option letter and the parameter, e.g. instead of -s The_Mystic.hexplt that uses -sThe_Mystic.hexplt.
To have minimum 4 columns and maximum 12, using The_Mystic.hexplt as a source palette, run:
   PNGofRowsOfRandomVerticalColorStripes.sh -sThe_Mystic.hexplt -m4 -n12
To additionally specify 20 total rows and dimensions of 640 accross and 480 down, run:
   PNGofRowsOfRandomVerticalColorStripes.sh -sThe_Mystic.hexplt -m4 -n12 -r20 -x640 y480
To do a second run of rows of columns before compositing, with -m -n and -r at 33 percent their values (it will round the results to integers), run:
   PNGofRowsOfRandomVerticalColorStripes.sh -sThe_Mystic.hexplt -m4 -n12 -r20 -x640 y480 -v0.33
NOTES
- Output file name format is <timestamp>_<paletteFileBaseNameNoExt>_RORVCS.png. RORVCS is both a funny word and an acronym for Rows of Random Vertical Color Stripes.
"
}


# NOTES:
# - two colons means it can take one optional parameter.
# Also, see MORE NOTES in the case switch below.
# Also, from a script I saw it can be useful to get the name of the script:
PROGNAME=$(basename $0)
# -- and then use that with the --name argument of getopts:
#    ARGS=`getopt -q --name "$PROGNAME" --long help,output:,verbose --options ho:v -- "$@"`
OPTS=$(getopt -o has::m::n::r::x::y::v:: --long help,sourcepalettefilename::,minstripes::,maxstripes::,rows::,xdimension::,ydimension::,variantspercent:: -n $PROGNAME -- "$@")

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

# SET ANY DEFAULTS that would be overriden by optional arguments here:
	minStripes=3
	maxStripes=22
	rows=26
	xDimension=1920
	yDimension=1080

while true; do
  case "$1" in
    -h | --help ) print_halp; exit 0 ;;
    -s | --sourcepalettefilename ) if [ "$2" == "" ]; then echo "WARNING: No value or a space (resulting in empty value) after optional parameter -s | --sourcepalettefilename. Pass a value without any space after -s (for example: -sThe_Mystic.hexplt), or else don't pass -c and a default value will be used for it. Exit."; exit 4; fi; sourcePaletteFileName=$2; shift; shift ;;
    -m | --minstripes ) if [ "$2" == "" ]; then echo "WARNING: No value or a space (resulting in empty value) after optional parameter -m | --minstripes. Pass a value without any space after -m (for example: -m8), or else don't pass -m and a default value will be used for it. Exit."; exit 4; fi; minStripes=$2; shift; shift ;;
    -n | --maxstripes ) if [ "$2" == "" ]; then echo "WARNING: No value or a space (resulting in empty value) after optional parameter -n | --maxstripes. Pass a value without any space after -n (for example: -n42), or else don't pass -n and a default value will be used for it. Exit."; exit 4; fi; maxStripes=$2; shift; shift ;;
    -r | --rows ) if [ "$2" == "" ]; then echo "WARNING: No value or a space (resulting in empty value) after optional parameter -r | --rows. Pass a value without any space after -r (for example: -r64), or else don't pass -r and a default value will be used for it. Exit."; exit 4; fi; rows=$2; shift; shift ;;
    -x | --xdimension ) if [ "$2" == "" ]; then echo "WARNING: No value or a space (resulting in empty value) after optional parameter -x | --xdimension. Pass a value without any space after -x (for example: -x1080), or else don't pass -x and a default value will be used for it. Exit."; exit 4; fi; xDimension=$2; shift; shift ;;
    -y | --ydimension ) if [ "$2" == "" ]; then echo "WARNING: No value or a space (resulting in empty value) after optional parameter -y | --ydimension. Pass a value without any space after -y (for example: -y1920), or else don't pass -y and a default value will be used for it. Exit."; exit 4; fi; yDimension=$2; shift; shift ;;
    -v | --variantspercent ) if [ "$2" == "" ]; then echo "WARNING: No value or a space (resulting in empty value) after optional parameter -v | --variantspercent. Pass a value without any space after -v (for example: -v0.33), or else don't pass -v and a default value will be used for it. Exit."; exit 4; fi; variantsPercent=$2; shift; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

# dev test prints -- comment out in production:
# echo sourcePaletteFileName is $sourcePaletteFileName
# echo minStripes is $minStripes
# echo maxStripes is $maxStripes
# echo rows is $rows
# echo xDimension is $xDimension
# echo xDimension is $yDimension

arrayOfPaletteFileNames=()
if [ "$sourcePaletteFileName" ] && [ "$sourcePaletteFileName" != "ALL" ]
then
	# Get full path to a specific palette, using RNDpaletteFileName even though it's not random, and even though this is in some sense a waste of a call -- it's just so I can only change one of these two code lines up here :)
	RNDpaletteFileName=$(findPalette.sh $sourcePaletteFileName)
	arrayOfPaletteFileNames+=("$RNDpaletteFileName")
fi
if [ "$sourcePaletteFileName" == "ALL" ]; then arrayOfPaletteFileNames=($(printAllPaletteFileNames.sh --fullpaths)); fi
if [ -z "$sourcePaletteFileName" ]
then
	# get file name of a random palette from palette repo:
	randomPaletteFileName=$(getRandomPaletteFileName.sh)
	arrayOfPaletteFileNames+=($randomPaletteFileName)
fi

if [ -z ${arrayOfPaletteFileNames[0]} ];
then
	echo "ERROR: problem locating or using palette file. Check 1) that you passed a correct palette file name. 2) that it is a valid (non-empty) palette, or findPalette.sh, whichever you're using."
	exit 1
fi

for sourcePaletteFileName in ${arrayOfPaletteFileNames[@]}
do
	fileNameNoPath="${sourcePaletteFileName##*/}"
	paletteFileBaseNameNoExt=${fileNameNoPath%.*}

	timestamp=$(date +"%Y_%m_%d__%H_%M_%S")
	workBaseName="$timestamp"_"$paletteFileBaseNameNoExt"_RORVCS
	mkdir $workBaseName
	cd $workBaseName
	# even though this script call wastes a file lookup the way that script is written now:
	# randomVerticalColorStripes.sh $minStripes $maxStripes $rows $fileNameNoPath
	if [ "$variantsPercent" ]
	then
		# printf to correctly round result to nearest integer; re: https://askubuntu.com/a/574474
		varMinStripes=$(echo "$variantsPercent * $minStripes" | bc | xargs printf %.0f)
		varMaxStripes=$(echo "$variantsPercent * $maxStripes" | bc | xargs printf %.0f)
		varRows=$(echo "$variantsPercent * $rows" | bc | xargs printf %.0f)
		# echo YARSH VARIANTS
		# echo "$minStripes $maxStripes $rows >"
		# echo "$varMinStripes $varMaxStripes $varRows"
		randomVerticalColorStripes.sh $varMinStripes $varMaxStripes $varRows $fileNameNoPath
	fi
	numPPMs=$(count.sh ppm)
	verticalTilesHeight=$(($yDimension / $numPPMs))
	imgs2imgsNN.sh ppm png $xDimension $verticalTilesHeight
	renumberFiles.sh -e png
	# imgList=($(printFilesTypes.sh NEWEST_FIRST png))
	mkdir pngIntermediaries
	mv *.png ./pngIntermediaries
	mkdir ppm
	mv *.ppm ./ppm/
		# DEPRECATED option:
		# read -p "Do things with the images in ./pngIntermediaries if you wish, for example glitch them and/or do Filter Forge filters or digital painting on them. Or do nothing with them. Then, when you're ready for them to be assembled into a 1080x1920 montage, press any key and then ENTER: " USERINPUT
	# the 38 in x38 below is the sum of the images made earlier via randomVerticalColorStripes.sh:
	cd ./pngIntermediaries
	# because with long names magick tripped on writing the file one directory up (failed to write the file), write it here:
	magick montage *.png -tile 1x"$numPPMs" -geometry +0+0 _FINAL_"$workBaseName".png
	# .. and then move it up:
	mv _FINAL_"$workBaseName".png ..
	cd ..
	rm -rf pngIntermediaries
	# archive ppm sources into .7z format file, then remove archived source folder:
	7z a ppm.7z ppm
	rm -rf ppm
	cd ..

	echo DONE. Results are in folder $workBaseName.
done