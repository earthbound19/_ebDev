# DESCRIPTION
# Looks for files named after the pattern .*YYYY.[.]MM.[.]DD.[.]HH.[.]MM.[.]SS and updates their modified date stamps to match. Works on all files from the directory tree from which it is run (recursive). Useful for correcting that information if you have for example restored from backups or copied accross drives (which can cause the file timestamps to be made anew, depending on the file system and/or tool), and if you want to examine files by sort of the date they were _actually_ created or modified, not just copied or restored.

# WARNING
# This script does not prompt to confirm date stamp updates, it just runs them without asking. Use at your own risk.

# USAGE
# Run without any parameter, from a directory tree which you want to so correct the file modified date stamps in:
#    dateByFileName.sh
# NOTE
# This script expects terminal-friendly file names. See ftun.sh.


# CODE
# TO DO
# Optional filtering of only specific file types (extensions)? Add parse/update of hours/minutes/seconds?
echo Creating batch script to update time stamps of all files in this path by parsing any date stamps in file names . . .
# List all files with a matching date pattern of 'yyyy-mm-dd to a file:
		# Rescued again by a genius breath at stackoverflow; to avoid referencing so many capture groups; re: http://stackoverflow.com/a/10993346/1397555
		# touch commands that work:
		# touch -c -t 201405140809 "./_patreon_cropOfFinal_07-18-2014__11-18-21_AM_FINAL_v04_29-703x12-377_300dpi.tif"
		# touch -c -t 201405140809.16 "./_patreon_cropOfFinal_07-18-2014__11-18-21_AM_FINAL_v04_29-703x12-377_300dpi.tif"
		# nested backreference command that works:
		# echo hello | sed 's/\(.*\(ll\).*\)/\1 \2/g'
find . -type f | sed -n 's/\(.*\([0-9]\{4\}\)[^0-9]\{1,2\}\([0-9]\{1,2\}\)[^0-9]\{1,2\}\([0-9]\{1,2\}\)[^0-9]\{1,2\}\([0-9]\{1,2\}\)[^0-9]\{1,2\}\([0-9]\{1,2\}\)[^0-9]\{1,2\}\([0-9]\{1,2\}\).*\)/touch -c -t  \2 \3 \4 \5 \6.\7 "\1"/p' > _UPDtimeStamp.sh
# NOTE: that double-space after the -t flag is intentional (so that there remains a space after later number string processing.

# replace all single-digit space-padded numbers with one zero pad:
sed -i 's/ \([0-9][^0-9]\)/ 0\1/g' _UPDtimeStamp.sh
# remove spaces between numbers:
sed -i 's/ \([0-9]\{2\}\)/\1/g' _UPDtimeStamp.sh

# Execute the file time stamp modification batch, then rename it to a date and time stamped .txt file:
echo Executing ./_UPDtimeStamp.sh . . .
./_UPDtimeStamp.sh
batchTimeStamp=$(date +"%Y%m%d_%H%M%S.%N")
mv _UPDtimeStamp.sh _UPDtimeStamp_executed_$batchTimeStamp-sh.txt

echo DONE correcting file timestamps to match date in filename. The timestamp modification script was executed and then renamed to _UPDtimeStamp_executed_$batchTimeStamp-sh.txt.
# SCRIPT END.


# RELEASE HISTORY
# v1.0 02/09/2016 11:08:42 PM First version that works on file name date formats which include yyyy-mm-dd and yyyy-mm-dd-hh-mm-ss, allowing for one or two-digit expressions for mm-dd (but not for hh-mm-ss, because it happens that no name-file-by-date functions that I have used do the latter.) Many revisions prior to this.
# v1.1 09/25/2016 05:05:03 PM Largely re-wrote, reducing quite a few lines of code to a few, also eliminating so many now irrelevant comments. Script no longer tolerates (if it ever did--I think it didn't work for) file names that don't include the pattern HH.[.]MM.[.]SS.
