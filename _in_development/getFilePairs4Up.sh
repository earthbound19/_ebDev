echo IN DEVELOPMENT. moved from autobrood repo intending to adapt for broader purposes.
exit
# TO DO
# - Get the script getFilePairs4down working as intended, then adapt this (or moveUp.sh) but for 4 dirs up.


# DESCRIPTION
# Moves matching file names (minus extension) from up to four paths up into the current folder. See USAGE.

# USAGE
# getFilePairs4Up.sh sourceFilesExtension targetFilesToMoveHereExtension
# EXAMPLE: suppose you've got some files named rnd_43aB.png and rnd_44Cd.png in the current path, which you rendered from source files rnd_43aB.flame and rnd43Cd.flame which are scattered one or more directories up from the current path, and that you want to move those matching .flame files into the current path. From the directory with those .png files, invoke this script thusly:
#  getFilePairs4Up.sh png flame
# This will result in all those matching .flame file names being moved from up to four paths above this path into this path. WARNING: if there is more than one of the same file name in different directories, one will clobber the other even if they have different content, without warning.



# CODE
abortScript=0

if [ -z "$1" ]
	then
		echo No paramater 1 passed. Will not run script. See USAGE comment at start of script.
		abortScript=1
	else
	findPairsFor=$1
fi

if [ -z "$2" ]
	then
		echo No paramater 2 passed. Will not run script. See USAGE comment at start of script.
		abortScript=1
	else
	movePairTypesHere=$2
fi

echo findPairsFor value\: $findPairsFor
echo movePairTypesHere value\: $movePairTypesHere

gfind . -maxdepth 1 -iname \*.$findPairsFor > file_list.txt
echo Scanning parent directories \(up to three levels up\) for $movePairTypesHere pairs of type $findPairsFor . . .

while read element
do
	# Trim off extension:
	element=${element%.*}
	# Also trim any ./ off the start of the file name:
	element=`echo $element | sed 's|^./||' | tr -d '\15\32'`
	echo that is $element

	# search up directories and move the applicable file here if it exists:
	if [ -e ../$element.$movePairTypesHere ]
		then
			echo running mv -f ../$element.$movePairTypesHere ./
			mv -f ../$element.$movePairTypesHere ./
	fi
	if [ -e ../../$element.$movePairTypesHere ]
		then
			echo running mv -f ../../$element.$movePairTypesHere ./
			mv -f ../../$element.$movePairTypesHere ./
	fi
	if [ -e ../../../$element.$movePairTypesHere ]
		then
			echo running mv -f ../../../$element.$movePairTypesHere ./
			mv -f ../../../$element.$movePairTypesHere ./
	fi
	if [ -e ../../../../$element.$movePairTypesHere ]
		then
			echo running mv -f ../../../../$element.$movePairTypesHere ./
			mv -f ../../../../$element.$movePairTypesHere ./
	fi
done < file_list.txt

rm ./file_list.txt