# DESCRIPTION: Creates cropped .bmp images from all .png images with white borders and a black interior (I think) in a directory tree. Useful e.g. for prepping art for conversion to a vector format without wasted border space.  NOTE: this relies on one of Fred's imagemagick scripts, which are not freely redistributable; you'll have to download it from the source yourself at: http://www.fmwconcepts.com/imagemagick/innercrop/index.php -- However, I use graphicsmagick, so that all imagemagic utilities are executed as `gm (utility name)`.

# USAGE: call this script from a directory tree full of .png images.

# TO DO: upgrade listing to all possible image types.

find . -iname \*.png > crop_imgs.txt

i=0
mapfile -t imgs < crop_imgs.txt
for element in "${imgs[@]}"
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
done

echo Cropped $i images. Done.

rm crop_imgs.txt

# ex. command: innerCrop.sh -o black der.png out.bmp