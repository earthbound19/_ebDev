# DESCRIPTION
# Converts all video files of a given type ($1) to another type ($2) with default crf (constant rate factor or quality) 13 (quite high quality).

# USAGE
# Invoke this script with two paramaters, the first being the source format and the second being the target, e.g.:
# thisScript.sh mov mp4

srcIMGformat=$1
destIMGformat=$2
	# Option which I haven't gotten to work yet (it works if I paste it into the command in the loop, but not as stored in the variable additonalParams) :
	# Pad video to a given size, with the video in the center:
	additionalParams="-vf scale=-1:1080:force_original_aspect_ratio=1,pad=1920:1080:(ow-iw)/2:(oh-ih)/2"
			# Tossed: -vf scale=-1:1080:force_original_aspect_ratio=1

# wut? Why did I code these next lines? There will never be $5 per script instructions; and that isn't the best way to check for parameter value (existence) :
if [ ! -a $5 ]
then
	param3="-background none"
fi


find . -iname \*.$srcIMGformat > IMGconvertList.txt
sed -i 's/^\.\/\(.*\)/\1/g' IMGconvertList.txt
mapfile -t IMGconvertList < IMGconvertList.txt
for element in "${IMGconvertList[@]}"
do
		IMGfilenameNoExt=`echo $element | sed 's/\(.*\)\.[^\.]\{1,5\}/\1/g'`
	if [ -a $IMGfilenameNoExt.$destIMGformat ]
	then
		echo conversion target candidate is $IMGfilenameNoExt.$destIMGformat
		echo target already exists\; will not render.
		echo . . .
	else
		echo converting $element . . .
		ffmpeg -i $IMGfilenameNoExt.$srcIMGformat $additionalParams -crf 17 $IMGfilenameNoExt.$destIMGformat
	fi
done

rm IMGconvertList.txt
