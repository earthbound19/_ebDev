# DESCRIPTION
# Creates cropped .bmp images from all images of many types in the current directory, such that white area outside black areas is discarded. Useful for preparing art for later conversion to a vector format without wasted border space.

# DEPENDENCIES
# `innercrop.sh` from Fred's ImageMagick scripts, in your PATH. As those scripts are not freely redistributable, you'll have to download it from the source yourself at: http://www.fmwconcepts.com/ImageMagick/innercrop/index.php 

# USAGE
# Run from a directory tree full of .png images, without any parameter:
#    cropAllPNG2BMP.sh


# CODE
allImageFileNames=($(printAllIMGfileNames.sh))

counter=0
for imageFileName in ${allImageFileNames[@]}
do
	imgFileNoExt=${imageFileName%.*}
	renderTarget=$imgFileNoExt.bmp
	echo renderTarget is $renderTarget
	if [ ! -f $renderTarget ]
	then
		echo Processing $imageFileName . . .
		echo Command is\:
		echo innercrop.sh -o black $imageFileName 
		innercrop.sh -o black $imageFileName $renderTarget
		echo ""
	else
		echo "Render target $renderTarget already exists; skipping. If you intended to do something with source file $imageFileName, perhaps change it to another file format and run this script again."
	fi
	counter=$[ $counter+1 ]
done

echo DONE processing $counter images.