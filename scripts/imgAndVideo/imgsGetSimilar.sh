# DESCRIPTION
# Produces list of images arranged by most similar to nearest neighbor in list (roughly, with some randomization in sorting so that most nearly-identical images are not always clumped together with least similar images toward the head or tail of the list). Some potential uses: use file list with ffmpeg to create an animation jumping from one image to the next most similar, through the list. Render abstract art collections in animation by sort of most similar groups, quasi-un-randomize randomly color-filled (or palette random filled) renders from e.g. colored svg images. Jumble up movie frames from a film scene excerpt in a perhaps wrong but similar frame order, etc.

# DEPENDENCIES
# Graphicsmagick, image files in a directory to work on, and bash / GNU utilities

# USAGE
# Invoke this script with one parameter, being the file format in the current dir. to operate on, e.g.:
#  ./imgsGetSimilar.sh png
# OPTIONAL: omit variable 1 to compare ALL files in current dir; will throw errors if some files are not images or valid images.
# NOTES
# - the comparison algorithm never compares the same image pair more than once.
# - see re_sort_imgsMostSimilar.sh to sort the result other ways.


# CODE
# TO DO:
# - refactor to allow continuation of interrupted runs (do not erase temp files; rather append to them.) This means not resizing for comparision any pre-existing files of the pattern __superShrunkRc6d__*, not wiping comparision result temp files, picking up where comparisons left off, and . . . ?

# If no $1 parameter, warn and exit.
if [ -z "$1" ]
then
	echo "No paramter \$1 passed to script; will exit. Re-run script with an image format extension (without any .) as the only parameter to the script; e.g.:"
	echo "	./imgsGetSimilar.sh png"
	exit
else
	searchRegex=$1
fi
# DEPRECATED until it is tested to see whether the presence of text files in list (will result from no $1 passed to script) will mess up process:
	# change search regex depending on presence or absense of parameter $1:
	# if [ -z "$1" ]
	# then
	# 	searchRegex='*'
	# else
	# 	searchRegex="$1"
	# fi


# CODE
# OPTIONAL wipe of all leftover files from previous run; comment out the next line if you don't want or need that:
rm -rf __superShrunkRc6d__*


# Because on stupid platforms find produces windows line-endings, convert them to unix after pipe | :
allIMGs=(`find . -maxdepth 1 -type f -iname \*.$searchRegex -printf '%f\n' | sort`)
# Create heavily shrunken image copies to run comparison on.
echo Generating severely shrunken image copies to run comparisons against . . .
for element in "${allIMGs[@]}"
do
	if [ -f "__superShrunkRc6d__""$element" ]
	then
				echo COMPARISON SOURCE FILE "__superShrunkRc6d__""$element" already exists\; assuming comparisons against it were already run\; skipping comparison.
	else
				echo converting $element to new shrunken image "__superShrunkRc6d__""$element" to make image comparison much faster . . .
		# gm convert $element -scale 7 __superShrunkRc6d__$element
		gm convert $element -scale 11 __superShrunkRc6d__$element
	fi
done
i_count=0
j_count=0
printf "" > compare__superShrunkRc6d__col1.txt
printf "" > compare__superShrunkRc6d__col2.txt
# List all possible pairs of file type $1, order is not important, repetition is not allowed (math algorithm $1 pick 2).
for i in ${allIMGs[@]}
do
	i_count=$(( i_count + 1 ))
	# Remove element i from a copy of the array so that we only iterate through the remaining in the array which have not already been compared; re http://unix.stackexchange.com/a/68323 :
	allIMGs_innerLoop=("${allIMGs[@]:$i_count}")
			# echo size of arr for inner loop is ${#allIMGs_innerLoop[@]}
	for j in ${allIMGs_innerLoop[@]}
	do
