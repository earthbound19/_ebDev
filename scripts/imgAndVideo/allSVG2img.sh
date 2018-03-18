# DESCRIPTION
# invokes SVG2img.sh for every *.svg file in the current directory, additionally passing other parameters which you must specify: see USAGE.

# USAGE
# invoke this script with the following parameters:
# $1 the number of pixels you wish the longest side of the output image to be.
# $2 the target file format e.g. png or jpg -- defaults to jpg if not provided.
# $3 optional--see parameter $4 description in SVG2img.sh.
# e.g.:
# ./thisScript.sh 4200 png 000066


# CODE
find . -name '*.svg' | sed 's|^./||' > all_svgs.txt
while read element
do
	SVG2img.sh $element $1 $2 $3
done < all_svgs.txt

rm all_svgs.txt