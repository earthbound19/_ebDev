# DESCRIPTION
# Produces list of images in the current directory arranged by next most similar. Compares all images in a directory. For the first image, it lists which image is most similar to it, then does the same for the second, then third image, and on until the end of the image list. The result is a list of images where every image is adjacent to the two images which are most similar to it. See NOTES for potential uses. It may end up that sort order is not strict; there may be some some randomization in sorting so that most nearly-identical images are not always clumped together with least similar images toward the head or tail of the list. I have not re-examined this since coding it and did not document that.

# DEPENDENCIES
# `printAllIMGfileNames.sh`, GraphicsMagick, image files in a directory to work on, and bash / GNU utilities

# USAGE
# Run with these parameters:
# - $1 OPTIONAL. File format (e.g. 'png') to run comparisons for. To compare ALL files in current directory, omit this parameter. It will throw errors for any files which are not valid images.
# For example, to compare all png format images in the current directory, run:
#    imgsGetSimilar.sh png
# To compare all (supported) image formats in the current directory, run:
#    imgsGetSimilar.sh
# NOTES
# - The comparison algorithm never compares the same image pair more than once.
# - See re_sort_imgsMostSimilar.sh to sort the result other ways.
# - See the echo statement at the end of the script for notes on scripts that can do things with the result lists.
# - Some potential uses: use file list with ffmpeg to create an animation jumping from one image to the next most similar, through the list. Render abstract art collections in animation by sort of most similar groups, quasi-un-randomize randomly color-filled (or palette random filled) renders from e.g. colored svg images. Jumble up movie frames from a film scene excerpt in a perhaps wrong but similar frame order, etc.


# CODE
# TO DO:
# - Allow continuation of interrupted runs (do not erase temp files; rather append to them)? This means not resizing for comparision any pre-existing files of the pattern __superShrunkRc6d__*, not wiping comparision result temp files, picking up where comparisons left off, and . . . ? Unless until that is done, exit on detect of info target file:
if [ -f IMGlistByMostSimilar.txt ]; then echo "NOTE: information target file IMGlistByMostSimilar.txt already exists. To recreate it, rename or delete it and run this script again. Exit."; exit 1; fi

allIMGs=()
if [ ! "$1" ]
then
	allIMGs=( $(printAllIMGfileNames.sh) )
else
	allIMGs=( $(find . -maxdepth 1 -type f -iname "*.$1" -printf '%f\n') )
fi

# OPTIONAL wipe of all leftover files from previous run; comment out the next line if you don't want or need that:
rm -rf __superShrunkRc6d__*

