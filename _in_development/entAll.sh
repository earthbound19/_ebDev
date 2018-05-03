gfind . > _allFiles.txt
while read element
do
	echo $element
done < _allFiles.txt
rm _allFiles.txt






# baseFileName=`basename "$line"`