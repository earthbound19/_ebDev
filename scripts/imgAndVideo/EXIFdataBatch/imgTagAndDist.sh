# DESCRIPTION: Tags imags with metadata customized by a simple editable text file template. Must run prepImageMetaData.sh and/or other scripts before.

# USAGE: correct. NOTE: fer mysic unknown you may not have permission to run the generated .bat file from cygwin/bash. If so, delete, then re-create the file from within windows. WUT? But it fixes it.

# TO DO:
# DOUBLE CHECK that the s.earthbound.io~ link is formatted correctly and works in result.
# - Document workings and use; ack. or fix clunky weaknesses in design.
# - Implement keyword heirarchies re: http://www.sno.phy.queensu.ca/~phil/exiftool/TagNames/MWG.html
# * DONE: Implement self-hosted polr url shortening for looong titles/self-hosted title search URLS. e.g. like http://polr.me/w9g or http://polr.me/11q3 ; dev code that works or doesn't depending on authentication; the following are for polr_cli_polrAcct.py : C:\Python27\Lib\site-packages\polr_cli\polr_cli.py --shorten http://earthbound\.io/q
#	Command that looks up target of shortened link, but relies on faulty dependency:
# 	Python polr_cli.py --lookup w9g
# 	Command that does NOT work at this writing at my self-hosted Polr install:
# 	Python polr_cli_s_eb.py --lookup 0
# 	API call URL that DOES work at my self-hosted Polr install--and saves the result URL to a plain-text URL! :
# 	wget -O shortened_URL.txt "http://s.earthbound.io/api/v2/action/shorten?key=50qq0n183q00p704osp1q1rrr48225&url=https://google.com&is_secret=false&response_type=plain_text"
#	NOTE that when logged in, it won't show the new link unless you reload the page.

find . -iname \*MD_ADDS.txt > images_MD_ADDS_list.txt
mapfile -t images_MD_ADDS_list < images_MD_ADDS_list.txt
for element in "${images_MD_ADDS_list[@]}"
do
	# Retrieve image title from ~MD_ADDS.txt for use in adding search engine query for original image source--adding that to the description tag:
	imageTitle=`sed -n 's/^-IPTC:ObjectName="\(.*\)"$/\1/p' $element`
	# re: https://gimi.name/snippets/urlencode-and-urldecode-for-bash-scripting-using-sed/ :
			# OR? : https://gist.github.com/cdown/1163649 :
	oy="http://earthbound.io/q/search.php?search=1&query=$imageTitle"
	oy=`echo "$oy" | sed -f /cygdrive/c/_devtools/scripts/urlencode.sed`
		# target format: http://s.earthbound.io/api/v2/action/shorten?key=50dd0a183d00c704bfc1d1eee48225&url=https://google.com&is_secret=false&response_type=plain_text
	wgetArg="http://s.earthbound.io/api/v2/action/shorten?key=50qq0n183q00p704osp1q1rrr48225&is_secret=false&response_type=plain_text&url=$oy"
	wget -O oy.txt $wgetArg
	# Insert that image title with a search query URL into the description tag; roundabout means via invoking script created with several text processing commands, because I can't figure the proper escape sequences if there even would be any working ones long cherished friend of a forgotten space and possible future time I love you for even reading this:
	# BUT WAIT! START OY TEH CLUGY ===================================
					# BUG FIXED--see next comment; NOTE the following will cause mashed redundant URLs if this script is run twice or more; you must delete the working ~MD_ADDS.txt and run prepImageMetaData.sh before this script: --. 2016-05-07 11:20 PM -RAH
			# CLEAR the urlencoded text after .*earthbound.io/q (if there is such text), lest redundant encodings append thereto on subsequent runs of this script:
			sed -i 's/\(.*print and usage at \).*/\1/g' $element
			# echo sed -i 's/\(.*You may find the original, print and use options at http:\/\/earthbound.io\/q\/?\).*/\1/g' $element
