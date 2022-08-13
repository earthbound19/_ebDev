# DESCRIPTION
# Helps either eliminate or group palettes (.hexplt files) in all subfolders of the current folder (but not palettes in the folder itself) which are perceptually similar (technically and logically: not very different below a threshold). Does this with a custom loop in this script, using other scripts also. To understand how all this works, you must examine the DESCRIPTION and USAGE etc. comments of all the scripts which this script runs.

# DEPENDENCIES
# `listAllSubdirs.sh`, `allPalettesCompareCIECAM02.sh`, `listPaletteDifferencesBelowThreshold.sh`, `groupPalettesDifferentBelowThreshold.sh`, `pruneByUnmatchedExtension.sh`, and any of their dependencies.

# USAGE
# Hack the global value right after the CODE comment per your want. Then run the script:
#    reduceSimilarPalettesAssistant.sh
# NOTES
# - Search for comments that read UNCOMMENT and OPTINOAL and examine them and follow their instructions, if you wish.
# - Also search for an OPTIONS comment to see alternate steps at that point. The grouping option is the hard-coded default.
# - Before working, this checks for the existence of similar_palettes_deleted.txt. If that file does not exist, work continues. If it does exist, work stops. If it does exist, work is skipped with a print notification of that fact. This allows breaking and resuming run of this script.
# - Via pruneByUnmatchedExtension.sh, this script sorts any resultant orphaned .hexplt files (for which matching png palettes were deleted) into a folder for review to delete.


# CODE
deletePalettesBelowDifferenceThreshold=0.137

currentDir=$(pwd)
allSubdirectoriesArray=( $(listAllSubdirs.sh) )
for directory in ${allSubdirectoriesArray[@]}
do
	printf "\nChanging to directory: $directory . . ."
	cd $directory
	# Only do things if there are .hexplt files (and assumed related files) to work on; re: https://stackoverflow.com/a/3856879/1397555
	count=$(ls -1 *.hexplt 2>/dev/null | wc -l)
	if [ $count != 0 ] && [ ! -f similar_palettes_deleted.txt ]
	then
		printf "\nAt least one .hexplt file found here OR log file similar_palettes_deleted.txt not found; proceeding . . .\n"
# TWO OPTIONS here: allRGBhexColorSortInCAM16-UCS.sh or allRGBhexColorSortInCIECAM02.sh; I've gone back and forth on which to use; CAM16 I had at one point thought sorted tint/shade better; now I'm not sure; it seemed to me at one point that CIECAM02 sorted hue better. I haven't re-examined that theory. allRGBhexColorSortInCIECAM02.sh does calculations much faster it seems:
# OPTIONAL; in many cases I've already run this over the directory, so it would be redundant and wasted work; UNCOMMENT if you want to use it:
#		allRGBhexColorSortInCIECAM02.sh
			# OPTIONAL count of lines in each hexplt (check if their data ended up OK after that sort) :
			# allHEXPLTs=( $(find . -maxdepth 1 -type f -iname \*.hexplt -printf '%f\n') )
			# for hexplt in ${allHEXPLTs[@]}
			# do
				# count=$(cat $hexplt | wc -l)
				# echo file $hexplt is with line count $count
			# done
#		rm *.png
# OPTIONAL STEP: (re)-render any palettes that were deleted or are otherwise not rendered:
#		renderAllHexPalettes.sh NULL 250 NULL
		allPalettesCompareCIECAM02.sh
		listPaletteDifferencesBelowThreshold.sh $deletePalettesBelowDifferenceThreshold
		# OPTIONS: the next line or the line after it (uncomment one):
			# deletePalettesDifferentBelowThreshold.sh
			groupPalettesDifferentBelowThreshold.sh
		# move any leftover .hexplt (no matched .png file -- matching png deleted) into a folder for review for deletion, via this script; not necessary if you use groupPalettesDifferentBelowThreshold.sh:
		pruneByUnmatchedExtension.sh hexplt png
		printf "Similar palettes which were in this directory below difference threshold 0.14 were either moved or deleted (depending on which option you have uncommented in the code).\nOrphan .hexplt files which have no matching png were sorted into a subfolder for review to delete.\n" > similar_palettes_deleted.txt
	else
		printf "\nNo hexplt file found in directory OR log file similar_palettes_deleted.txt was found; skipping directory."
	fi
	# change back to parent dir; not using pushd . /popd because it does weird unhelpful printing of the same directory over and over which I don't like and which isn't helpful:
	cd $currentDir
done
