# DESCRIPTION
# Incremental file number naming by label utility. Finds the highest numbered file having both the phrase _FINAL_ and a five-padded number (nnnnn) in the file name, and renames file names which have _FINAL_ in them but no five-padded numbers; *adding* incremented five-padded numbers to those file names (to number all such _FINAL_ files by incrementing numbers). Handy for incrementally numbering e.g. a lot of new original abstract art work master image file names; or numbering e.g. abstract works.

# TO DO
# - deprecate sections of this relying on slow (not database of a monitored file system driven) 'nix search commands, and use everythingCLI instead (as in indexWorksByLabel.sh).
# - break the deprecated sections out into if blocks that run depending on detected platform (windows or 'nixy system).
# - fix bug where file names which mistakenly have _FINAL_ twice in the name don't register (apparently) as a five-padded number. OR: warn this should never be.
# - determine whether any sed flag will make e.g. _[fF][iI][nN][aA][lL] unecessary as a search pattern (case-insenstitive search). My first searches for this said no . . .
# - In this script, make the following variables actually do anything :) which will mean case-insensitive regexes in sed maybe, or which whuh i dunno? :
# - improve the following description in the line of code starting with 'echo WARNING\:'.


# CODE
labelOne=_FINAL_
labelTwo=_work_

echo ""
echo "WARNING\: This script will produce undesired results if"
echo " any file names in the directory tree you run it from include"
echo " the phrase \"var\", \"variant\", or \"variation\"."
echo " This script will find, and build a script to optionally batch"
echo " rename files for this goal: incrementally number files which"
echo " include the full phrase $labelOne in their file name (it must"
echo " have underscores on both sides of it). The incremental"
echo " numbering will start off the highest found five-padded number"
echo " (format nnnnn) alongside $labelOne *and* the full phrase"
echo " $labelTwo, followed by a five-digit number (e.g."
echo " ""$labelTwo""_00088). ALSO NOTE: filenames must be properly named"
echo " with underscores _ instead of spaces\, and also any nnnnn"
echo " numbers must be surrounded by underscores\, for this to work."
echo " To get files nearer to or at that standard\, see the notes at"
echo " the start of __DigitalImagePress.sh."

PASS_STRING=FLORF

echo "If this is what you want, type:"
echo ""
echo "$PASS_STRING"
echo ""
echo "--and then press ENTER (or return, as the case may be)."
echo "If that is NOT what you want to do, press CTRL+z or CTRL+c,"
echo " or type something else and press ENTER, to terminate this"
echo "script."

read -p "TYPE HERE: " USERINPUT

if [ $USERINPUT == $PASS_STRING ]
then
	echo "User input equals pass string; proceeding."
else
	echo "User input does not equal $PASS_STRING."
	echo "script will exit without doing anything."
	exit
fi


echo Finding files to number by label . . .
if [ -a _batchNumbering ]
	then
		rm -rf _batchNumbering
		sleep 2		# Because the operating system can run slower than this script, in Windows' case ;)
		mkdir _batchNumbering
	else
		mkdir _batchNumbering
fi

# List all files in tree with $labelOne (upper or lowercase or mix) in their file name; also limited to file types we filter for:
gfind . -type f -iname "*_[fF][iI][nN][aA][lL]_*" > _batchNumbering/fileNamesWithLabelOne.txt
# wipe lines that end with file name extensions we don't need to be concerned with:
sed -i 's/.*\.txt//g' _batchNumbering/fileNamesWithLabelOne.txt
sed -i 's/.*\.xml//g' _batchNumbering/fileNamesWithLabelOne.txt
sed -i 's/.*\.ffxml//g' _batchNumbering/fileNamesWithLabelOne.txt
	# NOTE that for determining highest labelTwo count, $labelOne and $labelTwo are both guard-phrases; no file name without *both* those strings will be examined. Now, from fileNamesWithLabelOne.txt, divine the highest five-padded number accompanying the phrase $labelTwo "$labelTwo"00088 (e.g. _work_:00088) :
# strip all files out of that list that have the following regexes; because in my numbering scheme, color and animated etc. variants of a work don't get whole new work number:
sed -i 's/.*[vV][aA][rR][iI][aA][nN][tT].*//g' _batchNumbering/fileNamesWithLabelOne.txt
	# Also blank out lines that include the word "variation" (again case insensitive):
