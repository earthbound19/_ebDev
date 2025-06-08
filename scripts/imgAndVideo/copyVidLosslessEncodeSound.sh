# DESCRIPTION
# Copies the video stream of a source video and re-encodes the audio in aac high quality, into an mp4 container. Intended for slightly modified video distribution from source video from some (silly) devices that record AVC/PCM videos. Where PCM takes excessive file space, converting the PCM sound stream to aac saves a lot of space. Output files are named after the input file, but add ~_aacSound to the file name. Also, metadata and timestamps are copied from the source to the target via another script.

# DEPENDENCIES
#    ffmpeg, copyMetadataFromSourceFileToTarget.sh.

# USAGE
# Run with these parameters:
# - $1 file name of the source video (in the current directory) to re-encode the sound for.
# For example:
#    copyVidLosslessEncodeSound.sh inputVideo.MOV


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (file name of input video) passed to script. Exit."; exit 1; else inputFile=$1; fi

	# DEPRECATED, to avoid a weird situation where .MOV format would be needed to contain an M-JPEG stream with aac sound; whereas the mkv (Matroska) container can do that without complaint; however, at this writing, powers that be streaming / social media prefer mp4:
	# outputFileName=${inputFile%.*}_aacSound.mp4
outputFileName=${inputFile%.*}.mkv
if [ -e $outputFileName ]
then
	echo "Output file name $outputFileName already exists; will not clobber; skip. To re-render it, rename or delete that file, and run this script with the same input file again."
else
	echo Converting $inputFile . . .
		# HACKING COMMENTS FOR DIFFERENT CONTAINERS:
		# IF YOU USE A .mov container, add -movflags +faststart
		# IF YOU WANT A LOSSLESS MP4/H264 stream (but filesizes may baloon): ffmpeg -i input.avi -c:v libx264 -crf 0 -preset ultrafast -c:a aac output.mp4
		# MKV MATROSKA with any dubious or old / experimental codecs: ADD -strict experimental
	ffmpeg -i $inputFile -map 0:v -vcodec copy -map 0:a -acodec aac -crf 10 $outputFileName

	# copy metadata from source file to render target; the script also updates target timestamp to match metadata media creation date:
	copyMetadataFromSourceFileToTarget.sh $inputFile $outputFileName
fi