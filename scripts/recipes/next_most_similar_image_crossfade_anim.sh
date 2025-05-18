# DESCRIPTION
# Uses other scripts to create a video of crossfades through images sorted roughly by next most similar. Can be useful for exploring new abstract art ideas by crossfading similar (or very different!) images, or to explore visual ideas, or just for curiosity.

# USAGE
# Examine comments in the scripts this recipe uses to get an idea what goes on here. Run the following commands and scripts as listed in the source code, adapting for your situation. Refer to comments in code, but ffmpegCrossfadeIMGsToVideoFromFileList.sh has comments which are more complete. This script does pass on the folowing parameters though--because it's crazy, but I use this script from other scripts and it passes them to a script that passes them, so:
# Run this script with these parameters:
# - $1 OPTIONAL. Duration of crossfades between images, in decimal seconds, e.g. 2.5
# - $2 OPTIONAL. Duration of still image pads between crossfades, in decimal seconds, e.g. 1
# For example to set crossfades of 2.5 seconds and still images of 1 second, run:
#    next_most_similar_image_crossfade_anim.sh 2.5 1


# CODE
if [ "$1" ]; then crossFadeDuration=$1; else crossFadeDuration=2.7; printf "\nNo parameter \$1 (crossfade duration) passed to script. Setting to default $crossFadeDuration"; fi
if [ "$2" ]; then padding=$2; else padding=1.2; printf "\nNo parameter \$2 (padding time of still image between crossfades) passed to script. Setting to default $padding"; fi

pixelFormat="-pix_fmt yuv420p"
	# All images you operate on must be pngs for this to work:
	# To render pngs from all svgs in the current directory, run:
	# allSVG2img.sh 1080 png
imgsGetSimilar.sh png
	# After that step, if you want to insert an image to the very start of the process (e.g. to fade in from black and back to black at the end), name that image e.g. 000.png so that the following scripts will sort that first in the process:
mkNumberedCopiesFromFileList.sh
cd _temp_numbered
ffmpegCrossfadeIMGsToVideoFromFileList.sh $crossFadeDuration $padding
cd fadeSRCvideos
source concatVideos.sh avi fadeSRCvideosList.txt
convertedFileName=${concatenatedVideoFileName%.*}.mp4
ffmpeg -i $concatenatedVideoFileName -crf 13 $pixelFormat $convertedFileName
addBlankSoundToVid.sh $convertedFileName
mv $convertedFileName ../../

echo "DONE. Result is file $convertedFileName. There may be a lot of intermediate files in the fadeSRCvideos subdirectory, which you may want to partly or totally clean up."