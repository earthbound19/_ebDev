# DESCRIPTION
# Converts all images of type $1 in the current directory to type $2, by repeated calls of img2img.sh.

# USAGE
# For svgs, use `SVG2img.sh` or `allsvg2img.sh`, not this. This will do very crummy upscaling of vector images, _post-resterization_.
# Run this script with these parameters::
# - $1 the source file format e.g. bmp or png
# - $2 the target file format e.g. tif or jpg
# - $3 OPTIONAL. New image X (pixels across) dimension. Smaller strongly recommended. Aspect matching this many X pixels will be maintained. See details in img2img.sh
# Example that will convert all png images in the current directory to jpgs:
#    imgs2imgs.sh png jpg


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source image type to convert) passed to script. Exit."; exit 1; else sourceIMGformat=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (source image type to convert) passed to script. Exit."; exit 1; else destIMGformat=$2; fi
if [ "$3" ]; then param3=$3; fi

fileNamesList=$(find . -maxdepth 1 -type f -name \*.$sourceIMGformat -printf "%f\n")

for fileName in ${fileNamesList[@]}
do
	img2img.sh $fileName $destIMGformat $param3
done