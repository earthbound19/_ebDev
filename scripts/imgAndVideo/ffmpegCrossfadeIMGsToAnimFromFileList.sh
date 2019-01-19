# DESCRIPTION
# Render a sequence of image crossfades from a list (e.g. by next most similar image), using ffmpegCrossfadeIMGsToAnim.sh repeatedly.

# USAGE
# See "DEPENDENCIES" first. Then run:
# ./thisScript.sh

# DEPENDENCIES
# a 'nixy environment, gsed, paste, tail, perl, and the tools needed by ffmpegCrossfadeIMGsToAnim.sh

# RECIPE
# For a recipe that uses this script, see ffmpegCrossfadeIMGsToAnimFromFileList.sh in my _ebArt repository (in /recipes):


# TO DO
# - Interrupted run handling / resume? What to do with fadeSRCvideosList.txt in that case?
# - Fill out dependencis documentation.
# - Let this script take parameters.
# - Move and expand the above recipe/comments into a script in the _ebArt repo.
# - Figure out why its not allowing less than one second of padding; I thought it did before?
# - Parameterize source image extension. (?)


# CODE

# ====
# START GLOBALS

# UNCOMMENT THE VALUE ASSIGNMENTS you'd like to try:
# crossFadeDuration=0.23
crossFadeDuration=0.62
# crossFadeDuration=1.68
# crossFadeDuration=1.28
# crossFadeDuration=2.4
# crossFadeDuration=3.28
# crossFadeDuration=3.92
# crossFadeDuration=4.36
# crossFadeDuration=5.1
# crossFadeDuration=5.8
# crossFadeDuration=6.35
# crossFadeDuration=7.2
# crossFadeDuration=8
# crossFadeDuration=11.7
# NOTE: padding less than 1 (e.g. 0.17) will throw an error, apparently.
padding=1.1
# padding=1.25
# padding=1.54
# padding=1.65
# padding=1.78
# padding=1.91
# padding=2.24
# padding=2.81
# padding=3.2
# padding=4.7

# END GLOBALS
# ====

echo ~~~~
echo Creating image crossfade pairs list . . .
# strip 'file ' string out of IMGlistByMostSimilar.txt, and copy the result into a temp file we'll work from:
gsed 's/file \(.*\)/\1/g' IMGlistByMostSimilar.txt > tmp_cMQ3nW6QVY5hFn.txt
# strip all single-quote marks out of that:
tr -d "'" < tmp_cMQ3nW6QVY5hFn.txt > tmp_TAQZSDa6cn4EXn.txt
tmpSrcFile=tmp_TAQZSDa6cn4EXn.txt

# split every even-numbered line of text into listB; re http://www.theunixschool.com/2012/12/how-to-print-every-nth-line-in-file-in.html :
gsed -n 'n;p;' $tmpSrcFile > listB.txt
# remove the first line;
tail -n +2 $tmpSrcFile > tmp_Ud5EMH7y7fKDn7.txt
# split every odd-numbered line into listA:
gsed -n 'n;p;' tmp_Ud5EMH7y7fKDn7.txt > listA.txt
# add the missing first line back to listA:
firstLineOfList=`head -n 1 $tmpSrcFile`
gsed -i "1s/^/$firstLineOfList\n/" listA.txt		# Re a genius breath: https://superuser.com/a/246841/130772
# -- then work up those to versions of the list to a pair list; e.x. command to join list A C E with list B D E as pairs separated by a bar | :
paste -d '|' listA.txt listB.txt > filePairsFromOddNumberedLines.txt
# NOW WE HAVE (in filePairsFromOddNumberedLines.txt) a list of pairs for crossfades, starting from odd-numbered lines of $tmpSrcFile.
# DO ALL OF THAT AGAIN, but building a list starting from even-numbered lines, by stripping the first line off the list before we do the process again (we can reuse tmp_Ud5EMH7y7fKDn7.txt) :
gsed -n 'n;p;' tmp_Ud5EMH7y7fKDn7.txt > listB.txt
tail -n +2 tmp_Ud5EMH7y7fKDn7.txt > tmp_CdJeVagRZ8n8MS.txt
gsed -n 'n;p;' tmp_CdJeVagRZ8n8MS.txt > listA.txt
firstLineOfList=`head -n 1 tmp_Ud5EMH7y7fKDn7.txt`
gsed -i "1s/^/$firstLineOfList\n/" listA.txt
paste -d '|' listA.txt listB.txt > filePairsFromEvenNumberedLines.txt
# NOW WE HAVE (in filePairsFromEvenNumberedLines.txt) a list of pairs for crossfades, starting from odd-numbered lines of $tmpSrcFile.
# interleave the filePairsFromOdd~ and ~Even~ via this paste magic, re https://stackoverflow.com/a/4011824/1397555 :
paste -d '\n' filePairsFromOddNumberedLines.txt filePairsFromEvenNumberedLines.txt > allCrossfadePairs.txt
# strip any excess empty lines out of that:
gsed -i '/^$/d' allCrossfadePairs.txt
# wipe all trailing newlines from result, re https://stackoverflow.com/a/1654042/1397555 :
perl -pi -e 'chomp if eof' allCrossfadePairs.txt
# The last line of that is always one file (the last file in the list), which is convenient for dovetailing back to the first file (so that the whole animation loops); let's do that by appending the first listed file from $tmpSrcFile to the end of that line (which the previous perl command prepared for) :
firstFileName=`head -n 1 $tmpSrcFile`
printf "$firstFileName" >> allCrossfadePairs.txt
# temp file cleanup:
rm tmp_cMQ3nW6QVY5hFn.txt tmp_TAQZSDa6cn4EXn.txt tmp_Ud5EMH7y7fKDn7.txt listA.txt listB.txt filePairsFromOddNumberedLines.txt tmp_CdJeVagRZ8n8MS.txt filePairsFromEvenNumberedLines.txt

