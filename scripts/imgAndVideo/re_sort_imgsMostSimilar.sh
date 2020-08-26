# DESCRIPTION
# Re-sorts result list from imgsGetSimilar.sh according to whatever criteria you alter on the sort code line in this script (if the original results weren't to your liking).

# USAGE
# Examine the sort commands near the start of this script, uncomment the one you want, comment out the others, and run this script:
#    re_sort_imgsMostSimilar.sh


# CODE
# Sort results by erm eh what rank of keys by priority of certain columns in an attempt at something; various options follow; comment out those you don't use:
# sort -n -b -t\| -k2r -k1r -k3 comparisons__superShrunkRc6d__cols_unsorted.txt > tmp_fx49V6cdmuFp.txt
# sort -n -b -t\| -k1r -k2 comparisons__superShrunkRc6d__cols_unsorted.txt > tmp_fx49V6cdmuFp.txt
sort -n -b -t\| -k3r -k1 comparisons__superShrunkRc6d__cols.txt > tmp_fx49V6cdmuFp.txt

# Strip the numeric column so we can work up a file list of said ordering for animation:
sed -i 's/[^|]*|\(.*\)/\1/g' tmp_fx49V6cdmuFp.txt
# Strip all newlines so that the following sed operation that removes all but the 1st appearance of a match will work over every appearance of a match in the entire file (since they are all on one line, where otherwise the replace would only work on every individual line where the match is found):
tr '\n' '|' < tmp_fx49V6cdmuFp.txt > comparisons__superShrunkRc6d__cols_sorted.txt

echo -------------------
count=0
while read x
do
	echo replacing all but first appearance of file name $x in result file . . .
	# Delete all but first occurance of a word e.g. 'pattern' from a line; the way it works is: change the first 1 (in the following command) to a 2 to remove everything but the 2nd occurances of 'pattern', or 4 to remove everything but the 4th occurance of the pattern, or 1 to remove all but the first etc., the next example code line re; https://Unix.stackexchange.com/a/18324/110338 :
	# sed -e 's/pattern/_&/1' -e 's/\([^_]\)pattern//g' -e 's/_\(pattern\)/\1/' tstpattern.txt
	# ALSO NOTE that the & is a reference to the matched pattern, meaning the matched pattern will be substituted for & in the output.
	# sed -e 's/pattern/_&/1' -e 's/\([^_]\)pattern//g' -e 's/_\(pattern\)/\1/' tstpattern.txt
	sed -i -e "s/$x/_&/1" -e "s/\([^_]\)$x//g" -e "s/_\($x\)/\1/" comparisons__superShrunkRc6d__cols_sorted.txt
done < allIMGs.txt

# replace | with newlines to produce final frame list for e.g. ffmpeg to use:
tr '|' '\n' < comparisons__superShrunkRc6d__cols_sorted.txt > IMGlistByMostSimilar.txt
rm comparisons__superShrunkRc6d__cols_sorted.txt
# --or, that's ready after one more tweak for file list format ffmpeg demands:
sed -i "s/^\(.*\)/file '\1'/g" IMGlistByMostSimilar.txt

echo ~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-
echo FINIS\! You may now use the image list file IMGlistByMostSimilar.txt in conjunction with ffmpegAnimFromFileList.sh \(see comments of that script\) to produce an animation of these images arranged by most similar to nearest list neighbor \(roughly\, with some randomization in sorting so that most nearly-identical images are not always clumped together with least similar images toward the head or tail of the list\)\.

rm ./tmp_fx49V6cdmuFp.txt

# option for Cygwin:
cygstart ./IMGlistByMostSimilar.txt