# DESCRIPTION
# Creates converted copies of all images of many types in the current directory to format $1.

# USAGE
# From a directory with images in it of varying types, run this script with one parameter, which is the target format (or extension, without the . in it) to create converted copies of. For example, to create converted copies of many images in .jpg format, run:
#    IMGsTypesToIMGs.sh jpg


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (target format or extension (without any .) to convert to) passed to script. Exit."; exit 1; else destIMGformat=$1; fi

allIMGfileNamesArray=($(printAllIMGfileNames.sh))

for fileName in ${allIMGfileNamesArray[@]}
do
	img2img.sh $fileName $destIMGformat
done
