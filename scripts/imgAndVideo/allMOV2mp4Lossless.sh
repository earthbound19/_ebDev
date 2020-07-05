# DESCRIPTION
# Converts all .mov and .avi format video files in the current directory (ignores subdirectories) to .mp4 containers, losslessly (meaning there is no recompression: it directly copies the video streams into a new container).

# USAGE
# Invoke without any parameters:
#  allMOV2mp4Lossless.sh
# Also, see the extraParams and maybe hack its assignment per your preference.


# CODE
# The printf command trims any ./ from the start of output:
list=(`find . -maxdepth 1 \( -iname \*.mov -o -iname \*.MOV -o -iname \*.avi \) -printf '%f\n' | sort`)

# OPTIONAL EXTRA PARAMETERS
# Because ffmpeg can't handle pcm for mp4 right now, and that would be a silly waste of space for distribution anyway (compress it to aac) -- and it throws an error instructing me to add -strict -2 to that if I use aac; BUT the following is an option commented out in distribution because encoding to aac isn't lossless! -crf 15 is quite high quality encoding:
# extraParams="-acodec aac -crf 15 -strict -2"
# OR just straight copy the sound (default archived code option) even if it's a Canon DSLR .MOV pcm space hog sound channel:
extraParams="-acodec copy"

for element in ${list[@]}
do
	fileNameNoExt=${element%.*}
	ffmpeg -y -i $element $extraParams -vcodec copy $fileNameNoExt.mp4
done