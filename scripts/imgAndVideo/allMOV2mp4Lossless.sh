# DESCRIPTION
# Converts all .mov and .avi format video files in the current directory (ignores subdirectories) to .mp4 containers, losslessly (no recompression: direct stream copy).

# USAGE
# thisScript.sh

# These rediculous pipe acrobatics are to trim ./ off the start and any windows newlines that gnu ports of windows utilities create:
list=(`gfind . -maxdepth 1 \( -iname \*.mov -o -iname \*.MOV -o -iname \*.avi \) -printf '%f\n' | sort`)

# Optional extra parameters:
# extraParams="-acodec aac -crf 17 -strict -2"		# Because ffmpeg can't handle pcm for mp4 right now, and that would be a silly waste of space for distribution anyway (compress it to aac) -- and it throws an error instructing me to add -strict -2 to that if I use aac

for element in ${list[@]}
do
	fileNameNoExt=${element%.*}
	ffmpeg -y -i $element $extraParams -vcodec copy $fileNameNoExt.mp4
done