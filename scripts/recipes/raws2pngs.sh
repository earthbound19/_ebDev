# DESCRIPTION
# Converts all raw images in the current directory to tiffs and then small pngs, using other scripts.

# DEPENDENCIES
# dcraw, allRAWtoTIFF.sh, imgs2imgs.sh

# USAGE
# Run with these parameters:
# - $1 file format of raw files to convert from. If omitted, defaults to cr2.
# - $2 OPTIONAL. Pixels across to scale the png images down to, maintaining aspect ratio, and using a better downscale resizing method. If omitted, a default pixels across value is used.
# Example that will convert all cr2 images in the current directory to tiffs at the same resolution as the original images:
#    raws2imgs.sh
# Example that will convert all NEF format images (assuming they have the extension .nef) in the current directory to tiff images:
#    raws2pngs.sh nef
# Example that will convert all cr2 images to tiffs and then in turn to pngs 2000 pixels wide:
#    raws2pngs.sh nef 2000


# CODE
if [ ! "$1" ]; then sourceFormat=cr2; else sourceFormat=$1; fi
if [ ! "$2" ]; then destPixAcross=2000; else destPixAcross=$2; fi

allRAWtoTIFF.sh $sourceFormat
imgs2imgs.sh tiff png $destPixAcross