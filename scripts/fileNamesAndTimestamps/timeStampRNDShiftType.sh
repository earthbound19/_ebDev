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


# CODE
if [ "$1" ]; then modifyFileType=$1; else printf "\nNo parameter \$1 (file type to randomly shift time stamps for) passed to script. Exit."; exit 1; fi
# timeStampSecondShiftBackMax defaults to 900 (up to 15 minutes ago), but overrides to $2 if $2 is provided.
if [ "$2" ]; then timeStampSecondShiftBackMax=$2; else timeStampSecondShiftBackMax=900; fi
if [ ! "$3" ]; then maxdepthParam="-maxdepth 1"; fi

fileNamesList=($(find . $maxdepthParam -type f -name \*.$modifyFileType -printf "%f\n"))
arrayLength=${#fileNamesList[@]}
count=0
for file in ${fileNamesList[@]}
do
	count=$((count + 1))
	echo "~ file count $count of $arrayLength"
	echo "Modifying time stamp for file $file . . ."
	touch -r $file -d "-$((RANDOM % $timeStampSecondShiftBackMax + 0)) seconds" $file
done

echo DONE randomizing timestamps of all files of type $modifyFileType in the current directory by up to -$timeStampSecondShiftBackMax seconds.