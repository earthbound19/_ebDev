# DESCRIPTION
# Renders a phrase to an image from every font in the current path, with a caption giving the font name. The image is named after the font and saved to a ./fontRenders subdirectory.

# USAGE
#  previewFonts.sh

# TO DO:
# - Document this
# PARAMETERS yet to be programmed:
# $1 caption
# $2 pointsize
# $3 approx img size X

# DEPENDENCIES
# imagemagick, find (find), CourierMegaRS.ttf (Courier Mega Rounded Slab Regular font), a directory full of .ttf and/or .otf fonts you wish to render a phrase from.


# CODE
# If it doesn't exist, create a fontRenders subfolder to render all images into
if [ ! -d fontRenders ]
then
	mkdir fontRenders
fi

# CODE
find \*.ttf \*.otf | tr -d '\15\32' > all_fonts.txt
while IFS= read -r element || [ -n "$element" ]
do
	fileName="${element%.*}"
	echo -~-~
	# Render typeface declaration
	magick convert -background lightgrey -fill darkviolet -font CourierMegaRS.ttf -pointsize 20 -size 1000 caption:"Typeface: $fileName" tmpIMG1_fjinm732nCz.png
	# Render caption
	echo Rendering phrase from $fileName . . .
	magick convert -background lightgrey -fill darkviolet -font $element -pointsize 82 -size 1000 caption:"TESSERACT GROUP\nTesseract Group\ntesseract group" tmpIMG2_fjinm732nCz.png
	# Composite them and save the result to an image named after the font, in the ./fontRenders subdir
	magick tmpIMG1_fjinm732nCz.png tmpIMG2_fjinm732nCz.png -background lightgrey -gravity Southwest -append fontRenders\\$fileName.png
	echo -~-~
done < all_fonts.txt

rm all_fonts.txt tmpIMG1_fjinm732nCz.png tmpIMG2_fjinm732nCz.png