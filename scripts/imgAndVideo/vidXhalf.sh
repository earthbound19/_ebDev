# DESCRIPTION
# Re-encodes video stream of input file $1 at half resolution and copies (losslessly preserves) the audio stream into a new file named "$1"_half_resolution.mp4.

# USAGE
# Run with one parameter, which is the file name of the input video to make a half-resolution copy of:
#    vidXhalf.sh inputVideo.mp4
# Result file will be named <input_file_name>_half_resolution.mp4


# CODE
# ffmpeg parameters to change a video size on encode:
# -vf scale=iw/2:-1
# WHERE 2: will make it half-size, 3 third-size, 4 fourth-size etc.

pixelFormat="-pix_fmt yuv420p"

# check if source video filename contains the string "half_resolution", and skip encoding if it does:
echo "$1" | grep half_resolution &>/dev/null
if [ "$?" == "0" ]
then
	echo "WARNING: source file name "$1" contains the string \"half_resolution\", which indicates that it may itself already have been processed by this script. Assuming you may not want to re-processes it, so skipping. If you do in fact which to process it further, rename it to not contain that string, then run this script against it again."
else
	targetFileName=${1%.*}__half_resolution.mp4
	ffmpeg -y -i "$1" -vf scale=iw/2:-1 -crf 13 -c:a copy $pixelFormat "$targetFileName"
fi