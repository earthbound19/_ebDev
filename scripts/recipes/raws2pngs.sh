# DESCRIPTION
# Converts all raw images in the current directory to tiffs and then small pngs, using other scripts.

# DEPENDENCIES
# dcraw, 

# USAGE
# Run with these parameters:
# - $1 file format of raw files to convert from. If omitted, defaults to cr2.
# - $2 OPTIONAL. Pixels across to images down to for the pngs. If not provided, png conversion won't even take place. If provided, pngs will be scaled down proportionally using a better resizing method, to this many pixels wide.
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