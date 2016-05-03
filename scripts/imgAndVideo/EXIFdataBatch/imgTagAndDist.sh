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
# TO DO: vary the following command by file type.
# e.g.:   exiftool -CommonIFD0= testimg.tif    NECESSARY FOR TIFFS! RE: http://www.sno.phy.queensu.ca/~phil/exiftool/faq.html#Q7
# echo exiftool -CommonIFD0= $exifTagArgs $element


# !=========================
# TEST and code from here:


# retrieve source final master file name from ~MD_ADDS;
# First, retrieve ~MD_ADDS.txt filename from $element (is this redundant?!) :
# echo ==========
# sourceFinalMasterFilename=`echo "$element" | sed 's/.*\(\..\{1,4\}\)\$/\1/g'`
# sed 's/.*\(\..\{1,4\}\)\$/\1/g' $element
# echo $sourceFinalMasterFilename
echo ~~~~~~~~~~
sed 's/.* from master file: \(.*\)/\1/g' $element
# echo yuguy $masterFinalSourceImageFilename
# fileExt=`echo "$filename" | sed 's/.*\(\..\{1,4\}\)\$/\1/g'`
# ImageHistory tag string for filename? UserComment?
# to do if necc.: chnge thse lines to not use disk (I know is way)

	# > insertCustomImageMetadata__tempBatch.bat
# Use any/which? :	
# -@ ARGFILE ?
# -o xmp?
# -X (-xmlFormat) ? :
         # Use ExifTool-specific RDF/XML formatting for console output.
# -q quiet
done