# DESCRIPTION
# Renders a sequence of image crossfades from a list (e.g. by next most similar image), by calling `ffmpegCrossfadeIMGsToVideo.sh` repeatedly.

# DEPENDENCIES
# - a 'Nixy environment, sed, paste, tail, Perl, and the tools needed by `ffmpegCrossfadeIMGsToVideo.sh`.
# - a list of images (possibly sorted by next most similar), named `IMGlistByMostSimilar.txt`, as prepared by `imgsGetSimilar.sh` and/or `re_sort_imgsMostSimilar.sh`.

# USAGE
# Ensure you have DEPENDENCIES (see) in place. Then run with these parameters:
# - $1 Duration of crossfade, in decimal seconds, e.g. 2.5. If omitted, the script this calls uses a default.
# - $2 Duration of still image pad between crossfades, in decimal seconds, e.g. 1.1. If omitted, the script this calls uses a default.
# For example, to create an animation with crossfades of 2.5 seconds and still images of 1.1 seconds, run:
#    ffmpegCrossfadeIMGsToVideoFromFileList.sh 2.5 1.1

# RECIPE
# For a recipe that uses this script, see `next_most_similar_image_crossfade_anim.sh`.


# CODE
# TO DO
# - Parameterize source image extension.
# - Interrupted run handling / resume? What to do with fadeSRCvideosList.txt in that case?
# - Figure out why its not allowing less than one second of padding; I thought it did before?
if [ "$1" ]; then crossFadeDuration=$1; else printf "\nNo parameter \$1 (crossfade duration) passed to script. Exit"; exit 1; fi
if [ "$2" ]; then padding=$2; else printf "\nNo parameter \$2 (padding time of still image between crossfades) passed to script. Exit."; exit 2; fi

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
# add the missing first line back to listA:
firstLineOfList=$(head -n 1 $tmpSrcFile)
sed -i "1s/^/$firstLineOfList\n/" listA.txt		# Re a genius breath: https://superuser.com/a/246841/130772
# -- then work up those to versions of the list to a pair list; e.x. command to join list A C E with list B D E as pairs separated by a bar | :
paste -d '|' listA.txt listB.txt > filePairsFromOddNumberedLines.txt
# NOW WE HAVE (in filePairsFromOddNumberedLines.txt) a list of pairs for crossfades, starting from odd-numbered lines of $tmpSrcFile.
# DO ALL OF THAT AGAIN, but building a list starting from even-numbered lines, by stripping the first line off the list before we do the process again (we can reuse tmp_Ud5EMH7y7fKDn7.txt) :
sed -n 'n;p;' tmp_Ud5EMH7y7fKDn7.txt > listB.txt
tail -n +2 tmp_Ud5EMH7y7fKDn7.txt > tmp_CdJeVagRZ8n8MS.txt
sed -n 'n;p;' tmp_CdJeVagRZ8n8MS.txt > listA.txt
firstLineOfList=$(head -n 1 tmp_Ud5EMH7y7fKDn7.txt)
sed -i "1s/^/$firstLineOfList\n/" listA.txt
paste -d '|' listA.txt listB.txt > filePairsFromEvenNumberedLines.txt
# NOW WE HAVE (in filePairsFromEvenNumberedLines.txt) a list of pairs for crossfades, starting from odd-numbered lines of $tmpSrcFile.
# interleave the filePairsFromOdd~ and ~Even~ via this paste magic, re https://stackoverflow.com/a/4011824/1397555 :
paste -d '\n' filePairsFromOddNumberedLines.txt filePairsFromEvenNumberedLines.txt > allCrossfadePairs.txt
# strip any excess empty lines out of that:
sed -i '/^$/d' allCrossfadePairs.txt
# wipe all trailing newlines from result, re https://stackoverflow.com/a/1654042/1397555 :
Perl -pi -e 'chomp if eof' allCrossfadePairs.txt
# The last line of that is always one file (the last file in the list), which is convenient for dovetailing back to the first file (so that the whole animation loops); let's do that by appending the first listed file from $tmpSrcFile to the end of that line (which the previous Perl command prepared for) :
firstFileName=$(head -n 1 $tmpSrcFile)
printf "$firstFileName" >> allCrossfadePairs.txt
# temp file cleanup:
rm tmp_cMQ3nW6QVY5hFn.txt tmp_TAQZSDa6cn4EXn.txt tmp_Ud5EMH7y7fKDn7.txt listA.txt listB.txt filePairsFromOddNumberedLines.txt tmp_CdJeVagRZ8n8MS.txt filePairsFromEvenNumberedLines.txt

# TO DO: bug fix: the following works inconsistently--it doesn't always create all anims. If I echo the ffmpegCrossfadeIMGsToVideo.sh commands to a script file and call the script, it works. I suspect fould play with newlines. Maybe on Windows I must use  | tr -d '\15\32'  -- and maybe that breaks it on Unix / Mac? :
printf "" > fadeSRCvideosList.txt
# array will be used to move video files after a loop uses them:
fileList=$()
# parse pairs out of that resulting list and pass them to ffmpegCrossfadeIMGsToVideo.sh:
OIFS="$IFS"
IFS=
while read -r element || [ -n "$element" ]
do
# TO DO? : build arrays here and then iterate through the arrays (instead of this awful following KLUDGE)?
	imgOne=$(echo $element | sed 's/\(.*\)|.*/\1/g' | tr -d '\15\32')
			# echo imgOne is\: $imgOne
	imgTwo=$(echo $element | sed 's/.*|\(.*\)/\1/g' | tr -d '\15\32')
			# echo imgTwo is\: $imgTwo
	source ffmpegCrossfadeIMGsToVideo.sh $imgOne $imgTwo $crossFadeDuration $padding
	printf "file '$targetRenderFile'\n" >> fadeSRCvideosList.txt
	fileList+=($targetRenderFile)
done < allCrossfadePairs.txt
IFS="$OIFS"
# Sort crossfade source videos (generated by ffmpegCrossfadeIMGsToVideo.sh) into their own folder. NOTE that this relies on the file fadeSRCvideosList.txt created by ffmpegCrossfadeIMGsToVideo.sh.
# If it doesn't already exist, create directory to sort input static image (looped) video files:

if [ ! -d fadeSRCvideos ]; then mkdir fadeSRCvideos; fi
# Copy files into that folder whether they exist there already or not:
for fileName in ${fileList[@]}
do
	mv -f $fileName ./fadeSRCvideos/
done
mv -f fadeSRCvideosList.txt ./fadeSRCvideos/

echo DONE. Static image \(looped\) video files \(sources for crossfades\) have been moved into the ./fadeSRCvideos subdirectory, with a list of them in ./fadeSRCvideos/fadeSRCvideosList.txt.