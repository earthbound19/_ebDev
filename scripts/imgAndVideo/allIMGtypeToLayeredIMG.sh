# DESCRIPTION
# Combines all input image files of type $1 (parameter 1 to script) into a layered output image file. Suggested options: kra, ora, or psd; ora (works with Krita) recommended.

# DEPENDENCIES
# GraphicsMagick and Krita, both in your $PATH.

# USAGE
# Run this script with these parameters:
# - $1 The extension of all files in your current directory to operate on
# - $2 OPTIONAL. The desired final layered file format, e.g. tif or psd. If omitted, defaults to psd.
# Example run command:
#    allIMGtypeToLayeredIMG.sh tif ora
# NOTES
# - For best results, start with .tif images that store alpha information. Otherwise, IF YOUR SOURCE images are in a format (even with alpha information) other than .tif, GraphicsMagick may replace alpha values in each layer with black, which you'll want to eliminate with an unmultiply filter (in Photoshop and/or filter forge).
# - This script first converts to a layered .tif, then the target format. I discourage archiving images in layered .tif format, because Krita and Photoshop (at least) read them differently; Krita understands them, but Photoshop only reads one layer!
# - If the target format is .tif, it doesn't do an extra conversion step, it just gives you the layered .tif.
# - It may take a VERY long time to composite large image layers in Krita to psd, or in fact run out of memory (apparently?) and crash. If this happens, and this is sad: axe the layers into folders with fewer images, composite in the folders, and merge the composites.

# CODE
# TO DO
# Set defaulf ora format for destination file.
# Template command:
# gm convert 1.png 2.png 3.png 4.png out.tif

if [ "$1" ]; then intermediate_target=_all_"$1"_layered.tif; else printf "\nNo parameter $1 (input images type) passed to script. Exit."; exit 1; fi

if [ "$2" ]; then final_target=_all_"$1"_layered.$2; else final_target=_all_"$1"_layered.psd; fi

# check for non-error level after attempt to run krita executable as findable (hopefully) in PATH; if errorlevel exit with that errorlevel:
krita --version &>/dev/null
capturedErrorLevel="$?"
if [ "$capturedErrorLevel" != 0 ]; then echo captured error level $capturedErrorLevel on attempt to run krita. Krita apparently not installed or present in PATH. exit.; exit $capturedErrorLevel; fi

# list input files on one line with spaces in between, for formatting as parameters to `gm convert`; the tr command deletes any Windows newlines:
inputFiles=$(find -maxdepth 1 -type f -iname \*.$1 -printf "%P " | tr -d '\15\32')
# echo is $inputFiles

gm convert $inputFiles $intermediate_target

# if the final layered file format specified is tif, the final file already exists; do nothing else. if it's another format, convert to that format and delete the intermediary tif.:
if [ "$final_target" != "$intermediate_target" ]
then
	krita $intermediate_target --export --export-filename $final_target
	rm $intermediate_target
fi

echo DONE. See result image $final_target.