# DESCRIPTION
# Losslessly copies sound out of (virtually) any media file $1, starting at $2 seconds for $3 duration. Excertps the full duration from the start by default if $2 and $3 are not specified.

# USAGE
# Run with these parameters: 
# - $1 the file to excerpt from
# - $2 OPTIONAL. File extension (may imply container format) to copy the excerpted sound into, without any '.' in the extension (for example 'm4a' and not '.m4a). If omitted, defaults to extension of source file.
# - $3 OPTIONAL. The seconds to start at (resolution 00:00:00.0 available). If you don't pass this parameter it defaults to no parameter, which starts at the beginning.
# - $4 OPTIONAL. How long of a sound clip to losslessly extract (same time resolution available), starting from position $3. If only seconds, leading zeros (00: etc) can be omitted. If you don't pass this parameter it defaults to no parameter, which will cause the entire duration to be excerpted.
# Example that would copy sound to an m4a container, starting at 12 seconds, for a duration of 30 seconds:
#    ffmpegLosslessSoundExcerpt.sh inputFile.mp4 m4a 12 30


# CODE
# TO DO
# - Create an optional parameter for the end position of the excerpt, which will be subtracted from the start to produce (and override) the duration? Would require parsing and converting format 00:00:00.0 into seconds, substracting, then returning to that time format.
# - Update all scripts that extract to variables fileNameNoExt etc. to use this far more elegant method found at: https://www.cyberciti.biz/faq/Unix-linux-extract-filename-and-extension-in-bash/

# REFERENCE: ffmpeg parameters: -map 0:a : operate only on input audio stream, -ss : seconds to start at, -t: duration to copy, -acodec copy: copy contents without recompression of any kind (LOSSLESS).
if [ "$1" ]; then sourceFile=$1; else printf "\nNo parameter \$1 (source file name) passed to script. Exit."; exit 1; fi
if [ "$2" ]; then destFileExt="$2"; else destFileExt=${sourceFile##*.}; fi
if [ "$3" ]; then startParameter="-ss $3"; startFileNameString="_ss"$3; fi
if [ "$4" ]; then durationParameter="-t $4"; durationFileNameString="_"$4; fi

fileNameNoExt=${sourceFile%.*}

ffmpeg -y -i "$sourceFile" $startParameter $durationParameter -map 0:a -acodec copy "$fileNameNoExt"_soundLosslessExtract"$startFileNameString""$durationFileNameString"."$destFileExt"