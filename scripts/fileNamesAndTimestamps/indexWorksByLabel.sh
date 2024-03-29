# DESCRIPTION
# Indexes all text files in a directory tree with a file name of pattern `<anything>_EXPORTED_<anything>_MD_ADDS.txt` (case-sensitive) which contain an EXIF ImageHistory label (or tag or keyword) containing the string $1 (first parameter to this script); it also lists files that do _not_ contain the label--and files that don't contain that label mean a work has yet to have history (is yet to be published e.g. at a web site, the way I use this script). See USAGE for further explanation.

# DEPENDENCIES
# Everything Search Engine CLI (and an install of Everything search engine tool), and therefore Windows, GNU CoreItil ports (probably from MSYS2) including sed

# USAGE
# Run from the root of a directory tree with so many so $1 -patterned text files you wish to index; e.g.:
#    indexWorksByLabel.sh earthbound
# The script will write the full path of all file names with the pattern `<anything>_EXPORTED_<anything>_MD_ADDS.txt` which contain the string "earthbound" (in an EXIF ImageHistory tag metadata prep. line) to `__LABEL_MATCHED_WORKS.txt`, BY OVERWRITE (the file contents will be replaced). Such file names which do *not* contain that string will be written to __LABEL_NOT_MATCHED_WORKS.txt, also by overwrite.
# These files are reference for publishing my art work (determining what to publish next).
# NOTES
# - Searches are case-insensitive.
# - More specifically, it searches for the string `-EXIF:ImageHistory=".*publication.*` in all so-named text files it finds. 
# - The purpose is that I put keywords related to e.g. a web site I published a work at in the ImageHistory metadata tag to indicate that the work has been published at that site; this script helps me collect information from `<anything>_MD_ADDS.txt` files associated with artwork which function as a database of what has been published where. I have a file named `MD_ADDS_publication indexing labels tags keywords.txt` among my own files which lists those. Maybe it should be a public file? A different version of it, I think, used to be . . .


# CODE
# TO DO
# - break the deprecated sections out into if blocks that run depending on detected platform (windows or 'Nixy system).
# - Index MD_ADDS-~named text file names that do not also have the label _EXPORTED_ (to find and fix up anything so erroneously named). How can I do non-matches with Everything-CLI? There is a general expression option. Use a general expression?
label=$1
		# DEPRECATED, use if on non-Windows platform:
		# echo Listing to temp file all files matching pattern \.\*_EXPORTED_.\*_MD_ADDS.txt . . .
		# find . -regex .*_EXPORTED_.*_MD_ADDS.txt -type f > _tmp_JnhPUNahaRA5BdZdWx_EXPORTED_works_MD_ADDS_files.txt
# To get the current directory in Windows path form to prefix to the search query for everything CLI (es.exe), to avoid matches outside of the current path.
echo Finding all files in this directory tree that match file name pattern \.\*_EXPORTED_.\*_MD_ADDS.txt\, to index . . .
		# tr piped commands re: https://github.com/earthbound19/_ebDev/issues/6
thisDir=`pwd | tr -d '\15\32'`
thisDir=`cygpath -w $thisDir | tr -d '\15\32'`
echo $thisDir
		# DEPRECATED; resurrect if necessary for a 'Nixy system case:
		# Strip any \ char off the end of that (from a root dir it shows, but not in other dirs--we always want it not there) :
thisDir=`echo $thisDir | sed 's/\(.*\)\\$/\1/g' | tr -d '\15\32'`
es "$thisDir\*_EXPORTED_*_MD_ADDS.txt" > _tmp_4UFKgbkrnpDvZK.txt
		# ALTERNATE which will catch matches outside the directory tree from which this script is run:
		# es *_EXPORTED_*_MD_ADDS.txt > _tmp_4UFKgbkrnpDvZK.txt
# else the following tools get gummed up by windows newlines:
dos2unix _tmp_4UFKgbkrnpDvZK.txt
echo Adapting list of found files for processing . . .
# This is ghastly. Ugh. The cygpath run in the following loop fails unless windows path characters in the strings are escaped. Ugh. Ugh. I'm so glad I have a DOS escaping tool developed and at hand already for this, though. 11/17/2017 09:23:12 PM -RAH
escapeTextFileString.bat _tmp_4UFKgbkrnpDvZK.txt
# convert all those to Unix (Cygwin) paths:
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
printf "LIST OF Metadata preparation ~_MD_ADDS.txt files that have a label $label match in the ImageHistory field:\n\n" > __LABEL_MATCHED_WORKS.txt
printf "LIST OF Metadata preparation ~_MD_ADDS.txt files that do *not* have a label $label match in the ImageHistory field:\n\n" > __LABEL_NOT_MATCHED_WORKS.txt
while read element
do
			# DEPRECATED on account making list via everything CLI, but may be revived if you use a half-baked "nix" environment on windows using sed which makes windows newlines (ergo half-baked) :
			# element=`echo $element | sed 's/..\(.*\)/\1/g'`
			# stupid workaround for sed producing windows line endings:
			# echo $element > tmp_k6wttBxcPAxjXS7j7c6jknrfMxwkuR35x9.txt
			# dos2unix -q tmp_k6wttBxcPAxjXS7j7c6jknrfMxwkuR35x9.txt
			# element=$( < tmp_k6wttBxcPAxjXS7j7c6jknrfMxwkuR35x9.txt)
	echo checking file\: $element . . .
	echo ~~~~
	# Command that matches the desired pattern, and sets errorlevel as a result to 0 if the pattern is found; the \(.*\)\{0,\} or terminal-escaped (.*){0,} makes anything before $label optional; for Cygwin grep it works without that, but it may be technically more accurate, and needed on other platforms? :
	echo executing command\: grep -i "\-EXIF\:ImageHistory=\".*$label" "$element"
	grep -i "\-EXIF\:ImageHistory=\"\(.*\)\{0,\}$label" "$element"
	# After that command, errorlevel will be 0 if a match was found, and 1 if a match was not found. Exploit this. Store state of errorlevel after that command, in a variable:
	thisErrorLevel=`echo $?`
	if [ "$thisErrorLevel" == "0" ]
	then
		echo MATCH\: thisErrorLevel \= \"0\"
		echo $element >> __LABEL_MATCHED_WORKS.txt
	else
		echo NO MATCH\: thisErrorLevel \!\= \"0\"
		echo $element >> __LABEL_NOT_MATCHED_WORKS.txt
	fi
	
	# echo thisErrorLevel value is $thisErrorLevel
done < _tmp_JnhPUNahaRA5BdZdWx_EXPORTED_works_MD_ADDS_files.txt

rm -f _tmp_JnhPUNahaRA5BdZdWx_EXPORTED_works_MD_ADDS_files.txt _tmp_4UFKgbkrnpDvZK.txt _tmp_f4UvzEv8XXBhju.txt
			# Cleanup of file from now DEPRECATED code:
			# rm tmp_k6wttBxcPAxjXS7j7c6jknrfMxwkuR35x9.txt

echo DONE. Results are in __LABEL_MATCHED_WORKS.txt and __LABEL_NOT_MATCHED_WORKS.txt in this directory.