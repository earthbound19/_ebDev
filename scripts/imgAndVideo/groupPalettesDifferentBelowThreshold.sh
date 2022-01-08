# DESCRIPTION
# Last of a series of scripts designed to identify similar .hexplt format palettes. Takes palettes discovered by listPaletteDifferencesBelowThreshold.sh (which must be run first), which are similar, and copies them into new subfolders named after the palette they are similar to. Also copies any accompanying .png palette render images into the same folders. Can alternately move hexplt and palette images (instead of copy). For purposes of anything you would want to do with palettes that can be seen as perceptually similar, for example eliminating palettes so perceptually similar as to be practical duplicates, or grouping similar palettes.

# DEPENDENCIES
# - run of a previous script and anything it depends on (see USAGE)

# USAGE
# Before this script, run listPaletteDifferencesBelowThreshold.sh (which tells you to run another script before it), to generate the list paletteDifferencesBelowThreshold.txt. Then run with these parameters:
# - $1 OPTIONAL. Any word, for example FROGBALF, which causes the script to move files. If you omit this parameter, files are copied.
# For example, to copy all found similar palettes into subfodlers named after pair A for each discovered similairity, run:
#    groupPalettesDifferentBelowThreshold.sh
# To *move* palettes into subfolders instead of copying them (with possible side effects detailed under NOTE), run:
#    groupPalettesDifferentBelowThreshold.sh FROGBALF
# It will create a new subfolder for any palette for which one or more similar palettes were found, and copy that palette with the palette(s) similar to it into that new subfolder. You may then examine the resulting subfolder(s) for whatever further creative purposes you have (like deleting similar ones you like less, or copying them to a group of palettes elsewhere, or whatever).
# NOTE
# If you use parameter 1 (opt to move files), you may end up with folders where an A or B similarity pair wasn't moved, and empty subfolders. That may mean that one palette (B) had similarity to two or more other palettes (A and C [D, E..]) which were not similar enough to each other for grouping; e.g. B is within similarity threshold to both A and C, but A is not within that similarity threshold to C.


# CODE
# set default command to cp (copy);
command=cp
# override to mv if parameter 1 was passed to script:
if [ "$1" ]; then command=mv; fi

arrayOfFilesToScan=$(<paletteDifferencesBelowThreshold.txt)

# variables for feedback print:
linesCount=$(cat paletteDifferencesBelowThreshold.txt | wc -l)
loopCount=0
for element in ${arrayOfFilesToScan[@]}
do
	loopCount=$((loopCount + 1))
	printf "\n\nIteration $loopCount of $linesCount . . ."
	# Changing the \ backreference in this sed search to \1, \2 or \3 captures whatever is between the 0-1, 1-2, or 2-3 | character grouping:
	differenceRanking=$(sed 's/\([^|]*\)|\([^|]*\)|\([^|]*\)/\1/g' <<< $element)
	A_pair=$(sed 's/\([^|]*\)|\([^|]*\)|\([^|]*\)/\2/g' <<< $element)
	B_pair=$(sed 's/\([^|]*\)|\([^|]*\)|\([^|]*\)/\3/g' <<< $element)
	PNGmatchFor_A=${A_pair%.*}.png
	PNGmatchFor_B=${B_pair%.*}.png
	HEXPLTmatchFor_A=${A_pair%.*}.hexplt
	HEXPLTmatchFor_B=${B_pair%.*}.hexplt
	similarityRanking=$(bc <<< "1 - $differenceRanking")
	printf "\nDifference $differenceRanking (Similarity 0$similarityRanking)" 
	printf "\nPair $PNGmatchFor_A | $PNGmatchFor_B . . ."
	# get base name of palette (without extension) for pair A:
	targetDirName_for_A=${PNGmatchFor_A%.*}
	# create target dir if it doesn't exist:
	if [ ! -d $targetDirName_for_A ]
	then
		mkdir $targetDirName_for_A
	fi
	
	# copy (or move, depending on whether parameter 1 was passed to script) pair A hexplt into that folder only if that hasn't already been done:
	if [ ! -f $targetDirName_for_A/$HEXPLTmatchFor_A ]
	then
		if [ -f $HEXPLTmatchFor_A ]
		then
		$command $HEXPLTmatchFor_A $targetDirName_for_A/$HEXPLTmatchFor_A
		fi
	fi
	# ~pair A palette image into that folder only if it hasn't already:
	if [ ! -f $targetDirName_for_A/$PNGmatchFor_A ]
	then
		if [ -f $PNGmatchFor_A ]
		then
		$command $PNGmatchFor_A $targetDirName_for_A/$PNGmatchFor_A
		fi
	fi
	# ~pair B hexplt into that folder only if it hasn't already:
	if [ ! -f $targetDirName_for_A/$HEXPLTmatchFor_B ]
	then
		if [ -f $HEXPLTmatchFor_B ]
		then
		$command $HEXPLTmatchFor_B $targetDirName_for_A/$HEXPLTmatchFor_B
		fi
	fi
	# ~pair B palette image into that folder only if it hasn't already:
	if [ ! -f $targetDirName_for_A/$PNGmatchFor_B ]
	then
		if [ -f $PNGmatchFor_B ]
		then
		$command $PNGmatchFor_B $targetDirName_for_A/$PNGmatchFor_B
		fi
	fi
done

printf "\nDONE copying (or depending on whether you instructed the script to, moving) similar palettes (different below threshold) into subfolders named after similarity pair 'A'."