# DESCRIPTION
# Concatenates all video files (default extension .mp4) in a directory into one output file. Source files must all be encoded with the same codec and settings. In contrast to some other scripts here, it makes the list of videos "on the fly"--it will do so with whatever sort the `ls` command outputs.

# DEPENDENCIES
#    ffmpeg

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. Extension of e.g. mp4 files that are all encoded the same way. If not provided, defaults to mp4.
# Example with parameter $1:
#    concatVideos.sh avi
# Example without any parameter, which would concatenate all mp4 files:
#    concatVideos.sh
# Result file is `_mp4sConcatenated.mp4`.


# CODE
if [ "$1" ]
then
	vidExt=$1
else
	vidExt=mp4
fi

ls *.$vidExt > all$vidExt.txt
sed -i "s/^\(.*\)/file '\1'/g" all$vidExt.txt
ffmpeg -f concat -i all$vidExt.txt -c copy _"$vidExt"sConcatenated.$vidExt
rm all$vidExt.txt

echo DONE. See result file _"$vidExt"sConcatenated.$vidExt and move or copy it where you will.