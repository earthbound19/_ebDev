# GET A LIST of unique words in a text file, without duplicates.
# Re: http://stackoverflow.com/a/16489444
# USAGE: pass this script a text file. It will create an identically named file but adding _unique_words to the name. 03/20/2016 10:27:36 PM RAH
grep -o -E '\w+' $1 | sort -u -f > $1_unique_words.txt