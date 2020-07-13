# DESCRIPTION
# I know, the name of this script file is very long. This script helps eliminate palettes (.hexplt files) in all subfolders of the current folder (but not palettes in the folder itself) which are perceptually similar (technically and logically: not very different below a threshold). Does this with a custom loop in this script, using other scripts also. To understand all how this works, you must examine the DESCRIPTION and USAGE etc. comments of all the scripts which this script invokes.

# USAGE
# Hack the global value right after the CODE comment per your want. Then invoke the script:
#  intraPaletteSortByNextMostSimilarAndDeleteSimilarPalettes.sh
# NOTES
# - When this script completes work of removing similar palettes from a directory, it places a log file named similar_palettes_deleted.txt in that directory. Before working in any directory, it checks for that file, and if it exists, the script skips working in that directory. This allows breaking and resuming run of this script.
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
	if [ $count != 0 ] && [ ! -e similar_palettes_deleted.txt ]
	then
		printf "\nAt least one .hexplt file found here OR log file similar_palettes_deleted.txt not found; proceeding . . .\n"
# TWO OPTIONS here: allRGBhexColorSortInCAM16-UCS.sh or allRGBhexColorSortIn2CIECAM02.sh; I've gone back and forth on which to use; CAM16 I had at one point thought sorted tint/shade better; now I'm not sure; it seemed to me at one point that CIECAM02 sorted hue better. I haven't re-examined that theory. allRGBhexColorSortIn2CIECAM02.sh does calculations much faster it seems:
		allRGBhexColorSortIn2CIECAM02.sh
			# OPTIONAL count of lines in each hexplt (check if their data ended up ok after that sort) :
			# allHEXPLTs=(`find . -maxdepth 1 -type f -iname \*.hexplt -printf '%f\n'`)
			# for hexplt in ${allHEXPLTs[@]}
			# do
				# count=`cat $hexplt | wc -l`
				# echo file $hexplt is with line count $count
			# done
		rm *.png
		renderAllHexPalettes-gm.sh NULL 250 NULL
		allPalettesCompareCIECAM02.sh
		listPaletteDifferencesBelowThreshold.sh $deletePalettesBelowDifferenceThreshold
		deletePalettesDifferentBelowThreshold.sh
		# change back to parent dir; not using pushd . /popd because it does weird unhelpful printing of the same directory over and over which I don't like and which isn't helpful:
		printf "Similar palettes which were in this directory below difference threshold 0.14 were deleted.\n" > similar_palettes_deleted.txt
	else
		printf "\nNo hexplt file found in directory OR log file similar_palettes_deleted.txt was found; skipping directory."
	fi
	cd $currentDir
done
