# DESCRIPTION
# Inclusion text filter. Prints text file $2, modified, with only words that are also in text file $1. Another way of saying that is: prints only words in $2 that are in both $1 and $2. Both files must have one word per line.

# USAGE
# Run with these parameters:
# - $1 text file name of inclusion filter words (words you want printed)
# - $2 text file name to print words for only if they also appear in $1.
# For example:
#    filterIncludedWords.sh incudeWords.txt textToFilter.txt
# NOTES
# - The source text files are expected to have one word per line. This will not work the way you might want with paragraphs.
# - To capture results to a new file, use a redirect operator, like this:
#    filterIncludedWords.sh incudeWords.txt textToFilter.txt > filteredWords.txt


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (file name of text file of include filter words) passed to script. Exit."; exit 1; else includeFilterWordsFileName=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (file name of text file to print words from only if they appear in $\1) passed to script. Exit."; exit 2; else textToFilterFileName=$2; fi

awk '{if (f==1) { r[$0] } else if ($0 in r) { print $0 } } ' f=1 $includeFilterWordsFileName f=2 $textToFilterFileName