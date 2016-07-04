# DESCRIPTION: Tags imags with metadata customized by a simple editable text file template. Must run prepImageMetaData.sh and/or other scripts before.

# USAGE: correct. (MEAGER) NOTES: This expects all images it works upon to be .tif images, and won't work with anything else. Maybe I'll change it to also do non-standard tags in .png files, and do other source formats also.
# NOTE: fer mysic unknown you may not have permission to run the generated .bat file from cygwin/bash. If so, delete, then re-create the file from within windows. WUT? But it fixes it.

# TO DO:
# ? Don't update metadata template with a shortened URL (and retrieve a short URL) if one already exists.
#? Fix the continue prompt selection at the start to *work*. It used to; no idea what's different. ?
# Check: is it proper or does it work to use the -IPTC:ObjectName in this script? Should that be -MWG:Description?
# DOUBLE CHECK that the s.earthbound.io~ link is formatted correctly and works in result.
# - Document workings and use; ack. or fix clunky weaknesses in design.
# - Implement keyword heirarchies re: http://www.sno.phy.queensu.ca/~phil/exiftool/TagNames/MWG.html
# * DONE: Implement self-hosted polr url shortening for looong titles/self-hosted title search URLS. e.g. like http://polr.me/w9g or http://polr.me/11q3 ; dev code that works or doesn't depending on authentication; the following are for polr_cli_polrAcct.py : C:\Python27\Lib\site-packages\polr_cli\polr_cli.py --shorten http://earthbound\.io/q
				#	Command that looks up target of shortened link, but relies on faulty dependency:
				# 	Python polr_cli.py --lookup w9g
				# 	Command that does NOT work at this writing at my self-hosted Polr install:
				# 	Python polr_cli_s_eb.py --lookup 0
# 	API call URL that DOES work at my self-hosted Polr install--and saves the result URL to a plain-text URL! (except that that key is now retired ;) :
# 	wget -O shortened_URL.txt "http://s.earthbound.io/api/v2/action/shorten?key=3108e9a45e9f6edcf9eeaa1ca9712d&url=https://google.com&is_secret=false&response_type=plain_text"
#	NOTE that when logged in, it won't show the new link unless you reload the page.

# SCRIPT WARNING ==========================================
# NOTE: the following is commented out because something goofy is going on with maybe parenthesis parsing in the answers:
echo "imgTagAndDist.sh: this script will erase all metadata from the image files in the entire directory tree from which this is run. If this is something you mean to do, press y and enter. Otherwise press n and enter, or close this terminal."
	echo "!============================================================"
	# echo "DO YOU WISH TO CONTINUE running this script?"
    read -p "DO YOU WISH TO CONTINUE running this script? : y/n" CONDITION;
    if [ "$CONDITION" == "y" ]; then
		echo Ok! Working . . .
	else
		echo D\'oh!; exit;	
    fi
# END SCRIPT WARNING =======================================


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
	wgetArg="http://s.earthbound.io/api/v2/action/shorten?key=4ffdbbc5091420d5b0448ce42273c6&is_secret=false&response_type=plain_text&url=$oy"
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
	# ~
	# IF NO s.earthbound.io SHORTENED URL is in the metadata, fetch one and include it:
	grep -q s.earthbound.io $element
	if [ $? -eq 0 ]
		then
			echo Metadata file already contains s.earthbound.io\; will not update with any shortened URL.
		else
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
	fi
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
	# SFMFNpath will preserve any subdirectory paths and duplicate them to the target ../dist path:
	SFMFNpath=`sed -n 's/.*from master file: \.\/\(.*\/\).*\"/\1/p' $element`
# e.g. result val of SFMFNpath: subdir/
# OR if no subdir, it is blank.
	SFMFNwithExtension=`sed -n 's/.*from master file: \.\/\(.*\..\{1,4\}\)"/\1/p' $element`
					# echo ~~~~
						# echo SFMFNwithExtension is $SFMFNwithExtension
						# echo SFMFNnoExtension is $SFMFNnoExtension
						# echo that plus extension is $SFMFNnoExtension$SFMFNextension
					# echo ====
	# If SFMFNextension is .tif, strip all EXIF data by custom command upon inserting custom metadata; otherwise use a more general exif data strip command:
	if [ $SFMFNextension == ".tif" ] || [ $SFMFNextension == ".png" ] || [ $SFMFNextension == ".psd" ]
	then
		# echo is tif.
