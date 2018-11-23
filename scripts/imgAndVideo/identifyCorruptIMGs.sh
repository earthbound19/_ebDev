# DESCRIPTION
# Deletes all corrupt images of a type ($1) in a path--meaning recursively.

# USAGE
# Invoke this script with one parameter, being an image file extension type without any . in it.

# DEPENDENCIES
# graphicsmagick (gm identify)

# NOTES
# Format of command that will dump any errors to a text file:
# identify 1489.jpg 2> wut.txt


# CODE
if [ ! -d _irrecoverable ]; then mkdir _irrecoverable; fi

array=`gfind . -maxdepth 1 -type f -name "*.$1" -printf '%f\n' | sort`

for filename in ${array[@]}
do
	gm identify $filename 2> "$filename"_identify_log.txt
	blocksUsed=`gstat --format=%b "$filename"_identify_log.txt`
	if [ "$blocksUsed" != "0" ]
		then
			echo $blocksUsed blocks used for error log "$filename"_identify_log.txt\; moving associated file to dir for identifying possible irrepairably corrupted images.
			mv "$filename" ./_irrecoverable
			mv "$filename"_identify_log.txt ./_irrecoverable
	fi
	rm "$filename"_identify_log.txt
done

echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
echo -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
echo FINISHED attempting to identify irrecoverably corrupt image files. All such files have been moved to the new directory \.\/_irrecoverable. You may delete them or inspect them for false negatives.