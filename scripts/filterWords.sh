# DESCRIPTION
# Prints all words in text file $2 that don't appear in text file $1 (excludes all words $1 from $2), provided that both files have one word per line.

# USAGE
# Run with these parameters:
# - $1 text file name of filter words (words you do not want printed)
# - $2 text file name to filter words out of (words you want printed minus filter words).
# For example:
#    filterWords.sh filterWords.txt fileToFilterWordsFrom.txt
# NOTES
# - The source text files are expected to have one word per line. This will not work the way you might want with paragraphs.
# - To capture results to a new file, use a redirect operator, like this:
#    filterWords.sh filterWords.txt fileToFilterWordsFrom.txt > filteredWords.txt


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (file name of text file with filter words) passed to script. Exit."; exit 1; else fitlerWordsFileName=$1; fi
if [ ! "$2" ]; then printf "\nNo parameter \$2 (file name of text file to print with words filtered out of it) passed to script. Exit."; exit 2; else fileNameToFilterWordsFrom=$2; fi

# Thanks yet again to yet another genius breath yonder: http://stackoverflow.com/a/18477228/1397555
	# THE COMMAND TEMPLATE is:
	# awk '{if (f==1) { r[$0] } else if (! ($0 in r)) { print $0 } } ' f=1 exclude-these.txt f=2 from-this.txt
	# ADAPTED e.g. for removal of all actual English words (english_dictionary.txt) from gibberishWords.txt:
	# awk '{if (f==1) { r[$0] } else if (! ($0 in r)) { print $0 } } ' f=1 english_dictionary.txt f=2 gibberishWords.txt > gibberishWords_real_words_excluded.txt
awk '{if (f==1) { r[$0] } else if (! ($0 in r)) { print $0 } } ' f=1 $fitlerWordsFileName f=2 $fileNameToFilterWordsFrom