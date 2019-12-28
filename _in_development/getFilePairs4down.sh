echo IN DEVELOPMENT. moved from autobrood repo intending to adapt for broader purposes.
exit

# TO DO: adapt re getFilePairs4up.sh

# USAGE:
# Optional parameter: $1 an image format (e.g. jpg) to scan for. Defaults to png if not present.

if [ "$1" ]
	then
		imgFormat=$1
		echo Paramater 1 passed\, scanning for image format $imgFormat
	else
		imgFormat=png
fi


CygwinFind *.flame > allFiles.txt
CygwinFind *.flam3 >> allFiles.txt

mapfile -t seekIMGfiles < allFiles.txt

for element in ${seekIMGfiles[@]}
do
	# search down directories and moving file here if it exists; re a genius breath yon: http://stackoverflow.com/a/37012114
	# echo ELEMETN VAL IS $element
	# CygwinFind ./ -name "$element" -exec mv '{}' './' ';'
# TO DO: fix possible problem of it finding and attempting to move file onto itself in the path from which this is run (*and/or* in subdirectories)?
# TO DO: fix that that is searching for a .flame file, not an image file.

	# search up directories and move the applicable file here if it exists:
			# echo searching for ../$element.$imgFormat
	if [ -e ../$element.$imgFormat ]
		then
			echo running mv -f ../$element.$imgFormat ./
			mv -f ../$element.$imgFormat ./
	fi
		# echo searching for ../../$element.$imgFormat
	if [ -e ../../$element.$imgFormat ]
		then
			echo running mv -f ../../$element.$imgFormat ./
			mv -f ../../$element.$imgFormat ./
	fi
		# echo searching for ../../../$element.$imgFormat
	if [ -e ../../../$element.$imgFormat ]
		then
			echo running mv -f ../../../$element.$imgFormat ./
			mv -f ../../../$element.$imgFormat ./
	fi
		# echo searching for ../../../../$element.$imgFormat
	if [ -e ../../../../$element.$imgFormat ]
		then
			echo running mv -f ../../../../$element.$imgFormat ./
			mv -f ../../../../$element.$imgFormat ./
	fi
done


rm allFiles.txt