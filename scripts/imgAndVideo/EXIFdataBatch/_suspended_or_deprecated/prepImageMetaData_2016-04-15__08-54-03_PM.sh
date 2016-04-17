# REASON THIS VERSION OF THE SCRIPT IS SUSPENDED: Opted to provide a link to made-up postmodern art nonsense statements for images (at a dedicated webunnies page) instead of spamming the web with them. 04/15/2016 08:56:40 PM -RAH

# IF NOT EXIST __metadataAdditions MKDIR __metadataAdditions

# TO DO: make this adaptable for situations without label tags; e.g. no "abstraction" word in the file name--via switches?

# NOTE: This will fail to create an __metadataAdditions subfolder in the root folder from which this script is run (if that would be expected), but in my workflow that should never be expected.

# GIBBERISH OR OTHER GENERATED CAPTION insertion path option:
# NOTE that the two below differ in giving a slash at the end.
# Between the following double quotes, paste the Windows path to your caption source files:
captionSearchPathOne=`cygpath -u "D:\Alex\gibberish\IAE_generatedGibberish\pyMarkovGibbGen\edited"`
# TO DO: PENDING: Also (for another path):
# captionSearchPathTwo=`cygpath -u "D:\Alex\gibberish\IAE_generatedGibberish\pyMarkovGibbGen\edited"`

# Custom pre-prepared template metadata to combine with gibberish/caption source metadata; path and file name;
# Between the following double quotes, paste the Windows path to your custom image metadata template file:
metaDataTemplatePath=`cygpath -u "D:\Alex\Programming\_devtools\scripts\imgAndVideo\EXIFdataBatch"`
# For the following variable, give the file name of your custom image metadata template file:
metaDataTemplateFile=customImageMetadataTemplate.txt
metaDataTemplate=$metaDataTemplatePath/$metaDataTemplateFile

find . -iname \*_FINAL*.tif > imagesMetadataPrepList.txt
find . -iname \*_finalvar_*.tif >> imagesMetadataPrepList.txt
	# dev reference; for to do the preceding line but with many differtent filea tyeawps:
	# find . -iname \*.tif -o -iname \*.tiff -o -iname \*.png -o -iname \*.psd -o -iname \*.ora -o -iname \*.rif -o -iname \*.riff -o -iname \*.jpg -o -iname \*.jpeg -o -iname \*.gif -o -iname \*.bmp -o -iname \*.cr2 -o -iname \*.raw  -o -iname \*.crw -o -iname \*.pdf > imageFilesList.txt

