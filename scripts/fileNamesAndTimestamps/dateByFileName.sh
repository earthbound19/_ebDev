# DESCRIPTION: developing script; hope to correct the time stamps of files by the name of the files (in cases where the file is so named).
	# List all files matching a specific date file name pattern to a file:
		# SCRIPT DEV; iterations of developed commands:
			# find | sed 's/\(.*20[0-9]\{2\}.[0-9]\{1,2\}.[0-9]\{1,2\}.*\)/\1/g' > matches.txt
		# Then for the following hairy beast, which needs the parenthesis and curly braces escaped in bash:
		# (.*)(20[0-9]{2})(.)([0-9]{1,2})(.)([0-9]{1,2})(.*)
			# find | sed 's/\(.*\)\(20[0-9]\{2\}\)\(.\)\([0-9]\{1,2\}\)\(.\)\([0-9]\{1,2\}\)\(.*\)/\2 \4 \6/g' > matches.txt

# LICENSE: I wrote this from scratch and I release it to the Public Domain. 12/23/2015 11:36:51 PM -RAH

# TO DO: Optional filtering of only specific file types (extensions)? Add parsing/updating of hours/minutes/seconds?

# SCRIPT BEGIN.
echo Creating batch script to update time stamps of all files in this path by parsing any date stamps in file names . . .
# List all files with a matching date pattern of 'yyyy-mm-dd to a file:
		# Rescued again by a genius breath at stackoverflow; to avoid referencing so many capture groups; re: http://stackoverflow.com/a/10993346/1397555
find | sed -n 's/\(.*\)\(20[0-9]\{2\}\)\([^0-9]\{1,2\}\)\([0-9]\{1,2\}\)\([^0-9]\{1,2\}\)\([0-9]\{1,2\}\)\(.*\)/touch -c -t \2 \4 \6 "\1\2\3\4\5\6\7"/p' > _UPDtimeStamp.sh
		# DEPRECATED previous sed-escaped regex for that: (.*\)\(20[0-9]\{2\}\)\(.\)\([0-9]\{1,2\}\)\(.\)\([0-9]\{1,2\}\)\(.*\)

# List all files with a matching date pattern like the previous but including hour, minute and second; being an UBER-MONSTROUS regex with escape sequences; and in-line replace lines that should have that hh:mm:ss so that they do; which produces duplicate lines, which can be removed with the uniq command; with help from: http://stackoverflow.com/a/12007302/1397555 :
sed -i 's/\(.*\)\( ".\/.*20[0-9]\{2\}[^0-9]\{1,2\}[0-9]\{1,2\}[^0-9]\{1,2\}[0-9]\{1,2\}[^0-9]\{1,2\}\)\([0-9]\{2\}\)\([^0-9]\{1,2\}\)\([0-9]\{2\}\)\([^0-9]\{1,2\}\)\([0-9]\{2\}\)\(.*\)/\1 \3 \5 \7\2\3\4\5\6\7\8 /p' _UPDtimeStamp.sh
uniq _UPDtimeStamp.sh > temp.txt
rm _UPDtimeStamp.sh
mv temp.txt _UPDtimeStamp.sh

# Strip the line with _UPDtimeStamp.sh in it from the same file:
sed -i 's/.*_UPDtimeStamp\.sh.*//g' _UPDtimeStamp.sh
# Fix touch timestamp update commands that are in parameter format nnnn n nn
	# The [^0-9] expressions ensure no other numbers are immediately next to the date format match nnnn n[n] n[n]
	# I tried using that in the initial sed expression with no success. ?
sed -i 's/\(.*[^0-9]\)\(20[0-9][0-9] \)\([0-9] \)\([0-9][0-9]\)\([^0-9].*\)/\1\20\3\4\5/g' _UPDtimeStamp.sh

# Fix touch timestamp update commands that are in parameter format nnnn nn n
sed -i 's/\(.*[^0-9]\)\(20[0-9][0-9] \)\([0-9][0-9] \)\([0-9]\)\([^0-9].*\)/\1\2\30\4\5/g' _UPDtimeStamp.sh

# Fix touch timestamp update commands that are in parameter format nnnn n n
sed -i 's/\(.*[^0-9]\)\(20[0-9][0-9] \)\([0-9] \)\([0-9]\)\([^0-9].*\)/\1\20\30\4\5/g' _UPDtimeStamp.sh

# If hour etc. time stamps in file names do not conform to hhmm.ss, the following will fail:
# NEW REGEX HERE . . .

# We used spaces in the date format for parsing, but touch needs them without spaces; modify them thus; first including hh:mm:ss and then again for lines that only have yyyy:mm:dd:
	# Format is  [[cc]yy]MMDDhhmm[.ss] where MM specifies the two-digit numeric month, DD specifies the two-digit numeric day, hh specifies the two-digit numeric hour, mm specifies the two-digit numeric minutes. Optionally ss specifies the two-digit seconds, cc specifies the first two digits of the year, and yy specifies the last two digits of the year; example: -t 200701310846.26 --lifted straight from: https://en.wikipedia.org/wiki/Touch_%28Unix%29
sed -i 's/\(.*20[0-9]\{2\}\) \([0-9]\{2\}\) \([0-9]\{2\}\) \([0-9]\{2\}\) \([0-9]\{2\}\) \([0-9]\{2\}\)\(.*\)/\1\2\3\4\5.\6\7/g' _UPDtimeStamp.sh
sed -i 's/\(.*20[0-9]\{2\}\) \([0-9]\{2\}\) \([0-9]\{2\}\)\(.*\)/\1\2\3\4/g' _UPDtimeStamp.sh

# Execute the file time stamp modification batch, then rename it to a date and time stamped .txt file:
./_UPDtimeStamp.sh
batchTimeStamp=$(date +"%Y%m%d_%H%M%S.%N")
mv _UPDtimeStamp.sh _UPDtimeStamp_executed_$batchTimeStamp-sh.txt

echo DONE correcting file timestamps to match date in filename. The timestamp modification script was executed and then renamed to _UPDtimeStamp_executed_$batchTimeStamp-sh.txt.

# SCRIPT END.

# Unused dev reference:
# while read p
# do
	# echo $p
# done < matches.txt

# RELEASE HISTORY:
# v1.0 02/09/2016 11:08:42 PM First version that works on file name date formats which include yyyy-mm-dd and yyyy-mm-dd-hh-mm-ss, allowing for one or two-digit expressions for mm-dd (but not for hh-mm-ss, because it happens that no name-file-by-date functins that I have used do the latter.) Many revisions prior to this.
