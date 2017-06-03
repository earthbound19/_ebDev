# USAGE
# Invoke this script with one parameter, being the file format in the current dir. to operate on, e.g.:
# ./thisScript.sh png

# Template graphicsmagick command, re: http://www.imagemagick.org/Usage/compare/
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
	echo copying $element to shrunken __vapTe8pw8uWT6PPT4fcYURKQcXgaDZYfEY__$element to make image comparison much faster . . .
	gm convert $element -scale 10 __vapTe8pw8uWT6PPT4fcYURKQcXgaDZYfEY__$element
done < allIMGs.txt

# Prepend everything in allIMGs.txt with that wonky string file name identifier before running comparison via;
sed -i 's/^\(.*\)/__vapTe8pw8uWT6PPT4fcYURKQcXgaDZYfEY__\1/g' allIMGs.txt

mapfile -t allIMGs < allIMGs.txt
# TO DO: how to get things into an array on systems without mapfile--because methinks that's needed here with a nested loop where a read loop might be ridiculous? Can I just install mapfile on necessary platforms?

i_count=0
j_count=0
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
		# ODD ERRORS arise from mixed line-ending types, where gm returns windows-style, and printf commands produce unix-style. Solution: write to separate column files, convert all gm-created files to unix via dos2unix, then paste them into one file.
		echo "$metricPrint" >> hFeJPeBYE6w3ur_col1.txt
		printf "|$i|$j\n" >> hFeJPeBYE6w3ur_col2.txt
	done
done

# Combine ~col1 and ~col2 files into one file (pasting as columns), after getting the line endings in col1 to match col2 :
dos2unix hFeJPeBYE6w3ur_col1.txt
paste -d '' hFeJPeBYE6w3ur_col1.txt hFeJPeBYE6w3ur_col2.txt > tmp_WzzNtNBw2jYD9A.txt
# Remove temp file name gobbeldy-gook padding:
sed -i 's/__vapTe8pw8uWT6PPT4fcYURKQcXgaDZYfEY__//g' tmp_WzzNtNBw2jYD9A.txt
# Filter out information cruft; NOTE that if the first column isn't preceded by | then the later sort command won't work as intended:
sed -i 's/.*Total: \([0-9]\{1,11\}\.[0-9]\{1,11\}\).*|\([^|]*\).*|\([^|]*\).*/\1|\2|\3/g' tmp_WzzNtNBw2jYD9A.txt
# Sort results by reverse rank of keys by priority of columns 2, 1, 3; which is an attempt at most similar pairs adjacent (usually) :
sort -n -b -t\| -k3R -k1r tmp_WzzNtNBw2jYD9A.txt > tmp_fx49V6cdmuFp.txt
sed -i 's/[^|]*|\(.*\)/\1/g' tmp_fx49V6cdmuFp.txt
tr '\n' '|' < tmp_fx49V6cdmuFp.txt > tmp_yyYM7wvUZdc3Qg.txt

# Delete all but first occurance of a word e.g. 'pattern' from a line; the way it works is: change the first 1 (in the following command) to a 2 to remove everything but the 2nd occurances of 'pattern', or 4 to remove everything but the 4th occurance of the pattern, or 1 to remove all but the first etc., re; https://unix.stackexchange.com/a/18324/110338 :
	# e.g.
	# sed -e 's/pattern/_&/1' -e 's/\([^_]\)pattern//g' -e 's/_\(pattern\)/\1/' tstpattern.txt
	# ALSO NOTE that the & is a reference to the matched pattern, meaning the matched pattern will be substituted for & in the output.
# Scan through all image file names (which appear in our most previous temp file), repeating this step (the step being: delete all but the first occurance of the file name) for each file name. We will be left with one instance of each file name, in an order which (hopefully) has as many most similar image files near each other in the sequence:
	# NOTE that we are only using allIMGs.txt for this loop as a count of how many times to perform this operation.

count=0
while read x
do
	count=$(($count + 1))
	# find first occurance of a file name and store it in a variable. Note that the command combines two stream editor (sed) operations one after the other. Note also that the -e switch enables this operation after another operation:
	FFN=`sed -e "s/\([^|]*\)/ \1 /$count" -e 's/[^ ]* \([^ ]*\).*/\1/g' tmp_yyYM7wvUZdc3Qg.txt`
			# echo found file name $FFN for count $count
	# remove all but the first occurance of found file name:
	sed -i -e "s/$FFN/_&/1" -e "s/\([^_]\)$FFN//g" -e "s/_\($FFN\)/\1/" tmp_yyYM7wvUZdc3Qg.txt
done < allIMGs.txt

# replace | with newlines to produce final frame list for e.g. ffmpeg to use:
tr '|' '\n' < tmp_yyYM7wvUZdc3Qg.txt > IMGlistByMostSimilar.txt

rm allIMGs.txt hFeJPeBYE6w3ur_col1.txt hFeJPeBYE6w3ur_col2.txt tmp_yyYM7wvUZdc3Qg.txt tmp_fx49V6cdmuFp.txt tmp_WzzNtNBw2jYD9A.txt __vapTe8pw8uWT6PPT4fcYURKQcXgaDZYfEY__*