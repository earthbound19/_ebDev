# DESCRIPTION
# From a list of image filenames suitable for ffmpeg (which file names must be in the current folder), creates numbered copies of those files in a subdirectory, from which an animation may be made, e.g. via ffmpegAnimFromFileList.sh. SEE ALSO mkNumberedLinksFromFileList.sh if you prefer to make junctions (links) instead of file copies (junctions may be faster to create).

# DEPENDENCIES
# `IMGlistByMostSimilar.txt`, as prepared by `imgsGetSimilar.sh` and/or `re_sort_imgsMostSimilar.sh`.

# WARNINGS
# - This script perhaps dangerously assumes all file names provided in the list have the same extension.
# - It also clobbers any files that already exist when it copies (overwrites without prompt).
# KNOWN ISSUE
# - On copy of the list, it overwrites the last image with the second-to-last.

# USAGE
# FIRST, prepare a list of images, for example named `IMGlistByMostSimilar.txt`, as prepared by `imgsGetSimilar.sh` and/or `re_sort_imgsMostSimilar.sh`. Or manually prepare your own list with any other file name. The list must have the following layout or format:
#    file '263.jpg'
#    file '363.jpg'
#    file '064.jpg'
#    file '145.jpg'
# This format is suitable for ffmpeg.
# Run with one OPTIONAL parameter, which is the file name of any such list you have prepared.
# Example run with a file list parameter:
#    mkNumberedLinksFromFileList.sh customImageListForAnimation.txt
# If such a file name is not provided as the first parameter, a file list must be present in the same directory you run this script from, and the file list must be named `IMGlistByMostSimilar.txt`.
# To run the script without the optional first parameter, you would run:
#    mkNumberedLinksFromFileList.sh
# The script will scan the list and make numbered file copies in a subdirectory named `_temp_numbered`. This is preparation for other scripts which must operate on numbered files.


# CODE
# TO DO
# - Fix listed KNOWN ISSUE.

# IF NO list file provided, assume it is IMGlistByMostSimilar.txt:
if [ -z "$1" ]
then
	fileList=IMGlistByMostSimilar.txt; echo No file list parameter \(\$\1\) passed to script\; setting fileList to default IMGlistByMostSimilar.txt
else
	fileList=$1; echo fileList set to parameter \1\, $1
fi

# If the _temp_numbered directory already exists, TOAST IT without warning, then recreate it; otherwise create it:
if [ -d _temp_numbered ]; then rm -rf _temp_numbered; mkdir _temp_numbered; else mkdir _temp_numbered; fi

tempStr=`head -n 1 $fileList`
# NOTE that this script assumes a closing apostraphe or single quote in the input file! :
# No, the fileExt=${filename##*.} doesn't work here as there's a trailing ' to trim:
fileNameExt=`echo $tempStr | sed "s/.*\.\([^\.]\{1,5\}\)'.*/\1/g"`

# NOTE this script assumes a list formatted for concatenation by ffmpeg, and makes a temp copy of the list removing that syntax:
sed "s/file '\(.*\)'/\1/g" $fileList > tmp_kHDcaVmKUgsZp9cvU2QezUsZ3EYHAWbqkr.txt
dos2unix tmp_kHDcaVmKUgsZp9cvU2QezUsZ3EYHAWbqkr.txt

# Because some platforms pad wc output with spaces:
numElements=`wc -l < tmp_kHDcaVmKUgsZp9cvU2QezUsZ3EYHAWbqkr.txt | tr -d ' '`
digitsCount=${#numElements}

# create new IMGlistByMostSimilar.txt in the subdir the copies will be written to, only with the new file names (as those file names will be appended to that file in the following block) :
printf "" > ./_temp_numbered/$fileList
counter=0
while read element
do
	counter=$((counter + 1))
			# ex. to pad numbers to number of digits in %0n:
			# var=`printf "%05d\n" $element`
	paddedNum=`printf "%0"$digitsCount"d\n" $counter`
	echo "executing command: cp -f ./$element ./_temp_numbered/$paddedNum.$fileNameExt"
	cp -f ./$element ./_temp_numbered/$paddedNum.$fileNameExt
	# Because Cygwin can be silly with permissions (I can't use the .png images afterward without special access!) :
	chmod 777 ./_temp_numbered/$paddedNum.$fileNameExt
	echo "file '$paddedNum.$fileNameExt'" >> ./_temp_numbered/$fileList
done < ./tmp_kHDcaVmKUgsZp9cvU2QezUsZ3EYHAWbqkr.txt

rm ./tmp_kHDcaVmKUgsZp9cvU2QezUsZ3EYHAWbqkr.txt