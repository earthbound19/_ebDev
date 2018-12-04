# USAGE
# Invoke this cript with one optional parameter:
# $1 A file name of a list. The list is in the format:
#
# file '263.jpg'
# file '363.jpg'
# file '064.jpg'
# file '145.jpg'
#
# from this list there will be made numbered junctions (file names which are junctions) in a subdir.

# WARNING: this script perhaps dangerously assumes all file names provided in the list have the same extension.


# CODE
# IF NO list file provided, assume it is IMGlistByMostSimilar.txt:
if [ -z ${1+x} ]
then
	fileList=IMGlistByMostSimilar.txt; echo No file list parameter \(\$\1\) passed to script\; setting fileList to default IMGlistByMostSimilar.txt
else
	fileList=$1; echo fileList set to parameter \1\, $1
fi

# the mentioned "all files have the same extension" assumption is used here:
tempStr=`tail -n 1 IMGlistByMostSimilar.txt`

# NOTE that this assumes a closing apostraphe or single quote in the input file!-- and that we therefore here need to use gsed instead of fileExt=${filename##*.} :
fileNameExt=`echo $tempStr | gsed "s/.*\.\([^\.]\{1,5\}\)'.*/\1/g"`

digitsCount=${#fileNameExt}

# If the numberedLinks directory already exists, TOAST IT without warning, then recreate it:
if [ -a numberedLinks ]; then rm -rf numberedLinks; mkdir numberedLinks; else mkdir numberedLinks; fi

gsed "s/file '\(.*\)'/\1/g" $fileList > tmp_kHDcaVmKUgsZp9cvU2QezUsZ3EYHAWbqkr.txt

counter=0
while read element
do
	counter=$((counter + 1))
			# ex. to pad numbers to number of digits in %0n:
			# var=`printf "%05d\n" $element`
	paddedNum=`printf "%0"$digitsCount"d\n" $counter`
	command="link ./$element ./numberedLinks/$paddedNum.$fileNameExt"
	echo executing command\:
	echo $command
	$command
done < ./tmp_kHDcaVmKUgsZp9cvU2QezUsZ3EYHAWbqkr.txt

rm ./tmp_kHDcaVmKUgsZp9cvU2QezUsZ3EYHAWbqkr.txt