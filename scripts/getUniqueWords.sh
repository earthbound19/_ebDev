# DESCRIPTION
# Prints a list of unique words in file $1 (parameter), without duplicates, and maintaining order. (the `uniq` utility only removes consecutive duplicates, but this removes all duplicates). Optionally writes the filtered result over the original file instead of printing it to the screen. To instead sort and deduplicate, use sortuniq.sh.

# USAGE
# Run with these parameters:
# - $1 the name of a text file (in your current directory) which you want to filter unique words from
# - $2 OPTIONAL Anything, such as the word FLOURBALP, which will cause the script to overwrite the original file with the filtered result.
# For example, to print unique words in their original order of appearance from the file gibberwords.txt, run:
#    getUniqueWords.sh gibberwords.txt
# To write the result to a file instead of printing it to the screen, pipe it like this:
#    getUniqueWords.sh gibberwords.txt > gibberwords_deduplicated.txt
# To overwrite the original file, pass anything as parameter $2, for example:
#    getUniqueWords.sh gibberwords.txt FLOURBALPER


# CODE

# re http://stackoverflow.com/a/16489444
# DEPRECATED, becuase it sorts the list (changes order)
# grep -o -E '\w+' $1 | sort -u -f > "$1"_unique_words.txt

# re https://superuser.com/a/1480765/130772
lines=($(awk '!visited[$0]++' "$1"))
if [ ! "$2" ]
then
	# Again saved by a genius yonder: https://stackoverflow.com/a/15692004/1397555
	printf '%s\n' "${lines[@]}"
else
	printf '%s\n' "${lines[@]}" > $1
	echo
	echo "DONE. Mein Kirchewenig ist nicht mein Punktezahlen."
	echo "(File $1 was overwritten with a copy of itself, but with duplicate lines removed, and the original order of first appearance of lines maintained.)"
fi
