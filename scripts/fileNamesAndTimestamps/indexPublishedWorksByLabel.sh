# DESCRIPTION
# Indexes all text files in a directory tree with a file name of pattern .*_EXPORTED_.*_MD_ADDS.txt (case-sensitive). Such file names which contain the string:
# -EXIF:ImageHistory=".*First publication.*
# -- will be written to __EXPORTED_PUBLISHED_WORKS.txt, BY OVERWRITE (the file contents will be replaced). Such file names which do *not* contain that string will be written to __EXPORTED_UNPUBLISHED_WORKS.txt, also by overwrite.
# These files are reference for publishing my art work (determining what to publish next).

# DEPENDENCIES
# Gnu core utils, Everything search engine CLI (and an install of Everything search engine tool).

# USAGE
# Invoke this script from the root of a directory tree with so many so name-patterned text files you wish to index; e.g.:
# ./thisScript.sh

# NOTES
# This is a ghastly mutant of various text processing tools, and tied to the Windows platform (you can find code commented out with "DEPRECATED" comments, code which will make it work on a 'nix platform), but it works.

# TO DO
# Parameterize label so I can index works by keyword indicating publication at e.g. Flickr, Diaspora*, or email list. Get sed/gsed stinking case-insensitive search (necessarily) working for that task.
# index MD_ADDS-~named text file names not compliant to pattern standard (to find and fix up anything so erroneously named). How can I do non-matches with Everything CLI? There is a general expression option. Use a general expression?


# CODE
		# DEPRECATED, use if on non-Windows platform:
		# echo Listing to temp file all files matching pattern \.\*_EXPORTED_.\*_MD_ADDS.txt . . .
		# gfind . -regex .*_EXPORTED_.*_MD_ADDS.txt -type f > _tmp_JnhPUNahaRA5BdZdWx_EXPORTED_works_MD_ADDS_files.txt
# To get the current directory in Windows path form to prefix to the search query for everythingCLI, to avoid matches outside of the current path.
thisDir=`pwd`
# Gah. Gergh. Bergh. Bleh.
cygpath -w "$thisDir" > tmp_f4UvzEv8XXBhju.txt
thisDir=$( < tmp_f4UvzEv8XXBhju.txt)
everythingCLI "$thisDir\*_EXPORTED_*_MD_ADDS.txt" > _tmp_4UFKgbkrnpDvZK.txt
		# ALTERNATE which will catch matches outside the directory tree from which this script is run:
		# everythingCLI *_EXPORTED_*_MD_ADDS.txt > _tmp_4UFKgbkrnpDvZK.txt
# else the following tools get gummed up by windows newlines:
dos2unix _tmp_4UFKgbkrnpDvZK.txt
# This is ghastly. Ugh. The cygpath run in the following loop fails unless windows path characters in the strings are escaped. Ugh. Ugh. I'm so glad I have a DOS escaping tool developed and at hand already for this, though. 11/17/2017 09:23:12 PM -RAH
escapeTextFileString.bat _tmp_4UFKgbkrnpDvZK.txt
# convert all those to unix (cygwin) paths:
printf "" > _tmp_JnhPUNahaRA5BdZdWx_EXPORTED_works_MD_ADDS_files.txt
while read element
do
	# echo "$element"
	# ferf=flor
	cygpath -u "$element" >> _tmp_JnhPUNahaRA5BdZdWx_EXPORTED_works_MD_ADDS_files.txt
	# That stinking works with the DOS-escaped "$element". Wow. But yyech.
done < _tmp_4UFKgbkrnpDvZK.txt

printf "" > __EXPORTED_PUBLISHED_WORKS.txt
printf "" > __EXPORTED_UNPUBLISHED_WORKS.txt

echo Scanning all files in this directory tree that match file name pattern \.\*_EXPORTED_.\*_MD_ADDS.txt\, each for a line matching pattern \-EXIF\:ImageHistory\=\"\.\*\[pP\]ublication
echo . . .
# Read the lines in that temp file in a loop, run a grep operation on each file searching for a pattern, and log whether the pattern was found in the two described files:
while read element
do
			# DEPRECATED on account making list via everything CLI, but may be revived if you use a half-baked "nix" environment on windows using gsed which makes windows newlines (ergo half-baked) :
			# element=`echo $element | gsed 's/..\(.*\)/\1/g'`
			# stupid workaround for gsed producing windows line endings:
			# echo $element > tmp_k6wttBxcPAxjXS7j7c6jknrfMxwkuR35x9.txt
			# dos2unix -q tmp_k6wttBxcPAxjXS7j7c6jknrfMxwkuR35x9.txt
			# element=$( < tmp_k6wttBxcPAxjXS7j7c6jknrfMxwkuR35x9.txt)
	echo checking file\: $element . . .
	echo ~~~~
	# Command that matches the desired pattern, and sets errorlevel as a result to 0 if the pattern is found:
	grep '\-EXIF\:ImageHistory=".*[pP]ublication' "$element"
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

rm _tmp_JnhPUNahaRA5BdZdWx_EXPORTED_works_MD_ADDS_files.txt _tmp_4UFKgbkrnpDvZK.txt tmp_f4UvzEv8XXBhju.txt
# rm tmp_k6wttBxcPAxjXS7j7c6jknrfMxwkuR35x9.txt
