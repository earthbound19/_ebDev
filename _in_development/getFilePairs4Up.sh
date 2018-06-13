# IN DEVELOPMENT.

# DESCRIPTION
# Moves matching file names (minus extension) from up to four paths up into the current folder. See USAGE.

# USAGE
# thisScript.sh sourceFilesExtension targetFilesToMoveHereExtension
# EXAMPLE: suppose you've got some files named rnd_43aB.png and rnd_44Cd.png in the current path, which you rendered from source files rnd_43aB.flame and rnd43Cd.flame which are scattered one or more directories up from the current path, and that you want to move those matching .flame files into the current path. From the directory with those .png files, invoke this script thusly:
# thisScript.sh png flame
# This will result in all those matching .flame file names being moved from up to four paths above this path into this path.


# CODE
abortScript=0

if [ -z ${1+x} ]
	then
		echo No paramater 1 passed. Will not run script. See USAGE comment at start of script.
		abortScript=1
	else
	findPairsFor=$1
fi

if [ -z ${2+x} ]
	then
		echo No paramater 2 passed. Will not run script. See USAGE comment at start of script.
		abortScript=1
	else
	movePairTypesHere=$2
fi

echo findPairsFor value\: $findPairsFor
echo movePairTypesHere value\: $movePairTypesHere

exit

find . -maxdepth 1 -iname \*.$imgFormat > imgFiles.txt
echo Scanning parent directories \(up to three levels up\) for corresponding sheep genome files\; also any directory down . . .

while read element
do
	# trim any ./ off the start of the file name; also trim off extension:
	element=`echo $element | sed "s/\.\/\(.*\)\.$imgFormat/\1/g"`
	# echo that is $element
	# search down directories and moving file here if it exists; re a genius breath yon: http://stackoverflow.com/a/37012114
# find ./ -name "$element" -exec mv '{}' './' ';'
# TO DO: fix probs. with that; see comments in fetchGenomesImages.sh

	# search up directories and move the applicable file here if it exists:
	if [ -e ../$element.$searchExt ]
		then
			echo running mv -f ../$element.$searchExt ./
			mv -f ../$element.$searchExt ./
	fi
	if [ -e ../../$element.$searchExt ]
		then
			echo running mv -f ../../$element.$searchExt ./
			mv -f ../../$element.$searchExt ./
	fi
	if [ -e ../../../$element.$searchExt ]
		then
			echo running mv -f ../../../$element.$searchExt ./
			mv -f ../../../$element.$searchExt ./
	fi
	if [ -e ../../../../$element.$searchExt ]
		then
			echo running mv -f ../../../../$element.$searchExt ./
			mv -f ../../../../$element.$searchExt ./
	fi
done < imgFiles.txt

rm ./imgFiles.txt