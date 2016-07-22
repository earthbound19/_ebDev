# TO DO: Describe and document usage of this script. It makes a batch file to review for numbering particular files. Files will be number tagged that have a name format including _final_ or _final.{1,4} (the latter regex matching a file extension). Note in the documentation that var = variation, and any file name with a word including the letter group "var" may behave unexpectedly.

# TO DO? Alter the following to use a parameter:
label=abstr

# TO DO? : is the result file name fileNamesWithNumberTags.txt even accurate? Is it actually just file names that have numbers in them? Fix to reflect that if so.

echo NOTE: this batch will NOT tag files that begin with FINAL_, and it will produce errors if you have files with \5\-padded numbers in their name which do not also include the tag _FINAL_ \(case-insensitive\)\. Ensure your files meet these criteria before continuing. ALSO filenames must be properly named with underscores _ instead of spaces\, and also any nnnnn numbers must be surrounded by underscores\, for this to work. To get files nearer to or at that standard\, see the notes at the start of __DigitalImagePress.sh.
# TO DO: update dateByFileName.sh to check for that? Prompt the user to check for that via metamorphose2.exe?

echo Finding files to number by tag . . .

# If a _batchNumbering folder exists, empty, delete it, and recreate it; if it doesn't exist, create it.
# NOTE that this folder will be for a file listing all files in a directory tree (including in subfolders).
if [ -a _batchNumbering ]
	then
		rm -rf _batchNumbering
		sleep 2		# Because the operating system can run slower than this script, in Windows' case ;)
		mkdir _batchNumbering
	else
		mkdir _batchNumbering
fi

# PREPARE A LIST of all files to be tagged by number.
	# print every file (and do not print any folder names isolated), recursively, in the directory this script is run from, also excluding . (to avoid a parsing problem) to a text file, sorting by date, oldest first:
# */ TO DO: make a variant of this script for image, or make a switch that lists only image files.
	# for printf re: http://man7.org/linux/man-pages/man1/find.1.html
	# The following printf include prints the year, month, day, hour, minute, then second of the time the file was last modified [re -printf '%CY %Cm %Cd %CH %CM %CS %p\n'] (does that need %CY@ etc.?) ; followed by a sort of those, oldest first :
	# sort command reference: -k, --key=KEYDEF: sort via a key; KEYDEF gives location and type; KEYDEF is F[.C][OPTS][,F[.C][OPTS]] ; OPTS is one or more single-letter ordering options [bdfgiMhnRrV] ; --sort= WORD: WORD can include -g = general numeric sorting, -r = reverse sort. --parallel=N change number of sort threads. It happens that general numeric sorting sorts dates as I want; oldest first, from years down to seconds and even microseconds. -t _ would make the underscore _ a field separator.
# ALL FILE TYPES OPTION; comment out for use with images:
# find . -type f -regex '\.\/.*' -printf '%TY %Tm %Td %TH %TM %TS %p\n' | sort -g > _batchNumbering/fileNamesWithNumberTags.txt
# ALL USED IMAGE FILE TYPES OPTION; comment out for all files; NOTE: find -regex ".*\.\(xls\|csv\)" format is necessary here, apparently (else it thinks -printf is a parameter to -iname?) ; re: http://unix.stackexchange.com/a/28157/110338 -- also, -iregex makes the search case-insensitive:
find . -type f -iregex '\.\/.*.\(tif\|tiff\|png\|.psd\|ora\|kra\|rif\|riff\|jpg\|jpeg\|gif\|bmp\|cr2\|crw\|pdf\|ptg\)' -printf '%TY %Tm %Td %TH %TM %TS %p\n' | sort -g > _batchNumbering/fileNamesWithNumberTags.txt
	# Heck yeah! That worked! NOTE: that command sorts the file list by date per the need of the purpose of this script. I don't need the date info; printing that info enables a sort switch to so sort it. In the next step I remove the date prints and ./ before file paths.
# TO DO: create a mechanism that imports the file extensions to search for from a more easily modifiable text file, to be used by this and other scripts (like dateByFileName.sh and dateByMetaData.sh).
	# Trim that to a . (the current directory) and the rest of the path (no date info) :
sed -i 's/\([^\/]*\)\(\/.*\)/\.\2/g' ./_batchNumbering/fileNamesWithNumberTags.txt
	# Split that to two files; one is the paths, the other is all the file names after the paths:
