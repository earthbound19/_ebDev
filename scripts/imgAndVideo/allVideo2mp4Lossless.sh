# DESCRIPTION
# Converts all of many video media container (file) types in the current directory to mp4 containers, losslessly; there is no recompression: it directly copies the video streams into a new container. It also copies the file timestamps (including Windows-unique ones) from the original file to the converted target file.

# DEPENDENCIES
# ffmpeg, GNU touch, ExifTool

# USAGE
# Run without any parameters:
#    allVideo2mp4Lossless.sh
# Also, see the extraParams variable (and commented options for it) and maybe hack its assignment per your preference.


# CODE
mediaList=$(printAllVideoFileNames.sh)

# OPTIONAL EXTRA PARAMETERS
# Because ffmpeg can't handle pcm for mp4 right now, and that would be a silly waste of space for distribution anyway (compress it to aac) -- and it throws an error instructing me to add -strict -2 to that if I use aac; BUT the following is an option commented out in distribution because encoding to aac isn't lossless! -crf 15 is quite high quality encoding:
# extraParams="-acodec aac -crf 15 -strict -2"
# OR just straight copy the sound (default archived code option) even if it's a Canon DSLR .MOV pcm space hog sound channel:
extraParams="-acodec copy"

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
	ffmpeg -y -i $fileName $extraParams -vcodec copy $renderTarget
	touch -r $fileName $renderTarget
	ExifTool -overwrite_original "-FileModifyDate>FileCreateDate" $renderTarget
done