# DESCRIPTION
# Concatenates all video files (default extension .mp4) in a directory into one output file. Source files must all be encoded with the same codec and settings. In contrast to some other scripts here, it makes the list of videos "on the fly"--it will do so with whatever sort the `ls` command outputs.

# DEPENDENCIES
#    ffmpeg, randomString.sh

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. Extension of e.g. mp4 files that are all encoded the same way. If not provided, defaults to mp4.
# - $2 OPTIONAL. File name of list of files. The contents of this file must be in this format:
#    file 'file1.avi'
#    file 'file2.avi'
#    file 'anotherVideoFileName.avi'
#    file 'etcetera.avi'
# If $2 is used, $1 is ignored (and can technically be anything in that case, like the word NULL). It may be desirable to use $2 if you want a custom ordering for the concatenation of the files. If you only use $1, whatever order results from `ls $1` is the concatenation order.
# Example with only parameter $1:
#    concatVideos.sh avi
# Example without any parameter, which would concatenate all mp4 files:
#    concatVideos.sh
# The result concatenated file name in that case is _mp4sConcatenated.mp4`.
# Example with parameters $1 and $2:
#    concatVideos.sh YORGBLAF fadeSRCvideosList.txt
# NOTES
# This script sets an environment variable $concatenatedVideoFileName which will be set in a calling shell if you call this script this way:
#    source concatVideos.sh YORGBLAF fadeSRCvideosList.txt

# CODE
if [ "$1" ]; then vidExt=$1; else vidExt=mp4; fi
if [ "$2" ]; then srcFileList=$2; fi

if [ ! "$srcFileList" ]
then
	srcFileList=all"$vidExt".txt
	ls *.$vidExt > $srcFileList
	sed -i "s/^\(.*\)/file '\1'/g" $srcFileList
fi
rndString=$(randomString.sh 1 8)
concatenatedVideoFileName=_"$vidExt"sConcatenated_"$rndString".$vidExt
ffmpeg -f concat -i $srcFileList -c copy $concatenatedVideoFileName

echo DONE. See result file $concatenatedVideoFileName and move or copy it where you will.