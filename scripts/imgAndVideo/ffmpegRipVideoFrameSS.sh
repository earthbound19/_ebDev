# DESCRIPTION
# Outputs a .jpg image frame from a given percent (time) of an input video file. Output image is _video_frame_.jpg at this writing (plan: name it after the input video).

# USAGE
# Pass this script two parameters, being:
# $1 an input video file name to grab a frame from, and
# $2 what percent time into the video duration to grab a frame from, expressed in decimal (and allowing high decimal precision e.g. .214 -- meaningfulness of that precision (if it is actually useful at all) may depend on the video length).
# Example:
#  ./ffmpegRipVideoFrameSS.sh inputVideo.mp4 .86

# KNOWN ISSUES
# Copies the whole input video to a temp file; inefficient.

# TO DO
# Make a temporary junction (without funky characters in the file name, so that ffprobe can work on the file) to the input file, and work from the junction?
# Name the output .jpg image after the video file
# Random frame selection if $2 not provided
# Log $2 to a file for future reference


# CODE
# Kludge for titles having spaces in names:
cp "$1" ./tmp_bbE9pWyXSVshTm.mp4
eval "$(ffprobe -v error -of flat=s=_ -show_entries format=duration tmp_bbE9pWyXSVshTm.mp4)"
	# Stupid data wrangling necessary on Windows (which produces windows newlines that muck up intended functionality of the Cygwin echo command:
	echo $format_duration > tmp_eHmZQ2YtWKr8ZV7YpU3MUn3nrMV2tPT8Ge.txt
# NOTE: THE *0.9 means 90 percent, which is what bc will multiply the total seconds of the video by, which will give us a time (in seconds) ninety percent into the video, from which a later ffmpeg command will grab a frame from:
	echo *$2 >> tmp_eHmZQ2YtWKr8ZV7YpU3MUn3nrMV2tPT8Ge.txt
	dos2unix tmp_eHmZQ2YtWKr8ZV7YpU3MUn3nrMV2tPT8Ge.txt
	format_duration=`tr -d '\n' < tmp_eHmZQ2YtWKr8ZV7YpU3MUn3nrMV2tPT8Ge.txt`
	rm tmp_eHmZQ2YtWKr8ZV7YpU3MUn3nrMV2tPT8Ge.txt
	# WORKING bc command example from another script:
	# echo "scale=5; $xPix / $yPix" | bc
selectSecond=`echo "scale=0; $format_duration" | bc`

# re: https://stackoverflow.com/a/1198191/1397555
ffmpeg -ss $selectSecond -i tmp_bbE9pWyXSVshTm.mp4 -crf 1 -frames:v 1 oot.jpg
rm tmp_bbE9pWyXSVshTm.mp4