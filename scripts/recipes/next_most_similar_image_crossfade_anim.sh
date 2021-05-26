# DESCRIPTION
# Uses other scripts to create a video of crossfades through images sorted roughly by next most similar. Can be useful for exploring new abstract art ideas by crossfading similar (or very different!) images, or to explore visual ideas, or just for curiosity.

# USAGE
# Examine comments in the scripts this recipe uses to get an idea what goes on here. Run the following commands and scripts as listed in the source code, adapting for your situation. Refer to comments in code, but ffmpegCrossfadeIMGsToVideoFromFileList.sh has comments which are more complete.


# CODE
	# All images you operate on must be pngs for this to work:
	# To render pngs from all svgs in the current directory, run:
	# allSVG2img.sh 1080 png
imgsGetSimilar.sh png
	# After that step, if you want to insert an image to the very start of the process (e.g. to fade in from black and back to black at the end), name that image e.g. 000.png so that the following scripts will sort that first in the process:
mkNumberedCopiesFromFileList.sh
cd _temp_numbered
# NOTE: you may want to adjust parameters in this next script call! :
ffmpegCrossfadeIMGsToVideoFromFileList.sh
cd fadeSRCvideos
# allVidsType2VcompatMP4.sh avi
	# ALTERNATE to that, but not preferred, as it means no audio, and some stupid TVs present ugly complaints if no audio stream:
	# allVid2vid.sh avi mp4
concatVideos.sh mp4
addBlankSoundToVid.sh _mp4sConcatenated.avi

# Result will be in ..?