# DESCRIPTION
# Losslessly copies sound out of (virtually) any media file starting at $1 seconds for $2 duration (according to parameters passed to script)

# USAGE
# Run with these parameters: 
# - $1 the file to excerpt from
# - $2 the seconds to start at (resolution 00:00:00.0 available)
# - $3 how long of a sound clip to losslessly extract (same time resolution available) from that position. If only seconds, leading zeros (00: etc) can be omitted. 
# Example that would copy 30 seconds of sound starting at 12 seconds:
#    ffmpegLosslessSoundExcerpt.sh inputFile.m4a 12 30
# NOTE
# To excerpt everything after the start point, put a stupidly high number as the "how long" (third) parameter. This is a stupid kludge but it works.


# CODE
# TO DO
# - Create an optional parameter $3, which is the end position of the excerpt, which will be subtracted from $1 to produce (and override) $2? Would require parsing and converting format 00:00:00.0 into seconds, substracting, then returning to that time format.
# - Update all scripts that extract to variables fileNameNoExt etc. to use this far more elegant method found at: https://www.cyberciti.biz/faq/Unix-linux-extract-filename-and-extension-in-bash/

# REFERENCE: ffmpeg parameters: -map 0:a : operate only on input audio stream, -ss : seconds to start at, -t: duration to copy, -acodec copy: copy contents without recompression of any kind (LOSSLESS).
fileExt=${1##*.}
fileNameNoExt=${1%.*}

ffmpeg -y -i "$1" -ss $2 -t $3 -map 0:a -acodec copy "$fileNameNoExt"_soundLosslessExtract_ss"$2"_t"$3"."$fileExt"