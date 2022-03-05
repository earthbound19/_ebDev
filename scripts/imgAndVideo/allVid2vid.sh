# DESCRIPTION
# Converts all video files of type $1 (in the current directory) to type $2, with default crf (constant rate factor or quality) 13 (quite high quality). Conversion may be to the same type, as the target is named after the original but adds "_converted" to the file name. Also copies all possible metadata from the source file to the destination, via exiftool, and changes file time stamp to match original.

# DEPENDENCIES
# ffmpeg, ExifTool

# USAGE
# Run with these parameters:
# - $1 the source format (or file extension)
# - $2 the target format
# Example that will re-encode all files with the extension .mov to .mp4 files:
#    allVid2vid.sh mov mp4
# SEE ALSO the "ADDITIONAL PARAMETERS" comment section.


# CODE
srcIMGformat=$1
destIMGformat=$2

if [ "$1" ]
	then
		IMGconvertList=($(find . -maxdepth 1 -type f -iname \*.$srcIMGformat -printf '%f\n'))
	else
		echo "No parameter 1 (source format) passed to script. Will exit script."
		exit
fi
if [ "$2" ]
	then
		destIMGformat=$2
	else
		echo "No parameter 2 (destination format) passed to script. Will exit script."
		exit
fi

# ADDITIONAL PARAMETERS--uncomment whatever you may wish here:
# Option which I haven't gotten to work yet (it works if I paste it into the command in the loop, but not as stored in the variable additonalParams) :
# Pad video to a given size, with the video in the center:
# additionalParams="-vf scale=-1:1080:force_original_aspect_ratio=1,pad=1920:1080:\(ow-iw\)/2:\(oh-ih\)/2"
# Scale video to given pixels X, maintain aspect ratio, no padding:
# additionalParams="-vf scale=-1:640:force_original_aspect_ratio=1"
# Scale video down to half size; trying the \" escapes for double quote marks because it works from the terminal with those around the "scale" param:
# additionalParams="-vf scale=iw/2:-1"
# yuv420p is apparently required by instagram and probably facebook and others:
pixelFormat="-pix_fmt yuv420p"

for element in "${IMGconvertList[@]}"
do
	IMGfilenameNoExt=${element%.*}
	if [ -a "$IMGfilenameNoExt"_converted."$destIMGformat" ]
	then
		echo conversion target candidate is $IMGfilenameNoExt.$destIMGformat
		echo target already exists\; will not render.
		echo . . .
	else
		echo converting $element . . .
		ffmpeg -i "$IMGfilenameNoExt"."$srcIMGformat" $additionalParams -crf 13 $pixelFormat "$IMGfilenameNoExt"_converted."$destIMGformat"
		exiftool -overwrite_original -TagsFromFile "$IMGfilenameNoExt"."$srcIMGformat" "$IMGfilenameNoExt"_converted."$destIMGformat"
		ExifTool -overwrite_original "-FileModifyDate>FileCreateDate" $renderTarget
	fi
done