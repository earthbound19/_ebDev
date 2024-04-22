# DESCRIPTION
# IN DEVELOPMENT. Parameterization and documentation forthcoming. Functional first draft.

# DEPENDENCIES
# yes

# USAGE
# At this writing, run without any parameters and see what it does.


# CODE
augmentNcolors=7
paletteFileNames=($(printPaletteFileNamesWithNColors.sh -n 2 -c -f))
for paletteFileName in ${paletteFileNames[@]}
do
	# get the file name of the palette (strip off the path):
	paletteFileNameNoPath="${paletteFileName##*/}"
	# get the file name of that without the extension:
	paletteFileNameNoExtension=${paletteFileNameNoPath%.*}
	renderTargetFilename="$paletteFileNameNoExtension"_Augmented_"$augmentNcolors".hexplt
	echo "Augmenting palette $paletteFileNameNoPath to $renderTargetFilename. . ."
	augmentPalette.sh $paletteFileNameNoPath $augmentNcolors > $renderTargetFilename
	# render it:
	renderHexPalette.sh $renderTargetFilename
	# delete the local copy of the palette:
	rm $paletteFileNameNoPath
done

echo DONE.