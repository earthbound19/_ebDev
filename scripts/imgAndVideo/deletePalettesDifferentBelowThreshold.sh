# DESCRIPTION
# Last of a series of scripts designed to eliminate similar .hexplt format palettes. Interactively launches pairs of rendered palettes corresponding to .hexplt files found to be similar (not so different below a rating threshold), as discovered by listPaletteDifferencesBelowThreshold.sh (which must be run first). Logs how many comparisons have been examined and allows resume from Nth comparison (see USAGE).

# USAGE
# Before this script, run listPaletteDifferencesBelowThreshold.sh (which tells you to run another script before it), to generate the list paletteDifferencesBelowThreshold.txt. Then run with or without this parameter, and follow the prompts:
# - $1 OPTIONAL. Comparison number to start from, if this script was run prior but interrupted midway or if you want to skip some for any other reason. As the script runs, it logs each comparison iteration to deletePalettesDifferentBelowThresholdLog.txt. If the script is interrupted you may examine that file to know what iteration was last looked at by examining that file, then resume from that point.
# For example if the log file reads:
#    Iteration 320 of 794, pair CikkUp54.png | DNRi4NKs.png . . .
# To resume from that comparision, you may run this script with that first number:
#    deletePalettesDifferentBelowThreshold.sh 320
# The script will skip all iterations up to 320 and resume from there.
# To examine all iterations, run this script without any parameter:
#    deletePalettesDifferentBelowThreshold.sh 320


# CODE
if [ "$1" ]; then echo "Parameter \$1 passed to script (comparison number to resume from). Will use that"; resumeFromNumber=$1; else resumeFromNumber=0; fi

printf "\nThis script launches pairs of palette image renders associated with palettes ranked below a dissimilarity threhshold, in a comparison log file, paletteDifferencesBelowThreshold.txt. It uses the 'start' command repeatedly to launch images. The intent is that an image editor with a hotkey to delete an image will make it easier to delete one of a pair of palettes that you like less. Press any key to continue . . ."
read -rsn1

arrayOfFilesToDelete=$(<paletteDifferencesBelowThreshold.txt)

# variables for feedback print:
linesCount=$(cat paletteDifferencesBelowThreshold.txt | wc -l)
loopCount=0
for element in ${arrayOfFilesToDelete[@]}
do
	loopCount=$((loopCount + 1))
	if [ "$loopCount" -ge "$resumeFromNumber" ]
	then
		printf "\n\nIteration $loopCount of $linesCount . . ."
		# Changing the \ backreference in this sed search to \1, \2 or \3 captures whatever is between the 0-1, 1-2, or 2-3 | character grouping:
		A_pair=$(echo $element | sed 's/\([^|]*\)|\([^|]*\)|\([^|]*\)/\2/g')
		B_pair=$(echo $element | sed 's/\([^|]*\)|\([^|]*\)|\([^|]*\)/\3/g')
		PNGmatchFor_A=${A_pair%.*}.png
		PNGmatchFor_B=${B_pair%.*}.png
		printf "\nPair $PNGmatchFor_A | $PNGmatchFor_B . . ."
		# Skip delete prompt if either of pair not found:
		if [ ! -e $PNGmatchFor_A ] || [ ! -e $PNGmatchFor_B ]
		then
			printf "\n\n!-- A and/or B for pair not found. Will skip image launch attempt . . ."
		# Otherwise prompt to launch image pair and delete one:
		else
			# write to log (so user can look in log to know where to resume if process interrupted) :
			printf "Iteration $loopCount of $linesCount, pair $PNGmatchFor_A | $PNGmatchFor_B . . ." > deletePalettesDifferentBelowThresholdLog.txt
			printf '\n~\nAttempting "start" command to launch corresponding palette images for A and B in similarity pair. Delete the one you like less, then press any key to continue . . .'
			start $PNGmatchFor_A
			start $PNGmatchFor_B
			# Waits for keypess (no need to press key and then <enter>; it is immediate) :
			read -rsn1
		fi
	fi
done

