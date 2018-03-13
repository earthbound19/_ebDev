# DESCRIPTION
# Compresses the video and audio from any video container (that ffmpeg will handle) with lossless codecs (utvideo and flac) into a new file of the same container format (e.g. .avi, .mp4). The new video will be named <input_video_losslessCompress>.<inputVideoExtension>.

# USAGE
# ./thisScript.sh inputVideo.avi
# OR
# ./thisScript.sh inputVideo.mp4
# etc.


# CODE

# Extract base file name and extension into variables.
fileName="${1%.*}"
fileExt=`echo "${1##*.}"`

ffmpeg -y -i "$1" -codec:a flac -codec:v utvideo "$fileName"_losslessCompress."$fileExt"

echo DONE. $1 has been compressed to "$fileName"_losslessCompress."$fileExt". Examine that file for correctness. If it has no problems\, you may overwrite the original file $1 with the new file.