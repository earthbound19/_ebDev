# DESCRIPTION: Takes an input text paramater and outputs a ~_anagramized.txt text file where every vowel may be scrambled with an adjacent character. The result is readable to (about half of?) humans, but would take extra programming or resources for web keyword scanners (SPIES) to make good of.

# USAGE: run the script with one paramaeter, being the name of a text file in the same directory, to scrable. Results will appear in ~_anagramized.txt.

# cluge to keep punctuation clearer if oddly spaced bcse sed command my not make skip punctuation:
sed 's/\(\.,;:!?\"\)/ \1 /g' $1 > temp1.txt

tr ' ' '\n' < temp1.txt > temp2.txt
mapfile -t words < temp2.txt
rm temp1.txt temp2.txt

printf "" > $1\_anagramized.txt

for element in "${words[@]}"
do
	# adapted from: http://stackoverflow.com/a/26326317
	echo $element | sed 's/[aeiou]/&\n/g' | shuf | tr -d "\n" > temp2.txt
	scrambledWord=$( < temp2.txt )
	echo $scrambledWord >> $1\_anagramized.txt
done

tr '\n' ' ' < $1\_anagramized.txt > temp1.txt
rm $1\_anagramized.txt
mv temp1.txt $1\_anagramized.txt

