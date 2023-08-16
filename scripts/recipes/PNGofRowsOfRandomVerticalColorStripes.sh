# DESCRIPTION
# Uses other scripts to make many rows of various numbers of vertical color stripes from a randomly chosen palette (from _ebPalettes). Alternately can use a specified palette name ($1).

# DEPENDENCIES
# `printContentsOfRandomPalette_ls.sh` or `findPalette.sh`, `randomVerticalColorStripes.sh`, `imgs2imgsNN.sh`, `renumberFiles.sh`, and everything they may rely on.

# USAGE
# Run with these parameters:
# - $1 OPTIONAL the name of a .hexplt file from the _ebPalettes repository (it will be located via findPalette.sh). If not provided, one is randomly chosen via printContentsOfRandomPalette_ls.sh.
# For example, to generate an image using a randomly selected palette, run:
#    PNGofRowsOfRandomVerticalColorStripes.sh
# Or to generate an image from colors in the palette Clairvoyant.hexplt, run:
#    PNGofRowsOfRandomVerticalColorStripes.sh Clairvoyant.hexplt
# A few (IMO, possibly not humble) great palettes to try for parameter $1 are:
#    08_Faded_Lavender_to_Faded_Yellow_Yellow_Orange_Flower.hexplt
#    07_Dusty_Periwinkle_Blue_to_Yellow_Orange_Flower.hexplt
#    Banana_Split.hexplt
#    Clairvoyant.hexplt
# TO DO
# Parameterize min and max stripes, number of rows, and x and Y dimensions of target image.


# CODE
if [ "$1" ]
then
	# Get full path to a specific palette, using RNDpaletteFileName even though it's not random, and even though this is in some sense a waste of a call -- it's just so I can only change one of these two code lines up here :)
	RNDpaletteFileName=$(findPalette.sh $1)
	if [ "$RNDpaletteFileName" == "" ]; then echo "ERROR: palette file is empty. Check setup or usage of either printContentsOfRandomPalette_ls.sh or findPalette.sh, whichever you're using."; exit 1; fi
else
	# get file name of a random palette from palette repo; printContentsOfRandomPalette_ls.sh sets the variable $RNDpaletteFileName usable in this shell if I call it via `source`:
	source printContentsOfRandomPalette_ls.sh &>/dev/null
fi

sourcePaletteFileName="${RNDpaletteFileName##*/}"
paletteFileBaseNameNoExt=${sourcePaletteFileName%.*}

timestamp=$(date +"%Y_%m_%d__%H_%M_%S")
workBaseName="$timestamp"_"$paletteFileBaseNameNoExt"
mkdir $workBaseName
cd $workBaseName
destPixX=1080
destPixY=1920
randomVerticalColorStripes.sh 3 22 26 $sourcePaletteFileName
randomVerticalColorStripes.sh 23 111 12 $sourcePaletteFileName
numPPMs=$(count.sh ppm)
verticalTilesHeight=$(($destPixY / $numPPMs))
imgs2imgsNN.sh ppm png 1080 $verticalTilesHeight
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
magick montage *.png -tile 1x38 -geometry +0+0 ../_FINAL_"$workBaseName".png
cd ..
rm -rf pngIntermediaries
# archive ppm sources into .7z format file, then remove archived source folder:
7z a ppm.7z ppm
rm -rf ppm
cd ..