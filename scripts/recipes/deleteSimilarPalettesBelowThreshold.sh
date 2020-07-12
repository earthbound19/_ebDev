# DESCRIPTION
# Helps eliminate palettes (.hexplt files) in a collection which are perceptually similar (technically and logically: not very different below a threshold). Does this with a custom loop in this script, using other scripts also. See details under NOTES.

# USAGE
# Hack the global value right after the CODE comment per your want. Then invoke the script:
#  deleteSimilarPalettesBelowThreshold.sh
# NOTES
# - To remove palettes for which you manually delete a rendered PNG (because you don't want the palette), see listUnmatchedExtensions.sh or pruneByUnmatchedExtension.sh.


# CODE
deletePalettesBelowDifferenceThreshold=0.14

currentDir=`pwd`
allSubdirectoriesArray=(`listAllSubdirs.sh`)
for directory in ${allSubdirectoriesArray[@]}
do
	printf "\nChanging to directory: $directory . . ."
	cd $directory
	# Only do things if there are .hexplt files (and assumed related files) to work on; re: https://stackoverflow.com/a/3856879/1397555
	count=`ls -1 *.hexplt 2>/dev/null | wc -l`
	if [ $count != 0 ]
	then
		printf "\nAt least one .hexplt file found here; proceeding . . .\n"
# TWO OPTIONS here: allRGBhexColorSortInCAM16-UCS.sh or allRGBhexColorSortIn2CIECAM02.sh; I've gone back and forth on which to use; CAM16 I had at one point thought sorted tint/shade better; now I'm not sure; it seemed to me at one point that CIECAM02 sorted hue better. I haven't re-examined that theory. allRGBhexColorSortIn2CIECAM02.sh does calculations much faster it seems:
		allRGBhexColorSortIn2CIECAM02.sh
		rm *.png
		renderAllHexPalettes-gm.sh NULL 250 NULL
		allPalettesCompareCIECAM02.sh
		listPaletteDifferencesBelowThreshold.sh $deletePalettesBelowDifferenceThreshold
		# PENDING DEVELOPMENT:
		# deletePalettesDifferentBelowThreshold.sh
		# change back to parent dir; not using pushd . /popd because it does weird unhelpful printing of the same directory over and over which I don't like and which isn't helpful:
	fi
	cd $currentDir
done
