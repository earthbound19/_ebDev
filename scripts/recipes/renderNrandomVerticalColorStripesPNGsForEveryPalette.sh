# DESCRIPTION
# For every palette in the /palettes subfolder of the _ebPalettes repository, renders several images (png format) of random vertical color stripes. Accomplished via other scripts. Properties of the rendered images (including how many to render) are configurable via variable hacking; see USAGE.

# DEPENDENCIES
# Various scripts in the _ebDev repository, and their dependencies

# USAGE
# - Hack the values of variables after the CODE comment to alter various properties of the images (including how many of them to render per palette)
# - Run without any parameters:
#    renderNrandomVerticalColorStripesPNGsForEveryPalette.sh
# NOTES
# - This script skips renders if it finds targets already created related to a source. The purpose of this is to allow interrupt and resume of a batch of rendering from all palettes. If you want more, move them or the termninal to another directory and run it again.
# - If you don't want the rescaled palette stripes image, comment out the block of code between the REZISED PALETTE RENDER comments.

# CODE
pass1minStripesPerImage=7		# for 2-color palettes: maybe 13
pass1maxStripesPerImage=22		# for 2-color palettes: maybe 22
pass1imagesPerPalette=2			# for 2-color palettes: maybe 1
pass2minStripesPerImage=27
pass2maxStripesPerImage=39
pass2imagesPerPalette=2			# for 2-color palettes: maybe 1
pngXdimension=1920
pngYdimension=1080

allPaletteFileNames=($(printAllPaletteFileNames.sh))

allPaletteFileNamesLength=${#allPaletteFileNames[@]}
counter=1
for paletteFileName in ${allPaletteFileNames[@]}
do
	echo
	echo "WORKING ON:"
	echo "$counter of $allPaletteFileNamesLength palettes: $paletteFileName ($0) . . ."
	echo
	printf "  Checking for render targets related to $paletteFileName _or_ that the palette only has one color . . . "

	paletteBaseName=${paletteFileName%.*}
	fullPathToPalette=$(findPalette.sh $paletteFileName)

	# Check if the palette only has one color. If so, skip renders (which would only do a lot of work to do a solid color fill).
	# Test statement found via a genius breath yonder: https://stackoverflow.com/a/7702334
	# In the test statemetn: get array of colors from file by extracting all matches of a pattern of six hex digits preceded by a #, and then count via wc:
	if test $(grep -i -o '#[0-9a-f]\{6\}' $fullPathToPalette | wc -l) -eq 1
	then
		echo "NOTE: source palette only has one color, so working with that would do a lot of work to just do a solid color fill. Skipping renders."
		# skip this loop iteration:
		continue
	fi
	# Check if there are already render files based on the source palette file name. If there are, assume we don't want to make more, and skip renders (skip this loop iteration) for this source palette:
	if test -n "$(find . -maxdepth 1 -name "*$paletteBaseName*.png" -print -quit)"
	then
		printf "NOTE: file(s) with target pattern *$paletteBaseName*.png already exist. Skipping renders.\n"
		# skip this loop iteration:
		continue
	fi

	# REZISED PALETTE RENDER; comment out the lines in this indented block if you don't want a vertical stripe palette render of the same rescaled size as the other images:
	# temporarily copy the palette here
	cp $fullPathToPalette . &>/dev/null
	reformatHexPalette.sh -i $paletteFileName -a
	renderHexPalette.sh $paletteFileName
	paletteRenderTargetFileName=${paletteFileName%.*}.png
	img2imgNN.sh $paletteRenderTargetFileName bmp 1920 1080
	rm $paletteRenderTargetFileName
	intermediaryPaletteRenderTargetFileName=${paletteFileName%.*}.bmp
	img2img.sh $intermediaryPaletteRenderTargetFileName png
	rm $intermediaryPaletteRenderTargetFileName
	# END REZISED PALETTE RENDER

	# START FIRST PASS STRIPE COUNT PPM FILES
	source randomVerticalColorStripes.sh $pass1minStripesPerImage $pass1maxStripesPerImage $pass1imagesPerPalette $paletteFileName
	# because we called that with `source` it gave us an array of output ppm file names randomVerticalColorStripsOutputFileNames, which we'll iterate over to render as pngs:
	for PPMfileName in ${randomVerticalColorStripsOutputFileNames[@]}
	do
		# render as png to dimensions of global variables:
		img2imgNN.sh $PPMfileName png $pngXdimension $pngYdimension
			# stop here to check for a nonzero errorlevel from that script, and throw and exit if so:
			checkError=$?
			if [ $checkError != 0 ]; then printf "\nERROR! errorlevel $checkError returned by script call: img2imgNN.sh $paletteRenderTargetFileName bmp 1920 1080. Examine that script to isolate error. EXIT from $0"; exit 1; fi
		# delete source ppm file:
		rm $PPMfileName
	done
	# END FIRST PASS STRIPE COUNT PPM FILES
	# START FIRST PASS STRIPE COUNT PPM FILES
	source randomVerticalColorStripes.sh $pass2minStripesPerImage $pass2maxStripesPerImage $pass2imagesPerPalette $paletteFileName
				# delete the copied, modified palette file now that it has been rendered; it's not needed here) :
				rm $paletteFileName
	# use that refreshed randomVerticalColorStripsOutputFileNames array to iterate over to render as pngs:
	for PPMfileName in ${randomVerticalColorStripsOutputFileNames[@]}
	do
		# render as png to dimensions of global variables:
		img2imgNN.sh $PPMfileName png $pngXdimension $pngYdimension
		# delete source ppm file:
		rm $PPMfileName
	done
	# END FIRST PASS STRIPE COUNT PPM FILES
	counter=$((counter + 1))
done