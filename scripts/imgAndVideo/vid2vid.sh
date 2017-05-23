# DESCRIPTION
# Converts all video files of a given type ($1) to another type ($2) with default crf (constant rate factor or quality) 13 (quite high quality).

# USAGE
# Invoke this script with two paramaters, the first being the source format and the second being the target, e.g.:
# thisScript.sh mov mp4

srcIMGformat=$1
destIMGformat=$2

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
		# gm convert $param3 -scale $img_size $element $IMGfilenameNoExt.$destIMGformat
		ffmpeg -i $IMGfilenameNoExt.$srcIMGformat -crf 13 $IMGfilenameNoExt.$destIMGformat
	fi
done

rm IMGconvertList.txt