# Template graphicsmagick compare command, re: http://www.imagemagick.org/Usage/compare/
# compare -metric MAE img_11.png img_3.png null: 2>&1
				comp1="__superShrunkRc6d__""$i"
				comp2="__superShrunkRc6d__""$j"
		echo "comparing images: $i | $j . . . VIA COMMAND on proxy files for: gm compare -metric MAE $i $j null: 2>&1 | grep 'Total'"
		metricPrint=`gm compare -metric MAE $comp1 $comp2 null: 2>&1 | grep 'Total'`
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
# Back that up to a pre-sort text file in case subsequent sorting turns out not so useful:
cp comparisons__superShrunkRc6d__cols.txt comparisons__superShrunkRc6d__cols_unsorted.txt
# Sort results by reverse rank of keys by priority of certain columns in an attempt at most similar pairs adjacent (usually) ; or . . . some other thingy similar? Uncomment one option and comment out all others:
sort -n -b -t\| -k3r -k1 comparisons__superShrunkRc6d__cols.txt > tmp_fx49V6cdmuFp.txt
	# sort -n -b -t\| -k2r -k1r -k3 comparisons__superShrunkRc6d__cols.txt > tmp_fx49V6cdmuFp.txt
	# sort -n -b -t\| -k1r -k2 comparisons__superShrunkRc6d__cols.txt > tmp_fx49V6cdmuFp.txt
	# sort -n -b -t\| -k3r -k1 comparisons__superShrunkRc6d__cols.txt > tmp_fx49V6cdmuFp.txt
# Strip the numeric column so we can work up a file list of said ordering for animation:
sed -i 's/[^|]*|\(.*\)/\1/g' tmp_fx49V6cdmuFp.txt
# In which my utter frustration at windows newline-related bugs strikes again; re: https://stackoverflow.com/questions/3134791/how-do-i-remove-newlines-from-a-text-file
dos2unix tmp_fx49V6cdmuFp.txt
# Strip all newlines so that the following sed operation that removes all but the 1st appearance of a match will work over every appearance of a match in the entire file (since they are all on one line, where otherwise the replace would only work on every individual line where the match is found):
tr '\n' '|' < tmp_fx49V6cdmuFp.txt > comparisons__superShrunkRc6d__cols_sorted.txt

echo -------------------
count=0
for x in ${allIMGs[@]}
do
	echo replacing all but first appearance of file name $x in result file . . .
	# Delete all but first occurance of a word e.g. 'pattern' from a line; the way it works is: change the first 1 (in the following command) to a 2 to remove everything but the 2nd occurances of 'pattern', or 4 to remove everything but the 4th occurance of the pattern, or 1 to remove all but the first etc., the next example code line re; https://unix.stackexchange.com/a/18324/110338 :
	# sed -e 's/pattern/_&/1' -e 's/\([^_]\)pattern//g' -e 's/_\(pattern\)/\1/' tstpattern.txt
	# ALSO NOTE that the & is a reference to the matched pattern, meaning the matched pattern will be substituted for & in the output.
	# sed -e 's/pattern/_&/1' -e 's/\([^_]\)pattern//g' -e 's/_\(pattern\)/\1/' tstpattern.txt
	sed -i -e "s/$x/_&/1" -e "s/\([^_]\)$x//g" -e "s/_\($x\)/\1/" comparisons__superShrunkRc6d__cols_sorted.txt
done
dos2unix comparisons__superShrunkRc6d__cols_sorted.txt
# replace | with newlines to prep for final frame list for e.g. ffmpeg to use:
tr '|' '\n' < comparisons__superShrunkRc6d__cols_sorted.txt > IMGlistByMostSimilar.txt
rm comparisons__superShrunkRc6d__cols_sorted.txt
# That's ready after this tweak for file list format ffmpeg needs:
sed -i "s/^\(.*\)/file '\1'/g" IMGlistByMostSimilar.txt
dos2unix IMGlistByMostSimilar.txt

rm __superShrunkRc6d__*]
mv comparisons__superShrunkRc6d__cols.txt IMGlistByMostSimilarComparisons.txt
rm compare__superShrunkRc6d__col1.txt compare__superShrunkRc6d__col2.txt  tmp_fx49V6cdmuFp.txt

echo ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-
echo "FINIS! You may now use the image list file IMGlistByMostSimilar.txt in conjunction with e.g. any of these scripts: mkNumberedCopiesFromFileList.sh, ffmpegCrossfadeIMGsToAnimFromFileList.sh, ffmpegAnimFromFileList.sh, and maybe others. Also, the numeric closeness value that imagemagic thinks all two image pairs of all the images have is in IMGlistByMostSimilarComparisons.txt, which may also be useful for scripting."