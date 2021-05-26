# DESCRIPTION
# Find all corrupt images of type $1 in the current directory, and move them into an /_irrecoverable subdirectory for examination.

# DEPENDENCIES
# GraphicsMagick (gm identify)

# USAGE
# Run this script with one parameter, which is an image file extension type without any . in it. For example:
#    identifyCorruptIMGs.sh png
# NOTE
# To dump any errors to a text file from graphicsmagic, run this command:
#
#    gm identify 1489.jpg 2> wut.txt


# CODE
# TO DO: am I doing the same thing as here? And share it there if I am but doing it better: https://www.davidebarranca.com/2018/05/automated-check-for-corrupted-image-files-with-python-and-ImageMagick/
if [ ! -d _irrecoverable ]; then mkdir _irrecoverable; fi

array=($(find . -maxdepth 1 -type f -name "*.$1" -printf '%f\n' | sort))

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

printf "\n\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\n FINISHED attempting to identify irrecoverably corrupt image files. All such files have been moved to the new directory /_irrecoverable for you to inspect."