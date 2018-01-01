# USAGE
# Invoke this cript with one parameter:
# $1 The file list name, for which every file name in the list there will have numbered copies made in a subdir. Preparation for other scripts which must operate on numbered files.

# WARNING: this script perhaps dangerously assumes all file names provided in the list have the same extension.

# USAGE
# TO DO :) Document how to use this script.


# CODE
# IF NO list file provided, assume it is IMGlistByMostSimilar.txt:
if [ -z ${1+x} ]
then
	fileList=IMGlistByMostSimilar.txt; echo No file list parameter \(\$\1\) passed to script\; setting fileList to default IMGlistByMostSimilar.txt
else
	fileList=$1; echo fileList set to parameter \1\, $1
fi

tempStr=`head -n 1 $fileList`
# NOTE that this script also assumes a closing apostraphe or single quote in the input file! :
fileNameExt=`echo $tempStr | sed "s/.*\.\([^\.]\{1,5\}\)'.*/\1/g"`

if [ -a numberedCopies ]; then rm -rf numberedCopies; mkdir numberedCopies; else mkdir numberedCopies; fi

# NOTE ALSO that this script assumes a list formatted for concatenation by ffmpeg, and makes a temp copy of the list removing that syntax:
sed "s/file '\(.*\)'/\1/g" $fileList > tmp_kHDcaVmKUgsZp9cvU2QezUsZ3EYHAWbqkr.txt

numElements=`wc -l < $fileList`
digitsCount=${#numElements}

# create new IMGlistByMostSimilar.txt in the subdir the copies will be written to, only with the new file names (as those file names will be appended to that file in the following block) :
printf "" > ./numberedCopies/$fileList
counter=0
while read element
do
	counter=$((counter + 1))
			# ex. to pad numbers to number of digits in %0n:
			# var=`printf "%05d\n" $element`
	paddedNum=`printf "%0"$digitsCount"d\n" $counter`
	command="cp ./$element ./numberedCopies/$paddedNum.$fileNameExt"
	echo "file '$paddedNum.$fileNameExt'" >> ./numberedCopies/$fileList
	echo executing command\:
	echo $command
	$command
done < ./tmp_kHDcaVmKUgsZp9cvU2QezUsZ3EYHAWbqkr.txt

rm ./tmp_kHDcaVmKUgsZp9cvU2QezUsZ3EYHAWbqkr.txt