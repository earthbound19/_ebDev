# DESCRIPTION
# Adds blank sound to a video by re-muxing the original video stream (stream copy--so lossless copy) into the same container format, only with a new, silent 11000Hz aac audio track the duration of the clip. Blank sound will be aac encoded--hack this script if the source container isn't compatible. Needed e.g. for stupid TVs that complain if a media file has no sound track (instead of just ignoring it).

# WARNING
# This replaces the original video without warning, with the new copy that has a silent sound track added.

# DEPENDENCIES
# a 'nixy environment, ffmpeg

# USAGE
# Pass this script one parameter, being a video file, e.g.:
#  ./addBlankSoundToVid.sh inputVideoFile.mp4


# CODE
# extract file extension from $1:
fileExt="${1##*.}"

# re: https://stackoverflow.com/a/18700245/1397555
ffmpeg -y -f lavfi -i aevalsrc=0 -i $1 -vcodec copy -shortest -strict experimental -ac 1 -ar 11025 "tmp_bmS9h4AJ"."$fileExt"
rm $1
mv "tmp_bmS9h4AJ"."$fileExt" $1