# DESCRIPTION
# Creates a converted copy of image file name $1 to format $2, via ImageMagick. Will not convert if render target already exists.

# DEPENDENCY
# ImageMagick installed in your PATH.


# USAGE
# Run this script with these parameters::
# - $1 the file name of the file to convert
# - $2 the image extension (format) to convert it to (without any . in the extension).
# For example, to create a converted copy of color_growth_title.psd to a .png image, run:
#    img2img.sh color_growth_title.psd png
# NOTES
# - To batch convert many images of one type to another, see imgs2imgs.sh (which calls this script repeatedly).
# - For svgs, use SVG2img.sh or allsvg2img.sh, not this. This will do very crummy upscaling of vector images, _post-resterization_.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source image type to convert) passed to script. Exit."; exit 1; else sourceIMG=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (format or extension to convert to) passed to script. Exit."; exit 1; else destIMGformat=$2; fi

renderTarget=${sourceIMG%.*}.$destIMGformat
if [ -e $renderTarget ]
then
	printf "\n~\nRender target $renderTarget already exists; skipping render. To recreate it, delete it and run this script again with the same parameters.\n"
else
	printf "\n~\nWill create converted copy of $sourceIMG as $renderTarget . . .\n"
	magick convert $sourceIMG -flatten $renderTarget 2>/dev/null
fi