# exit
			# OY, that was a rather dodgy bug to sort out :/ 2016-05-07 11:55 PM -RAH
	# END OY TEH CLUGY ===================================
	sed -n 's/\(.*\)\(print and use options at.*\)/\2/p' $element > flerf.txt
	cat flerf.txt oy.txt > zorg.txt
	tr -d '\n' < zorg.txt > floofy_floo.txt
	# BECAUSE that text file has / characters that choke sed later on, escape them to \/	; this doom was foretold after much pain of spirit 2016-05-07 7:54 PM -RAH:
	sed -i 's/\//\\\//g' floofy_floo.txt
	# for % characters also, only for DOS, so double %; this doom was also foretold after much pain of spirit 05/08/2016 10:30:25 PM -RAH
	sed -i 's/%/%%/g' floofy_floo.txt
	# maybe relvnt thar? : http://stackoverflow.com/a/9488318
	descriptionAddendum=$( < floofy_floo.txt)
	echo desc. add.\:
	echo $descriptionAddendum
	echo elem.\:
	echo $element
	sed -i "s/\(.* print and usage at \).*/\1$descriptionAddendum\"/g" $element
	rm flerf.txt oy.txt zorg.txt floofy_floo.txt
					# DEPRECATED APPROACH; in favor of specifying argument switches (e.g. + or - or -Tag+=Word) in customImageMetadataTemplate.txt itself:
					# For every file listed in images_MD_ADDS_list.txt, precede every line with a dash, to make it an exiftool parameter:
					# sed 's/\(.*\)$/-\1/g' $element > fersh.txt
					# tr '\n' ' ' < fersh.txt > ghor.txt
	tr '\n' ' ' < $element > ghor.txt
	exifTagArgs=$( < ghor.txt)
	rm ghor.txt
	# Retrieve extension of source final master file name (SFMFN) from ~MD_ADDS; and store it in a variable; thanks re http://stackoverflow.com/a/1665574 :
	SFMFNextension=`sed -n 's/.*from master file.*\(\..\{1,4\}\)"/\1/p' $element`
	# Retrieve and store full ~ file name with extension; the \.\/ part escapes ./ (which ./ this sed command also strips) :
				# SFMFNnoExtension=`sed -n 's/.*from master file: \.\/\(.*\)\..\{1,4\}"/\1/p' $element`
	SFMFNpath=`sed -n 's/.*from master file: \.\/\(.*\/\).*\"/\1/p' $element`
	SFMFNwithExtension=`sed -n 's/.*from master file: \.\/\(.*\..\{1,4\}\)"/\1/p' $element`
					# echo ~~~~
						# echo SFMFNwithExtension is $SFMFNwithExtension
						# echo SFMFNnoExtension is $SFMFNnoExtension
						# echo that plus extension is $SFMFNnoExtension$SFMFNextension
					# echo ====
	# If SFMFNextension is .tif, strip all EXIF data by custom command upon inserting custom metadata; otherwise use a more general exif data strip command:
	if [ $SFMFNextension == ".tif" ]
	then
		# echo is tif.
		echo exiftool -CommonIFD0= -adobe:all= -xmp:all= -photoshop:all= -iptc:all= -overwrite_original -k $exifTagArgs $SFMFNpath\__tagAndDistPrepImage$SFMFNextension > exiftool_temp_update_metadata.bat
		# In two commands because for wait what?
		# echo exiftool $exifTagArgs $SFMFNpath\__tagAndDistPrepImage$SFMFNextension >> exiftool_temp_update_metadata.bat
				# e.g.:   exiftool -CommonIFD0= testimg.tif    NECESSARY FOR removing tags from tiffs! RE: http://www.sno.phy.queensu.ca/~phil/exiftool/faq.html#Q7
				# ALSO RE: http://u88.n24.queensu.ca/exiftool/forum/index.php/topic,5111.msg24655.html#msg24655
				# -adobe:all= -xmp:all= -photoshop:all= -tagsfromfile @ -iptc:all -overwrite_original
	else
		# echo is not tif.
		echo exiftool -adobe:all= -xmp:all= -photoshop:all= -iptc:all= -overwrite_original -k $exifTagArgs $SFMFNpath\__tagAndDistPrepImage$SFMFNextension > exiftool_temp_update_metadata.bat
	fi
		# Use any/which? :
		# -@ ARGFILE ?
		# -o xmp?
		# -X (-xmlFormat) ? :
				 # Use ExifTool-specific RDF/XML formatting for console output.
		# -q quiet

	# run created script, then delete it:
	if [ -a ../dist ]; then	der=derp; else mkdir ../dist; fi
	# echo -=-=
	# Copy to new ~tagAndDistPrep image before running metadata update batch against it (so that the batch will even do any work) ; but only if the dist. file doesn't exist:
	cp -f "$SFMFNwithExtension" "$SFMFNpath\__tagAndDistPrepImage$SFMFNextension"
	cygstart -w exiftool_temp_update_metadata.bat
	echo Ran exiftool_temp_update_metadata.bat . . .
	printf "" > exiftool_temp_update_metadata.bat
	# Move the new, properly metadata tagged file to a permanent distribution location:
# TO DO: MAKE IT MAKE THE DEST PATH IF NECESSARY; er make that nxt -a :
	if [ -a "../dist/$SFMFNpath$imageTitle$SFMFNextension" ]
	then
		echo DESTINATION FILE "../dist/$SFMFNpath$imageTitle$SFMFNextension" already exists\, so this won\'t overwrite it. If you mean to update the destination file\, first delete it\, and then run this script again. If you also intend to alter or recreate the metadata\, delete the assocaited ~_MD_ADDS.txt file as well\, and run prepImageMetaData.sh before this.
	else
		# Make target directory for dist file, only if it doesn't exist:
		if [ -a ../dist/$SFMFNpath ]; then	der=derp; else mkdir ../dist/$SFMFNpath; fi
		mv "$SFMFNpath\__tagAndDistPrepImage$SFMFNextension" "../dist/$SFMFNpath$imageTitle$SFMFNextension"
	fi
	echo -~-~
done

echo Metadata modified for each image\, and each final distribution image copied one directory tree up\, in \.\.\/dist \[dist. path mirror of origin path\]\.


# DEVELOPMENT HISTORY:
# 2016-05-07 feature complete and debugged.
# 05/08/2016 01:03:47 PM--05/08/2016 10:35:46 PM oops, moar bunniesugs. Also needs feature of /dist/[path/] copy being named after img. title. got that working but and BUGS FIXED: * not copying to dist/[mirror src path] -- FIXED 05/08/2016 01:23:46 PM * keyword tag items duplicating -- FIXED cause uncertain but found process could build them up or not clear prior ones [how? no prior ones in process I thought?!] until removal of -tagsfromfile @ argument. Remove that argument, and EXIF/IPTC tags fully (instead of partially) clear. 05/08/2016 19:48:07 PM RAH* somehow echoed ls / dir. items listed in Description field -- FIXED: cause was asterisks used as separators in customImageMetadataTemplate.txt which somehow functioned as a "list everything in this directory" command when called by? . . . something. 05/08/2016 03:17:11 PM * redundant file list files and no delete of. EH, WHATEV. * conditional creation of ../dist/$SFMFNpath directory -- DONE 05/08/2016 03:28:12 PM * Also found urlencoded strings in metadata prep file lost % sign; found cause is DOS misinterpreting them in metadata update batch; escaped them via %%. FIXED. 05/08/2016 10:34:53 PM -RAH