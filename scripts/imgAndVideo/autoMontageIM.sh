# DESCRIPTION
# Uses imagemagick montage to pack all images of type $1 in the current
# directory into a montage of approximate size $2. Tiles are padded
# with a dark gray, and the entire result image is padded with a darker gray.

# USAGE
# Invoke the script with two parameters, being:
# $1 an image file type, without any . in the extension, e.g.
#  png, not .png. All images of this type in the current
#  directory will be used in the montage. Also,
# $2 OPTIONAL. Approximate intended width of the final montage image,
#  in pixels. Tiles in the image will not be enlarged to fill up space (only
#  shrunk if necessary). For smaller images, if you set an outsized
#  montage size ($2), this could lead to a lot of gray padding
#  around images in the montage. IF NOT PROVIDED, montage size will be
#  ~= to first image found.
# Example invocation that will create a montage of ~800 px wide
#  using all png images in the current directory:
# autoMontageIM.sh png 800


# CODE
# If user did not pass parameter $1, warn and exit.
if ! [ "$1" ]
then
	echo No parameter \$1 \(image type\) passed to script. Exit.
	exit
else
	imageType=$1
fi

    # Get dimensions of first image of type $1 found.
    # -printf '%f\n' chops off the ./ at the start which we don't want:
firstImage=`gfind . -maxdepth 1 -type f -name "*.png" -printf '%f\n' | head -n 1`
originalIMGwidth=`gm identify -format "%w" $firstImage`
originalIMGheight=`gm identify -format "%h" $firstImage`

if ! [ "$2" ]
then
	echo No parameter \$2 \(montage width in pixels\) passed to script\; will set montage width to width of first image found.
	montageWidthInPixels=$originalIMGwidth
else
	montageWidthInPixels=$2
fi

numImagesFound=`gfind . -maxdepth 1 -type f -name "*.png" -printf '%f\n' | wc -l`
SQRTofNumImagesFound=`echo "scale=0; sqrt($numImagesFound) + 1" | bc`
tileWidth=`echo "scale=0; $montageWidthInPixels / $SQRTofNumImagesFound" | bc`

heightToWidthAspect=`echo "scale=5; $originalIMGwidth / $originalIMGheight" | bc`
tileHeight=`echo "scale=0; $tileWidth / $heightToWidthAspect" | bc`
widthPadding=`echo "scale=0; $tileWidth - ($tileWidth * 95.5 / 100)" | bc`
heightPadding=`echo "scale=0; $tileHeight - ($tileHeight * 95.5 / 100)" | bc`
echo "numImagesFound=$numImagesFound SQRTofNumImagesFound=$SQRTofNumImagesFound tileWidth=$tileWidth firstImage=$firstImage originalIMGwidth=$originalIMGwidth originalIMGheight=$originalIMGheight heightToWidthAspect=$heightToWidthAspect tileHeight=$tileHeight widthPadding=$widthPadding heightPadding=$heightPadding"
# Create the montage to a temp image file.
# Because I can't seem to find the escape sequence necessary to do this from bash+cmd, print the command to a bash script, then execute the script:
geometryParam="$tileWidth"x$tileHeight\>+$heightPadding+$heightPadding
echo "magick montage -background '#767575' -tile "$SQRTofNumImagesFound" -geometry '$geometryParam' *.$imageType ___oooot_n4yR24PG.png" > tmp_command_MbVTjRGUYXUJ.sh
./tmp_command_MbVTjRGUYXUJ.sh
rm tmp_command_MbVTjRGUYXUJ.sh
# Get dimensions of result and calculate desired (larger) pad size for result:
originalIMGwidth=`gm identify -format "%w" ___oooot_n4yR24PG.png`
originalIMGheight=`gm identify -format "%h" ___oooot_n4yR24PG.png`
paddedImageW=`echo "$originalIMGwidth + ($widthPadding * 2.25)" | scale=0 bc`
paddedImageH=`echo "$originalIMGheight + ($widthPadding * 2.25)" | scale=0 bc`
echo Will pad final montage from $originalIMGwidth to $paddedImageW and $originalIMGheight to $paddedImageH . . .
# Pad temp image file to final result file:
gm convert ___oooot_n4yR24PG.png -gravity center -background '#454444' -extent "$paddedImageW"x"$paddedImageH" _montage.png
# Remove temp image file:
rm ___oooot_n4yR24PG.png