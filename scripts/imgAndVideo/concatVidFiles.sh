# DESCRIPTION:
# concatenates all video files (default extension .mp4) in a directory into one output file. Source files must all be encoded with the same codec and settings.

# USAGE:
# Ensure this script is in your $PATH, and invoke it from a directory with video e.g. mp4 files that are encoded the same way. The result will appear in _mp4sConcatenated.mp4.
# Optional paramater $1 <videoExtension> e.g.:
# thisScript.sh avi
# If no parameter passed, defaults to mp4.

# DEPENDENCIES: ffmpeg and a 'nix system (can be cygwin for Windows).

if [ ! -z ${1+x} ]
	then
	vidExt=$1
	else
	vidExt=mp4
fi

ls *.$vidExt > all$vidExt.txt
gsed -i "s/^\(.*\)/file '\1'/g" all$vidExt.txt
ffmpeg -f concat -i all$vidExt.txt -c copy _"$vidExt"sConcatenated.$vidExt
rm all$vidExt.txt

echo DONE. See result file _"$vidExt"sConcatenated.$vidExt and move or copy it where you will.