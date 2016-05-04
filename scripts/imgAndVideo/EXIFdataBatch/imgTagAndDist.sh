# exiftool -P -Copyright="Richard Alexander Hall, all rights reserved." -Artist="Richard Alexander Hall" -overwrite_original
find . -iname \*MD_ADDS.txt > images_MD_ADDS_list.txt
mapfile -t images_MD_ADDS_list < images_MD_ADDS_list.txt
for element in "${images_MD_ADDS_list[@]}"
do
	# Prep custom temp exiftool batch for image associated with ~images_MD_ADDS_list.txt . . .
		# For evry file listed in images_MD_ADDS_list.txt, precede every line with a dash, to make it an exiftool parameter:
	sed 's/\(.*\)$/-\1/g' $element > temp.txt
	tr '\n' ' ' < temp.txt > temp2.txt
	exifTagArgs=$(<temp2.txt)
	rm temp.txt temp2.txt
	# Retrieve extension of source final master file name from ~MD_ADDS; and store it in a variable; thanks re http://stackoverflow.com/a/1665574 :
	SFMFNextension=`sed -n 's/.*from master file.*\(\..\{1,4\}\)"/\1/p' $element`
	# Retrieve and store full ~ file name with extension; the \.\/ part escapes ./ (which ./ this sed command also strips) :
				# SFMFNwithExtension=`sed -n 's/.*from master file: \.\/\(.*\..\{1,4\}\)"/\1/p' $element`
	SFMFNnoExtension=`sed -n 's/.*from master file: \.\/\(.*\)\..\{1,4\}"/\1/p' $element`
	# If SFMFNextension is .tif, strip all EXIF data by custom command upon inserting custom metadata; otherwise use a more general exif data strip command:
	if [ $SFMFNextension == ".tif" ]; then
		# echo is tif.
		# e.g.:   exiftool -CommonIFD0= testimg.tif    NECESSARY FOR removing tags from tiffs! RE: http://www.sno.phy.queensu.ca/~phil/exiftool/faq.html#Q7
		echo exiftool -CommonIFD0= $exifTagArgs $SFMFNwithExtension
		# echo ~~~~~
			# echo SFMFNwithExtension is $SFMFNwithExtension
			# echo SFMFNnoExtension is $SFMFNnoExtension
		echo ~ + ~Extension is $SFMFNnoExtension$SFMFNextension
		echo ====
	else
		echo is not tif.
	fi

	# Use any/which? :	
	# -@ ARGFILE ?
	# -o xmp?
	# -X (-xmlFormat) ? :
			 # Use ExifTool-specific RDF/XML formatting for console output.
	# -q quiet
done