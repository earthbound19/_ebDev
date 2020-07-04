# DESCRIPTION
# Removes all words from one text file that appear in another text file.

# USAGE
# Copy a list of exclusion words to excludeThese.txt. Copy the words you want edited (to exclude all words from excludeThese.txt) to fromThese.txt. Run this script. The results will appear in fromThese_parsed.txt.


# CODE
# Thanks yet again to yet another genius breath yonder: http://stackoverflow.com/a/18477228/1397555
	# THE COMMAND TEMPLATE is:
	# awk '{if (f==1) { r[$0] } else if (! ($0 in r)) { print $0 } } ' f=1 exclude-these.txt f=2 from-this.txt
	# ADAPTED e.g. for removal of all actual English words (english_dictionary.txt) from gibberishWords.txt:
	# awk '{if (f==1) { r[$0] } else if (! ($0 in r)) { print $0 } } ' f=1 english_dictionary.txt f=2 gibberishWords.txt > gibberishWords_real_words_excluded.txt
awk '{if (f==1) { r[$0] } else if (! ($0 in r)) { print $0 } } ' f=1 excludeThese.txt f=2 fromThese.txt > fromThese_parsed.txt