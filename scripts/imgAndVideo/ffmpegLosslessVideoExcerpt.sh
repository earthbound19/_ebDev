# DESCRIPTION
# Identical to ffmpegLosslessAudioExcerpt.sh (SEE), but for video.


# CODE
# TO DO: anything in the script mentioned under DESCRIPTION.

fileExt=`echo "${1##*.}"`
		# echo fileExt val is $fileExt
fileNameNoExt=`echo "${1%.*}"`
		# echo fileNameNoExt val is $fileNameNoExt

ffmpeg -y -i "$1" -ss $2 -t $3 -map 0:v -vcodec copy "$fileNameNoExt"_soundLosslessExtract_ss"$2"_t"$3"."$fileExt"