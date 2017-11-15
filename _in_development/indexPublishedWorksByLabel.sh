# DESCRIPTION
# Indexes all text files in a directory tree with a file name of pattern _EXPORTED_.*_MD_ADDS (case-sensitive). Such file names which contain the string:
# -EXIF:ImageHistory=".*First publication.*
# -- will be written to _publishedFinalWorks.txt, BY OVERWRITE (the file contents will be replaced). Such file names which do *not* contain that string will be written to _unpublishedFinalWorks.txt, also by overwrite.
# These files are reference for publishing my art work (determining what to publish next).

labelOne=_EXPORTED_

# List all files matching desired pattern and write them to temp file
gfind . -regex .*_EXPORTED_.*_MD_ADDS.txt -type f > _tmp_JnhPUNahaRA5BdZdWx_EXPORTED_works_MD_ADDS_files.txt
exit
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

		# FAIL: if [ -z ${fileLabelNumber+x} ]
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
		echo Highest found number tag among all files in this directory tree is\: $fileLabelNumber
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