# TO DO: double-check: I *think* the -m flag, in ignoring minor warnings, allows writing strings into metadata longer than specs allow:
				echo writing commmand for tif file to exiftool_temp_update_metadata.bat\:
				echo exiftool -CommonIFD0= -adobe:all= -xmp:all= -photoshop:all= -iptc:all= -m -overwrite_original -k $exifTagArgs $SFMFNpath\__tagAndDistPrepImage$SFMFNextension
		echo exiftool -CommonIFD0= -adobe:all= -xmp:all= -photoshop:all= -iptc:all= -m -overwrite_original -k $exifTagArgs $SFMFNpath\__tagAndDistPrepImage$SFMFNextension > exiftool_temp_update_metadata.bat
		# In two commands because for wait what?
		# echo exiftool $exifTagArgs $SFMFNpath\__tagAndDistPrepImage$SFMFNextension >> exiftool_temp_update_metadata.bat
				# e.g.:   exiftool -CommonIFD0= testimg.tif    NECESSARY FOR removing tags from tiffs! RE: http://www.sno.phy.queensu.ca/~phil/exiftool/faq.html#Q7
				# ALSO RE: http://u88.n24.queensu.ca/exiftool/forum/index.php/topic,5111.msg24655.html#msg24655
				# -adobe:all= -xmp:all= -photoshop:all= -tagsfromfile @ -iptc:all -overwrite_original
	else
		# echo is not tif.
				echo writing commmand for non-tif file to exiftool_temp_update_metadata.bat\:
				echo exiftool -adobe:all= -xmp:all= -photoshop:all= -iptc:all= -m -overwrite_original -k $exifTagArgs $SFMFNpath\__tagAndDistPrepImage$SFMFNextension
		echo exiftool -adobe:all= -xmp:all= -photoshop:all= -iptc:all= -m -overwrite_original -k $exifTagArgs $SFMFNpath\__tagAndDistPrepImage$SFMFNextension > exiftool_temp_update_metadata.bat
	fi
		# Use any/which? :
		# -@ ARGFILE ?
		# -o xmp?
		# -X (-xmlFormat) ? :
				 # Use ExifTool-specific RDF/XML formatting for console output.
		# -q quiet

	# run created script, then delete it:
	if [ ! -d ../dist ]; then mkdir ../dist; fi
	# echo -=-=
	# Copy to new ~tagAndDistPrep image before running metadata update batch against it (so that the batch will even do any work) ; NOTE that if $SFMFNpath is empty, the dest path to copy to will simply be ./ ; this doom of using two sets of double quotes for the dest path was at last prophecied 06/20/2016 11:18:51 PM -RAH; BUT WAIT, THERE'S MORE!--and rediscovered thanks to a missing double quote mark typographical error 07/01/2016 10:18:40 PM -RAH:
	cp -f "./$SFMFNwithExtension" "./$SFMFNpath""__tagAndDistPrepImage""$SFMFNextension"
	# Because (it seems) cygwin can create a batch file the system doesn't have permission to run? AND no permissions are given to open that copied file:
	chmod 777 exiftool_temp_update_metadata.bat "./$SFMFNpath""__tagAndDistPrepImage""$SFMFNextension"
	cygstart -w exiftool_temp_update_metadata.bat
	echo Ran exiftool_temp_update_metadata.bat . . .
# printf "" > exiftool_temp_update_metadata.bat
	# Move the new, properly metadata tagged file to a permanent distribution location; but only if the dist. file doesn't exist:
# TO DO: MAKE IT MAKE THE DEST PATH IF NECESSARY; er make that nxt -a :
	if [ -e "../dist/$SFMFNpath$imageTitle$SFMFNextension" ]
	then
		echo DESTINATION FILE "../dist/$SFMFNpath$imageTitle$SFMFNextension" already exists\, so this won\'t overwrite it. If you mean to update the destination file\, first delete it\, and then run this script again. If you also intend to alter or recreate the metadata\, delete the assocaited ~_MD_ADDS.txt file as well\, and run prepImageMetaData.sh before this.
	else
		# Make target directory for dist file, only if it doesn't exist:
		if [ ! -e ../dist/$SFMFNpath ]; then mkdir ../dist/$SFMFNpath; fi
		mv -f "./$SFMFNpath""__tagAndDistPrepImage$SFMFNextension" "../dist/$SFMFNpath$imageTitle$SFMFNextension"
	fi
	echo -~-~
done

rm -f exiftool_temp_update_metadata.bat imagesMetadataPrepList.txt images_MD_ADDS_list.txt

echo Metadata modified for each image\, and each final distribution image copied one directory tree up\, in \.\.\/dist \[dist. path mirror of origin path\]\.


# DEVELOPMENT HISTORY:

# 2016-06-20 11:47:00 PM
# Bug fix: tagged files in root of dir from which script is run wouldn't create in same dir, and therefore wouldn't get metadata update and move to ../dist/[path]. Corrected relevant code line to:
# cp -f "$SFMFNwithExtension" "./$SFMFNpath""__tagAndDistPrepImage$SFMFNextension"
# .. and modified other relevant lines to have two sets of "" for the target.

# 2016-05-08 01:03:47 PM--2016-05-08 10:35:46 PM
# Bug fixes. Also needs feature of /dist/[path/] copy being named after img. title. got that working but and BUGS FIXED: * not copying to dist/[mirror src path] -- FIXED 05/08/2016 01:23:46 PM * keyword tag items duplicating -- FIXED cause uncertain but found process could build them up or not clear prior ones [how? no prior ones in process I thought?!] until removal of -tagsfromfile @ argument. Remove that argument, and EXIF/IPTC tags fully (instead of partially) clear. 19:48:07 PM RAH* somehow echoed ls / dir. items listed in Description field -- FIXED: cause was asterisks used as separators in customImageMetadataTemplate.txt which somehow functioned as a "list everything in this directory" command when called by? . . . something. 03:17:11 PM * redundant file list files and no delete of. EH, WHATEV. * conditional creation of ../dist/$SFMFNpath directory -- DONE 03:28:12 PM * Also found urlencoded strings in metadata prep file lost % sign; found cause is DOS misinterpreting them in metadata update batch; escaped them via %%. FIXED. 10:34:53 PM -RAH

# 2016-05-07
# Feature complete.