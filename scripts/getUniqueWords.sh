# DESCRIPTION
# Creates a list of unique words in file $1 (parameter), without duplicates. It will create an identically named file but adding _unique_words.txt to the end of the file name.

# USAGE
# Pass this script the name of a text file which you want to filter unique words from, e.g.:
#  getUniqueWords.sh gibberwords.txt


# CODE
# Re http://stackoverflow.com/a/16489444
grep -o -E '\w+' $1 | sort -u -f > "$1"_unique_words.txt