# DESCRIPTION
# Creates an animation from all images of type $1 in the current directory, by creating numbered hardlinks to them in a temp subdirectory, moving into that directory, creating the animation, moving it out of the directory, then removing the temp directory.

# USAGE
# To create an animation from e.g. all png images in the current directory, invoke this script thus:
#  anim_from_imgs.sh png
# For any other image type specify that (the extension of it without the . in the extension) as parameter $1.


# CODE
if ! [ "$1" ]; then printf "\nNo parameter \$1 (extension of images to make animation from, e.g. png) passed to script. Exit."; exit; fi


mkNumberedLinks.sh $imageFileType
cd _temp_numbered
ffmpegAnim.sh 30 30 13 $imageFileType
mv *.mp4 ..
cd ..
rm -rf _temp_numbered