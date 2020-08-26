# DESCRIPTION
# Losslessly copies sound and video out of (virtually) any media file starting at $1 seconds for $2 duration (according to parameters passed to script).

# USAGE
# Run this script with these parameters:
# - $1 the file to excerpt from
# - $2 the seconds to start at (resolution 00:00:00.0 available -- meaning HH:MM:SS.milliseconds (numbers after the . being milliseconds)
# - $3 how long of a clip to losslessly extract (same time resolution available) from that position. If only seconds, leading zeros (00: etc) can be omitted.
# Example that would copy a 30 second sound and video clip starting at 12 seconds:
#    ffmpegLosslessVideoExcerpt.sh inputFile.mp4 12 30
# NOTES
# - To excerpt everything after the start point, put a stupidly high number as the "how long" (third) parameter. This is a stupid kludge but it works.
# - You (apparently) may also specify start and endpoint with ffmpeg like this:
#        ffmpeg -i inputFile -c copy -ss 00:09:23 -to 00:25:33 outputFile


# CODE
fileExt=`echo "${1##*.}"`
fileNameNoExt=`echo "${1%.*}"`

ffmpeg -y -i "$1" -ss $2 -t $3 -map 0:v -vcodec copy -map 0:a -acodec copy "$fileNameNoExt"_soundLosslessExtract_ss"$2"_t"$3"."$fileExt"