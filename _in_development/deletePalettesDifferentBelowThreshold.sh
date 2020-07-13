# DESCRIPTION
# Last of a series of scripts designed to eliminate similar .hexplt format palettes. Interactively launches pairs of rendered palettes corresponding to .hexplt files found to be similar (not so different below a rating threshold), as discovered by listPaletteDifferencesBelowThreshold.sh (which must be run first).

# USAGE
# Before this script, run listPaletteDifferencesBelowThreshold.sh (which tells you to run another script before it), to generate the list paletteDifferencesBelowThreshold.txt. Then run this script:
#  deletePalettesDifferentBelowThreshold.sh
# -- and follow the prompts.


# CODE
printf "\nThis script launches pairs of palette image renders associated with palettes ranked below a dissimilarity threhshold, in a comparison log file, paletteDifferencesBelowThreshold.txt. It uses the 'start' command repeatedly to launch images. The intent is that an image editor with a hotkey to delete an image will make it easier to delete one of a pair of palettes that you like less. Press any key to continue . . ."
read -rsn1

arrayOfFilesToDelete=$(<paletteDifferencesBelowThreshold.txt)

for element in ${arrayOfFilesToDelete[@]}
do
	# Changing the \ backreference in this sed search to \1, \2 or \3 captures whatever is between the 0-1, 1-2, or 2-3 | character grouping:
	A_pair=`echo $element | sed 's/\([^|]*\)|\([^|]*\)|\([^|]*\)/\2/g'`
	B_pair=`echo $element | sed 's/\([^|]*\)|\([^|]*\)|\([^|]*\)/\3/g'`
		# dev test print:
		# echo "$element >"
		# echo "$A_pair | $B_pair"
		# echo " . . ."
	PNGmatchFor_A=${A_pair%.*}.png
	PNGmatchFor_B=${B_pair%.*}.png
	# Skip delete prompt if either of pair not found:
	if [ ! -e $PNGmatchFor_A ] || [ ! -e $PNGmatchFor_B ]
	then
		printf "\n\n!-- A and/or B for pair not found. Will skip image launch attempt . . ."
	# Otherwise prompt to launch image pair and delete one:
	else
		printf '\n~\nAttempting "start" command to launch corresponding palette images for A and B in similarity pair. Delete the one you like less, then press any key to continue . . .'
		start $PNGmatchFor_A
		start $PNGmatchFor_B
		# Waits for keypess (no need to press key and then <enter>; it is immediate) :
		read -rsn1
	fi
done

