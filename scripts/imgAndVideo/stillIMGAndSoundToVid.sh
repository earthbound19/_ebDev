# DESCRIPTION
# Takes an input sound file $1 and still image $2, and creates a video still from $2 matched to duration $1. Then muxes the sound and video together, losslessly embedding (copying) the sound stream. Output file is named <`$1>_still_$2.mp4`. See also stillIMGsAndSoundToVid.sh (plural IMGs, not singular IMG).

# USAGE
# Run with these parameters:
# - $1 input sound file name
# - $2 input still image file name
# For example:
#    stillIMGAndSoundToVid.sh input.wav still.png


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (input sound file name) passed to script. Exit."; exit 1; else inputSoundFile=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (input still image file name) passed to script. Exit."; exit 2; else inputStillImage=$2; fi

pixelFormat="-pix_fmt yuv420p"

soundClipDuraton=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $inputSoundFile)

tmpVideoClipName=${inputStillImage%.*}__still.mp4

# Generate still video of input image to duration of input sound file:
if [ ! -e $tmpVideoClipName ]
then
    ffmpeg -y -loop 1 -i $inputStillImage -t $soundClipDuraton -crf 7 $pixelFormat $tmpVideoClipName
else
    echo "Target file $tmpVideoClipName already exists; will not clobber. To re-create it, delete it and then run this script again with the same parameters."
fi

targetVideoClipName=${inputSoundFile%.*}_sound_compressed__and__${inputStillImage%.*}_still__muxed__.mp4
# Mux the two into one .mp4, then dispose of the temp video file:
if [ ! -e "$targetVideoClipName" ]
then
    ffmpeg -y -i $tmpVideoClipName -i $inputSoundFile -c:v copy -c:a aac $targetVideoClipName
else
    echo "Target file $targetVideoClipName already exists; to recreate it, delete it and then run this script again with the same parameters."
fi

# Delete temp file
rm $tmpVideoClipName