sed 's/\(.*\/\)\(.*\)/\1/g' ./_batchNumbering/fileNamesWithNumberTags.txt > ./_batchNumbering/PartA_paths.txt
sed 's/\(.*\/\)\(.*\)/\2/g' ./_batchNumbering/fileNamesWithNumberTags.txt > ./_batchNumbering/PartB_originalFiles.txt
	# Blank out lines in ~B that include the word "variant" (case insensitive, which is what [vV][aA] etc. does) or "variation" or "var", as we need not number those. NOTE that this maintains the same number and order of lines (important for later steps), but simply makes some of the lines which we won't use empty. This clunky but necessary solution (for case-insensitivity) found in this comment: http://stackoverflow.com/questions/4412945/case-insensitive-search-replace-with-sed#comment31685516_4412964
# TO DO? : Eh, I want some way to number them the same as what they are a variant of.
sed -i 's/.*[vV][aA][rR][iI][aA][nN][tT].*//g' ./_batchNumbering/PartB_originalFiles.txt
	# Also blank out lines that include the word "variation" (again case insensitive):
sed -i 's/.*[vV][aA][rR][iI][aA][tT][iI][oO][nN].*//g' ./_batchNumbering/PartB_originalFiles.txt
sed -i 's/.*[vV][aA][rR].*//g' ./_batchNumbering/PartB_originalFiles.txt
	# Blank out lines from ~B which lack the tag _final_ or _final.{1,4} (that last being a regex for file extensions), and NOTE that the form FINAL_remainderOfFileName.tif is *not* supported); or really replace them with a string that tells a future step to delete the whole line, thanks to help re: http://stackoverflow.com/questions/12176026/whats-wrong-with-my-lookahead-regex-in-linux-sed/12178023#12178023
sed -i '/.*_[fF][iI][nN][aA][lL]_.*/! s/.*/NO_NOT_DO_NORTHING_DELETE_THE_LINE_THIS_ENDS_UP_AT_FINALLY_OK_THX_BAI/' ./_batchNumbering/PartB_originalFiles.txt
# SUSPEND PREPARING the list of files to be tagged by number for a while, to . . .


# GET HIGHEST NUMBER TAG--NOTE that this must be done before stripping out the file names that match _final/_final *and* already also have a _nnnnn number tag in a later step (which later step will be do not number already properly number-tagged files); ergo the note above to SUSPEND doing that while we do the following;
	# Note also that the following will not erroneously include other forms of numbers e.g. ..383.99829.png and .._87398x44386.png:
	# Note also the next line is an upgrade from the prior deprecated: sed -i 's/.*\/.*_[0-9]\{5\}_.*\|.*_[0-9]\{5\}\.[^0-9]\{1,4\}//g' ./_batchNumbering/filesWithTagAndNoNumber.txt
# TO DO: put the following note in the documentation: Note also that this necessitates a stub "image" file with the highest used number to be placed in the directory tree in which this script will be executed, in cases where the highest used number would not otherwise be in said tree!
echo Finding highest number tag among all file names in this directory tree . . .
sed '/.*_[0-9]\{5\}_.*\|.*_[0-9]\{5\}\.[^0-9]\{1,4\}/!d' ./_batchNumbering/PartB_originalFiles.txt > ./_batchNumbering/numbersFromFileNames.txt
# Reduce those results to numbers only (no text):
				# BUG FIX 2016-07-21: what are the file naming assumptions for the following? Because if I have a file name like _FINAL_00010_2016_07_07__04_27_34__813340400_and_2016_07_07__04_31_01__597083900_alternate.flam3.png, it extracts the highest number from the first five digits of that last long number in the file name, which is erroneous. I *think* I need it to only match where there's a pattern of numbers, then not numbers--the numbers five characters long? I'm going to re-code with that assumption. So the next line is DEPRECATED, and the line after it is the re-worked one; UNANSWERED QUESTION: do I also require the number to be prefixed with an underscore? I'm going to assume NOT--that I only need the 5-digit number to be preceded and postfixed by non-number characters. ALSO TO DO: variablize (is that a word?!) the 5-digit padding to make it possible for it to be 4, 7, whatever--ANYWAY:
				# sed -i 's/.*_\([0-9]\{5\}\)\(.*\.[^\.]\{1,6\}\)/\1/g' ./_batchNumbering/numbersFromFileNames.txt