# calculate number of comparisons to be done as reference for feedback print; re https://www.calculator.net/permutation-and-combination-calculator.html?cnv=8&crv=2&x=55&y=16
# yes, this is crazy. Do it with inline Python code calls to the Python interpreter;
# see if Python is installed and gives errorlevel 0 for version check:
python --version &>/dev/null
if [ $? == 0 ]
then
	allIMGsArrLen=${#allIMGs[@]}
	combinationsCalcNumerator=$(
	echo $allIMGsArrLen | python -c 'import sys; import math; print(math.factorial(int(sys.stdin.readline())));'
	)
	combinationsCalcDenominator_calcOne=$(($allIMGsArrLen - 2))
	combinationsCalcDenominator_calcTwo=$(
	echo $combinationsCalcDenominator_calcOne | python -c 'import sys; import math; print(math.factorial(int(sys.stdin.readline())));'
	)
	# using Python here also because ridiculous integer digit counts broke bash math :)
	combinationsCalcDenominator=$(python -c "val = 2 * $combinationsCalcDenominator_calcTwo; print(val)")
	numComparisonsToDo=$(python -c "val = $combinationsCalcNumerator / $combinationsCalcDenominator; print(int(val))")
else
	numComparisonsToDo="(UNKNOWN -- you may wish to install Python and be sure it is in your PATH)"
fi

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
		# gm convert $element -scale 11 __superShrunkRc6d__$element
		gm convert $element -scale 48 __superShrunkRc6d__$element
	fi
done
printf "" > compare__superShrunkRc6d__col1.txt
printf "" > compare__superShrunkRc6d__col2.txt

# List all possible pairs of file type $1, order is not important, repetition is not allowed (math algorithm $1 pick 2).
i_count=0
j_count=0
for i in ${allIMGs[@]}
do
	i_count=$(( i_count + 1 ))
	# Remove element i from a copy of the array so that we only iterate through the remaining in the array which have not already been compared; re http://Unix.stackexchange.com/a/68323 :
	allIMGs_innerLoop=("${allIMGs[@]:$i_count}")
	for j in ${allIMGs_innerLoop[@]}
	do
		j_count=$(( j_count + 1 ))
		echo "~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~"
		echo "MAKING COMPARISON $j_count of $numComparisonsToDo . . ."
# Template GraphicsMagick compare command, re: http://www.ImageMagick.org/Usage/compare/
# compare -metric MAE img_11.png img_3.png null: 2>&1
				comp1="__superShrunkRc6d__""$i"
				comp2="__superShrunkRc6d__""$j"
		echo "comparing images: $i | $j . . . VIA COMMAND on proxy files for: gm compare -metric MAE $i $j null: 2>&1 | grep 'Total'"
		metricPrint=`gm compare -metric MAE $comp1 $comp2 null: 2>&1 | grep 'Total'`
		# ODD ERRORS arise from mixed line-ending types, where gm returns windows-style, and printf commands produce Unix-style. Solution: write to separate column files, later (after these nested loop blocks) convert all gm-created files to Unix via dos2unix, then paste them into one file.
		echo "$metricPrint" >> compare__superShrunkRc6d__col1.txt
		printf "|$i|$j\n" >> compare__superShrunkRc6d__col2.txt
	done
done

# Re prevous comment in nested loop blocks:
dos2unix compare__superShrunkRc6d__col1.txt
paste -d '' compare__superShrunkRc6d__col1.txt compare__superShrunkRc6d__col2.txt > comparisons__superShrunkRc6d__cols.txt
# Filter out information cruft; NOTE that if the first column isn't preceded by | then the later sort command won't work as intended:
sed -i 's/.*Total: \([0-9]\{1,11\}\.[0-9]\{1,11\}\).*|\([^|]*\).*|\([^|]*\).*/\1|\2|\3/g' comparisons__superShrunkRc6d__cols.txt

# UNCOMMENT ONLY ONE of the below sort lines; the columns are comparasion float (lower is closer image is least different), file name pair A, file name pair B:
# DEFAULT: sort by first column, lowest value first:
sort -n -b -t\| -k1						comparisons__superShrunkRc6d__cols.txt > tmp_fx49V6cdmuFp.txt
# Sort by third column reversed, then first column:
# sort -n -b -t\| -k3r -k1				comparisons__superShrunkRc6d__cols.txt > tmp_fx49V6cdmuFp.txt
# etc:
# sort -n -b -t\| -k2r -k1r -k3			comparisons__superShrunkRc6d__cols.txt > tmp_fx49V6cdmuFp.txt
# sort -n -b -t\| -k1r -k2				comparisons__superShrunkRc6d__cols.txt > tmp_fx49V6cdmuFp.txt
# sort -n -b -t\| -k3r -k1				comparisons__superShrunkRc6d__cols.txt > tmp_fx49V6cdmuFp.txt

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
	# Delete all but first occurance of a word e.g. 'pattern' from a line; the way it works is: change the first 1 (in the following command) to a 2 to remove everything but the 2nd occurances of 'pattern', or 4 to remove everything but the 4th occurance of the pattern, or 1 to remove all but the first etc., the next example code line re; https://Unix.stackexchange.com/a/18324/110338 :
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

# Rename comparison results list that has numeric image similarity rankings, and keep it around (don't delete it), so we can make further use of it via other scripts:
mv comparisons__superShrunkRc6d__cols.txt imageDifferenceRankings.txt
# Delete the other temp files:
rm *__superShrunkRc6d__* tmp_fx49V6cdmuFp.txt

echo ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-
echo "FINIS! Results are in IMGlistByMostSimilar.txt and imageDifferenceRankings.txt. The former is a list sorted by approximately nearest most similar image. The latter is a list of all image comparison values. NOTE: A value approaching (or actually at!) zero (0) in the list means the compared images are near identical or are identical. A value approaching 1 (or at 1!) means they are nearly totally different (or actually opposite!) Scripts which may process these result lists: mkNumberedCopiesFromFileList.sh, ffmpegCrossfadeIMGsToVideoFromFileList.sh, ffmpegAnimFromFileList.sh, and maybe others."