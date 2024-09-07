# DESCRIPTION
# Converts all of many video media container (file) types in the current directory to mp4 containers, losslessly; there is no recompression: it directly copies the video streams into a new container. It also copies the file timestamps (including Windows-unique ones) and relevant metadata from the original file to the converted target file, via another script. For options for lossless video but lossy sound, see NOTES.

# DEPENDENCIES
# ffmpeg, GNU touch, copyMetadataFromSourceFileToTarget.sh 

# USAGE
# Run without any parameters:
#    allVideo2mp4Lossless.sh
# NOTES
# If you have a .mov container as source with PCM sound, you may get an error copying (maybe mp4 files can't have PCM audio??). In that case try `copyVidLosslessEncodeSound.sh` or `copyVidLosslessEncodeSoundAllType.sh`


# CODE
mediaList=$(printAllVideoFileNames.sh)

for fileName in ${mediaList[@]}
do
	fileNameNoExt=${fileName%.*}
	fileExt=${fileName##*.}
# SKIP if the file extension is mp4:
		if [ "$fileExt" == "mp4" ]
		then
			echo "~ SKIPPING conversion of $fileName to mp4 because it already is . . ."
			continue
		fi
	echo "Converting $fileName to mp4 container as $fileNameNoExt.mp4 . . ."
	renderTarget=$fileNameNoExt.mp4
	ffmpeg -y -i $fileName -c copy $renderTarget
	# copy metadata from source file to render target; the script also updates target timestamp to match metadata media creation date:
	copyMetadataFromSourceFileToTarget.sh $fileName $renderTarget FNEORN
done