# TO DO: bug fix: the following works inconsistently--it doesn't always create all anims. If I echo the ffmpegCrossfadeIMGsToAnim.sh commands to a script file and call the script, it works. I suspect fould play with newlines. Maybe on Windows I must use  | tr -d '\15\32'  -- and maybe that breaks it on unix / Mac? :
printf "" > fadeSRCvideosList.txt
printf "" > srsly.sh
# parse pairs out of that resulting list and pass them to ffmpegCrossfadeIMGsToAnim.sh:
while IFS= read -r element || [ -n "$element" ]
do
# TO DO? : build arrays here and then iterate through the arrays (instead of this awful following KLUDGE)?
	imgOne=`echo $element | gsed 's/\(.*\)|.*/\1/g' | tr -d '\15\32'`
			# echo imgOne is\: $imgOne
	imgTwo=`echo $element | gsed 's/.*|\(.*\)/\1/g' | tr -d '\15\32'`
			# echo imgTwo is\: $imgTwo
# KLUDGE:
# I DON'T KNOW why bash on Mac won't run every loop of the following commands from this loop, but it won't--it never completes all of them (it completes a random assortment of them--usually only the first). But with the following ugly kludge of writing all the commands to a script, then running the script, it works:
	# The following script is invoked with `source` so that we make use of a variable named $targetRenderFile which that script sets, which persists in the shell after return:
	echo "source ffmpegCrossfadeIMGsToAnim.sh $imgOne $imgTwo $crossFadeDuration $padding" >> srsly.sh
	# Add the filename stored in the $targetRenderFile variable to a list of all rendered crossfade videos:
	echo "echo \$targetRenderFile >> fadeSRCvideosList.txt" >> srsly.sh
done < allCrossfadePairs.txt
chmod +x ./srsly.sh
source ./srsly.sh
rm ./srsly.sh

# Sort crossfade source videos (generated by ffmpegCrossfadeIMGsToAnim.sh) into their own folder. NOTE that this relies on the file fadeSRCvideosList.txt created by ffmpegCrossfadeIMGsToAnim.sh.
# If it doesn't already exist, create directory to sort input static image (looped) video files:
if [ ! -d fadeSRCvideos ]; then mkdir fadeSRCvideos; fi
# Copy files into that folder whether they exist there already or not:
while IFS= read -r element || [ -n "$element" ]
do
	mv -f $element ./fadeSRCvideos/
done < fadeSRCvideosList.txt
mv -f fadeSRCvideosList.txt ./fadeSRCvideos/
	echo DONE. Static image \(looped\) video files \(sources for crossfades\) have been moved into the ./fadeSRCvideos subdirectory, with a list of them in ./fadeSRCvideos/fadeSRCvideosList.txt.