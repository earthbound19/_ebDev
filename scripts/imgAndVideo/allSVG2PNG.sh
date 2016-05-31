# DESCRIPTION: creates .png files from all .svg files in a directory tree, via imagemagick.

# USAGE: invoke this script with one parameter, being the number of pixels you wish the longest side of the converted .svg file to be.

# template command: magick -size 850 test.svg result.png
# NOTE that for the -size parameter, it scales the imagesso that the longest side is that many pixels.

# If no image size parameter, set default image size of 300.
if [ -a $1 ]
then
	img_size=300
fi

find . -iname \*.svg > all_svgs.txt
mapfile -t all_svgs < all_svgs.txt
for element in "${all_svgs[@]}"
do
		# Because I couldn't get this done with an echo piped to sed:
		echo $element > temp.txt
		sed -i 's/\(.*\).svg/\1/g' temp.txt
	svgFilenameNoExtension=$( < temp.txt)
	if [ -a $svgFilenameNoExtension.png ]
	then
		echo render candidate is $svgFilenameNoExtension.png
		echo target already exists\; will not render.
		echo . . .
	else
		echo rendering $element . . .
		magick -size $1x$1 $element $svgFilenameNoExtension.png
	fi
done

rm temp.txt all_svgs.txt