# DESCRIPTION: Creates a batch template, mv_commands.txt, to rename files to include a number for abstract art that which create too quickly to easily keep track of by number (which is a problem when I simply name them abstraction_nnnnn :) It does this for all file names that include the name/tag $label (_final_, as scripted, which can be altered by changing this script, or, TO DO: by a parameter passed to this script). The created batch numbers so tagged files by order of last modification (newest last). It decides on a starting number by finding the highest number in the tag format (at this writing) _nnnnn_ (a five-digit number e.g. 00024).

# ! WARNING: For my purposes, do the following before using this script; perhaps TO DO would be update the script to do/warn about this:
## Ensure that every variant, n-digit number tag, and final tag are all _surrounded_ by underscores _. Incorrect naming may result otherwise. This means search for each tag without surrounding underscores and ensure cases where there aren't any are corrected.
## Ensure that no folders have the _final_ tag in their filename! It will mess up numbering if they do! TO DO: Fix that--make the script check for that and not count those cases?

# LICENSE: I wrote this and I release it to the Public Domain. 12/02/2015 06:17:34 PM -RAH


# FIRST NOTES:
# All files must be dos/cygwin prompt-friendly for this to work, e.g. there must not be any spaces in file names, at least. Also place a final_nnnnn.png numbered stub file (from a renamed text file) into the directory you scan for numbering/proposed renaming. DO NOT GIVE IMAGE DIMENSIONS in file names e.g. _final_abstraction_00435_12000x6000px.psd, as that can mess up the file numbering scan (and I haven't yet managed a regex that precludes this problem).

# FILE NAMING RULES for this script to work:
# To tag a file for numbering, add the expression _final_ into the file name.
# Files numbered by tag will match the expressions _nnnnn_ (e.g. _00020_) or e.g. _nnnnn.png, _nnnnn.tif, etc.
# Folders must never have the tag _final_ in their file name.
# It is safe to give file names numbers in forms other than the two given for number labels; it is safe for example to name files ~12000x6000~ or ~202.54321~. HOWEVER, at this writing it doesn't always fail to match those, and to be safe, you should always pad alternate numbers (non-tag numbers) with dashes, e.g. -12000x6000- and -202.54321- -- although actually I don't know whether that even would remedy the problem :(

# KNOWN ISSUES: A limitation of this script at this writing is that it must be copied into the directory for whose subdirectories it is meant to search and work against.

# RELEASE HISTORY:
# 2015-11-27 v0.9 initial release. I'll call it 1.0 when it has documentation sufficient to get anyone besides myself using it :) At this writing, the script must be copied into the directory for which it is intended to run.


## TO DO: Fix whatever causes this to not work as expected against the file names 202.60985_and_202.52834_interpolate.flam3 and 202.60985_and_202.52834_interpolate.jpg.
## TO DO: Pull the unorganized notes out of the deprecated archive and make a sensible readme for fileNumberByLabel.sh.
## TO DO: Log files that caused count increment (re the forsaken .ahk version).
## TO DO: Make this ignore .xml or other files via parameters and/or file extension search list. For that matter, make it search for files (not exclude) the same way.
## TO DO: Make the label alterable via script parameter.
## TO DO: Make this give a log file of files ignored for renaming?
## TO DO: Make this dynamically adaptable to include any possible number of digits for identified and manipulated numbers.
## TO DO? : Handle cases of files where the words mod and tangent are really supposed to be variants? Or just rename those files?
## TO DO: Ensure other tools are using variation in file names, not variant.


# CODE
# FIND HIGHEST tagged number in format [0-9]{5} (five digits)_.
	# GET LIST of all files tagged $label.
	# Adapted from: http://unix.stackexchange.com/a/9249
	# --and from: http://stackoverflow.com/a/23208069
	# --and from (re CASE INSENSITIVE REGEX!):
	# http://alvinalexander.com/blog/post/linux-unix/case-insensitive-file-searching-unix-linux-mac-osx
find . -regex '.*' -printf '%T@ %c %p\n' | sort -k 1n,1 -k 7 | cut -d' ' -f2- > fileNamesWithNumberTags.txt
	# Trim that to only the file names (no paths or date info) :
sed -i 's/.*\/\(.*\)/\1/g' fileNamesWithNumberTags.txt
	# Trim that to only file names with the tag _final_ (no longer paying mind to the path since that was deleted), by deleting lines that do *not* match _final_; the [fF] etc. that follows causes case-insensitive search (the Cygwin sed I use doesn't seem to support that):
