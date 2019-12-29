# USAGE
# Invoke this script with one parameter:
# $1 The file list name, for which every file name in the list will have numbered copies made in a subdir. This is preparation for other scripts which must operate on numbered files.

# WARNING: this script perhaps dangerously assumes all file names provided in the list have the same extension. Also, it clobbers any files that already exist when it copies (overwrites without prompt).

# DEPENDENCIES
# IMGlistByMostSimilar.txt as prepared by imgsGetSimilar.sh and/or re_sort_imgsMostSimilar.sh

# USAGE
# TO DO
# - detail usage
# - BUG FIX: on copy it is overwriting the last image with the second-to-last. ?
# - Document how to use this script :)


# CODE
# IF NO list file provided, assume it is IMGlistByMostSimilar.txt:
if [ -z "$1" ]
then
	fileList=IMGlistByMostSimilar.txt; echo No file list parameter \(\$\1\) passed to script\; setting fileList to default IMGlistByMostSimilar.txt
else
	fileList=$1; echo fileList set to parameter \1\, $1
fi

# If the _temp_numbered directory already exists, TOAST IT without warning, then recreate it; otherwise create it:
if [ -d _temp_numbered ]; then rm -rf _temp_numbered; mkdir _temp_numbered; else mkdir _temp_numbered; fi

tempStr=`ghead -n 1 $fileList`
# NOTE that this script assumes a closing apostraphe or single quote in the input file! :
# No, the fileExt=${filename##*.} doesn't work here as there's a trailing ' to trim:
fileNameExt=`echo $tempStr | gsed "s/.*\.\([^\.]\{1,5\}\)'.*/\1/g"`

# NOTE this script assumes a list formatted for concatenation by ffmpeg, and makes a temp copy of the list removing that syntax:
gsed "s/file '\(.*\)'/\1/g" $fileList > tmp_kHDcaVmKUgsZp9cvU2QezUsZ3EYHAWbqkr.txt
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