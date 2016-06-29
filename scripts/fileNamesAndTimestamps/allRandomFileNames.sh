# TO DO: make this keep extensions. this is quick and drity for flam3 files. 06/12/2016 09:15:44 AM -RAH
# Build from the following snippets to do that; I think var is the extension:
	# newFileName=`echo $var | sed 's/\.*\(................\).*/\1/g'`
	# var=`echo $var | sed 's/\.*\(................\)\(.*\)/\2/g'`
			# echo newFileName is $newFileName.dat

ls > allFiles.txt
mapfile -t array < allFiles.txt
rm allFiles.txt
# arrSize=${#array[@]}
for filename in ${array[@]}
do
	newFileName=`cat /dev/urandom | tr -cd 'a-km-np-zA-KM-NP-Z2-9___~~~~' | head -c 4`
		# echo renaming file $filename . . . to $newFileName.flam3
		# newFileName=`echo $var | sed 's/\.*\(................\).*/\1/g'`
		# var=`echo $var | sed 's/\.*\(................\)\(.*\)/\2/g'`
				# echo newFileName is $newFileName.dat
				# echo var is $var
	mv ./$filename ./$newFileName.flam3
done