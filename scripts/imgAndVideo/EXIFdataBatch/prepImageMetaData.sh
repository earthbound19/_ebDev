# IN DEVELOPMENT
# MAY NOT bE PRODUCTION READY

metaDataTemplatePath=`cygpath -u "C:\_devtools\scripts\imgAndVideo\EXIFdataBatch"`
metaDataTemplateFile=customImageMetadataTemplate.txt
metaDataTemplate=$metaDataTemplatePath/$metaDataTemplateFile

find . -iname \*_FINAL*.tif > imagesMetadataPrepList.txt
find . -iname \*_finalvar_*.tif >> imagesMetadataPrepList.txt
# Because both of those necessary searches can lead to duplicate listings, sort everything and trim duplicates:
sort imagesMetadataPrepList.txt > temp1.txt
uniq temp1.txt > temp2.txt
rm imagesMetadataPrepList.txt temp1.txt
mv temp2.txt imagesMetadataPrepList.txt
# exit
	# dev reference; for to do the preceding line but with many differtent filea tyeawps:
	# find . -iname \*.tif -o -iname \*.tiff -o -iname \*.png -o -iname \*.psd -o -iname \*.ora -o -iname \*.rif -o -iname \*.riff -o -iname \*.jpg -o -iname \*.jpeg -o -iname \*.gif -o -iname \*.bmp -o -iname \*.cr2 -o -iname \*.raw  -o -iname \*.crw -o -iname \*.pdf > imageFilesList.txt
echo start . . .
currdir=`pwd`
mapfile -t imagesMetadataPrepArray < imagesMetadataPrepList.txt
for element in "${imagesMetadataPrepArray[@]}"
do
	echo Preparing image metadata from template and image file name $element . . .
				# DEPRECATED, because much as I hate it, putting like-named files into a new subfolder will cause path length errors in windows:
				# imagePath=`expr match "$element" '\(.*\)\/.*'`
				# if [ -a $imagePath/_metadataAdditions ]
	imagePath=`expr match "$element" '\(.*\)\/.*'`
	imageFileNameNoExt=`expr match "$element" '.*\/\(.*\)\..*'`
	metaDataAdditionsTextFile=$imagePath/$imageFileNameNoExt\_MD_ADDS.txt
	if [ -a $imagePath/$metaDataAdditionsTextFile ]
	then
		echo CREATE METADATA PREP FILE $currdir\/$metaDataAdditionsTextFile\, as it does not already exist.
# CONTINUE DEBUGGING HERE
			# Create stub metadata file using filename for title and metadata template:
echo Title=\"$imageFileNameNoExt\" > temp.txt
		# BUT for flikr, TITLE field will be filled by IPTC "object name--" does it seriously ignore EXIF Title field?! ;
cat temp.txt $metaDataTemplate > $metaDataAdditionsTextFile
rm temp.txt
		# Else the intended tag for a next line gets munged into the same line:
printf "\n" >> $metaDataAdditionsTextFile
		# To open the metadata prep file and corresponding image file in the default programs, to make any necessary metadata prep. changes:
# cygstart $element
echo "$currdir/$metaDataAdditionsTextFile"
		# read -n 1 "Opening metadata prep text file and corresponding image for reference. Edit and save the prep text file as necessary, then press any key to continue."
	else
		# DO NOT OVERWRITE THE EXISTING FILE--and I'd think that for this control block, by removing the -a and moving else to then it would work the same way, but no. Also, this will break unless there is any actual statement to execute after that then clause (then, there, yet).
		der=duh
		echo METADATA PREP FILE $imagePath/$metaDataAdditionsTextFile ALREADY EXISTS\, so I will not alter it. If you mean to recreate that file then delete it and run this script again.
		# continue
	fi
done

# ECHO exiftool -P -Copyright="Richard Alexander Hall, all rights reserved." -Artist="Richard Alexander Hall"