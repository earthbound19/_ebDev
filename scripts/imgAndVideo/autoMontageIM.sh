# DESCRIPTION
# Uses imagemagick montage to pack all images of type $1 in the current
# directory into montage. Tiles are padded with a dark gray, and the
# entire result image is padded with a darker gray.

# USAGE
# Invoke the script with one parameter, being an image file type
# without any . in the extension, e.g.:
# autoMontageIM.sh png


# CODE
# If user did not pass parameter $1, warn and exit.
if ! [ "$1" ]; then echo No parameter \$1 passed to script. Exit.; fi

    # Get dimensions of first image of type $1 found.
    # -printf '%f\n' chops off the ./ at the start which we don't want:
firstImage=`gfind . -maxdepth 1 -type f -name "*.png" -printf '%f\n' | head -n 1`
width=`gm identify -format "%w" $firstImage`
height=`gm identify -format "%h" $firstImage`
    # With that information, set a pad size for images to go into the montage.
widthPadding=`echo "$width - ($width * 95.5 / 100)" | scale=0 bc`
heightPadding=`echo "$height - ($height * 95.5 / 100)" | scale=0 bc`
echo Will pad each image to "$widthPadding"x"$heightPadding" . . .
    # "Use > to change the dimensions of the image only if its size exceeds the geometry specification." re: http://astroa.physics.metu.edu.tr/MANUALS/ImageMagick/montage.html#opti
    # (that may be the default anyway though)
    # Also, it seems the -geometry option is intended only to alter the tiled images, not the resultant composite image directly.
# Create the montage to a temp image file.
magick montage -background '#767575' -geometry \>+"$widthPadding"\+"$heightPadding" *.$1 ___oooot_n4yR24PG.png
# Get dimensions of result and calculate desired (larger) pad size for result:
width=`gm identify -format "%w" ___oooot_n4yR24PG.png`
height=`gm identify -format "%h" ___oooot_n4yR24PG.png`
paddedImageW=`echo "$width + ($widthPadding * 2.25)" | scale=0 bc`
paddedImageH=`echo "$height + ($widthPadding * 2.25)" | scale=0 bc`
echo Will pad final montage from $width to $paddedImageW and $height to $paddedImageH . . .
# Pad temp image file to final result file:
gm convert ___oooot_n4yR24PG.png -gravity center -background '#454444' -extent "$paddedImageW"x"$paddedImageH" _montage.png
# Remove temp image file:
rm ___oooot_n4yR24PG.png