# DESCRIPTION
# Creates a converted copy of image file name $1 to format $2, via ImageMagick, optionally downsizing (with good downsizing method) via $3. If downsizing is done, to try to avoid file name conflicts (to avoid clobbering the original file if converting to the same target format as source), it adds an _x800 (or the number of pixels accross) phrase to the target file name. Will not convert if render target already exists (including if the render target has that number of pixels phrase. Also updates timestamp of target file to match the source it was converted from, for file by time stamp sorting (or any other) reference.

# DEPENDENCY
# ImageMagick installed in your PATH.


# USAGE
# Run this script with these parameters::
# - $1 the file name of the file to convert
# - $2 the image extension (format) to convert it to (without any . in the extension).
# - $3 OPTIONAL. New image X (pixels across) dimension. Smaller strongly recommended. Input image will be converted to linear RGB, downsized with Lanczos method, maintaining aspect, converted back to sRGB, and saved. NOTE: you may be able to use other imagmagick downscale flag options such as percent e.g. 33%, though in the case of percent at least, you'll need to use two percent signs to "escape" those characters on Windows; e.g. 30%% for thirty percent. The conversion to linear RGB described preserves lightness much better in my tests. Photoshop default downscaling produces a happy medium between preserved brightness and perceptual surrounding/mixed darkness. Direct sRGB (no linear intermediary) is worst.
# For example, to create a converted copy of color_growth_title.psd to a .png image, run:
#    img2img.sh color_growth_title.psd png
# NOTES
# - To batch convert many images of one type to another, see imgs2imgs.sh (which calls this script repeatedly).
# - For svgs, use SVG2img.sh or allsvg2img.sh, not this. This will do very crummy upscaling of vector images, _post-resterization_.


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source image type to convert) passed to script. Exit."; exit 1; else sourceIMG=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (format or extension to convert to) passed to script. Exit."; exit 1; else destIMGformat=$2; fi
if [ "$3" ]; then additionalConvertOptions="-colorspace RGB -filter Lanczos -resize $3 -colorspace sRGB"; dimSTR=_"$3x"; fi

renderTarget=${sourceIMG%.*}$dimSTR.$destIMGformat

# if additionalConvertOptions is set, check for redundant dimension string in render target name and exit with warning if there is one, because we would be doing a duplicate render if that is the case:
if [ "$additionalConvertOptions" ]
then
	redundantStringCheck="$dimSTR""$dimSTR"
	echo $renderTarget | grep "$redundantStringCheck"
	if [ "$?" == "0" ]; then echo "WARNING: redundant dimension string \"$redundantStringCheck\" in would-be render target file name \"$renderTarget\", because you may be attempting a conversion that was already done. Skipping render. Exit."; exit; fi
fi

if [ -e $renderTarget ]
then
	printf "\n~\nRender target $renderTarget already exists; skipping render. To recreate it, delete it and run this script again with the same parameters.\n"
else
	printf "\n~\nWill create converted copy of $sourceIMG as $renderTarget . . .\n"
	magick convert $sourceIMG -flatten $additionalConvertOptions $renderTarget 2>/dev/null
	touch -r $sourceIMG $renderTarget
fi