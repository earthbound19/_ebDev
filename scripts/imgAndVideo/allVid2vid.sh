# DESCRIPTION
# Converts all video files of a given type ($1) to another type ($2) with default crf (constant rate factor or quality) 13 (quite high quality).

# USAGE
# Invoke this script with two paramaters, the first being the source format and the second being the target, e.g.:
# thisScript.sh mov mp4
# ALSO, see the "ADDITIONAL PARAMTERS" comment section.

# DEPENDENCIES
# gsed, gfind, ffmpeg


# CODE
srcIMGformat=$1
destIMGformat=$2

if ! [ -z ${1+x} ]
	then
		IMGconvertList=(`gfind . -maxdepth 1 -type f -iname \*.$srcIMGformat -printf '%f\n'`)
	else
		echo "No parameter 1 (source format) passed to script. Will exit script."
		exit
fi
if ! [ -z ${2+x} ]
	then
		destIMGformat=$2
	else
		echo "No parameter 2 (destination format) passed to script. Will exit script."
		exit
fi

# ADDITIONAL PARAMETERS--uncomment whatever you may wish here:
	# Option which I haven't gotten to work yet (it works if I paste it into the command in the loop, but not as stored in the variable additonalParams) :
	# Pad video to a given size, with the video in the center:
	# additionalParams="-vf scale=-1:1080:force_original_aspect_ratio=1,pad=1920:1080:(ow-iw)/2:(oh-ih)/2"
	# Scale video to given pixels X, maintain aspect ratio, no padding:
	additionalParams="-vf scale=-1:720:force_original_aspect_ratio=1"

for element in "${IMGconvertList[@]}"
do
	IMGfilenameNoExt=${element%.*}
	if [ -a $IMGfilenameNoExt.$destIMGformat ]
	then
		echo conversion target candidate is $IMGfilenameNoExt.$destIMGformat
		echo target already exists\; will not render.
		echo . . .
	else
		echo converting $element . . .
		ffmpeg -i "$IMGfilenameNoExt"."$srcIMGformat" $additionalParams -crf 17 "$IMGfilenameNoExt"_x720."$destIMGformat"
	fi
done