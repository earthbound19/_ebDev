# DESCRIPTION: Prepares image metadata text file for insertion into images via exiftool (I forget the command or batch that does that; TO DO: implement that.)

# USAGE: CORRECT. SEE DESCRIPTION. Run this from a cygwin prompt in a directory with images in the directory tree for which you wish to create custom metadata ~_MD_ADDS.txt files which another script will use to set image metadata tags.

# NOTE: cygpath use else err next:
metaDataTemplatePath=`cygpath -u "C:\_devtools\scripts\imgAndVideo\EXIFdataBatch"`
metaDataTemplateFile=customImageMetadataTemplate.txt
metaDataTemplate=$metaDataTemplatePath/$metaDataTemplateFile

find . -iname \*_FINAL*.tif -o -iname \*_FINAL*.tiff -o -iname \*_FINAL*.png -o -iname \*_FINAL*.psd -o -iname \*_FINAL*.ora -o -iname \*_FINAL*.rif -o -iname \*_FINAL*.riff -o -iname \*_FINAL*.jpg -o -iname \*_FINAL*.jpeg -o -iname \*_FINAL*.gif -o -iname \*_FINAL*.bmp -o -iname \*_FINAL*.cr2 -o -iname \*_FINAL*.raw  -o -iname \*_FINAL*.crw -o -iname \*_FINAL*.pdf > imagesMetadataPrepList.txt

find . -iname \*_FINALvar*.tif -o -iname \*_FINALVAR*.tiff -o -iname \*_FINALVAR*.png -o -iname \*_FINALVAR*.psd -o -iname \*_FINALVAR*.ora -o -iname \*_FINALVAR*.rif -o -iname \*_FINALVAR*.riff -o -iname \*_FINALVAR*.jpg -o -iname \*_FINALVAR*.jpeg -o -iname \*_FINALVAR*.gif -o -iname \*_FINALVAR*.bmp -o -iname \*_FINALVAR*.cr2 -o -iname \*_FINALVAR*.raw  -o -iname \*_FINALVAR*.crw -o -iname \*_FINALVAR*.pdf >> imagesMetadataPrepList.txt
				# FORMER CODE:
				# find . -iname \*_FINAL*.tif > imagesMetadataPrepList.txt
				# find . -iname \*_finalvar_*.tif >> imagesMetadataPrepList.txt


# dev reference; for to do the preceding line but with many differtent file types:
# use prefix=\*_FINAL*		~finalvar~			?	;		OR an or regex if poss.?	:
	# find . -iname \*.tif -o -iname \*.tiff -o -iname \*.png -o -iname \*.psd -o -iname \*.ora -o -iname \*.rif -o -iname \*.riff -o -iname \*.jpg -o -iname \*.jpeg -o -iname \*.gif -o -iname \*.bmp -o -iname \*.cr2 -o -iname \*.raw  -o -iname \*.crw -o -iname \*.pdf > imageFilesList.txt
# OR: just list _all_ image files to text file, then reduce it to list _final / _finalvar name-tagged file names only?
# Because all those necessary searches can lead to duplicate listings, sort everything and trim duplicates:
sort imagesMetadataPrepList.txt > temp1.txt
uniq temp1.txt > temp2.txt
	# Remove ./ from start of file li . . neh.
	# sed i- 's/^\.\/\(.*\)/g' temp2.txt
rm imagesMetadataPrepList.txt temp1.txt
mv temp2.txt imagesMetadataPrepList.txt

echo starting metadata prep . . .

currdir=`pwd`
mapfile -t imagesMetadataPrepArray < imagesMetadataPrepList.txt
for element in "${imagesMetadataPrepArray[@]}"
do
		# echo Preparing image metadata from template and image file name $element . . .
					# DEPRECATED, because much as I hate it, putting like-named files into a new subfolder will cause path length errors in windows:
					# imagePath=`expr match "$element" '\(.*\)\/.*'`
					# if [ -a $imagePath/_metadataAdditions ]
		imagePath=`expr match "$element" '\(.*\)\/.*'`
		imageFileNameNoExt=`expr match "$element" '.*\/\(.*\)\..*'`
		metaDataAdditionsTextFile=$imagePath/$imageFileNameNoExt\_MD_ADDS.txt
				# NOTE: the following check previously didn't behave as wanted, because I erroneously checked for $imagePath/$metaDataAdditionsTextFile:
		if [ -a $metaDataAdditionsTextFile ]
		then
			# DO NOT OVERWRITE THE EXISTING FILE
			# der=duh
			echo =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
			echo Would-be newly created metadata additions text file already exists \($metaDataAdditionsTextFile\). Will not overwrite.
		else
			# CREATE AND DO STUFF with the new file
			echo CREATING METADATA PREP FILE $currdir\/$metaDataAdditionsTextFile\ . . .
			# Write file name to text file and alter for human readability via text search-replacements:
			echo $imageFileNameNoExt > temp.txt
				# TO DO: other text replacements besides the following?
				sed -i 's/_[fF][iI][nN][aA][lL]//g' temp.txt
				sed -i 's/_[fF][iI][nN][aA][lL][vV][aA][rR]/Variation of/g' temp.txt
				sed -i 's/FFlib/Filter Forge library/g' temp.txt
				sed -i 's/FF\([0-9]\{1,\}..\)/Filter Forge library \1/g' temp.txt
				sed -i 's/pre\([0-9]\{1,\}\)/preset \1/g' temp.txt
				# Delete any leading whitespace from name field:
				tr '_' ' ' < temp.txt > temp2.txt
				sed -i 's/^\s\{1,\}//g' temp2.txt
					# ALSO WORKS on that last line: ~   [[:space:]]    instead of    \s
				sed -i 's/^[vV][aA][rR] /Variation of /g' temp2.txt
					# Thanks to: http://stackoverflow.com/a/10771857 :
			imagePreparedTitle=$(<temp2.txt)
			echo Title=\"$imagePreparedTitle\" > temp.txt
			# Create stub metadata file using (modified) filename for title and metadata template:
			cat temp.txt $metaDataTemplate > $metaDataAdditionsTextFile
			rm temp.txt temp2.txt
			# So the tag to be added doesn't get munged onto the same line as the last tag:
			printf "\n" >> $metaDataAdditionsTextFile
			echo ImageHistory=\"Exported or copied from master file: $element\" >> $metaDataAdditionsTextFile
			# To open the metadata prep file and corresponding image file in the default programs, to make any necessary metadata prep. changes:
			echo =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
			read -n 1 -p "After you press any key, the metadata text file $metaDataAdditionsTextFile and corresponding image \"$element\" will open. There will be a short pause before it opens. Edit and save the opened prep text file, then close it and the image. Another prompt (if any) will appear here."
			cygstart $element
				# Because delays loading the text file into an editor (COMPUTER SCIENCE?!) can cause image viewer focus problems; force-focus the image for 2 seconds, by way of a pause:
			sleep 2
			cygstart $metaDataAdditionsTextFile
			echo =~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~
		fi
done

# DEVELOPMENT HISTORY:
# BEFORE NOW: SO MANY CODE. SO COMPUTER SCIENCE. SO WOW.
# 2016-04-26 10:27 PM: regex title prep from filename. Add support for many image file types. One-handed programming in broken radius surgery recovery duress. -RAH
