# DESCRIPTION
# invokes SVG2img.sh for every *.svg file in the current directory, additionally passing other parameters which you must specify: see USAGE.

# USAGE
# invoke this script with the following parameters:
# $1 the number of pixels you wish the longest side of the output image to be.
# $2 the target file format e.g. png or jpg -- defaults to jpg if not provided.
# $3 optional--see parameter $4 description in SVG2img.sh.
# e.g.:
# ./allSVG2img.sh 4200 png 000066
# NOTE: to render svgs in subdirectories as well, remove "-maxdepth 1" from the array build code line.


# CODE
# Set defaults or use parameters passed to script, depending.
if [ "$1" ]
then
	longestImageSide=$1
else
	longestImageSide=4200
	echo "No parameter \$1. Set to default $longestImageSide."
fi

if [ "$2" ]
then
	targetIMGformat=$2
else
	targetIMGformat=png
	echo "No parameter \$2. Set to default $targetIMGformat."
fi

if [ "$3" ]
then
	bgColorParam=$3
else
	echo "No parameter \$3; setting to default hex 000000 background color."
	bgColorParam='000000'
fi

# Do the conversions.
array=(`find . -maxdepth 1 -type f -iname \*.svg -printf '%f\n'`)
for element in ${array[@]}
do
	SVG2img.sh $element $longestImageSide $targetIMGformat $bgColorParam
done