sed -i 's/.*[^0-9]\([0-9]\{5\}\)[^0-9].*/\1/g' ./_batchNumbering/numbersFromFileNames.txt
		# 6, because Dessault Systemmes names files *.sldprt and *.sldasm, and I want to consider them too.
	# Put those numbers into an array, and sort it to find the highest one
# mapfile -t numbersArray < ./_batchNumbering/numbersFromFileNames.txt

sort --reverse ./_batchNumbering/numbersFromFileNames.txt > ./_batchNumbering/sortedNumbersTemp.txt
rm ./_batchNumbering/numbersFromFileNames.txt
mv ./_batchNumbering/sortedNumbersTemp.txt ./_batchNumbering/numbersFromFileNames.txt
num=`head -1 ./_batchNumbering/numbersFromFileNames.txt`
if [ -z "$num" ]; then echo !================================!; echo !================================!; echo PROBLEM: no five-digit padded number found among any files. No numbering to be done. Check your files.; echo !================================!; echo !================================!; exit; else echo Highest found number tag among all files in directory is $num; fi
echo Continuing prep of list of files to be numbered . . .
# RESUME PREPARING LIST of files to be numbered (which include the _final tag, but which do *not* have a _nnnnn number tag) ;
	# First delete every line (really set a tag to soon delete it) which includes an _nnnnn number tag (earlier we did this with the _final_ and _final.xyz tag); we only want to rename or number files that don't have it (note that if file naming is done properly, these will have already been deleted along with _final/_final.xyz tags) :
sed -i 's/.*_[0-9]\{5\}_.*\|.*_[0-9]\{5\}\.[^0-9]\{1,6\}/NO_NOT_DO_NORTHING_DELETE_THE_LINE_THIS_ENDS_UP_AT_FINALLY_OK_THX_BAI/g' ./_batchNumbering/PartB_originalFiles.txt
# According to some note I left here and could not any longer decipher and have now deleted, there was a neet at this point to swap out all spaces in filenames with underscores? Irrelevant now, as processes before insist/assure that filenames will never have spaces.
mapfile -t filesToNumberArray < ./_batchNumbering/PartB_originalFiles.txt
	# Wipe the following file if it exists, to prep for recreating it through repeated appendages:
printf "" > ./_batchNumbering/target_fileNames.txt
	# To use at the end of the script for stats:
	oldNum=$num
for fileName in ${filesToNumberArray[@]}
do
		# echo fileName val is $fileName
	if [[ $fileName == NO_NOT_DO_NORTHING_DELETE_THE_LINE_THIS_ENDS_UP_AT_FINALLY_OK_THX_BAI ]]
	then echo NO_NOT_DO_NORTHING_DELETE_THE_LINE_THIS_ENDS_UP_AT_FINALLY_OK_THX_BAI >> ./_batchNumbering/target_fileNames.txt
			# The former code (which would have followed here), num=$(($num + 1)) is DEPRECATED, AS THAT THREW an error; fixed by adapting from from and thanks to yet again one o' the many genius breaths yon: http://unix.stackexchange.com/questions/168674/how-to-iterate-a-zero-padded-integer-in-bash/168686#168686
	else
		# Increment the highest number, to put it in the file rename list:
		num=$(printf %05d "$((10#$num + 1))")
		# The following puts in necessary explicit spacing bewtween the underscores and $num, else it won't interpret the variable; and I take out the spaces after. Surely there's a better way?
		echo $fileName | sed "s/\(.*_[fF][iI][nN][aA][lL]\)\(.*\)/\1_ $label _ $num _\2/g" >> ./_batchNumbering/target_fileNames.txt
	fi
done 
# Remove the inserted spaces created in that loop (most previous comment):
sed -i 's/ //g' ./_batchNumbering/target_fileNames.txt

