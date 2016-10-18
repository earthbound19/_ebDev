# DESCRIPTION
# Converts all files of a given type ($1) to another type ($2) by nearest niegbhor resize method to dimension NNNNxNNN ($3)

# USAGE
# detail. NOTE: given format (file extension) parameters should not include a . before them.
# optional parameter $4 will make the background transparent for compatible image formats

srcIMGformat=$1
destIMGformat=$2
img_sizeX=$3
img_sizeY=$4

if [ ! -a $5 ]
then
	param3="-background none"
fi


CygwinFind . -iname \*.$srcIMGformat > IMGconvertList.txt
sed -i 's/^\.\/\(.*\)/\1/g' IMGconvertList.txt
mapfile -t IMGconvertList < IMGconvertList.txt
for element in "${IMGconvertList[@]}"
do
		IMGfilenameNoExt=`echo $element | sed 's/\(.*\)\.[^\.]\{1,5\}/\1/g'`
	if [ -a $IMGfilenameNoExt.$destIMGformat ]
	then
		echo render candidate is $IMGfilenameNoExt.$destIMGformat
		echo target already exists\; will not render.
		echo . . .
	else
		echo rendering $element . . .
		# magick $param3 -scale $img_size $element $IMGfilenameNoExt.$destIMGformat
		nconvert -rtype quick -resize $img_sizeX $img_sizeY -out $destIMGformat -o $IMGfilenameNoExt.$destIMGformat $IMGfilenameNoExt.$srcIMGformat
	fi
done

rm IMGconvertList.txt