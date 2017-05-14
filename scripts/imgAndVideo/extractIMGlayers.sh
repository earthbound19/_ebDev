# USAGE
# Invoke this script with $1 parameter, being a file name to rip layers out of and place in a /$1_layers subdir; e.g.:
# thisScript.sh inFile.psd
# OR, probably:
# thisScript.sh inFile.tif
# -- or perhaps any other supported layered file format.

# NOTES: At this writing and perhaps every writing, this script may produce files with layer numbers not corresponding to layer numbers in the input file. Also it may crop layers which have transparency and no visible pixels flush with all image edges.

# TO DO? examine: http://undertheweathersoftware.com/how-to-extract-layers-from-a-photoshop-file-with-imagemagick-and-python/

# CODE
	# re: http://stackoverflow.com/questions/6598848/extract-layers-from-psd-with-imagemagick-preserving-layout --and -help info (-verbose switch)
# perhaps kludgy, but all I can figure to do; figures out and stores number of images' layers in $numLayers:
gm identify -verbose $1 > temp_j4EQD83qVYb74ZKeZaMRrWXxw8CBu53uN5.txt
sed -i -n '/Scene/p' temp_j4EQD83qVYb74ZKeZaMRrWXxw8CBu53uN5.txt
thisStr=`wc -l temp_j4EQD83qVYb74ZKeZaMRrWXxw8CBu53uN5.txt`
numLayers=`echo $thisStr | sed 's/^\([0-9]\{1,\}\) .*/\1/g'`
rm temp_j4EQD83qVYb74ZKeZaMRrWXxw8CBu53uN5.txt

imgFileNoExt=`echo $1 | sed 's/\(.*\)\..\{1,4\}/\1/g'`

# create subdir named after image to extract layers ("scenes") to:
if [ ! -d "$imgFileNoExt"_scenes ]; then mkdir "$imgFileNoExt"_scenes; fi

for i in `seq 1 $numLayers`
do
	gm convert $1[$i] "$imgFileNoExt"_scenes/"$imgFileNoExt"_layer"$i".png
done