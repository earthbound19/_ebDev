# DESCRIPTION
# Losslessly copies sound and video out of (virtually) any media file starting at $1 seconds for $2 duration (according to parameters passed to script), and also copies metadata and timestamp from source to excerpted copy.

# DEPENDENCIES
# ffmpeg, copyMetadataFromSourceFileToTarget.sh from _ebDev

# USAGE
# Run this script with these parameters:
# - $1 the file to excerpt from
# - $2 the seconds to start at (resolution 00:00:00.0 available -- meaning HH:MM:SS.milliseconds (numbers after the . being milliseconds)
# - $3 how long of a clip to losslessly extract (same time resolution available) from that position. If only seconds, leading zeros (00: etc) can be omitted.
# Example that would copy a 30 second sound and video clip starting at 12 seconds:
#    ffmpegLosslessVideoExcerpt.sh inputFile.mp4 12 30
# NOTES
# - To excerpt everything after the start point, put a stupidly high number as the "how long" (third) parameter. Maybe that's a kludge, but it works.
# - You (apparently) may also specify start and endpoint with ffmpeg like this:
#        ffmpeg -i inputFile -c copy -ss 00:09:23 -to 00:25:33 outputFile


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (file name of source file to excerpt) passed to script. Exit."; exit 1; else sourceFileName=$1; fi

if [ ! "$2" ]; then printf "\nNo parameter \$2 (time to start except at, in format hh:mm:ss.ms) passed to script. Exit."; exit 2; else startTime=$2; fi

if [ ! "$3" ]; then printf "\nNo parameter \$3 (duration to excerpt, beginning at start time, in format hh:mm:ss.ms) passed to script. Exit."; exit 3; else excerptDuration=$3; fi

sourceFileExt=${sourceFileName##*.}
sourceFileNameNoExt=${sourceFileName%.*}

startTimeSTR=$(echo $startTime | tr ':.' '_')
durationSTR=$(echo $excerptDuration | tr ':.' '_') 
renderTargetFileName="$sourceFileNameNoExt"_soundLosslessExtract_ss"$startTimeSTR"_t"$durationSTR"."$sourceFileExt"
ffmpeg -y -i "$sourceFileName" -ss "$startTime" -t "$excerptDuration" -map 0:v -vcodec copy -map 0:a -acodec copy $renderTargetFileName

# Copy metadata from original file to shortened render target, and also update the time stamp of target.mp4 to the media creation date and time from metadata:
copyMetadataFromSourceFileToTarget.sh "$1" $renderTargetFileName FNEORN