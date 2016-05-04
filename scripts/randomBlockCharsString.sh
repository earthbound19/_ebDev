# DESCRIPTION: returns one random, extremely long string of blocky utf8 characters.

# USAGE: Run this script and open the resultant blockString.txt. NOTE: unless I figure out a better way, this copies values from a source file randomly.

# LICENSE: I wrote and deed this to the Public Domain 05/04/2016 12:22:51 PM -RAH

# NOTE: To work as expected, this should be and write to utf8 encoding (simply convert the result to that encoding via npp+ encoding menu if it is not thus encoded).

printf "" > temp.txt

for elm in {1..90}
do
	shuf blockChars.txt >> temp.txt
done

tr -d '\n' < temp.txt > blockString.txt
rm temp.txt

cygstart blockString.txt

# HISTORY:
# 05/04/2016 12:37:50 PM -RAH Created after seeing these interesting characters in an .nfo; coincidentally, just such blocky "noise" suited for what I had wanted at that moment to make!

