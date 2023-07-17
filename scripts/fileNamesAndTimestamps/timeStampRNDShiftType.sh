# DESCRIPTION
# Touch (update timestamp of) all files in the current directory of type $1 to the timestamp of the file minus a random number of seconds up to $2 seconds ago. For situations where you may want to list file by timestamp and have that mean random list order. Or any other purpose you might have for random time stamp shift. Optionally works on all files of type $1 in all subdirectories also.

# USAGE
# Run with these parameters:
# - $1 file type to operate on without a dot in the extension, e.g. png
# - $2 OPTIONAL. Maximum number of seconds ago to randomly change the timestamp of the file to. For example 600 would be up to ten minutes (60 seconds time 10) ago. If omitted, a default is used (see code check of parameter $2 in script)
# - $3 OPTIONAL. Anything, such as the word YGRDRARD, which will cause the script to operate on all files of type $1 in all subdirectories also. Note that if you use this you must use $2.
# For example, to randomly modify the time stamps of all .png files to the default randomization range, run:
#    timeStampRNDShiftType.sh png
# To do the same and specify a random range of up to 7,200 seconds (or 2 hours) ago, run:
#    timeStampRNDShiftType.sh png 7200
# To do the same operating on all png files in all subdirectories also, run:
#    timeStampRNDShiftType.sh png 7200 YGRDRARD
# NOTES:
# - On Windows, this modifies the Date Modified stamp, which for file sorting purposes you would want to reference after running this script.
# - Because on Windows this changes the Date Modified stamp and leaves other Date stamps untouched, and that drives me a little crazy, you may optionally additionally call toOldestWindowsDateTime.sh on the Date-stamp-updated file to make them all the same as the oldest stamp, by hacking the script to uncomment the line that has that call. Which might after running this be incorrect if the oldest stamp is yet older. Which I'm okay with for my purposes.
# - It's not going to work if you give seconds past 12 digits. So not more than -999,999,999,999 (999 billion +)


# CODE
if [ "$1" ]; then modifyFileType=$1; else printf "\nNo parameter \$1 (file type to randomly shift time stamps for) passed to script. Exit."; exit 1; fi
# timeStampSecondShiftBackMax defaults to 900 (up to 15 minutes ago), but overrides to $2 if $2 is provided.
if [ "$2" ]; then timeStampSecondShiftBackMax=$2; else timeStampSecondShiftBackMax=100000; fi
if [ ! "$3" ]; then maxdepthParam="-maxdepth 1"; fi

fileNamesList=($(find . $maxdepthParam -type f -name \*.$modifyFileType -printf "%P\n"))
arrayLength=${#fileNamesList[@]}
count=0
for file in ${fileNamesList[@]}
do
	count=$((count + 1))
	echo "~ file count $count of $arrayLength"
	echo "Modifying time stamp for file $file . . ."
		# deprecated alternate explored when I wondered if `$((RANDOM % ..` wasn't working:
		# rndSHIFT=$(shuf -i 3-$timeStampSecondShiftBackMax -n 1)
		# touch -r $file -d "-$rndSHIFT seconds" $file
	touch -r $file -d "-$((RANDOM % $timeStampSecondShiftBackMax + 0)) seconds" $file
	# OPTIONAL update all timestamps (supposedly) to oldest:
	# toOldestWindowsDateTime.sh $file
done

echo DONE randomizing timestamps of all files of type $modifyFileType in the current directory by up to -$timeStampSecondShiftBackMax seconds.