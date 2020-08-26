# DESCRIPTION
# Creates cropped .bmp images with white borders and a black interior (I think) from all .png images in a directory tree. Useful for prepping art for conversion to a vector format without wasted border space. NOTE: this relies on one of Fred's ImageMagick scripts, which are not freely redistributable; you'll have to download it from the source yourself at: http://www.fmwconcepts.com/ImageMagick/innercrop/index.php -- However, I use GraphicsMagick, so that all ImageMagick utilities are executed as `gm (utility name)`.

# USAGE
# Run from a directory tree full of .png images, without any parameter:
#    cropAllPNG2BMP.sh


# CODE
# TO DO:
# - upgrade listing to all possible image types.
# - make a private fork of Fred's scripts that use GraphicsMagick, since I've migrated to that for all of my scripts? Keep a legacy ImageMagick install? :/
find . -maxdepth 1 -iname \*.png > crop_imgs.txt

i=0
while read element
do
	imgFileNoExt=`echo $element | sed 's/\(.*\)\..\{1,4\}/\1/g'`
	if [ -a $imgFileNoExt.bmp ]
	then
		der=duh
	else
		echo processing $imgFileNoExt
		echo command is\:
		echo innerCrop.sh -o black $element $imgFileNoExt.bmp
		innerCrop.sh -o black $element $imgFileNoExt.bmp
# UNCOMMENT the next line to pause between conversions and thereby reduce CPU usage/heat:
echo pausing for a bit to cool the processor . . . && sleep 4
# ! --------
# OPTIONAL--COMMENT OUT THE NEXT LINE IF YOU DON'T WANT THE ORIGINAL IMAGE DELETED! :
rm $element
# ! --------
	i=$[ $i+1 ]
	fi
done < crop_imgs.txt

echo Cropped $i images. Done.

rm crop_imgs.txt

# ex. command: innerCrop.sh -o black der.png out.bmp