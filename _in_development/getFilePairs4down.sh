echo IN DEVELOPMENT. moved from autobrood repo intending to adapt for broader purposes.
exit
# TO DO
# - Make use of this? http://stackoverflow.com/a/37012114 :
#  find ./ -name "$element" -exec mv '{}' './' ';'
# - Does this even have to be limited to files 4 paths down? Couldn't it just be of arbitrary depth?
# - ALSO, DO NOT CLOBBER FILES. Check for file existence in target path before move, and don't copy to if it exists, and write conflict detail to a log file, and prompt user to examine log file.

# USAGE:
# Optional parameter: $1 an image format (e.g. jpg) to scan for. Defaults to png if not present.

if [ "$1" ]
	then
		imgFormat=$1
		echo Paramater 1 passed\, will operate on files of type $imgFormat
	else
		imgFormat=png
fi

seekIMGfiles=(`find . -type f -name '*.flam3' -printf "%P\n" -o -name '*.flame' -printf "%P\n"`)
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