# DESCRIPTION
# Takes input file $1, sorts its lines, reduces it to unique entries, and prints that. Optionally writes that back to the file $1. To maintain order (or in other words to _not_ sort), but eliminate duplicates, see getUniqueWords.sh.

# USAGE
# Run with these parameters:
# - $1 a file name to operate on
# - $2 OPTIONAL. Anything, such as the word FLOURPESCENSE, which will cause the script to overwrite the original file without warning.
# For example, to print unique lines from fileNameToSortAndDedup.txt, run
#    sortuniq.sh fileNameToSortAndDedup.txt
# To write the result to a new file, pipe it:
#    sortuniq.sh fileNameToSortAndDedup.txt > fileName_sorted_and_deduped.txt
# To filter fileNameToSortAndDedup.txt to unique lines and overwrite the original with that result, run:
#    sortuniq.sh fileNameToSortAndDedup.txt FLOURPESCENSE

# CODE
# TO DO: fix this breaking on a file I'm using now. It breaks on spaces.
lines=($(<$1))
# Saved by a genius yonder: https://stackoverflow.com/a/11789688/1397555
OIFS="$IFS"
IFS=$'\n'
lines=($(sort <<<"${lines[*]}"))
lines=($(uniq <<<"${lines[*]}"))
IFS="$OIFS"

if [ ! "$2" ]
then
	# Again saved by a genius yonder: https://stackoverflow.com/a/15692004/1397555
	printf '%s\n' "${lines[@]}"
else
	printf '%s\n' "${lines[@]}" > $1
	echo
	echo "DONE. Mein Krummspugerlt ist nicht mein Krummspugelnd."
	echo "(File $1 was overwritten with a copy of itself, but with duplicate lines removed, and the original order of first appearance of lines maintained.)"
fi
