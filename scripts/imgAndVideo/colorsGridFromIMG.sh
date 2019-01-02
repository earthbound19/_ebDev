# to do: parameterize, describe, instruct
# FIX BUGS.
# - temp color extracting folder renames. get it to actually work in a folder named after input image. maybe by removing terminal-unfriendly characters from generated target folder name?
# NOTE the text file after image name it expects: $1.hybrid-colors-hex.txt
# ALSO NOTE that for bugs, the lowest number this script will give you a 2x multiple colors for is 6.

# DEPENDENCIES
# GraphicsMagick e.g. for:
# $ gm convert
# Correct, not imagemagick (like in a related script), which on my Mac install is flaking out on input file parameter lists.

# PARAMETERS
# $1 image file name for which a palette was made.

# TO DO
# Incorporate dominant color extraction and utilization (as bg and/or extended tile)
# ? Fix this zertsmeh_temp_for_colors thing? Maybe try and see if just colors/imagename.png will work again.
# - make for params: num colors, num columns, num rows, tile size.
# - strip bad . characters out of generated intermediate files.


# generate an image from a hex palette input file.
  # count colors in palette.

# Create subdir of large images from colors in input hex file. It's okay--it does this extremely fast.
if [ ! -d ./zertsmeh_temp_for_colors ]
then
  mkdir ./zertsmeh_temp_for_colors
fi

while read element
do
  hexNoHash=`echo $element | sed 's/\#//g'`
  gm convert -size 256x256 xc:\#$hexNoHash zertsmeh_temp_for_colors/$hexNoHash.png
done < $1.hybrid-colors-hex.txt

# make the actual montage image.
# e.g. gm montage colors/5A6D40.png colors/757F26.png colors/C68C15.png colors/8F322F.png colors/954B29.png out.png

# TO DO: implement e.g. -tile 8x40 flag depending on desired aspect, etc.
tileParam="-tile 9x500"

  # make temporary script to create a grid montage of the colors:
echo gm montage $tileParam -background gray -geometry 300x300+0+0 \\ > mkGridHead.txt
  # convert hex color scheme text list file to parameter list for ~magick:
    # to do? make the following in-memory:
sed 's/.*#\(.*\)$/zertsmeh_temp_for_colors\/\1.png \\/' $1.hybrid-colors-hex.txt > mkGridSRCimgs.txt
echo $1.extracted-colors.png > mkGridTail.txt
cat mkGridHead.txt mkGridSRCimgs.txt mkGridTail.txt > mkColorPaletteGrid.sh
rm mkGridHead.txt mkGridSRCimgs.txt mkGridTail.txt
chmod 777 ./mkColorPaletteGrid.sh
./mkColorPaletteGrid.sh
mv ./mkColorPaletteGrid.sh ./$1-mkColorPaletteGrid.sh.txt
mv zertsmeh_temp_for_colors $1.colors

echo DONE--created color palette image is $1.extracted-colors.png, and the .sh script that generated it has been renamed to $1-mkColorPaletteGrid.sh.txt. You will also find color swatch images from the palette in $1.colors.