# CONSTRUCT RENAME command file!
sed 's/\(.*\)/mv "\1"/g' ./_batchNumbering/fileNamesWithNumberTags.txt > ./_batchNumbering/temp1.txt
paste --delimiter='' ./_batchNumbering/PartA_paths.txt ./_batchNumbering/target_fileNames.txt > ./_batchNumbering/temp2.txt
# Delete any resulting trailing space; if that even matters (not tested):
sed -i 's/\(.*\)/ "\1"/g' ./_batchNumbering/temp2.txt
paste --delimiter='' ./_batchNumbering/temp1.txt ./_batchNumbering/temp2.txt > ./_batchNumbering/mv_commands.txt
# Delete all the lines that we don't want to execute (for which the obnoxous NO_NOT_DO.. label has been longstanding) ; re http://stackoverflow.com/questions/5410757/delete-a-line-containing-a-specific-string-using-sed/5410784#5410784
sed -i '/NO_NOT_DO_NORTHING_DELETE_THE_LINE_THIS_ENDS_UP_AT_FINALLY_OK_THX_BAI/d' ./_batchNumbering/mv_commands.txt
# THAT THAR created the batch rename script (to be checked and changed to a .bat script)!

# EVERYTHING ESSENTIAL done!

# PREPARE FILES for user to check for unintended duplicates.
	# Adapted from a genius breath yon: http://unix.stackexchange.com/a/44739
	# Print all files minus extensions to a file via find, a pipe, and sed; if there are any identical file names (minus the extensions) this may be a flag for unintended duplicate files which would result in two erroneous number tag increments:
find | sed 's/\(.*\)\..*/\1/' > ./_batchNumbering/possible_unwanted_duplicates.txt
	# Sort that so that we will actually properly find duplicates, because the later uniq command only uniquefies files that have all duplicate lines adjacent to each other:
	sort ./_batchNumbering/possible_unwanted_duplicates.txt > ./_batchNumbering/erp.txt
	rm ./_batchNumbering/possible_unwanted_duplicates.txt
	mv ./_batchNumbering/erp.txt ./_batchNumbering/possible_unwanted_duplicates.txt
	# Prep a file with instructions, to list duplicates:
echo FOLLOWS a list of paths and filenames without file extensions. There are duplicate file names with different extensions in the given paths for each file. Depending on your workflow, you may want move e.g. web-ready .tif or .png files from different image format masters into an entirely separate /dist directory tree, to keep intended file numbering proper here, thar, then, yet. > ./_batchNumbering/temp1.txt
# Put an empty newline after that so the following appended content will be more legible:
echo >> ./_batchNumbering/temp1.txt
	# Filter that down to only one listing per duplicate line:
uniq -d ./_batchNumbering/possible_unwanted_duplicates.txt > ./_batchNumbering/temp2.txt
	# Delete blank lines from that, and append it to temp2.txt at the same time; adapted re: http://stackoverflow.com/questions/16414410/delete-empty-lines-using-sed
sed -i '/^$/d' ./_batchNumbering/temp2.txt
cat ./_batchNumbering/temp1.txt ./_batchNumbering/temp2.txt > ./_batchNumbering/temp3.txt
mv ./_batchNumbering/temp3.txt ./_batchNumbering/possible_unwanted_duplicates.txt


# PRINT STATISTICS and help messages.
proposedNewlyTaggedFiles=$(printf %05d "$((10#$num - 10#$oldNum))")
proposedNewlyTaggedFiles=$((10#$proposedNewlyTaggedFiles))
echo =====~-=-~-=-~-=-~-=-~-=-~=====
echo DONE. Highest proposed new number tag is $num.
echo There are $proposedNewlyTaggedFiles proposed newly tagged files.
echo =====~-=-~-=-~-=-~-=-~-=-~=====
echo NOTES: Check ./_batchNumbering/possible_unwanted_duplicates.txt for the same.
echo Also examine ./_batchNumbering/mv_commands.txt, and if all the proposed
echo renames in that file are correct, change the extension to .sh, move it up one
echo directory from the ./_batchNumbering subfolder, and run it from the shell
echo \(you may want to delete it or rename it to a .txt file afterward\).
echo If the proposed file name changes in that batch are not correct, find the
echo cause, fix it, and run this script again to generate a new
echo ./_batchNumbering/mv_commands.txt file. You might also get help fixing errors
echo by examining ./_batchNumbering/numbersFromFileNames.txt and
echo ./_batchNumbering/fileNamesWithNumberTags.txt.


# Delete now unecessary files.
rm ./_batchNumbering/temp1.txt ./_batchNumbering/temp2.txt


# 01/24/2016 12:42:00 AM re-check and bugfix session of this batch script DONE. Mind what is left in the TO DO comments.