sed -i '/.*_[fF][iI][nN][aA][lL]_.*/!d' fileNamesWithNumberTags.txt
	# Trim that to only file names that do *not* include the label variant (without the quote marks) ; by deleting all lines (file names) from the list that match _variant_ (and also search cAse INsenSitiVE):
sed -i 's/.*[vV][aA][rR][iI][aA][nN][tT].*//g' fileNamesWithNumberTags.txt
	# To count, we don't need to worry about exluding file names from the list that don't match the regex _[-09]{5}_, we simply only search for . . . well, reduce all the text to that, for each line. But that must happen only against a list where the file names (not paths) match the regex _final_. Thank you for listening to my jumbled brain.
		# DEPRECATED; explanation follows:
		# Reduce that to only include file names with five-digit numbers; by deleting lines that do *not* match _[0-9]{5}_:
		# sed -i '/.*_[0-9]\{5\}_.*/!d' fileNamesWithNumberTags.txt
		# PROBLEM: That means filenames like e.g. _final_00003.psd (which has a valid number tag) were *not* matched, and therefore the highest number found could be erroneous; also, it would mismatch non-number tags such as in file names like _stub_FINal_image383.99829.png and  _FINal_imageWithWierdNumbers_87398x44386.png
		# SOLUTION: Use also the regex .*_[0-9]\{5\}\.[^0-9]\{1,4\} which will match e.g. _final_00003.psd (with prejudice against any five-letter image format file extensions).
		# COMBINING those, this is the monstrous regex I get, and it works!
sed -i '/.*_[0-9]\{5\}_.*\|.*_[0-9]\{5\}\.[^0-9]\{1,4\}/!d' fileNamesWithNumberTags.txt
	# Reduce that to only the five digit numbers, then read it into an array which will be sorted by highest number:
	# TO DO: Fix the following to 's/.*_\([0-9]\{5\}\)_.*/\1/g'; but that causes problems with e.g. the filename _FINAL_abstraction_00375_-2014-12-10__08.11.18_AM__202.60985_and_202.52834_interpolate-size2560x1920__FFmulti__.tif; fix the preceding code line in this file to solve that problem. DONE. Fixed by adding underscores to the following regex, then after that a regex that strips every line that has underscores. 2015-11-30 -RAH
sed 's/.*_\([0-9]\{5\}\)_.*/\1/g' fileNamesWithNumberTags.txt > numbersFromFileNames.txt
sed -i 's/.*_.*//g' numbersFromFileNames.txt
	# Clean that up to eliminate any resultant blank lines (wouldn't be necessary with a more elegant solution) :
		# TO DO: fix problem that follows? :
		# YES, IT'S RIDICULOUS . . .
		sed -i ':a;N;$!ba;s/\n\n\n\n/\n/g' numbersFromFileNames.txt
		sed -i ':a;N;$!ba;s/\n\n\n/\n/g' numbersFromFileNames.txt
		sed -i ':a;N;$!ba;s/\n\n/\n/g' numbersFromFileNames.txt
		sed -i ':a;N;$!ba;s/\n\n/\n/g' numbersFromFileNames.txt
		sed -i ':a;N;$!ba;s/\n\n/\n/g' numbersFromFileNames.txt
# Put those numbers into an array, and sort it to find the highest one (the sort command could as easily do) :
mapfile -t numbersArray < numbersFromFileNames.txt
# rm numbersFromFileNames.txt
num=00000
for element in ${numbersArray[@]}
do		# echo element value is $element
	if [[ $num < $element ]]
	then		# echo found element val $element is higher than num value $num
		num=$element
	fi
done
echo highest found labeled number is $num.


# RENAMING
	# Create a list of all filenames with these criteria: has _final_ in the filename, but doesn't have a number in the format _nnnnn_ (e.g. _00020_); create a list of files which are tagged to be auto-numbered by this script.
find . -regex '.*' -printf '%T@ %c %p\n' | sort -k 1n,1 -k 7 | cut -d' ' -f2- > filesWithTagAndNoNumber.txt
	# Prune the date stamp info before the paths start:
sed -i 's/.*\ \(\.\/.*\)/\1/g' filesWithTagAndNoNumber.txt
	# DELETE EVERY line that does *not* match the expression \(.*\/\)\(.*_final_.*\) ; re: http://stackoverflow.com/a/9544146
	# NOTE: the [fF] etc groups make the search case-insensitive. There apparently isn't a Cygwin sed option for that.
