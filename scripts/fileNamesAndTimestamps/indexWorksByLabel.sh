# DESCRIPTION
# Indexes all text files in a directory tree with a file name of pattern .*_EXPORTED_.*_MD_ADDS.txt (case-sensitive) which contain an EXIF ImageHistory tag containing the string $1 (first parameter to this script). See USAGE for further explanation.

# DEPENDENCIES
# Cygwin (and gsed), Everything search engine CLI (and an install of Everything search engine tool).

# USAGE
# Invoke this script from the root of a directory tree with so many so $1 -patterned text files you wish to index; e.g.:
# ./thisScript.sh earthbound
# The script will write the full path of all file names with the pattern .*_EXPORTED_.*_MD_ADDS.txt which contain the string "earthound" (in an EXIF ImageHistory tag metadata prep. line) to __KEYWORD_MATCHED_WORKS.txt, BY OVERWRITE (the file contents will be replaced). Such file names which do *not* contain that string will be written to __KEYWORD_NOT_MATCHED_WORKS.txt, also by overwrite.
# These files are reference for publishing my art work (determining what to publish next).
# More specifically, it searches for the string:
# -EXIF:ImageHistory=".*publication.*
# -- in all so named text files it finds. 
# NOTE that searches are case-insensitive.
# AN EXAMPLE KEYWORDS documentation file is at _ebArt/MD_ADDS_publication_progress_indexing_keywords.txt

# DEV NOTES
# This is a ghastly mutant of various text processing tools, and tied to the Windows platform (you can find code commented out with "DEPRECATED" comments, code which will make it work on a 'nix platform), but it works.

# TO DO
# - break the deprecated sections out into if blocks that run depending on detected platform (windows or 'nixy system).
# - Index MD_ADDS-~named text file names that do not also have the label _EXPORTED_ (to find and fix up anything so erroneously named). How can I do non-matches with Everything-CLI? There is a general expression option. Use a general expression?


# CODE
label=$1
		# DEPRECATED, use if on non-Windows platform:
		# echo Listing to temp file all files matching pattern \.\*_EXPORTED_.\*_MD_ADDS.txt . . .
		# gfind . -regex .*_EXPORTED_.*_MD_ADDS.txt -type f > _tmp_JnhPUNahaRA5BdZdWx_EXPORTED_works_MD_ADDS_files.txt
# To get the current directory in Windows path form to prefix to the search query for everythingCLI, to avoid matches outside of the current path.
echo Finding all files in this directory tree that match file name pattern \.\*_EXPORTED_.\*_MD_ADDS.txt\, to index . . .
		# tr piped commands re: https://github.com/earthbound19/_ebDev/issues/6
thisDir=`pwd | tr -d '\15\32'`
thisDir=`cygpath -w $thisDir | tr -d '\15\32'`
		# DEPRECATED; resurrect if necessary for a 'nixy system case:
		# Strip any \ char off the end of that (from a root dir it shows, but not in other dirs--we always want it not there) :
thisDir=`echo $thisDir | gsed 's/\(.*\)\\$/\1/g'`
everythingCLI "$thisDir\*_EXPORTED_*_MD_ADDS.txt" > _tmp_4UFKgbkrnpDvZK.txt
		# ALTERNATE which will catch matches outside the directory tree from which this script is run:
		# everythingCLI *_EXPORTED_*_MD_ADDS.txt > _tmp_4UFKgbkrnpDvZK.txt
# else the following tools get gummed up by windows newlines:
dos2unix _tmp_4UFKgbkrnpDvZK.txt
echo Adapting list of found files for processing . . .
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

# TO DO: check that actually echoes the actual characters of the regex? :
echo 'Scanning all files in prepared list for a line matching pattern \-EXIF\:ImageHistory\=\"\.\*\$label \(case-insensitive\)'
echo . . .
# Read the lines in that temp file in a loop, run a grep operation on each file searching for a pattern, and log whether the pattern was found in the two described files:
printf "" > __KEYWORD_MATCHED_WORKS.txt
printf "" > __KEYWORD_NOT_MATCHED_WORKS.txt
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
	# Command that matches the desired pattern, and sets errorlevel as a result to 0 if the pattern is found; the \(.*\)\{0,\} or terminal-escaped (.*){0,} makes anything before $label optional; for cygwin grep it works without that, but it may be technically more accurate, and needed on other platforms? :
	echo executing command\: grep -i "\-EXIF\:ImageHistory=\".*$label" "$element"
	grep -i "\-EXIF\:ImageHistory=\"\(.*\)\{0,\}$label" "$element"
	# After that command, errorlevel will be 0 if a match was found, and 1 if a match was not found. Exploit this. Store state of errorlevel after that command, in a variable:
	thisErrorLevel=`echo $?`
	if [ "$thisErrorLevel" == "0" ]
	then
		echo MATCH\: thisErrorLevel \= \"0\"
		echo $element >> __KEYWORD_MATCHED_WORKS.txt
	else
		echo NO MATCH\: thisErrorLevel \!\= \"0\"
		echo $element >> __KEYWORD_NOT_MATCHED_WORKS.txt
	fi
	
	# echo thisErrorLevel value is $thisErrorLevel
done < _tmp_JnhPUNahaRA5BdZdWx_EXPORTED_works_MD_ADDS_files.txt
exit

rm -f _tmp_JnhPUNahaRA5BdZdWx_EXPORTED_works_MD_ADDS_files.txt _tmp_4UFKgbkrnpDvZK.txt _tmp_f4UvzEv8XXBhju.txt
			# Cleanup of file from now DEPRECATED code:
			# rm tmp_k6wttBxcPAxjXS7j7c6jknrfMxwkuR35x9.txt

echo DONE. Results are in __KEYWORD_MATCHED_WORKS.txt and __KEYWORD_NOT_MATCHED_WORKS.txt in this directory.