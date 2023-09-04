# DESCRIPTION
# Outputs a .png image frame from a given percent (time) of an input video file. Output image is named after the input video and time with a .png extension. Optionally outputs any number of additional frames from a list of percent times. See USAGE.

# DEPENDENCIES
# ffmpeg, ffprobe

# USAGE
# Run with these parameters:
# - $1 an input video file name to export a frame from, and
# - $2 what percent time into the video duration to export a frame from, expressed in decimal (and allowing high decimal precision e.g. .214 -- meaningfulness of that precision (if it is actually useful at all) may depend on the video length).
# - $3, $4, $5 etc. OPTIONAL. Additional percent times to export frames from, as in $2. You may provide any number of these, separated by spaces.
# Example that will export a frame from 86 percent into the source video inputVideo.mp4:
#    ffmpegRipVideoFrameSS.sh inputVideo.mp4 .86
# Example that will export frames from 10 percent, 20 percent, 86 percent, and 95 percent of the same:
#    ffmpegRipVideoFrameSS.sh inputVideo.mp4 0.1 0.2 .86 0.95


# CODE
if [ "$1" ]; then inputFile=$1; else printf "\nNo parameter \$1 (input file name) passed to script. Exit."; exit 1; fi
if [ ! "$2" ]; then echo "\nNo parameter \$2 (percent of time of video to get frame from) passed to script. Exit."; exit 2; fi

# copy arguments to script to array:

OIFS="$IFS"
IFS=$'\n'
arrayOfPercentTimes=("$@")
arrayOfPercentTimes=(${arrayOfPercentTimes[@]:1})
IFS="$OIFS"

for percentTimeToExportFrameFrom in ${arrayOfPercentTimes[@]}
do
	# get duration of video:
	inputMediaDuration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $inputFile)
	selectSecond=$(echo "scale=-0; $inputMediaDuration * $percentTimeToExportFrameFrom" | bc)
	echo "$percentTimeToExportFrameFrom percent of $inputMediaDuration is $selectSecond; exporting from at the time from source file $inputFile . . ."
	outputFileSSstring=$(tr '.' '-' <<< $selectSecond)
	targetFileName=${inputFile%.*}_s"$outputFileSSstring".png

	# re: https://stackoverflow.com/a/1198191/1397555
	ffmpeg -y -ss $selectSecond -i $inputFile -frames:v 1 $targetFileName
done