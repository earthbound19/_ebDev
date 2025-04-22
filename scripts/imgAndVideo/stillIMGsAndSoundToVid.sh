# DESCRIPTION
# Takes an input sound file $1 and still images (source animation frames) series in format $2 (default png), and creates a video still from all of them, matched to duration $1. Then muxes the sound and video together, losslessly embedding (copying) the sound stream. Output file is named <`$1>_animation.mp4`. See also stillIMGAndSoundToVid.sh (singular IMG, not plural IMGs). For animation without sound, see ffmpegAnim.sh.

# USAGE
# Run with these parameters:
# - $1 input sound file name
# - $2 OPTIONAL. Input image series file type, e.g. tga. Defaults to png if omitted. These must be zero-padded numbered images e.g. 0.png, 1.png, 2.png or 01.png, 02.png, 03.png, .. 12.png, etc.
# For example, to only specify the input sound file $1 and use the default png for $2:
#    stillIMGAndSoundToVid.sh input.aac
# Or to specify the input sound file $1 and override the default png with tga, run:
#    stillIMGAndSoundToVid.sh input.aac tga


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (input sound file name) passed to script. Exit."; exit 1; else inputSoundFile=$1; fi
if [ "$2" ]; then printf "\nNo parameter \$2 (input still image animation series format, e.g. tga) passed to script. Using default png."; else inFileType=png; fi

# get array of input files; tacked sort on to the end of this because find displays newer files first which can break numbering if files in the middle of a sequence have an older time stamp than the start; also apparently `find` has no built-in options for sorting so this would be the correct way to sort, re: https://serverfault.com/questions/181787/find-command-default-sorting-order
array=( $(find . -maxdepth 1 -type f -name "*.$inFileType" -printf '%f\n' | sort -n) )
# if files are numbered, first file in array is also the first frame number:
first_frame_from_filename=${array[0]%.*}
# lastFoundFileType=${array[-1]}
digitsPadCount=${#first_frame_from_filename}
total_frames=${#array[@]}

# yuv420p is apparently required by BLORGH and probably BLURGH and others:
pixelFormat="-pix_fmt yuv420p"
additionalParams="-preset veryslow"

soundClipDuraton=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $inputSoundFile)

targetVideoClipName=${inputSoundFile%.*}_animation.mp4

framerate=$(echo "$total_frames / $soundClipDuraton" | bc -l)
# printf "total_frames is $total_frames and framerate is $framerate"

# TO PAD to black e.g. 1920x1080, insert this line after the -i input switche's line:
# -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" \
ffmpeg -y \
  -framerate "$framerate" \
  -i %0"$digitsPadCount"d.$inFileType \
  -i "$inputSoundFile" \
  -c:v libx264 -crf 18 -preset ultrafast \
  -shortest -c:a copy \
  "$targetVideoClipName"