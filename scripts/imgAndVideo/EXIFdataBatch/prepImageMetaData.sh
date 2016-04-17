# IF NOT EXIST __metadataAdditions MKDIR __metadataAdditions

# TO DO: make this adaptable for situations without label tags; e.g. no "abstraction" word in the file name--via switches?

# NOTE: This will fail to create an __metadataAdditions subfolder in the root folder from which this script is run (if that would be expected), but in my workflow that should never be expected.


# Custom pre-prepared template metadata to combine with gibberish/caption source metadata; path and file name;
# Between the following double quotes, paste the Windows path to your custom image metadata template file:
metaDataTemplatePath=`cygpath -u "C:\_devtools\scripts\imgAndVideo\EXIFdataBatch"`
# For the following variable, give the file name of your custom image metadata template file:
metaDataTemplateFile=customImageMetadataTemplate.txt
# metaDataTemplate=$metaDataTemplatePath/$metaDataTemplateFile
metaDataTemplate=$metaDataTemplatePath/$metaDataTemplateFile

find . -iname \*_FINAL*.tif > imagesMetadataPrepList.txt
find . -iname \*_finalvar_*.tif >> imagesMetadataPrepList.txt
# Because both of those necessary searches can lead to duplicate listings, sort everything and trim duplicates:
sort imagesMetadataPrepList.txt > temp1.txt
uniq temp1.txt > temp2.txt
rm imagesMetadataPrepList.txt temp1.txt
mv temp2.txt imagesMetadataPrepList.txt
	# dev reference; for to do the preceding line but with many differtent filea tyeawps:
	# find . -iname \*.tif -o -iname \*.tiff -o -iname \*.png -o -iname \*.psd -o -iname \*.ora -o -iname \*.rif -o -iname \*.riff -o -iname \*.jpg -o -iname \*.jpeg -o -iname \*.gif -o -iname \*.bmp -o -iname \*.cr2 -o -iname \*.raw  -o -iname \*.crw -o -iname \*.pdf > imageFilesList.txt

mapfile -t imagesMetadataPrepArray < imagesMetadataPrepList.txt
for element in "${imagesMetadataPrepArray[@]}"
do
	echo Preparing image metadata from template and image file name $element . . .
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
		# BUT for flikr, TITLE field will be filled by IPTC "object name--" does it seriously ignore EXIF Title field?! ;
		cat temp.txt $metaDataTemplate > $metaDataAdditionsTextFile
		# Else the intended tag for a next line gets munged into the same line:
		printf "\n" >> $metaDataAdditionsTextFile
	fi
done

# ECHO exiftool -P -Copyright="Richard Alexander Hall, all rights reserved." -Artist="Richard Alexander Hall"