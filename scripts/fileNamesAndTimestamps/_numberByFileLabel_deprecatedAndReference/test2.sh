# RENAMING: Create a list of all filenames with these criteria: has _final_ in the filename, but doesn't have a number in the format _nnnnn_ (e.g. _00020_); this will be a list of files to be auto-numbered by this script.
find . -regex '.*' -printf '%T@ %c %p\n' | sort -k 1n,1 -k 7 | cut -d' ' -f2- > filesWithTagAndNoNumber.txt
	# Prune the date stamp info before the paths start:
sed -i 's/.*\ \(\.\/.*\)/\1/g' filesWithTagAndNoNumber.txt
	# DELETE EVERY line that does *not* match the expression \(.*\/\)\(.*_final_.*\) ; re: http://stackoverflow.com/a/9544146
	# NOTE: the [fF] etc groups make the search case-insensitive. There apparently isn't a Cygwin sed option for that.
# sed -i '/.*\/.*_[fF][iI][nN][aA][lL]_.*/!d' filesWithTagAndNoNumber.txt

# !======
# TO DO; fix a problem with that: it matches if the path has _final_ and the filename doesn't; it should only match the filename.
# !======

# sed -i '/.*\/.*_final_.*/!d' filesWithTagAndNoNumber.txt

	# DELETE EVERY line that *matches* the expression .*_[0-9]\{5\}_.* OR e.g. the pattern _00024.png ; or in other words exclude all file names that do not have valid number tags, but other number formats, e.g. .*203.55461.* or .*1280x720.*) :
	# DEPRECATED:
	# sed -i 's/.*\/.*_[0-9]\{5\}_.*//g' filesWithTagAndNoNumber.txt
	# UPGRADED to add support for pattern e.g. _00024.png:
# sed -i 's/.*\/.*_[0-9]\{5\}_.*\|.*_[0-9]\{5\}\.[^0-9]\{1,4\}//g' filesWithTagAndNoNumber.txt

# ? reference to adapt that last? :
# sed -i '/.*\/.*_[0-9]\{5\}_.*\|.*_[0-9]\{5\}\.[^0-9]\{1,4\}/!d' numbersFromFileNames.txt
	# Read those into an array:
	
# Golden ridiculous test sed regex that got me on my way to solving a super hard problem; it isolates _final_ if it appears before a file name (in other words in the path) from _final_ if it appears after the path (in other words in a file name):
# sed 's/\([^\/]*_final_[^\/]*\)\(\/[^\/]*\)/\1~\2/g' testSrc.txt

# NO! All I need to do is look for /.*_final_.* and then a line ending!