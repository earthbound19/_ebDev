# DESCRIPTION: returns one random, extremely long string of blocky utf8 characters.

# USAGE: Run this script and open the resultant blockString.txt. NOTE: unless I figure out a better way, this copies values from a source file randomly.

# LICENSE: I wrote and deed this to the Public Domain 05/04/2016 12:22:51 PM -RAH

# NOTE: To work as expected, this should be and write to utf8 encoding (simply convert the result to that encoding via npp+ encoding menu if it is not thus encoded).

printf "" > temp.txt

THIS_SCRIPTS_PATH="`dirname \"$0\"`"
	# echo THIS_SCRIPTS_PATH val is\:
	# echo $THIS_SCRIPTS_PATH

for elm in {1..90}
do
	shuf "$THIS_SCRIPTS_PATH/blockChars.txt" >> temp.txt
done

tr -d '\n' < temp.txt > blockString.txt
rm temp.txt

cygstart blockString.txt

# HISTORY:
# 05/04/2016 12:37:50 PM -RAH Created after seeing these interesting characters in an .nfo; coincidentally, just such blocky "noise" suited for what I had wanted at that moment to make!
# 10/04/good buddy/2016 12:15 PM on lunch at work -RAH updated to find the path of this dir, store it in THIS_SCRIPTS_PATH, and invoke it locally to actually make use of blockstring.txt

