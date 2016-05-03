echo BEGINNING correcting of timestamps to match any EXIF data . . .

# TO DO: remove file extensions from the following list which will never contain metadata.
# Another (easier to read and change?) way to do the following: find . -type f -iregex '\.\/.*.\(tif\|tiff\|png\|.psd\|ora\|kra\|rif\|riff\|jpg\|jpeg\|gif\|bmp\|cr2\|crw\|pdf\|ptg\)' -printf '%TY %Tm %Td %TH %TM %TS %p\n' | sort -g > _batchNumbering/fileNamesWithNumberTags.txt
find . -iname \*.tif -o -iname \*.tiff -o -iname \*.png -o -iname \*.psd -o -iname \*.ora -o -iname \*.rif -o -iname \*.riff -o -iname \*.jpg -o -iname \*.jpeg -o -iname \*.gif -o -iname \*.bmp -o -iname \*.cr2 -o -iname \*.raw  -o -iname \*.crw -o -iname \*.pdf -o -iname \*.mov -o -iname \*.mp4 -o -iname \*.m4a > dateByImageInfoFilesListTemp.txt

mapfile -t imageFiles < ./dateByImageInfoFilesListTemp.txt
for filename in ${imageFiles[@]}
do
			# echo filename is:
			# echo $filename
			# DEPRECATED FOR FAIL; looks for date information which so far it seems only exists in .psd files, where I know exiftool can extract date modified and date created info:
			# exiv2 -T mv "$filename"
		# NOTES:
		# Correlation of fields displayed \(when you list EXIF data using exiftool)\, relating to time stamps:
		# EXIF "Create Date" means what the EXIF metadata says is the date \(and time\) the file was created.
		# EXIF "File Creation Date/Time" means what time the *computer's file system* says the date was created. By telling EXIFTOOL to modify this, it interprets that as "modify the created date time stamp in the computer's file system." The EXIF "field" to change the file system's file creation date/time is: FileCreateDate
		# EXIF "Modify Date" means what the EXIF metadata says is the date and time the file was last modified.
		# EXIF "File Modification Date/Time" is what the file system says is the last date and time the file was modified \(in the same way as "File Creation Date/Time"\).
	# With thanks to smart folks who wrote at: http://photo.stackexchange.com/a/27246/44663 and http://www.sno.phy.queensu.ca/~phil/exiftool/TagNames/EXIF.html :
	exiftool "-CreateDate>FileCreateDate" "$filename"
	exiftool "-ModifyDate>FileModifyDate" "$filename"
done

echo DONE updating image file timestamps to match metadata.

rm ./dateByImageInfoFilesListTemp.txt

# REVISION HISTORY
# v1 Feature complete 01/11/2016 10:48:08 PM -RAH