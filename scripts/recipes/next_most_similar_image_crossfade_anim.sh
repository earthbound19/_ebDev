# DESCRIPTION
# see next_most_similar_image_anim.sh in this repo.

# Examine comments in the scripts this recipe uses (which are at https://github.com/earthbound19/_ebDev) to get an idea what goes on here. Run the following commands and scripts as listed, adapting for your situation. At this writing, ffmpegCrossfadeIMGsToAnimFromFileList.sh has comments which may be more complete than this recipe listing of scripts.

	# All images you operate on must be pngs for this to work:
	# To render pngs from all svgs in the current directory, run:
	# allSVG2img.sh 1080 png
imgsGetSimilar.sh png
	# After that step, if you want to insert an image to the very start of the process (e.g. to fade in from black and back to black at the end), name that image e.g. 000.png so that the following scripts will sort that first in the process:
mkNumberedCopiesFromFileList.sh
cd _temp_numbered
# NOTE: calls ffmpegCrossfadeIMGsToAnim.sh, for which you may want to adjust hard-coded parameters! :
ffmpegCrossfadeIMGsToAnimFromFileList.sh
cd fadeSRCvideos
# allVidsType2VcompatMP4.sh avi
	# ALTERNATE to that, but not preferred, as it means no audio, and some stupid TVs present ugly complaints if no audio stream:
	# allVid2vid.sh avi mp4
concatVidFiles.sh mp4
addBlankSoundToVid.sh _mp4sConcatenated.avi

# Result will be in ..?