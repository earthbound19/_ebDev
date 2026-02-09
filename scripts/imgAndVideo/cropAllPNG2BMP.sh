# DESCRIPTION
# DEPRECATED. You may be able to get this working, but I strongly suggest you use cropTransparencyOffAllImages.py instead. As of 2026-02-08, could not get this .sh script to work with convert.exe / the script it relies on, possibly because of a Windows utility (convert.exe) file name conflict with imagemagick.
# Creates cropped copies of all images of many types in the current directory, such that all areas without any pixels (only transparency -- or alternately only white?) are cropped off, and only a rectangle bounding all pixel values remains. Useful for preparing art for later conversion to a vector format without wasted border space.

# DEPENDENCIES
# - `innercrop.sh` from Fred's ImageMagick scripts, in your PATH. As those scripts are not freely redistributable, you'll have to download it from the source yourself at: http://www.fmwconcepts.com/imagemagick/innercrop/index.php
# - imagemagick and accompanying executable utilities in your PATH _before_ the identically named convert.exe Windows utility (if on Windows), so that imagemagick's convert.exe is called instead of Windows'

# USAGE
# Run from a directory tree full of .png images, without any parameter:
#    cropAllPNG2BMP.sh


# CODE
allImageFileNames=($(printAllIMGfileNames.sh))
fullpathToScript=$(getFullPathToFile.sh innercrop.sh)

counter=0
for imageFileName in ${allImageFileNames[@]}
do
	imgFileNoExt=${imageFileName%.*}
	renderTarget="$imgFileNoExt"_cropped.png
	echo renderTarget is $renderTarget
	if [ ! -f $renderTarget ]
	then
		echo Processing $imageFileName . . .
		echo Command is\:
		echo $fullpathToScript -o black $imageFileName 
		$fullpathToScript -o black $imageFileName $renderTarget
		echo ""
	else
		echo "Render target $renderTarget already exists; skipping. If you intended to do something with source file $imageFileName, perhaps change it to another file format and run this script again."
	fi
	counter=$[ $counter+1 ]
done

echo DONE processing $counter images.