mapfile -t imagesMetadataPrepArray < imagesMetadataPrepList.txt
for element in "${imagesMetadataPrepArray[@]}"
do
				# DEPRECATED, because much as I hate it, putting like-named files into a new subfolder will cause path length errors in windows:
				# imagePath=`expr match "$element" '\(.*\)\/.*'`
				# if [ -a $imagePath/_metadataAdditions ]
	imagePath=`expr match "$element" '\(.*\)\/.*'`
	imageFileNameNoExt=`expr match "$element" '.*\/\(.*\)\..*'`
	metaDataAdditionsTextFile=$imagePath/$imageFileNameNoExt.MD_ADDS.txt
	if [ -a $imagePath/$metaDataAdditionsTextFile ]
	then
			# DO NOT OVERWRITE OR APPEND TO AN EXISTING FILE--and I'd think that for this control block, by removing the -a and moving else to then it would work the same way, but no. Also, this will break unless there is any actual statement to execute after that then clause (then, there, yet).
		echo $imagePath/$metaDataAdditionsTextFile already exists so I will not alter it. If you mean to recreate that file then delete it and run this script again.
	else
				# DEPRECATED, for same reasons noted in earlier similar comment:
				# mkdir $imagePath/_metadataAdditions
			# Create stub metadata file using filename for title and metadata template:
		echo Title=\"$imageFileNameNoExt\" > temp.txt
		cat temp.txt $metaDataTemplate > $metaDataAdditionsTextFile
		# Else the intended tag for a next line gets munged into the same line:
		printf "\n" >> $metaDataAdditionsTextFile
		# ========== BEGIN GIBBERISH CAPTION CREATE ==========
			# search a gibbersource path--copy and paste into the following double quote marks to set (will convert to cygwin path):
				# DEPRECATED development code; moved earlier in this script after testing:
				# captionSearchPathOne=`cygpath -u "D:\Alex\gibberish\IAE_generatedGibberish\pyMarkovGibbGen\edited"`
			# List all files in caption search path into temp.txt, then prune it down to only .txt files:
		ls $captionSearchPathOne/*.txt > temp.txt
		sed -i '/\(\.txt\)/!d' temp.txt
			# Put that into an array:
		mapfile -t gibberishTextFilenamesArray < temp.txt
			# BUG found: if you use a move command that writes the moved file into a folder that did not exist before the move command was issued, cygwin apparently cannot see the newly created folder. If instead you issue a mkdir command beforehand, cygwin will see the new folder and move the file into it properly. Ergo the necessity of the following command block (if else because mkdir throws an error if the folder already exists) :
		if [ -a $captionSearchPathOne/used ]
			then
				# echo A used directory already exists so I will not create it.
				# Do nothing.
				derp=dur
			else
				mkdir $captionSearchPathOne/used
				echo Created used subdirectory because it did not exist.
		fi
		if [ -a ${gibberishTextFilenamesArray[0]} ]
			then
				# Add EXIF caption to EXIFdataPrepTemp.txt, and write all prepared metadata into image file:
				echo found ${gibberishTextFilenamesArray[0]}. Will insert contents of into Caption EXIF tag.
				echo Caption=\" > temp.txt
				echo \" > temp2.txt
					# trim troublesome characters out of ${gibberishTextFilenamesArray[0]} inline, including replacing double newlines with a tilde ~ :
					sed -i 's/\"//g' ${gibberishTextFilenamesArray[0]}
					tr '\t' ' ' < ${gibberishTextFilenamesArray[0]} > derp.txt;	rm ${gibberishTextFilenamesArray[0]}; mv derp.txt ${gibberishTextFilenamesArray[0]}
					sed -i ':a;N;$!ba;s/\n\n/ ~ /g' ${gibberishTextFilenamesArray[0]}
				paste temp.txt ${gibberishTextFilenamesArray[0]} temp2.txt > EXIFdataPrepTemp.txt
				cat $metaDataAdditionsTextFile EXIFdataPrepTemp.txt > temp.txt; rm $metaDataAdditionsTextFile; mv temp.txt $metaDataAdditionsTextFile
				rm EXIFdataPrepTemp.txt temp2.txt
				# cat ___ EXIFdataPrepTemp.txt
				# INSERT THE DATA HERE
				# Archive the used gibberish/caption data so it won't be reused:
				echo \# formerly ${gibberishTextFilenamesArray[0]} \: > header.txt
				cat header.txt ${gibberishTextFilenamesArray[0]} > catHeaderGibText.txt
				rm header.txt
				mv catHeaderGibText.txt "${gibberishTextFilenamesArray[0]}"
				mv "${gibberishTextFilenamesArray[0]}" $captionSearchPathOne/used/$imageFileNameNoExt-caption.txt
				# metaDataAdditionsTextFile
# TO DO: prepend to the gibberish source text file a note about which file the EXIF data was inserted into.
			else
				echo no text file found in $captionSearchPathOne. Aborting script.
				exit
		fi				# This block done, 03/19/2016 01:12:10 AM -RAH
		# ========== END GIBBERISH CAPTION CREATE ==========
	fi
done

# ECHO exiftool -P -Copyright="Richard Alexander Hall, all rights reserved." -Artist="Richard Alexander Hall"