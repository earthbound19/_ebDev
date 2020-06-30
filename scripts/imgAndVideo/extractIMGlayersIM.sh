# DESCRIPTION
# SEE ALSO extractIMGlayersGM. OR TRY: Photoshop -> File menu -> Export -> Layers to files (and the alpha may only look good if you export to png-24)! This script exports layers in an image file (e.g. psd or tif source file) to png images.

# USAGE
# Invoke this script with $1 parameter, being a file name to rip layers out of and place in a /$1_layers subdir; e.g.:
#  ./extractIMGlayersIM.sh inFile.psd
# OR, probably:
#  ./extractIMGlayersIM.sh inFile.tif
# -- or perhaps any other supported layered file format.

# DEV NOTES
# If ever trouble that the following would mitigate? : https://stackoverflow.com/a/29400082/1397555


# CODE
# identify file layers and write them to a temp text file:
magick identify $1 > tmp_MeK3vSg5HjdntjPkq6K.txt
# Count the number of lines in that:
numLayers=`wc -l < tmp_MeK3vSg5HjdntjPkq6K.txt | tr -d ' '`
rm tmp_MeK3vSg5HjdntjPkq6K.txt
# layer [0] as given in that file we read represents all layers in a layered file flattened, so we actually want numLayers - 1:
numLayers=$(( numLayers - 1 ))
echo numLayers is $numLayers

imgFileNoExt=`echo $1 | gsed 's/\(.*\)\..\{1,4\}/\1/g'`

# create subdir named after image to extract layers ("scenes") to:
if [ ! -d "$imgFileNoExt"_scenes ]; then mkdir "$imgFileNoExt"_scenes; fi

for i in `seq 1 $numLayers`
do
	echo attempting to extract layer $i . . .
	magick $1[$i] "$imgFileNoExt"_scenes/"$imgFileNoExt"_layer"$i".png
done