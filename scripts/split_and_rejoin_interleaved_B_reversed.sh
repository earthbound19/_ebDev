# DESCRIPTION
# Does custom sorting of a file list or a list in the clipboard (the clipboard probably only for MSYS2 / Windows). Intended for Spotify playlist custom reordering, but could be used for other purposes. It does this:
# - splits a list in a file (e.g. copied and pasted from the UI of a spotify playlist) $1 OR from the clipboard
# - interleaves the lines of the split files (or clipboard) with the 1st file (A) reversed before interleaving.
# This results in file A blending in reverse with file B (B still in the order it was). The result file name is  destFileName=${sourceFile%.*}_split_and_rejoined_B_interleaved.txt. If you provide no source file (and use the clipboard) the result is written to fb320fe2_fileList.txt_split_and_rejoined_B_interleaved.txt.
# If no source file is provided it assumes the list is on the clipboard, and also copies the result back over the clipboard. Otherwise it doesn't copy to the clipboard.

# USAGE
# Run with these parameters:
# - $1 OPTIONAL file name of source list to parse. If not provided, the script assumes you copied the list to the clipboard (MSYS2 only, probably), and works with that.
# Example using a source file:
#    split_and_rejoin_interleaved_B_reversed.sh sourceList.txt
# Example using the clipboard; copy the list to the clipboard, then run this script with no parameter:
#    split_and_rejoin_interleaved_B_reversed.sh


# CODE
# delete temp file names in case they're leftover from broken runs:
rm part1.txt part2.txt part1_reversedTMP.txt &>/dev/null

# first use of cygwin clipboard functionality in any script; re https://williammitchell.blogspot.com/2008/03/fun-with-cygwins-devclipboard.html
if [ "$1" ]
	then sourceFile=$1
else
	sourceFile="fb320fe2_fileList.txt"
	cat /dev/clipboard > $sourceFile
fi

# construct target file name:
destFileName=${sourceFile%.*}_split_and_rejoined_B_interleaved.txt

	# split the source file -- the resulting file names for this command are x00 and x01:
	# DEPRECATED -- THIS BRAT SPLIT IN THE MIDDLE OF A LINE! :
	# split --numeric-suffixes=0 -n 2 $sourceFile

awk 'NR <= (n = int((NR_TOTAL+1)/2)) {print > "part1.txt"; next} {print > "part2.txt"}' NR_TOTAL=$(wc -l < $sourceFile) $sourceFile

# append newline; if there's a trailing line with no newline at the end, tac reads two lines as 1; this works around that:
printf "\n" >> part1.txt
printf "\n" >> part2.txt

# but then reverse A for our purposes; agh, on disk:
tac part1.txt > part1_reversedTMP.txt

# make new array from both; this omits any resulting blank lines:
filenames=($(paste -d '\n' part1_reversedTMP.txt part2.txt ))

# only overwrite clipboard if there is no $1 variable (if nothing was passed to the script); otherwise write to file:
if [ ! "$1" ];
then
	printf '%s\n' "${filenames[@]}" > /dev/clipboard
	# also delete related temp files is clipboard was used:
	rm fb320fe2_fileList.txt
	echo "DONE. Result written to clipboard."
else
	# else print that array to dest file:
	printf '%s\n' "${filenames[@]}" | tr -d '\15\32' > $destFileName
	echo "DONE. Result written to $destFileName"
fi

# delete temp intermediary files
rm part1.txt part2.txt part1_reversedTMP.txt