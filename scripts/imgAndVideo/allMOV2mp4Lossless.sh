# DESCRIPTION
# Converts all .mov format video files in the current path to .mp4 containers, losslessly (no recompression: direct stream copy).

# USAGE
# thisScript.sh

# These rediculous pipe acrobatics are to trim ./ off the start and any windows newlines that gnu ports of windows utilities create:
list=`find . -name '*.mov' -o -name '*.MOV' | sed 's|^./||' | tr -d '\15\32'`

# Optional extra parameters:
# extraParams="-acodec aac -crf 17 -strict -2"		# Because ffmpeg can't handle pcm for mp4 right now, and that would be a silly waste of space for distribution anyway (compress it to aac) -- and it throws an error instructing me to add -strict -2 to that if I use aac

for element in ${list[@]}
do
	fileNameNoExt=${element%.*}
	ffmpeg -y -i $element $extraParams -vcodec copy $fileNameNoExt.mp4
done