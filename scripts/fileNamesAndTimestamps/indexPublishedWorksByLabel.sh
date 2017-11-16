# DESCRIPTION
# Indexes all text files in a directory tree with a file name of pattern .*_EXPORTED_.*_MD_ADDS.txt (case-sensitive). Such file names which contain the string:
# -EXIF:ImageHistory=".*First publication.*
# -- will be written to __EXPORTED_PUBLISHED_WORKS.txt, BY OVERWRITE (the file contents will be replaced). Such file names which do *not* contain that string will be written to __EXPORTED_UNPUBLISHED_WORKS.txt, also by overwrite.
# These files are reference for publishing my art work (determining what to publish next).

# USAGE
# Invoke this script from the root of a directory tree with so many so name-patterned text files you wish to index; e.g.:
# ./thisScript.sh

# TO DO
# index MD_ADDS-~named text file names not compliant to pattern standard (to find and fix up anything so erroneously named).


# CODE
echo Listing to temp file all files matching pattern \.\*_EXPORTED_.\*_MD_ADDS.txt . . .
gfind . -regex .*_EXPORTED_.*_MD_ADDS.txt -type f > _tmp_JnhPUNahaRA5BdZdWx_EXPORTED_works_MD_ADDS_files.txt
printf "" > __EXPORTED_PUBLISHED_WORKS.txt
printf "" > __EXPORTED_UNPUBLISHED_WORKS.txt

echo Scanning all files in this directory tree that match file name pattern \.\*_EXPORTED_.\*_MD_ADDS.txt\, each for a line matching pattern \-EXIF\:ImageHistory\=\"\.\*\[pP\]ublication
echo . . .
# Read the lines in that temp file in a loop, run a grep operation on each file searching for a pattern, and log whether the pattern was found in the two described files:
while read element
do
	element=`echo $element | gsed 's/..\(.*\)/\1/g'`
		# stupid workaround for gsed producing windows line endings:
		echo $element > glorp_tmp_k6wttBxcPAxjXS7j7c6jknrfMxwkuR35x9.txt
		dos2unix -q glorp_tmp_k6wttBxcPAxjXS7j7c6jknrfMxwkuR35x9.txt
		element=$( < glorp_tmp_k6wttBxcPAxjXS7j7c6jknrfMxwkuR35x9.txt)
	echo checking file\: $element . . .
	# Command that matches the desired pattern, and sets errorlevel as a result to 0 if the pattern is found:
	grep -q '\-EXIF\:ImageHistory=".*[pP]ublication' $element
	# After that command, errorlevel will be 0 if a match was found, and 1 if a match was not found. Exploit this. Store state of errorlevel after that command, in a variable:
	thisErrorLevel=`echo $?`
	if [ "$thisErrorLevel" == "0" ]
	then
		echo $element >> __EXPORTED_PUBLISHED_WORKS.txt
	else
		echo $element >> __EXPORTED_UNPUBLISHED_WORKS.txt
	fi
	
	# echo thisErrorLevel value is $thisErrorLevel
done < _tmp_JnhPUNahaRA5BdZdWx_EXPORTED_works_MD_ADDS_files.txt

rm _tmp_JnhPUNahaRA5BdZdWx_EXPORTED_works_MD_ADDS_files.txt glorp_tmp_k6wttBxcPAxjXS7j7c6jknrfMxwkuR35x9.txt

