# DESCRIPTION
# Converts all of many video media container (file) types in the current directory to a new container format, losslessly; there is no recompression: it directly copies the video streams into a new container. It also copies the file timestamps (including Windows-unique ones) and relevant metadata from the original file to the converted target file, via another script. Defaults to mkv (Motroska) containers, losslessly. Container format can be changed with parameter (see USAGE). For options for lossless video but lossy sound, see NOTES.

# DEPENDENCIES
# ffmpeg, GNU touch, copyMetadataFromSourceFileToTarget.sh, toOldestWindowsDateTime.sh

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. A format container extension without a preceding period, e.g. 'mp4', to specify the output container. If omitted defaults to 'mkv' (Motroska).
# For example to use the default mkv container, run without any parameter:
#    allVideo2mp4Lossless.sh
# Or to override to an mp4 extension / container, run:
#    allVideo2VideoLossless.sh mp4
# NOTES
# - if you have a .mov container as source with PCM sound and attempt to copy the streams to target mp4 format, you may get an error copying (maybe mp4 files can't have PCM audio, it seems). In that case try `copyVidLosslessEncodeSound.sh` or `copyVidLosslessEncodeSoundAllType.sh`, or try an mk4 container.
# - conversion from .mov to .mkv may not maintain image rotation flags, and conversion from .mov to .mk4 may.


# CODE
if [ "$1" ]; then containerFormat=$1; else containerFormat='mkv'; echo "No container format parameter \$1 passed; defaulting to "$containerFormat"."; fi

mediaList=$(printAllVideoFileNames.sh)

for fileName in ${mediaList[@]}
do
	fileNameNoExt=${fileName%.*}
	fileExt=${fileName##*.}

	# SKIP if the file extension of source is the same as dest:
	if [ "$fileExt" == "$containerFormat" ]
	then
		echo "~ SKIPPING conversion of $fileName to $containerFormat because it already is . . ."
		continue
	fi

	echo "Converting $fileName to $containerFormat container as $fileNameNoExt.$containerFormat . . ."
	renderTarget=$fileNameNoExt.$containerFormat

	# convert only if render target does not already exist; otherwise skip:
	if [ ! -f $renderTarget ]
	then
		# something that might be tried here that may preclude metadata copy in the step after is adding metadata copy flags: ffmpeg -y -i $fileName -c copy -movflags use_metadata_tags $renderTarget
		ffmpeg -y -i $fileName -c copy $renderTarget
		# copy metadata from source file to render target; the script also updates target timestamp to match metadata media creation date:
		copyMetadataFromSourceFileToTarget.sh $fileName $renderTarget FNEORN
		# update created date in windows to match (now probably) older "modified" date (it was modified before it was created?! -- great scott! :
		toOldestWindowsDateTime.sh $renderTarget
	else
		echo "SKIPPING RENDER TARGET $renderTarget, as it already exists."
	fi
done