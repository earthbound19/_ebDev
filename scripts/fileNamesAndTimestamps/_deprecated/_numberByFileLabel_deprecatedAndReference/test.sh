# cygwinFind . -regex '.*_final_.*' -printf '%T@ %c %p\n' | sort -k 1n,1 -k 7 | cut -d' ' -f2- > 1.txt
# sed 's/.*\.\/\(.*\)/\1/g' 1.txt > 2.txt
# sed 's/[\^0-9]/~~__~~__/g' 2.txt > 3.txt
# sed -i 's/.*~~__~~__.*//g' 3.txt > 4.txt
# sed -i ':a;N;$!ba;s/\n\n//g' 4.txt > 5.txt
# sed 's/.*\.\/\(.*\)/\1/g' allFilesWithTag.txt > numbersFromFileNames.txt
# sed -i 's/.*\([0-9]\{5\}\).*/\1/g' numbersFromFileNames.txt
# sed -i 's/[^0-9]//g' numbersFromFileNames.txt
# sed -i 's/\(.*_abstraction\) \([0-9]\{5\}\) \(.*\)/\1_\2_\3/g' mv_commands.sh



# NOTES
# match-replaces all forward slashes:
# sed 's/[\^\/]/~/g' 2.txt
# groups everything before slash with slash, then the second group after the slash:
# sed 's/\(.*\/\)\(.*\)/\1\2/g' 2.txt
# Replaces a lot of non-digit items after the final slash with a tilde:
# echo last test . . .
# sed 's/\(.*\/\)[^0-9]*/\1~/g' 2.txt


# FIND HIGHEST numbered file in format [0-9]{5} (five digits).
# TO DO: Make this dynamically adaptable to include any possible number of digits for identified and manipulated numbers.
cygwinFind . -regex '.*_final_.*' -printf '%T@ %c %p\n' | sort -k 1n,1 -k 7 | cut -d' ' -f2- > allFilesWithTag.txt
	# I actually don't entirely know how that adapted line of code works, so I'm just pruning its output to omit the date stamp information and trim it to the paths and filenames only:
sed 's/.*\.\/\(.*\)/\1/g' allFilesWithTag.txt > filesWith~tag~AndNoNumber.txt
		# Would produce a list of file names without the paths, but it turns out I want the paths:
		# sed 's/.*\/\(.*\)/\1/g' temp2.txt > filesWith~tag~AndNoNumber.txt
	# The following two lines are a nasty cluge around the fact that I haven't found a working sed regex to delete all lines (from a text file) which include any number. TO DO: Fix this so it doesn't delete lines that include a number in a folder name (so, only in anything after the final forward slash / ).
sed 's/[\^0-9]/~~__~~__/g' filesWith~tag~AndNoNumber.txt
sed 's/.*~~__~~__.*//g' filesWith~tag~AndNoNumber.txt
	# Remove all double-newlines (empty lines) ; adapted from a genius breath at: http://stackoverflow.com/a/1252191/1397555
sed -i ':a;N;$!ba;s/\n\n//g' filesWith~tag~AndNoNumber.txt
mapfile -t filesWith_tag_andNoNumber_array < filesWith~tag~AndNoNumber.txt
for fileName in ${filesWith_tag_andNoNumber_array[@]}
do
	der=duh
		# echo element value is $fileName
done

	# FIND HIGHEST numbered file in format [0-9]{5} (five digits).
#	 TO DO: Make this dynamically adaptable to include any possible number of digits for identified and manipulated numbers.
sed 's/.*\.\/\(.*\)/\1/g' allFilesWithTag.txt > numbersFromFileNames.txt
	# rm allFilesWithTag.txt
sed -i 's/.*\([0-9]\{5\}\).*/\1/g' numbersFromFileNames.txt
	# I haven't figured why, but that output can include output that has no numbers in it, which the following removes:
sed -i 's/[^0-9]//g' numbersFromFileNames.txt




# ? : demarks everything after the first / -- to what use? :
# sed 's/\(.*\/\)\(.*[0-9].*\)/\1~_-~-_~\2/g' filesWith~tag~AndNoNumber.txt