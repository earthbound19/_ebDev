# DESCRIPTION:
# Invokes utVideoNoSound.sh repeatedly. Encodes all video files of a given type (default .avi) in a directory to UTvideo (lossless but compressed) format AVIs.

# USAGE:
# Ensure this script is in your $PATH, and invoke it from a directory with avi files that are too huge. Results will appear as ~UTvideo~ file names.
# Optional paramater $1 <videoExtension> e.g.:
#  utVideoNoSound_all.sh avi
# If no parameter passed, defaults to avi.

# DEPENDENCIES: ffmpeg and a 'nix system (can be cygwin for Windows).

if [ "$1" ]
	then
	vidExt=$1
	else
	vidExt=avi
fi

find *.$vidExt > allvids.txt
mapfile -t allVids < allvids.txt
rm allvids.txt
for element in "${allVids[@]}"
do
	utVideoNoSound.sh "$element"
done