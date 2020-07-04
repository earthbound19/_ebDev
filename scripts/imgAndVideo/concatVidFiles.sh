# DESCRIPTION:
# Concatenates all video files (default extension .mp4) in a directory into one output file. Source files must all be encoded with the same codec and settings. In contrast to some other scripts here, it makes the list of videos "on the fly"--it will do so with whatever sort the `ls` command outputs.

# DEPENDENCIES: ffmpeg and a 'nix system (can be cygwin for Windows).

# USAGE:
# Invoke from a directory with video e.g. mp4 files that are all encoded the same way. The result will appear in _mp4sConcatenated.mp4.
# Optional paramater $1, video file type extension (without the . in the file name) will override the default mp4 and concatenate whatever other format you specify thus, e.g.:
#  concatVidFiles.sh avi
# If no parameter passed, defaults to mp4.


# CODE
if [ "$1" ]
then
	vidExt=$1
else
	vidExt=mp4
fi
ls *.$vidExt > all$vidExt.txt
gsed -i "s/^\(.*\)/file '\1'/g" all$vidExt.txt
exit
ffmpeg -f concat -i all$vidExt.txt -c copy _"$vidExt"sConcatenated.$vidExt
rm all$vidExt.txt

echo DONE. See result file _"$vidExt"sConcatenated.$vidExt and move or copy it where you will.