sed -i 's/.*[vV][aA][rR][iI][aA][tT][iI][oO][nN].*//g' _batchNumbering/fileNamesWithLabelOne.txt
sed -i 's/.*[vV][aA][rR].*//g' _batchNumbering/fileNamesWithLabelOne.txt
# delete resulting empty lines (unsure if strictly necessary) :
sed -i '/^\s*$/d' _batchNumbering/fileNamesWithLabelOne.txt

# Reduce fileNamesWithLabelOne.txt to only files that also have the phrase $labelTwo in the file name:
sed -n 's/\(.*_[wW][oO][rR][kK]_.*\)/\1/p' _batchNumbering/fileNamesWithLabelOne.txt > _batchNumbering/fileNamesWithBothLabels.txt 
sed -n 's/.*_[wW][oO][rR][kK]_\([0-9]\{5\}\)_.*/\1/p' _batchNumbering/fileNamesWithBothLabels.txt > _batchNumbering/numbersFromFileNames.txt
sort _batchNumbering/numbersFromFileNames.txt > _batchNumbering/tmp.txt
rm _batchNumbering/numbersFromFileNames.txt
uniq _batchNumbering/tmp.txt > _batchNumbering/numbersFromFileNames.txt
rm _batchNumbering/tmp.txt
	# List all files which have $labelOne in the file name, but which do *not* have $labelTwo; which can be done by concatenating the two found labels lists, sorting them, then reducing the file to all lines which did not have any duplicates (meaning, if there is more than one copy of any line, remove the copies *and* the original line also--or in other words, print only unique lines, re a genius breath yon: http://www.thegeekstuff.com/2013/05/uniq-command-examples).
cat _batchNumbering/fileNamesWithLabelOne.txt _batchNumbering/fileNamesWithBothLabels.txt > _batchNumbering/tmp.txt
sort _batchNumbering/tmp.txt > _batchNumbering/tmp2.txt
uniq -u _batchNumbering/tmp2.txt > _batchNumbering/filesToLabel.txt
rm _batchNumbering/tmp.txt _batchNumbering/tmp2.txt

# Number list has already been sorted such that we can grab the highest number from the end of it:
fileLabelNumber=`tail -1 ./_batchNumbering/numbersFromFileNames.txt`

if [[ $fileLabelNumber == "" ]]
	then
		echo !================================!
		echo !================================!
		echo PROBLEM: no five-digit padded number found among any files. No numbering to be done. Check your files.
		echo !================================!
		echo !================================!
		exit
	else
		echo ================================
		echo Highest found number label among all files in this directory tree is\: $fileLabelNumber
		echo ================================
fi

# Construct a batch that will, if run, rename all the found files with incrementing next-highest numbers for $labelTwo:
timestamp=`date +"%Y_%m_%d__%H_%M_%S__%N"`
builtBatchScript="_batchNumbering/renameBatch_""$timestamp".sh.txt
printf "" > $builtBatchScript
mapfile -t filesToLabel < _batchNumbering/filesToLabel.txt
for element in ${filesToLabel[@]}
do
	fileLabelNumber=$(printf %05d "$((10#$fileLabelNumber + 1))")
		# reference sed command that prints all such files:
		# sed 's/\(.*\)\(_[fF][iI][nN][aA][lL]_\)\(.*\)/\1\2\3/g' filesToLabel.txt
	targetFileName=`echo $element | sed "s/\(.*\)\(_[fF][iI][nN][aA][lL]_\)\(.*\)/\1\2\work_$fileLabelNumber\_\3/g"`
	echo "mv $element $targetFileName" >> $builtBatchScript
done

echo Proposed renames are in the file $builtBatchScript \-\- examine that script and\, if all the proposed renames are correct\, move it up from the _batchNumbering directory to this one\, rename the extension from \.sh.txt to \.sh\, and run that script. You may want to then rename it back to \.sh.txt.
echo The new highest file label number would be\: $fileLabelNumber
echo Boinfliberjeyabe\!


# DEVELOPMENT LOG
# 01/24/2016 12:42:00 AM re-check and bugfix session of this batch script DONE. Mind what is left in the TO DO comments.
# 2017-01-14__06-05-32_AM VERY GREATLY simplified (and made more truly functional as intended, I think) this script. Prior version copied to ./_deprecated/numberFilesByLabel_v0.9.17.sh