sed -i '/.*\/.*_[fF][iI][nN][aA][lL]_.*/!d' filesWithTagAndNoNumber.txt
	# DELETE EVERY line that *matches* the expression .*_[0-9]\{5\}_.* OR e.g. the pattern _00024.png ; to include all file names that do not have valid number tags, but do have other number formats, e.g. .*203.55461.* or .*1280x720.* :
		# DEPRECATED; because it doesn't catch cases like _00024.png:
		# sed -i 's/.*\/.*_[0-9]\{5\}_.*//g' filesWithTagAndNoNumber.txt
	# UPGRADED to add support for pattern e.g. _00024.png:
sed -i 's/.*\/.*_[0-9]\{5\}_.*\|.*_[0-9]\{5\}\.[^0-9]\{1,4\}//g' filesWithTagAndNoNumber.txt
# Delete double newlines (empty lines):
		# BLERGH also fix (TO DO):
		sed -i ':a;N;$!ba;s/\n\n\n\n/\n/g' filesWithTagAndNoNumber.txt
		sed -i ':a;N;$!ba;s/\n\n\n/\n/g' filesWithTagAndNoNumber.txt
		sed -i ':a;N;$!ba;s/\n\n/\n/g' filesWithTagAndNoNumber.txt
		sed -i ':a;N;$!ba;s/\n\n/\n/g' filesWithTagAndNoNumber.txt
		sed -i ':a;N;$!ba;s/\n\n/\n/g' filesWithTagAndNoNumber.txt
	# Read those into an array:
mapfile -t filesToNumberArray < filesWithTagAndNoNumber.txt
# rm filesWithTagAndNoNumber.txt
	# Empty the commands file so it can be repopulated:
printf "" > mv_commands.txt
	# RENAME FILES with proper incrementing numbers, conditionally by parameter [which?] passed to script.
oldNum=$num
for fileName in ${filesToNumberArray[@]}
do
	# num=$(($num + 1))		THAT THREW an error; fixed by next line, adapted from and thanks to yet again one o' the many genius breaths yon: http://unix.stackexchange.com/questions/168674/how-to-iterate-a-zero-padded-integer-in-bash/168686#168686
	num=$(printf %05d "$((10#$num + 1))")
		# echo num value is $num
		# echo fileName value is $fileName.
	# The following only works if I have a space before and after the $num variable, so it must be subsequently altered with a sed command to replace those spaces with underscores:
	echo mv \"$fileName\" \"${fileName/_final_/_final_abstraction $num }\" >> mv_commands.txt
	echo >> mv_commands.txt
done
	# RE THE most recent comment:
sed -i 's/\(.*_abstraction\) \([0-9]\{5\}\) \(.*\)/\1_\2_\3/g' mv_commands.txt

# CREATE unintended duplicates check file:
	# Adapted from a genius breath yon: http://unix.stackexchange.com/a/44739
	# Print all files minus extensions to a file via find, a pipe, and sed:
find | sed 's/\(.*\)\..*/\1/' > possible_unwanted_duplicates.txt
	# Prep a file with instructions, to list duplicates:
echo FOLLOWS a list of paths and filenames without file extensions. There are duplicate file names with different extensions in the given paths for each file. Depending on your workflow, you may want move e.g. web-ready .tif or .png files from different image format masters into an entirely separate /dist directory tree, to keep intended file numbering proper here, thar, then, yet. > temp.txt
	# Filter that down to only one listing per duplicate line:
uniq -d ./possible_unwanted_duplicates.txt >> temp.txt
rm possible_unwanted_duplicates.txt
mv temp.txt possible_unwanted_duplicates.txt
proposedNewlyTaggedFiles=$(printf %05d "$((10#$num - 10#$oldNum))")
proposedNewlyTaggedFiles=$((10#$proposedNewlyTaggedFiles))
echo =====~-=-~-=-~-=-~-=-~-=-~=====
echo DONE. Highest proposed new number tag is $num\; or there are $proposedNewlyTaggedFiles proposed newly tagged files.
echo =====~-=-~-=-~-=-~-=-~-=-~=====
echo NOTES: Check possible_unwanted_duplicates.txt for the same. Also examine mv_commands.txt, and if all the proposed renames in that file are correct, change the extension to .sh and run it from the shell. If they are not correct, find the cause, fix it, and run this script again to get a new set of proposed rename commands. You might also get help fixing errors by examining numbersFromFileNames.txt and fileNamesWithNumberTags.txt.