	echo "!============================================================"
	echo "The text of all .txt files will be assembled by this script into _allTXTsInUTF8.txt. NOTE: if any characters, in filenames in the directory you run this script against, are not script-friendly (for example if the file names contain spaces), this script may fail. Unmess text file names before running this script."
	echo "Do you wish to run this script?"
	echo "!============================================================"
	echo "IF YOU HAVE READ the above, type the number corresponding to your answer, then press <enter>. If you haven't read the warning, your answer is 2 (No)."
	select yn in "Yes" "No"
	do
		case $yn in
			Yes ) echo Dokee-okee! Working . . .; break;;
			No ) echo Doh!; exit;;
		esac
	done


ls *.txt > allFiles
mapfile -t filesArray < allFiles
rm allFiles

for filename in "${filesArray[@]}"
do
	temp=`file -bi $filename`
	type=`echo $temp | sed 's/.*=\(.*\)/\1/g'`
	echo type of $filename is:
	echo $type
	
	if [ "$type" != "us-ascii" ]
	then
		echo file $filename probably needs conversion to utf8, and/or for (perverted!) DOS line-endings to be converted to unix. Enter dos2unix and iconv. Converting to unix + utf8 and appending to _allTXTsInUTF8.txt . . .
		dos2unix -l -n $filename out.txt
		rm $filename
		iconv -t utf8 out.txt >> $filename
	else
		echo file $filename does not need conversion, appending to _allTXTsInUTF8.txt . . .
		# cat _allTXTsInUTF8.txt $filename >> temp.txt
		# rm _allTXTsInUTF8.txt
		# mv temp.txt _allTXTsInUTF8.txt
	fi
done