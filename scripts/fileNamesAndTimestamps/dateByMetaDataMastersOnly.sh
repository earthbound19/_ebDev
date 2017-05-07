# IN DEVELOPMENT? Figure that out.

# DESCRIPTION: Corrects erroneous creation and moficiation file system timestamps in image files by modifying file system file time stamps from file metadata. Runs on every file in a directory tree from which this script is executed. This is a fix for the problem that file system time stamps for files can be thrown off by e.g. restoring files from backups or copying accross drives. It assumes there is any such useful metadata to correct time stamps from. If there isn't any such metadata, nothing will happen for every respective files this script runs against.

echo BEGINNING correcting of timestamps to match any EXIF data . . .

# TO DO: remove file extensions from the following list which will never contain metadata.
# Another (easier to read and change?) way to do the following: find . -type f -iregex '\.\/.*.\(tif\|tiff\|png\|.psd\|ora\|kra\|rif\|riff\|jpg\|jpeg\|gif\|bmp\|cr2\|crw\|pdf\|ptg\)' -printf '%TY %Tm %Td %TH %TM %TS %p\n' | sort -g > _batchNumbering/fileNamesWithNumberTags.txt
find . -iname \*.tif -o -iname \*.tiff -o -iname \*.psd -o -iname \*.mov -o -iname \*.mp4 -o -iname \*.m4a > dateByImageInfoFilesListTemp.txt
mapfile -t imageFiles < ./dateByImageInfoFilesListTemp.txt
for filename in ${imageFiles[@]}
do
			# echo filename is:
			# echo $filename
			# DEPRECATED FOR FAIL; looks for date information which so far it seems only exists in .psd files, where I know exiftool can extract date modified and date created info:
			# exiv2 -T mv "$filename"
		# NOTES on metadata e.g. shown by exiftool; all of these can be manipulated by exiftool:
# File Modification Date/Time: 2016:09:24 20:37:23+01:00		FileModifyDate; file system's modification date+time
# File Access Date/Time      : 2016:09:24 20:37:23+01:00		Computer file system's access date+time
# File Creation Date/Time    : 2016:09:24 20:37:23+01:00		FileCreateDate; Computer file system's create date+time
# Create Date                : 2016:09:13 05:43:22-06:00		CreateDate; EXIF metadata create date+time, more reliable
# Metadata Date              : 2016:09:13 06:26:04-06:00		Exif access time?
# Modify Date                : 2016:09:13 06:26:04				ModifyDate; EXIF metadata modify date+time, more reliable

	# With thanks to smart folks who wrote at: http://photo.stackexchange.com/a/27246/44663 and http://www.sno.phy.queensu.ca/~phil/exiftool/TagNames/EXIF.html :
	exiftool -overwrite_original "-CreateDate>FileCreateDate" "$filename"
	exiftool -overwrite_original "-ModifyDate>FileModifyDate" "$filename"
done

echo DONE updating image file timestamps to match metadata.

rm ./dateByImageInfoFilesListTemp.txt

# REVISION HISTORY
# v1 Feature complete 01/11/2016 10:48:08 PM -RAH


# DISCARDED (AND DUPLICATE) though potentially useful code/notes:
	# get and filter timestamps of file via exiftool and sed:
# exiftool derp.tif > wut_-32.txt
	# extract file name line to temp file:
# sed -n 's/\(.*File Name.*\)/\1/p' wut_-32.txt > file_name_line.txt
	# reduce to only lines with date stamps of format 2011:11:11 18:11:11+00:00; pruning off the extraneous first part of the line meanwhile:
# sed -i -n 's/\(.*: [0-9]\{4\}:[0-9]\{2\}:[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}.*\)/\1/p' wut_-32.txt
		
	# sort the results, to put the oldest (or "smallest" in a sense) file stamp on the first line:
# sort wut_-32.txt > YA_DIS_TING.txt
# rm wut_-32.txt
	# get first sorted line of file:
# head -n 1 YA_DIS_TING.txt > wut_-32.txt
# rm YA_DIS_TING.txt

	# WILL USE ONE OF THE FOLLOWIGN COMMANDS--A FORM OF THEM ANYWAY:
			# Copies modification time stamp to creation time stamp; re: http://u88.n24.queensu.ca/exiftool/forum/index.php/topic,5007.msg24088.html#msg24088
# ExifTool -overwrite_original "-FileModifyDate>FileCreateDate" tests__erp.tif
		# NOTE that this will work for *any* type of file (apparently), not just images! Exiftool doubles as a more advanced "touch" utility!
	# Visa-versa:
# ExifTool -overwrite_original "-FileCreateDate>FileModifyDate" tests__erp.tif


	# OTHER DEPRECATED DEV NOTES:
	# NOTE that this particular script may only work with Cygwin/windows, as it invokes the Windows shell dir command.
	# ex. output of Windows command dir /T:C erp.tif:
	# ..
	# 09/22/2016  08:12 PM       908,285,548 erp.tif

	# Usage of gnuWin32touch.exe:
	# gnuWin32touch.exe: [OPTION]... FILE...
	# -t option:
	# -t STAMP               use [[CC]YY]MMDDhhmm[.ss] instead of current time


	# exploring:
	# re: http://stackoverflow.com/a/29990643
	# stat -c "%w" erp.tif | cut -d" " -f1
