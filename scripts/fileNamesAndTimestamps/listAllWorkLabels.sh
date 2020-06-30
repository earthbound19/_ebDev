# DESCRIPTION
# For artwork publication tracking via annotated metadata. Retrieves and lists the EXIF ImageHistory section from the metadata prep field of that name, from all file names of a specific pattern, looking for a specific string, and writes the results to a reference file. See USAGE.

# DEPENDENCIES
# A 'nixy envirnment (e.g. MSYS2 or Cygwin), Everything search engine CLI (and an install of Everything search engine tool), and therefore Windows (unless/until Everything appears on other platforms.

# USAGE
# From a directory with file names of the pattern .*_EXPORTED_.*_MD_ADDS.txt (in the immediate folder and/or subdirectories), invoke this script:
#  listAllWorkLabels.sh
# The script will write the full path of all file names with that pattern in the file name _and_ which contain the string "earthound" (in an EXIF ImageHistory tag metadata prep. line) to __ALL_LABELED_WORKS.txt, then copy the ImageHistory metadata prep text from all those files to __ALL_WORK_LABELS.txt, for parsing and sorting by hand.
# NOTES
# SEARCH PATTERN LIMITATIONS: this expects UPPERCASE_LABELS to to be between the text `-EXIF:ImageHistory=` and `. ` (the ImageHistory tag and a period, then space). If any intended labels are otherwise, they will not be found.

# TO DO
# - Intelligent parsing to extract all UPPERCASE_LABELS?


# CODE
		# echo Finding all files in this directory tree that match file name pattern \.\*_EXPORTED_.\*_MD_ADDS.txt\, to index . . .
		# tr piped commands re: https://github.com/earthbound19/_ebDev/issues/6
thisDir=`pwd | tr -d '\15\32'`
thisDir=`cygpath -w $thisDir | tr -d '\15\32'`
thisDir=`echo $thisDir | gsed 's/\(.*\)\\$/\1/g' | tr -d '\15\32'`
everythingCLI "$thisDir\*_EXPORTED_*_MD_ADDS.txt" > _tmp_hXhsyZvaWb6eXp.txt
		# ALTERNATE which will catch matches outside the directory tree from which this script is run:
		# everythingCLI *_EXPORTED_*_MD_ADDS.txt > _tmp_hXhsyZvaWb6eXp.txt
# else the following tools get gummed up by windows newlines:
dos2unix _tmp_hXhsyZvaWb6eXp.txt
		# echo Adapting list of found files for processing . . .
# This is ghastly. Ugh. The cygpath run in the following loop fails unless windows path characters in the strings are escaped. Ugh. Ugh. I'm so glad I have a DOS escaping tool developed and at hand already for this, though. 11/17/2017 09:23:12 PM -RAH
escapeTextFileString.bat _tmp_hXhsyZvaWb6eXp.txt
# convert all those to unix (cygwin) paths:
printf "" > _tmp_hQAhJTRaGnHef5_EXPORTED_works_MD_ADDS_files.txt
while read element
do
		# echo "$element"
		# ferf=flor
	cygpath -u "$element" >> _tmp_hQAhJTRaGnHef5_EXPORTED_works_MD_ADDS_files.txt
done < _tmp_hXhsyZvaWb6eXp.txt

# TO DO: check that actually echoes the actual characters of the regex? :
		# echo SCANNING ALL FILES in prepared list . .

printf "" >> __ALL_LABELED_WORKS.txt
printf "" >> __ALL_WORK_LABELS.txt
while read element
do
			echo checking file\: $element . . .
			echo ~~~~
	returnStr=`grep '\-EXIF:ImageHistory=".*[A-Z]\{2,\}.*\. ' $element`
			# echo returnStr value is\:
			# echo $returnStr
	# After that command, errorlevel will be 0 if a match was found, and 1 if a match was not found. Exploit this. Store state of errorlevel after that command, in a variable:
	thisErrorLevel=`echo $?`
			# echo errorLevel is\: $thisErrorLevel
	if [ "$thisErrorLevel" == "0" ]
	then
		# echo MATCH\: thisErrorLevel \= \"0\"
		echo $element >> __ALL_LABELED_WORKS.txt
		echo $returnStr >> __ALL_WORK_LABELS.txt
	fi
done < _tmp_hQAhJTRaGnHef5_EXPORTED_works_MD_ADDS_files.txt

# rm ALL THE FILES

echo DONE. Results are in __ALL_LABELED_WORKS.txt and __ALL_WORK_LABELS.txt