# DESCRIPTION
# Combines all input image files of type $1 (parameter 1 to script) into a layered output image file. Suggested options: kra, ora, or psd; ora (works with Krita) recommended.

# DEPENDENCIES
# GraphicsMagick and Krita, both in your $PATH.

# USAGE
# Invoke this script with two parameters, being $1 the extension of all files in your current directory to operate on, and $2 (optional) the desired final layered format.
#  ./allIMGtypeToLayeredIMG.sh tif ora

# NOTES
# FOR BEST RESULTS start with .tif images that store alpha information. Otherwise, IF YOUR SOURCE images are in a format (even with alpha information) other than .tif, graphicsmagick may replace alpha values in each layer with black, which you'll want to eliminate with an unmultiply filter (in photoshop and/or filter forge).
# Script first converts to a layered .tif, then the target format. I discourage archiving images in layered .tif format, because Krita and Photoshop (at least) read them differently; Krita understands them, but Photoshop only reads one layer!

# TO DO
# Set defaulf ora format for destination file.


# CODE
# Template command:
# gm convert 1.png 2.png 3.png 4.png out.tif

find *.$1 > all_$1.txt
dos2unix all_$1.txt

while read element
do
	# echo $element
	inputFiles="$inputFiles $element"
done < all_$1.txt
rm all_$1.txt

# echo $inputFiles
gm convert $inputFiles _all_$1_layered.tif

krita _all_$1_layered.tif --export --export-filename _all_$1_layered.$2
# rm _all_$1_layered.tif

echo DONE. See result image _all_$1_layered.$2