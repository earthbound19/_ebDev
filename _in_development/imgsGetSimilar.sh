# DESCRIPTION
# Produces list of images arranged by most similar to nearest neighbor in list (roughly, with some randomization in sorting so that most nearly-identical images are not always clumped together with least similar images toward the head or tail of the list). Resultant file list is suitable for use by ffmpeg as a frame list for animation. Some potential uses: render abstract art collections in animation by sort of most similar groups, quasi-un-randomize randomly color-filled (or palette random filled) renders from e.g. colored svg images. Jumble up movie frames from a film scene excerpt in a perhaps wrong but similar frame order. etc.

# USAGE
# Invoke this script with one parameter, being the file format in the current dir. to operate on, e.g.:
# ./thisScript.sh png
# OPTIONAL: omit variable 1 to compare ALL files in current dir; will throw errors if some files are not images or valid images.

# DEPENDENCIES
# Graphicsmagick, image files in a directory to work on, and bash / GNU utilities

# TO DO:
# - fix so that formatting is not like the following:
# file './tile_0115.png
# '
# -- but rather like the following:
# file './tile_0115.png'
# - UM, this is making a monster file list? does it need de-duping? Is this script actually done?

# change search regex depending on presence or absense of parameter $1:
if [ -z ${1+x} ]
then
	searchRegex='.*'
else
	searchRegex=".$1"
fi


# CODE

	# OPTIONAL wipe of all leftover files from previous run; comment out everything in the following block if you don't want that:
	rm __superShrunkRc6d__*
	rm allIMGs.txt compare__superShrunkRc6d__col1.txt compare__superShrunkRc6d__col2.txt tmp_yyYM7wvUZdc3Qg.txt tmp_fx49V6cdmuFp.txt comparisons__superShrunkRc6d__cols.txt __superShrunkRc6d__*

find ./* -type f -iregex ".*\.$1" > allIMGs.txt
# because gfind produces windows line-endings, convert them to unix:
dos2unix allIMGs.txt
sed -i 's/^\(\.\/\)\(.*\)/\2/g' allIMGs.txt

# Create heavily shrunken image copies to run comparison on.
echo Generating severely shrunken image copies to run comparisons against . . .
allIMGs=( $( < allIMGs.txt) )

for element in "${allIMGs[@]}"
do
	if [ -f "__superShrunkRc6d__""$element" ]
	then
		echo COMPARISON SOURCE FILE "__superShrunkRc6d__""$element" already exists\; assuming comparisons against it were already run\; skipping comparison.
	else
		echo copying $element to shrunken "__superShrunkRc6d__""$element" to make image comparison much faster . . .
		gm convert $element -scale 10 __superShrunkRc6d__$element
	fi
done

# Prepend everything in allIMGs.txt with that wonky string file name identifier before running comparison via;
sed -i 's/^\(.*\)/__superShrunkRc6d__\1/g' allIMGs.txt


i_count=0
j_count=0
printf "" > compare__superShrunkRc6d__col1.txt
printf "" > compare__superShrunkRc6d__col2.txt
# List all possible pairs of file type $1, order is not important, repetition is not allowed (math algorithm $1 pick 2).
for i in "${allIMGs[@]}"
do
	i_count=$(( i_count + 1 ))
	# Remove element i from a copy of the array so that we only iterate through the remaining in the array which have not already been compared; re http://unix.stackexchange.com/a/68323 :
	allIMGs_innerLoop=("${allIMGs[@]:$i_count}")
			# echo size of arr for inner loop is ${#allIMGs_innerLoop[@]}
	for j in "${allIMGs_innerLoop[@]}"
	do
# Template graphicsmagick compare command, re: http://www.imagemagick.org/Usage/compare/
# compare -metric MAE img_11.png img_3.png null: 2>&1
		echo "comparing images: $i | $j . . . VIA COMMAND: gm compare -metric MAE $i $j null: 2>&1 | grep 'Total'"
		metricPrint=`gm compare -metric MAE $i $j null: 2>&1 | grep 'Total'`
		# ODD ERRORS arise from mixed line-ending types, where gm returns windows-style, and printf commands produce unix-style. Solution: write to separate column files, later (after these nested loop blocks) convert all gm-created files to unix via dos2unix, then paste them into one file.
		echo "$metricPrint" >> compare__superShrunkRc6d__col1.txt
		printf "|$i|$j\n" >> compare__superShrunkRc6d__col2.txt
	done
done

# Re prevous comment in nested loop blocks:
dos2unix compare__superShrunkRc6d__col1.txt
paste -d '' compare__superShrunkRc6d__col1.txt compare__superShrunkRc6d__col2.txt > comparisons__superShrunkRc6d__cols.txt
# Filter out information cruft; NOTE that if the first column isn't preceded by | then the later sort command won't work as intended:
sed -i 's/.*Total: \([0-9]\{1,11\}\.[0-9]\{1,11\}\).*|\([^|]*\).*|\([^|]*\).*/\1|\2|\3/g' comparisons__superShrunkRc6d__cols.txt
# Sort results by reverse rank of keys by priority of certain columns in an attempt at most similar pairs adjacent (usually) :
sort -n -b -t\| -k2r -k1r -k1 comparisons__superShrunkRc6d__cols.txt > tmp_fx49V6cdmuFp.txt
# Strip the numeric column so we can work up a file list of said ordering for animation:
sed -i 's/[^|]*|\(.*\)/\1/g' tmp_fx49V6cdmuFp.txt
exit
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
# --or, that's ready after one more tweak for file list format ffmpeg demands:
sed -i "s/^\(.*\)/file '\1'/g" IMGlistByMostSimilar.txt


echo ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-
echo FINIS\! You may now use the image list file IMGlistByMostSimilar.txt in conjunction with ffmpegAnimFromFileList.sh \(see comments of that script\) to produce an animation of these images arranged by most similar to nearest neighbor in list \(roughly\, with some randomization in sorting so that most nearly-identical images are not always clumped together with least similar images toward the head or tail of the list\)\.