# DESCRIPTION
# OR TRY: Photoshop -> File menu -> Export -> Layers to files (and the alpha may only look good if you export to png-24)! How long has that been there, and I bothered with coding this script?! Maybe it wasn't in the Photoshop version I had at the time? Also see NOTES. This script exports layers in an image file (e.g. psd or tif source file) to png images.

# USAGE
# Invoke this script with $1 parameter, being a file name to rip layers out of and place in a /$1_layers subdir; e.g.:
# thisScript.sh inFile.psd
# OR, probably:
# thisScript.sh inFile.tif
# -- or perhaps any other supported layered file format.

# NOTES
# GraphicsMagick seems not to with the reading .psd files. You must save any .psd file from Photoshop to a layered .tif, probably put a tick mark in "save transparency", maybe with no image compression.
# At this writing and perhaps every writing, this script may produce files with layer numbers not corresponding to layer numbers in the input file. Also it may crop layers which have transparency and no visible pixels flush with all image edges.

# DEV NOTES
# Once this worked for me using graphicsMagick; now it doesn't. But does work with imagemagick. Le sigh. Putting both gm and magick in _ebSuperBin, and splitting this into two scripts, each adapted for the other.
# Um, this can be done far more simply? re https://gist.github.com/pepebe/2955410 OR https://superuser.com/a/44602
# TO DO? examine: http://undertheweathersoftware.com/how-to-extract-layers-from-a-photoshop-file-with-imagemagick-and-python/
# -- OR: https://github.com/psd-tools/psd-tools


# CODE
	# re: http://stackoverflow.com/questions/6598848/extract-layers-from-psd-with-imagemagick-preserving-layout --and -help info (-verbose switch)
# perhaps kludgy, but all I can figure to do; figures out and stores number of images' layers in $numLayers:
gm identify -verbose $1 > temp_j4EQD83qVYb74ZKeZaMRrWXxw8CBu53uN5.txt
sed -i -n '/Scene/p' temp_j4EQD83qVYb74ZKeZaMRrWXxw8CBu53uN5.txt
thisStr=`wc -l temp_j4EQD83qVYb74ZKeZaMRrWXxw8CBu53uN5.txt | tr -d ' '`
numLayers=`echo $thisStr | sed 's/^\([0-9]\{1,\}\) .*/\1/g'`
echo numLayers is $numLayers
exit
rm temp_j4EQD83qVYb74ZKeZaMRrWXxw8CBu53uN5.txt
imgFileNoExt=`echo $1 | sed 's/\(.*\)\..\{1,4\}/\1/g'`

# create subdir named after image to extract layers ("scenes") to:
if [ ! -d "$imgFileNoExt"_scenes ]; then mkdir "$imgFileNoExt"_scenes; fi

for i in `seq 1 $numLayers`
do
	echo attempting to extract layer $i . . .
	gm convert $1[$i] "$imgFileNoExt"_scenes/"$imgFileNoExt"_layer"$i".png
done