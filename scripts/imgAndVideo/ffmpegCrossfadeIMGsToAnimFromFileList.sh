# DESCRIPTION
# Render a sequence of image crossfades from a list (e.g. by next most similar image), using ffmpegCrossfadeIMGsToAnim.sh repeatedly.

# USAGE
# See "DEPENDENCIES" first. Then run:
# ./thisScript.sh

# DEPENDENCIES
# Before running this script, several other scripts must first be run against a series of images. Examine the comments of each script to learn how they work. They are:
# imgsGetSimilar.sh png
# mkNumberedCopiesFromFileList.sh
# then cd into the resultant numberedCopies folder, and run this script.
# Then run e.g.
# concatVidFiles.sh avi

# TO DO
# - Document what the heck this is and how the heck to use it; e.g. detail how two passes are needed, which will result in a series of output videos that can be concatenated into a longer anim by another script. NOTE that documentation must change when I code the following:
# - Parameterize source image extension.
# - Parameterize crossfade duration.
# - Parameterize padding duration.

# crossFadeDuration=1.68
crossFadeDuration=2.4
# crossFadeDuration=4.36
# crossFadeDuration=5.8
# crossFadeDuration=7.2
padding=0.31
# padding=2.04

echo ~~~~
echo Creating image crossfade pairs list . . .
# strip 'file ' string out of IMGlistByMostSimilar.txt, and copy the result into a temp file we'll work from:
sed 's/file \(.*\)/\1/g' IMGlistByMostSimilar.txt > tmp_cMQ3nW6QVY5hFn.txt
# strip all single-quote marks out of that:
tr -d "'" < tmp_cMQ3nW6QVY5hFn.txt > tmp_TAQZSDa6cn4EXn.txt
tmpSrcFile=tmp_TAQZSDa6cn4EXn.txt

# split every even-numbered line of text into listB; re http://www.theunixschool.com/2012/12/how-to-print-every-nth-line-in-file-in.html :
sed -n 'n;p;' $tmpSrcFile > listB.txt
# remove the first line;
tail -n +2 $tmpSrcFile > tmp_Ud5EMH7y7fKDn7.txt
# split every odd-numbered line into listA:
sed -n 'n;p;' tmp_Ud5EMH7y7fKDn7.txt > listA.txt
# rm tmp_Ud5EMH7y7fKDn7.txt
# add the missing first line back to listA:
firstLineOfList=`head -n 1 $tmpSrcFile`
sed -i "1s/^/$firstLineOfList\n/" listA.txt		# Re a genius breath: https://superuser.com/a/246841/130772
# -- then work up those to versions of the list to a pair list; e.x. command to join list A C E with list B D E as pairs separated by a bar | :
paste -d '|' listA.txt listB.txt > filePairsFromOddNumberedLines.txt
# NOW WE HAVE (in filePairsFromOddNumberedLines.txt) a list of pairs for crossfades, starting from odd-numbered lines of $tmpSrcFile.
# DO ALL OF THAT AGAIN, but building a list starting from even-numbered lines, by stripping the first line off the list before we do the process again (we can reuse tmp_Ud5EMH7y7fKDn7.txt) :
sed -n 'n;p;' tmp_Ud5EMH7y7fKDn7.txt > listB.txt
tail -n +2 tmp_Ud5EMH7y7fKDn7.txt > tmp_CdJeVagRZ8n8MS.txt
sed -n 'n;p;' tmp_CdJeVagRZ8n8MS.txt > listA.txt
firstLineOfList=`head -n 1 tmp_Ud5EMH7y7fKDn7.txt`
sed -i "1s/^/$firstLineOfList\n/" listA.txt
paste -d '|' listA.txt listB.txt > filePairsFromEvenNumberedLines.txt
# NOW WE HAVE (in filePairsFromEvenNumberedLines.txt) a list of pairs for crossfades, starting from odd-numbered lines of $tmpSrcFile.
# interleave the filePairsFromOdd~ and ~Even~ via this paste magic, re https://stackoverflow.com/a/4011824/1397555 :
paste -d '\n' filePairsFromOddNumberedLines.txt filePairsFromEvenNumberedLines.txt > allCrossfadePairs.txt
# strip excess empty lines out of that:
sed -i '/^$/d' allCrossfadePairs.txt
# wipe all trailing newlines from result, re https://stackoverflow.com/a/1654042/1397555 :
perl -pi -e 'chomp if eof' allCrossfadePairs.txt
# The last line of that is always one file (the last file in the list), which is convenient for dovetailing back to the first file (so that the whole animation loops); let's do that by appending the first listed file from $tmpSrcFile to the end of that line (which the previous perl command prepared for) :
firstFileName=`head -n 1 $tmpSrcFile`
printf "$firstFileName" >> allCrossfadePairs.txt
# temp file cleanup:
rm tmp_cMQ3nW6QVY5hFn.txt tmp_TAQZSDa6cn4EXn.txt tmp_Ud5EMH7y7fKDn7.txt listA.txt listB.txt filePairsFromOddNumberedLines.txt tmp_CdJeVagRZ8n8MS.txt filePairsFromEvenNumberedLines.txt

echo ~~~~
echo Repeatedly invoking ffmpegCrossfadeIMGsToAnim.sh with parameters from image crossfade pairs list . . .
# parse pairs out of that resulting list and pass them to ffmpegCrossfadeIMGsToAnim:
while read element
do
	imgOne=`echo $element | sed 's/\(.*\)|.*/\1/g'`
			# echo imgOne is\: $imgOne
	imgTwo=`echo $element | sed 's/.*|\(.*\)/\1/g'`
			# echo imgTwo is\: $imgTwo
	echo command is\:
	echo ffmpegCrossfadeIMGsToAnim.sh $imgOne $imgTwo $crossFadeDuration $padding
	ffmpegCrossfadeIMGsToAnim.sh $imgOne $imgTwo $crossFadeDuration
done < allCrossfadePairs.txt