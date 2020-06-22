# DESCRIPTION
# using other scripts, compares all images in a directory. For the first image, it lists which
# image is most similar to it, then does the same for the second, then third image, and on until
# the end of the image list. The result is a list of images where every image is adjacent to the
# two images which are most similar to it. Then it strings those images together into a 60fps
# animation.

# Examine comments in the scripts this recipe uses (which are at https://github.com/earthbound19/_ebDev) to get an idea what goes on here. Run the following commands and scripts as listed, adapting for your situation. At this writing, ffmpegCrossfadeIMGsToAnimFromFileList.sh has comments which may be more complete than this recipe listing of scripts.

	# All images you operate on must be pngs for this to work:
	# To render pngs from all svgs in the current directory, run:
	# allSVG2img.sh 1080 png
imgsGetSimilar.sh png
	# After that step, if you want to insert an image to the very start of the process (e.g. to fade in from black and back to black at the end), name that image e.g. 000.png so that the following scripts will sort that first in the process:
mkNumberedCopiesFromFileList.sh
cd _temp_numbered
ffmpegAnim.sh 60 60 13 png

# Result will be in ..?