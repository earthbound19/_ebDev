# DESCRIPTION
# Creates a still color video the duration of a source sound, in an mp4 media container, copying the sound losslesly into the video container. Useful for sharing music on silly platforms that only share video but not sound.

#DEPENDENCIES
# randomString.sh, graphicsmagick (convert), ffmpeg

# USAGE
# Run with these parameters:
# - $1 file name of input sound file
# - $2 OPTIONAL. Dimensions of output video, expressed in format NNNNxNNN (for example 1920x1080). Defaults to 1280x720 if omitted.
# - $3 OPTIONAL. Solid color to make video of at size $2. Default #180028 (dark violet) if omitted. May be RGB hex format, and possibly many words (anything that graphicsmagic convert recognizes). If RGB hex format, you may need to surround the parameter in single or double quote marks, for example '#01edfd' for a cyan color.
# Example that will create a video of default size and color from one input sound file:
#    addColorStillVideoToSound.sh Final_Fantasy_Legends__track_01.mp3
# Example that will create a video of size 720x720 of default color from one input sound file:
#    addColorStillVideoToSound.sh Final_Fantasy_Legends__track_01.mp3 720x720
# Example that will create a video of size 720x720 with red still color in hex format:
#    addColorStillVideoToSound.sh Final_Fantasy_Legends__track_01.mp3 720x720 '#ea0000'
# WARNING
# This clobbers (overwrites) the target video file if it already exists, without warning.

# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (source audio file name) passed to script. Exit."; exit 1; else sourceAudioFile=$1; fi
if [ ! "$2" ]; then outputVideoDimensions='1280x720'; else outputVideoDimensions=$2; fi
if [ ! "$3" ]; then stillImageColor='#180028'; else stillImageColor=$3; fi

# -pix_fmt yuv420p is for silly platforms that require that:
pixelFormat="-pix_fmt yuv420p"
sourceAudioFileNoExt=${sourceAudioFile%.*}
rndString=$(randomString.sh 1 14)
stillIMGtmpFileName="$rndString"_tmp_still_image.png
targetVideoFileName="$sourceAudioFileNoExt"_blankVideo.mp4
gm convert -size $outputVideoDimensions xc:$stillImageColor $stillIMGtmpFileName
ffmpeg -y -loop 1 -i $stillIMGtmpFileName -i $sourceAudioFile -c:a copy -shortest -c:v libx264 -tune stillimage $pixelFormat $targetVideoFileName
rm $stillIMGtmpFileName