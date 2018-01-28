# DESCRIPTION
# Outputs a .jpg image frame from a given percent (time) of an input video file. Output image is _video_frame_.jpg at this writing (plan: name it after the input video).

# USAGE
# Pass this script two parameters, being:
# $1 an input video file name to grab a frame from, and
# $2 what percent time into the video duration to grab a frame from, expressed in decimal (and allowing high decimal precision e.g. .214 -- meaningfulness of that precision (if it is actually useful at all) may depend on the video length).
# Example:
# thisScript.sh inputVideo.mp4 .86

# KNOWN ISSUES
# Copies the whole input video to a temp file; inefficient.

# TO DO
# Make a temporary junction (without funky characters in the file name, so that ffprobe can work on the file) to the input file, and work from the junction?
# Name the output .jpg image after the video file
# Random frame selection if $2 not provided
# Log $2 to a file for future reference


# CODE
# Kludge for titles having spaces in names:
cp "$1" ./tmp_BZKcWq6C7QqfTt.mp4
eval "$(ffprobe -v error -of flat=s=_ -show_entries format=duration tmp_BZKcWq6C7QqfTt.mp4)"
# Example output from that:
# format_duration="93.761000"
# Strips blasted meddling windows newline that ends up in the variable and makes it unusable by other utilities:
format_duration=`echo $format_duration | tr -d '\15\32'`

# I *think* the tr -d.. command necessarily eliminates windows newlines from the variable:
selectSecond=`echo "scale=0; $format_duration" | bc | tr -d '\15\32'`
echo fler $selectSound

# re: https://stackoverflow.com/a/1198191/1397555
ffmpeg -ss $selectSecond -i tmp_BZKcWq6C7QqfTt.mp4 -crf 1 -frames:v 1 oot.jpg
rm tmp_BZKcWq6C7QqfTt.mp4