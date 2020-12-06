# DESCRIPTION
# Extracts image layers from a Photoshop file to numbered, individual images, in a subfolder named <sourceFileName>_scenes.
# SEE ALSO extractIMGlayersGM.sh OR TRY: Photoshop -> File menu -> Export -> Layers to files (and the alpha may only look good if you export to png-24)! This script exports layers in an image file (e.g. psd or tif source file) to png images.

# USAGE
# Run with these parameters:
# - $1 file name to rip layers out of and place in a /$1_layers subdir
# - $2 OPTIONAL. Layer number to extract (no other layers will be extracted). If not provided, all layers will be extracted. If provided as the word "TOP," only the highest layer will be extracted. If provided as any number which corresponds to a layer number that exist in the source image, only that layer will be extracted.
# EXAMPLE COMMAND that will rip all layers from the file inFile.psd, and place them in a subdirectory named inFile_scenes:
#    extractIMGlayersIM.sh inFile.psd
# EXAMPLE COMMAND that will rip the 2nd layer from the file inFile.psd:
#    extractIMGlayersIM.sh inFile.psd 2
# EXAMPLE COMMAND that will rip the topmost layer (scene) from the file inFile.psd:
#    extractIMGlayersIM.sh inFile.psd TOP
# It may work with various layered formats, for example also tif files:
#    extractIMGlayersIM.sh inFile.tif
# -- or perhaps any other supported layered file format.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source file name to extract image layers from) passed to script. Exit."; exit 1; else sourceFileName=$1; fi
imgFileNoExt=${sourceFileName%.*}
subFolderName="$imgFileNoExt"_scenes

# NOTE: this next is a conditional assingment to a global variable:
if [ "$2" ]
then
	layerToExtract=$2
else
	layerToExtract="ALL"
fi

# FUNCTION; extract image layers:
extract_layer_num() {
	# The doom of layers being of wrong size solved here by a genius breath yonder; re: https://stackoverflow.com/a/29400082/1397555
	echo "Attempting to extract layer $1 . . ."
	magick convert \
	$sourceFileName[0] \
	$sourceFileName[$1] \
	\(                    \
	 -clone 0           \
	 -alpha transparent \
	\)                    \
	-swap 0           \
	+delete           \
	-coalesce         \
	-compose src-over \
	-composite        \
	"$subFolderName""/""$imgFileNoExt"_layer"$1".png
}

# If it does not already exist, create subdir named after image to extract layers to; else exit with message folder already exists:
if [ ! -d $subFolderName ]
then
	mkdir $subFolderName
# If that case succeeded (if we newly created a folder), do image processing work (identify number of layers, and conditionally extract certain layers to new subfolder:
	# BEGIN ALL LAYERS EXTRACT CASE
	if [ "$layerToExtract" == "ALL" ]
	then
		# get number of file layers:
		topLayerNumber=$(magick identify $1 | wc -l)
		# layer [0] as given in that file we read represents all layers in a layered file flattened, so we actually want topLayerNumber - 1:
		topLayerNumber=$(( topLayerNumber - 1 ))
		echo identified $topLayerNumber layers in file $1.

		for i in $(seq 1 $topLayerNumber)
		do
			# FUNCTION CALL:
			extract_layer_num "$i"
		done
	# END ALL LAYERS EXTRACT CASE
	else
		# BEGIN TOP LAYER EXTRACT (ELSE) CASE
		if [ "$layerToExtract" == "TOP" ]
		then
			# get number of file layers:
			topLayerNumber=$(magick identify $1 | wc -l)
			topLayerNumber=$((topLayerNumber - 1))	# because that ended up +1 what is wanted, BUT ONLY IN THIS CASE. ?
# CONTINUE CODING HERE: WHY DOESN'T THIS WORK??!! :
			# echo "extract_layer_num $topLayerNumber"
			# FUNCTION CALL:
			extract_layer_num "$topLayerNumber"
		else
			extract_layer_num "$layerToExtract"
		fi
		# END TOP LAYER EXTRACT CASE
	fi
else
	printf "\n~\nSubdirectory ""$imgFileNoExt""_scenes already exists; will not clobber. To re-extract the image layers, delete that subdirectory and re-run this script with the same source file name parameter.\n"
fi