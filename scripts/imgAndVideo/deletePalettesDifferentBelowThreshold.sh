# DESCRIPTION
# Last of a series of scripts designed to eliminate similar .hexplt format palettes. Interactively launches pairs of rendered palettes corresponding to .hexplt files found to be similar (not so different below a rating threshold), as discovered by listPaletteDifferencesBelowThreshold.sh (which must be run first). Logs how many comparisons have been examined and allows resume from Nth comparison (see USAGE).
# For assistance with managing copies of palettes (in favorites collections), this script optionally uses everything CLI (es.exe, if it makes a successful attempt to run an executable of that name in a way that will produce no error), for statistics on how many copies of given images are found on your (Windows) computer. See USAGE for details.

# DEPENDENCIES
# - run of a previous script and anything it depends on (see USAGE)
# - A default image editor associated with the image files in the list which this script depends on (paletteDifferencesBelowThreshold.txt)
# - Optionally, everything CLI (es.exe, see DESCRIPTION)

# USAGE
# Before this script, run listPaletteDifferencesBelowThreshold.sh (which tells you to run another script before it), to generate the list paletteDifferencesBelowThreshold.txt. Then run with or without this parameter, and follow the prompts:
# - $1 OPTIONAL. Comparison number to start from, if this script was run prior but interrupted midway or if you want to skip some for any other reason. As the script runs, it logs each comparison iteration to deletePalettesDifferentBelowThresholdLog.txt. If the script is interrupted you may examine that file to know what iteration was last looked at by examining that file, then resume from that point.
# For example if the log file reads:
#    Iteration 320 of 794, pair CikkUp54.png | DNRi4NKs.png . . .
# To resume from that comparision, you may run this script with that first number:
#    deletePalettesDifferentBelowThreshold.sh 320
# The script will skip all iterations up to 320 and resume from there.
# To examine all iterations, run this script without any parameter:
#    deletePalettesDifferentBelowThreshold.sh
# NOTES
# - This script detects whether everything CLI (es.exe) is installed and executes normally, and if so, it enables you to pick favorite palettes and copy them into palette collections, by printing information about how many copies of the palette (ASSUMED: in .hexplt format) are found on your computer. If this script prints information on the count of that palette file found on the computer, you'll know you don't need to copy the palette to another location (a collection), as it has already been copied (there are 2 or more of it).
# - If this script gets an error on attempt to run everything CLI, it will print a count for a palette with a question mark, which indicates that the number of them on the computer is unknown.

# CODE
if [ "$1" ]; then echo "Parameter \$1 passed to script (comparison number to resume from). Will use that"; resumeFromNumber=$1; else resumeFromNumber=0; fi

everythingCLIworking='False'
es ANtUeH52yu9rtxWaBEBAqm5UsJ34Sghjz9vzRujyVN
if [ $(echo $?) == "0" ]
then
	everythingCLIworking='True'
fi
echo value of everythingCLIworking is $everythingCLIworking

printf "\nThis script launches pairs of palette image renders associated with palettes ranked below a dissimilarity threshold, in a comparison log file, paletteDifferencesBelowThreshold.txt. It uses the 'start' command repeatedly to launch images. The intent is that an image editor with a hotkey to delete an image will make it easier to delete one of a pair of palette images that you like less. Press any key to continue . . ."
read -rsn1

arrayOfFilesToScan=$(<paletteDifferencesBelowThreshold.txt)

# variables for feedback print:
linesCount=$(cat paletteDifferencesBelowThreshold.txt | wc -l)
loopCount=0
for element in ${arrayOfFilesToScan[@]}
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
		HEXPLTmatchFor_A=${A_pair%.*}.hexplt
		HEXPLTmatchFor_B=${B_pair%.*}.hexplt
		printf "\nPair $PNGmatchFor_A | $PNGmatchFor_B . . ."
		# Skip delete prompt if either of pair not found:
		if [ ! -e $PNGmatchFor_A ] || [ ! -e $PNGmatchFor_B ]
		then
			printf "\n\n!-- A and/or B for pair not found. Will skip image launch attempt . . ."
		# Otherwise prompt to launch image pair and delete one:
		else
			# write to log (so user can look in log to know where to resume if process interrupted) :
			if [ "$everythingCLIworking" == 'True' ]
			then
				count_pngs_A=$(es $PNGmatchFor_A | wc -l)
				count_pngs_B=$(es $PNGmatchFor_B | wc -l)
				count_hexplts_A=$(es $HEXPLTmatchFor_A | wc -l)
				count_hexplts_B=$(es $HEXPLTmatchFor_B | wc -l)
			else
				count_pngs_A='n?'
				count_pngs_B='n?'
				count_hexplts_A='n?'
				count_hexplts_B='n?'
			fi
			printf "Iteration $loopCount of $linesCount, pair $PNGmatchFor_A | $PNGmatchFor_B . . ." > deletePalettesDifferentBelowThresholdLog.txt
			printf "\n~\nAttempting \"start\" command to launch corresponding palette images for A and B in similarity pair:\n~\n$PNGmatchFor_A ($count_pngs_A) : $HEXPLTmatchFor_A ($count_hexplts_A)\n$PNGmatchFor_B ($count_pngs_B) : $HEXPLTmatchFor_B ($count_hexplts_B)\n~\nDelete the one you like less, or alternately maybe copy one or both to a palette/similar palettes collection, then press any key to continue . . .\n"
			start $PNGmatchFor_A
			start $PNGmatchFor_B
			# Waits for keypess (no need to press key and then <enter>; it is immediate) :
			read -rsn1
		fi
	fi
done

