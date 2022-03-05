# DESCRIPTION
# Converts all of many video media container (file) types in the current directory to mp4 containers, losslessly; there is no recompression: it directly copies the video streams into a new container. It also copies the file timestamps (including Windows-unique ones) and relevant metadata from the original file to the converted target file.

# DEPENDENCIES
# ffmpeg, GNU touch, ExifTool

# USAGE
# Run without any parameters:
#    allVideo2mp4Lossless.sh
# Also, see the extraParams variable (and commented options for it) and maybe hack its assignment per your preference.


# CODE
mediaList=$(printAllVideoFileNames.sh)

# OPTIONAL EXTRA PARAMETERS
# Because ffmpeg uncompressed/PCM audio is a silly waste of space for distribution, the following is an option commented out in distribution because encoding to aac isn't lossless! -crf 15 is very high quality encoding (practically though not actually lossless?) :
# extraParams="-acodec aac -crf 15"
# OR just straight copy the sound (default archived code option) even if it's a Canon DSLR .MOV pcm space hog sound channel:
# extraParams="-c:a copy"

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
	ffmpeg -y -i $fileName $extraParams -c:v copy $renderTarget
	# Copy metadata from original file to render target:
	exiftool -overwrite_original -TagsFromFile $fileName $renderTarget
	# Update time stamp of file to metadata creation date; uses a conditional like is given in this post: https://exiftool.org/forum/index.php?topic=6519.msg32511#msg32511 -- but adding an -else clause:
	exiftool -if "defined $CreateDate" -v -overwrite_original '-FileModifyDate<CreateDate' -d "%Y_%m_%d__%H_%M_%S%%-c.%%e" -else -v -overwrite_original '-FileModifyDate<DateTimeOriginal' -d "%Y_%m_%d__%H_%M_%S%%-c.%%e" $renderTarget

done