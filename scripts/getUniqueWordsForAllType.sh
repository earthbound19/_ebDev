# DESCRIPTION
# Runs getUniqueWords.sh for all files of type $1, OVERWRITING the originals with the found list of unique words (in original order).

# USAGE
# Run with these parameters:
# - $1 file type to run this script against (e.g. txt or hexplt)
# For example:
#    getUniqueWordsForAllType.sh hexplt


# CODE
# DELETE this line and the next if your script doesn't need them; otherwise adapt per your needs:
if [ ! "$1" ]; then printf "\nNo parameter \$1 (file type to run getUniqueWords.sh repeatedly for all files of that type in the current directory) passed to script. Exit."; exit 1; else fileType=$1; fi

echo florf

array=($(find . -maxdepth 1 -type f -iname \*.$fileType -printf '%f\n'))

for element in ${array[@]}
do
	echo working on file $element . . .
	lines=$(cat $element | wc -l)
	echo line count before is $lines . . .
	getUniqueWords.sh $element FLOURBALPER
	lines=$(cat $element | wc -l)
	echo line count after is $lines
	echo ----
done
