# DESCRIPTION
# Does custom sorting of a file list or a list in the clipboard (the clipboard probably only for MSYS2 / Windows). Intended for Spotify playlist custom reordering, but could be used for other purposes.
# The process:
# - Takes a list from a file $1, OR from the clipboard if no source file provided.
# - Processes the list by removing items one at a time from the start of the list, and distributing them into three component lists (A, B, C) in a repeating 4-step cycle:
#   1. Append to the end of component A (start of final list)
#   2. Append to the start of component C (end of final list)
#   3. Append to the start of component B (middle section)
#   4. Append to the end of component B (middle section), then reset cycle
# - When all items have been removed from the source list, it joins list components in order: A + B + C
# - Assuming a source list sorted by descending valence (highest first), this creates two valence waves, with higher values at the start, end and middle; a three-peak/tent-like distribution.
# - if it used a file as the source, it writes the result to a file named after the source file, in the format <source file basename>_two_wave_distribution.txt.
# - if it used the clipboard as the source, it copies the result back to the clipboard, replacing the clipboard.

# USAGE
# Run with these parameters:
# - $1 OPTIONAL file name of source list to parse. If not provided, the script assumes you copied the list to the clipboard (MSYS2 only, probably), and works with that.
# Example using a source file:
#    three_pole_tent_sort.sh sourceList.txt
# Example using the clipboard; copy the list to the clipboard, then run this script with no parameter:
#    three_pole_tent_sort.sh


# CODE
# delete temp file names in case they're leftover from broken runs:
rm part1.txt part2.txt part1_reversedTMP.txt part2_reversedTMP.txt &>/dev/null

# first use of cygwin clipboard functionality in any script; re https://williammitchell.blogspot.com/2008/03/fun-with-cygwins-devclipboard.html
if [ "$1" ]
	then sourceFile=$1
else
	sourceFile="fb320fe2_fileList.txt"
	cat /dev/clipboard > $sourceFile
fi

# construct target file name:
destFileName=${sourceFile%.*}_two_wave_distribution.txt

# Read source list into an array
mapfile -t sourceList < "$sourceFile"

# Initialize component arrays and cycle counter
componentA=()
componentB=()
componentC=()
cycleIndex=0

# Process each item from the source list
for item in "${sourceList[@]}"; do
	# Increment cycle counter (1-4)
	((cycleIndex++))
	
	case $cycleIndex in
		1)
			# Append to component A (start of final list)
			componentA+=("$item")
			;;
		2)
			# Prepend to component C (end of final list)
			componentC=("$item" "${componentC[@]}")
			;;
		3)
			# Prepend to component B (middle section, before existing B items)
			componentB=("$item" "${componentB[@]}")
			;;
		4)
			# Append to component B (middle section, after existing B items)
			componentB+=("$item")
			# Reset cycle counter
			cycleIndex=0
			;;
	esac
done

# Join components in order: A + B + C
finalList=("${componentA[@]}" "${componentB[@]}" "${componentC[@]}")

# only overwrite clipboard if there is no $1 variable (if nothing was passed to the script); otherwise write to file:
if [ ! "$1" ];
then
	printf '%s\n' "${finalList[@]}" > /dev/clipboard
	# also delete related temp files if clipboard was used:
	rm fb320fe2_fileList.txt
	echo "DONE. Result written to clipboard."
else
	# else print that array to dest file:
	printf '%s\n' "${finalList[@]}" | tr -d '\15\32' > $destFileName
	echo "DONE. Result written to $destFileName"
fi

# delete temp intermediary files
rm part1.txt part2.txt part1_reversedTMP.txt part2_reversedTMP.txt &>/dev/null