# DESCRIPTION
# invokes SVG2img.sh for every *.svg file in the current directory, additionally passing other parameters which you must specify: see USAGE.

# USAGE
# invoke this script with the following parameters:
# $1 the number of pixels you wish the longest side of the output image to be.
# $2 the target file format e.g. png or jpg -- defaults to jpg if not provided.
# $3 optional--include this parameter (it can be anything) to make the background transparent; otherwise it defaults to an opaque background of a color hard-coded (hack the script--see the commented out background colors section--to change the background color).
# e.g.:
# ./thisScript.sh 4200 png foo


# CODE
find . -name '*.svg' | sed 's|^./||' > all_svgs.txt
while read element
do
	SVG2img.sh $element $1 $2 $3
done < all_svgs.txt

rm all_svgs.txt