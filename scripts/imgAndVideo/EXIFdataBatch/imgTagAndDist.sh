# DESCRIPTION: Tags imags with metadata customized by a simple editable text file template. Must run prepImageMetaData.sh and/or other scripts before.

find . -iname \*MD_ADDS.txt > images_MD_ADDS_list.txt
mapfile -t images_MD_ADDS_list < images_MD_ADDS_list.txt
for element in "${images_MD_ADDS_list[@]}"
do
	# Retrieve image title from ~MD_ADDS.txt for use in adding search engine query for original image source--adding that to the description tag:
	imageTitle=`sed -n 's/^Title="\(.*\)"$/\1/p' $element`
	# re: https://gimi.name/snippets/urlencode-and-urldecode-for-bash-scripting-using-sed/ :
			# OR? : https://gist.github.com/cdown/1163649 :
	echo "$imageTitle" | sed -f /cygdrive/c/_devtools/scripts/urlencode.sed > oy.txt
	# Insert that image title with a search query URL into the description tag; roundabout means via invoking script created with several text processing commands, because I can't figure the proper escape sequences if there even would be any working ones long cherished friend of a forgotten space and possible future time I love you for even reading this:
	# BUT WAIT! START OY TEH CLUGY ===================================
					# BUG FIXED--see next comment; NOTE the following will cause mashed redundant URLs if this script is run twice or more; you must delete the working ~MD_ADDS.txt and run prepImageMetaData.sh before this script: --. 2016-05-07 11:20 PM -RAH
			# CLEAR the urlencoded text after .*earthbound.io/q (if there is such text), lest redundant encodings append thereto on subsequent runs of this script:
			sed -i 's/\(.*You may find the original, print and use options at http:\/\/earthbound.io\/q\/?\).*/\1/g' $element
			# OY, that was a rather dodgy bug to sort out :/ 2016-05-07 11:55 PM -RAH
	# END OY TEH CLUGY ===================================
	sed -n 's/\(.*\)\(print and use options at.*\)/\2/p' $element > flerf.txt
	# exit
	cat flerf.txt oy.txt > zorg.txt
	tr -d '\n' < zorg.txt > floofy_floo.txt
	# BECAUSE that text file has / characters that choke sed later on, escape them to \/	; this doom was foretold after much pain of spirit 2016-05-07 7:54 PM -RAH:
	sed -i 's/\//\\\//g' floofy_floo.txt
	descriptionAddendum=$( < floofy_floo.txt)
	sed -i "s/\(.*You may find the original, \).*/\1$descriptionAddendum\"/g" $element
	rm flerf.txt oy.txt zorg.txt floofy_floo.txt
	# For every file listed in images_MD_ADDS_list.txt, precede every line with a dash, to make it an exiftool parameter:
	sed 's/\(.*\)$/-\1/g' $element > temp.txt
	tr '\n' ' ' < temp.txt > temp2.txt
	exifTagArgs=$( < temp2.txt)
	rm temp.txt temp2.txt
	# Retrieve extension of source final master file name (SFMFN) from ~MD_ADDS; and store it in a variable; thanks re http://stackoverflow.com/a/1665574 :
	SFMFNextension=`sed -n 's/.*from master file.*\(\..\{1,4\}\)"/\1/p' $element`
	# Retrieve and store full ~ file name with extension; the \.\/ part escapes ./ (which ./ this sed command also strips) :
				# SFMFNnoExtension=`sed -n 's/.*from master file: \.\/\(.*\)\..\{1,4\}"/\1/p' $element`
	SFMFNpath=`sed -n 's/.*from master file: \.\/\(.*\/\).*\"/\1/p' $element`
	SFMFNwithExtension=`sed -n 's/.*from master file: \.\/\(.*\..\{1,4\}\)"/\1/p' $element`

	# If SFMFNextension is .tif, strip all EXIF data by custom command upon inserting custom metadata; otherwise use a more general exif data strip command:
	if [ $SFMFNextension == ".tif" ]; then
		# echo is tif.
		echo exiftool -CommonIFD0= -adobe:all= -xmp:all= -photoshop:all= -tagsfromfile @ -iptc:all -overwrite_original $exifTagArgs $SFMFNpath\__tagAndDistPrepImage$SFMFNextension > exiftool_temp_update_metadata.bat
				# e.g.:   exiftool -CommonIFD0= testimg.tif    NECESSARY FOR removing tags from tiffs! RE: http://www.sno.phy.queensu.ca/~phil/exiftool/faq.html#Q7
				# ALSO RE: http://u88.n24.queensu.ca/exiftool/forum/index.php/topic,5111.msg24655.html#msg24655
				# -adobe:all= -xmp:all= -photoshop:all= -tagsfromfile @ -iptc:all -overwrite_original
		# echo ~~~~~
			# echo SFMFNwithExtension is $SFMFNwithExtension
			# echo SFMFNnoExtension is $SFMFNnoExtension
			# echo that plus extension is $SFMFNnoExtension$SFMFNextension
		# echo ====
	else
		# echo is not tif.
		echo exiftool -adobe:all= -xmp:all= -photoshop:all= -tagsfromfile @ -iptc:all -overwrite_original $exifTagArgs $SFMFNpath\__tagAndDistPrepImage$SFMFNextension > exiftool_temp_update_metadata.bat
	fi

# run created script, then delete it:
	if [ -a ../dist ]
	then
		der=derp
	else
		mkdir ../dist
	fi

	echo -=-=
	# Copy to new ~tagAndDistPrep image before running metadata update batch against it (so that the batch will even do any work) :
	cp -f $SFMFNwithExtension $SFMFNpath\__tagAndDistPrepImage$SFMFNextension
	# Run and delete said batch:
	cygstart -w exiftool_temp_update_metadata.bat
	echo Ran exiftool_temp_update_metadata.bat . . .
	rm exiftool_temp_update_metadata.bat
	# Move the new, properly metadata tagged file to a permanent distribution location:
	# echo _ Move the new, properly metadata tagged file to a permanent distribution location:
# TO DO: MAKE IT MAKE THE DEST PATH IF NECESSARY; er make that nxt -a :
	mkdir ../dist/$SFMFNpath
	mv $SFMFNpath\__tagAndDistPrepImage$SFMFNextension ../dist/$SFMFNwithExtension
	echo ~~~~
		# Use any/which? :
		# -@ ARGFILE ?
		# -o xmp?
		# -X (-xmlFormat) ? :
				 # Use ExifTool-specific RDF/XML formatting for console output.
		# -q quiet
done

echo Image copied and metadata set. Look for the final distribution image one directory up and in a /dist directory tree.