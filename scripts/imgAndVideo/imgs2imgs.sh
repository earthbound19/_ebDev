# DESCRIPTION
# Converts all images of type $1 in the current directory to type $2, by repeated calls of img2img.sh.

# USAGE
# For svgs, use `SVG2img.sh` or `allsvg2img.sh`, not this. This will do very crummy upscaling of vector images, _post-resterization_.
# Run this script with these parameters::
# - $1 the source file format e.g. bmp or png
# - $2 the target file format e.g. tif or jpg
# - $3 OPTIONAL. New image X (pixels across) dimension. Smaller strongly recommended. Aspect matching this many X pixels will be maintained. See details in img2img.sh
# - $4 OPTIONAL. Anything, for example the word HOIHOI, which will cause the script to do conversion in all subfolders also. To use this but not $3, pass the word NULL for $3
# Example that will convert all png images in the current directory to jpgs:
#    imgs2imgs.sh png jpg
# Example that will do the same but force a size of 450 pixels across:
#    imgs2imgs.sh png jpg 450
# Example that will convert all png images to jpg images in all subdirectories as well, but without any resizing (effectively no parameter $3) :
#    imgs2imgs.sh png jpg NULL HOIHOI

# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source image type to convert) passed to script. Exit."; exit 1; else sourceIMGformat=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (source image type to convert) passed to script. Exit."; exit 1; else destIMGformat=$2; fi
if [ "$3" ] && [ "$3" != 'NULL' ]; then param3=$3; fi

# make a paths array which is of all subdirectories if $4 was passed, or only the current directory if $4 was _not_ passed:
if [ "$4" ]
then
	paths=($(find . -type d))
else
	paths=$(pwd)
fi

thisRootDir=$(pwd)
for path in ${paths[@]}
do
	# in the case of paths only having the current path; this is a tiny waste of changing to the same directory:
	cd $path
	fileNamesList=($(find . -maxdepth 1 -type f -name \*.$sourceIMGformat -printf "%f\n"))
	for fileName in ${fileNamesList[@]}
	do
		img2img.sh $fileName $destIMGformat $param3
	done
	cd $thisRootDir
done