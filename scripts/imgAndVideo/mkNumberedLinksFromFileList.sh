# USAGE
# Invoke this cript with one parameter:
# $1 The file list name, for which every file name in the list there will be numbered junction (file names which are junctions) in a subdir.

# WARNING: this script perhaps dangerously assumes all file names provided in the list have the same extension; which is done on these next lines:
tempStr=`head -n 1 IMGlistByMostSimilar.txt`
echo that is $tempStr
# NOTE that this assumes a closing apostraphe or single quote in the input file! :
fileNameExt=`echo $tempStr | sed "s/.*\.\([^\.]\{1,5\}\)'.*/\1/g"`

if [ -a numberedLinks ]; then rm -rf numberedLinks; mkdir numberedLinks; else mkdir numberedLinks; fi

sed "s/file '\(.*\)'/\1/g" $1 > tmp_kHDcaVmKUgsZp9cvU2QezUsZ3EYHAWbqkr.txt

numElements=`wc -l < $1`
digitsCount=${#numElements}

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