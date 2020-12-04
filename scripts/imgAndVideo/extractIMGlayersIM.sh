# DESCRIPTION
# SEE ALSO extractIMGlayersGM. OR TRY: Photoshop -> File menu -> Export -> Layers to files (and the alpha may only look good if you export to png-24)! This script exports layers in an image file (e.g. psd or tif source file) to png images.

# USAGE
# Run this script with $1 parameter, which is a file name to rip layers out of and place in a /$1_layers subdir; e.g.:
#    extractIMGlayersIM.sh inFile.psd
# OR, probably:
#    extractIMGlayersIM.sh inFile.tif
# -- or perhaps any other supported layered file format.


# CODE
# DEV NOTES
# If ever trouble that the following would mitigate? : https://stackoverflow.com/a/29400082/1397555

if [ ! "$1" ]; then printf "\nNo parameter \$1 (source file name to extract image layers from) passed to script. Exit."; exit 1; else sourceFileName=$1; fi

imgFileNoExt=${sourceFileName%.*}
# If it does not already exist, do image processing work (identify layers, create subdir named after image to extract layers ("scenes") to, and extract images to it) ; if it does already exist, warn and exit.
if [ ! -d "$imgFileNoExt"_scenes ]
then
	# get number of file layers:
	numLayers=$(magick identify $1 | wc -l)
	# layer [0] as given in that file we read represents all layers in a layered file flattened, so we actually want numLayers - 1:
	numLayers=$(( numLayers - 1 ))
	echo identified $numLayers layers in file $1.

	mkdir "$imgFileNoExt"_scenes

	for i in `seq 1 $numLayers`
	do
		echo attempting to extract layer $i . . .
		magick $1[$i] "$imgFileNoExt"_scenes/"$imgFileNoExt"_layer"$i".png
	done
else
	echo "Subdirectory ""$imgFileNoExt""_scenes already exists; will not clobber. To re-extract the image layers, delete that subdirectory and re-run this script with the same source file name parameter."
fi