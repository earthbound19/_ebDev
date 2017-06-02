# USAGE
# invoke this script with one parameter, being the file format in the current dir. to operate on, e.g.:
# ./thisScript.sh png

# template command, re: http://www.imagemagick.org/Usage/compare/
# compare -metric MAE img_11.png img_3.png null: 2>&1

# List all possible pairs of file type $1, order is not important, repetition is not allowed ($1 pick 2).

# Delete any wonky file names from prior or interrupted run:
rm __vapTe8pw8uWT6PPT4fcYURKQcXgaDZYfEY__*
# DEV ONLY:
rm *.txt

find *.$1 > allIMGs.txt

# Create heavily shrunken image copies to run comparison on.
echo Generating severely shrunken image copies to run comparisons with . . .
while read element
do
	echo copying $element to shrunken __vapTe8pw8uWT6PPT4fcYURKQcXgaDZYfEY__$element . . .
	gm convert $element -scale 10 __vapTe8pw8uWT6PPT4fcYURKQcXgaDZYfEY__$element
done < allIMGs.txt

# prepend everything in allIMGs.txt with that wonky string file name identifier before running comparison via;
sed -i 's/^\(.*\)/__vapTe8pw8uWT6PPT4fcYURKQcXgaDZYfEY__\1/g' allIMGs.txt

mapfile -t allIMGs < allIMGs.txt
# TO DO: how to get things into an array on systems without mapfile--because methinks that's needed here with a nested loop where a read loop might be ridiculous? Can I just install mapfile on necessary platforms?

i_count=0
j_count=0
printf "" > ImagePairSimilarityRankings.txt
printf "" > hFeJPeBYE6w3ur_col1.txt
printf "" > hFeJPeBYE6w3ur_col2.txt
for i in "${allIMGs[@]}"
do
	i_count=$(( i_count + 1 ))
	# Remove element i from a copy of the array so that we only iterate through the remaining un-paired element science thing computer sort yeh in inner loop;
	# re: http://unix.stackexchange.com/a/68323
	allIMGs_innerLoop=("${allIMGs[@]:$i_count}")
			# echo size of arr for inner loop is ${#allIMGs_innerLoop[@]}
	for j in "${allIMGs_innerLoop[@]}"
	do
			echo "comparing images: $i | $j . . . VIA COMMAND: gm compare -metric MAE $i $j null: 2>&1 | grep 'Total'"
			metricPrint=`gm compare -metric MAE $i $j null: 2>&1 | grep 'Total'`
			# ODD ERRORS arise from mixed line-ending types, where gm returns windows-style, and printf commands produce unix-style. Solution: write to separate column files, convert all gm-created files to unix via dos2unix, then paste them into one file.printf "$metricPrint" >> ImagePairSimilarityRankings.txt
			echo "$metricPrint" >> hFeJPeBYE6w3ur_col1.txt
			printf " | $i | $j\n" >> hFeJPeBYE6w3ur_col2.txt
	done
done

# Combine ~col1 and ~col2 files into one file (pasting as columns), after getting the line endings in col1 to match col2 :
dos2unix hFeJPeBYE6w3ur_col1.txt
paste -d '' hFeJPeBYE6w3ur_col1.txt hFeJPeBYE6w3ur_col2.txt > ImagePairSimilarityRankings.txt
# Remove temp file name gobbeldy-gook padding:
sed -i 's/__vapTe8pw8uWT6PPT4fcYURKQcXgaDZYfEY__//g' ImagePairSimilarityRankings.txt
# Filter out information cruft; NOTE that if the first column isn't preceded by | then the later sort command won't work as intended:
sed -i 's/.*Total: \([0-9]\{1,11\}\.[0-9]\{1,11\}\) .*| \([^|]*\) .*| \([^|]*\).*/| \1 | \2 | \3/g' ImagePairSimilarityRankings.txt
# Sort results by rank of most similar pairs; an -r flag added after -n will reverse the result sorting:
	# e.g.:
	# sort --field-separator='|' -k 1n,1n -k 3n,3n -k 2n,2n ImagePairSimilarityRankings.txt > wut.txt
sort -n -r --field-separator='|' -k 1n,1n -k 3n,3n ImagePairSimilarityRankings.txt > wut.txt
rm ./ImagePairSimilarityRankings.txt && mv ./wut.txt ./ImagePairSimilarityRankings.txt
# TO DO: make use of allIMGs.txt here for further filtering of that list to eliminate all subsequent duplicate appearances of a file name.
# dev command that will delete all but first occurance of word 'pattern' from a line; re; https://unix.stackexchange.com/a/18324/110338 :
# sed -e 's/pattern/_&/1' -e 's/\([^_]\)pattern//g' -e 's/_\(pattern\)/\1/' tstpattern.txt

rm allIMGs.txt hFeJPeBYE6w3ur_col1.txt hFeJPeBYE6w3ur_col2.txt
rm __vapTe8pw8uWT6PPT4fcYURKQcXgaDZYfEY__*