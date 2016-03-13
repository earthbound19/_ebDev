# IF NOT EXIST __metadataAdditions MKDIR __metadataAdditions

# TO DO: make this adaptable for situations without label tags; e.g. no "abstraction" word in the file name--via switches?

# NOTE: This will fail to create an __metadataAdditions subfolder in the root folder from which this script is run (if that would be expected), but in my workflow that should never be expected.

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
		# Do nothing, meaning DO NOT OVERWRITE OR APPEND TO AN EXISTING FILE--and I'd think that for this control block, by removing the -a and moving else to then it would work the same way, but no. Also, this will break unless there is any actual statement to execute after that then clause (then, there, yet).
		stubVar=blergh
	else
				# DEPRECATED, for same reasons noted in earlier similar comment:
				# mkdir $imagePath/_metadataAdditions
		echo Title=\"$imageFileNameNoExt\" > temp.txt
		cat temp.txt customImageMetadataTemplate.txt > $metaDataAdditionsTextFile
		# TO DO: Cat/paste commandshere using pre-generated and edited IAE gib would be the way to make nonsense captions/descriptions; the pre-text would be:
		# Caption="
		# --the mid-text (via paste) would be from the IAE gib text body, and the post-text would be:
		# "
	fi
done

rm temp.txt

# ECHO exiftool -P -Copyright="Richard Alexander Hall, all rights reserved." -Artist="Richard Alexander Hall"