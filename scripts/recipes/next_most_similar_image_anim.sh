# DESCRIPTION
# Using other scripts, creates an animation where every frame is the next most similar image. Animation is 30fps, but with the source "framerate" for each image at 0.83 FPS (each still in the animation shows ~1.2 seconds).

# USAGE
# Examine the source code of this script, and the scripts it calls, to get an idea what goes on here. Run this script with:
#    next_most_similar_image_anim.sh


# CODE
	# Run the following commands and scripts as listed, adapting for your situation.
	# All images you operate on must be pngs for this to work:
# allSVG2img.sh 1080 png
imgsGetSimilar.sh png
	# After that step, if you want to insert an image to the very start of the process (e.g. to fade in from black and back to black at the end), name that image e.g. 000.png so that the following scripts will sort that first in the process:
mkNumberedCopiesFromFileList.sh
cd _temp_numbered
ffmpegAnim.sh 0.83 30 13 png

# Result will be in ..?