# DESCRIPTION
# Renames all files of a given extension (via parameter) in the path from which this script is called--renames them to zero-padded numbers matching the number of digit columns of the count of all said files. WARNING: use this only in directories where you actually want _all_ files of the given extension renamed by numbers.

# USAGE
# With this script in your $PATH, invoke it from a terminal, passing it one paramater, being the file extension (without a dot) that you wish for it to operate on, e.g.:
# renumberFiles.sh png

# NOTE: this will choke on file names with console-unfriendly characters e.g. spaces, parenthesis and probably others.

# TO DO? give this script a warning y/n prompt.
# TO DO? Make the option to move all renamed files in the path to the root folder this is invoked from a parameter option?

echo Hi persnonzez!!!!!!!!!!!!!!! HI!! -Nem

# find *.$1 > allFiles.txt

	# OPTIONAL variation that renames all files of given extension *recursively--* WARNING; it moves all of them into whatever path root this is invoked from:
	find $directory -type f -name "*.$1" > allFiles.txt

# WORKAROUND for that or other versions of echo sometimes throwing in unwanted \r characters:
tr -d '\r' < allFiles.txt > wut.txt
rm allFiles.txt
mv wut.txt allFiles.txt
arraySize=$(wc -l < allFiles.txt)
numDigitsOf_arraySize=${#arraySize}

mapfile -t allFilesArray < allFiles.txt
rm allFiles.txt

counter=0
for filename in ${allFilesArray[@]}
do
			# echo filename is\:
			# echo $filename
	counter=$((counter + 1))
	countString=`printf "%0""$numDigitsOf_arraySize""d\n" $counter`
			# echo "mv $filename $countString.$1"
	# echo . . .
	mv $filename $countString.$1
done


# DEVELOPMENT HISTORY
# 2016/07/17 I wish it hadn't taken me a silly half hour (more?) to write this. It used to be it would take much longer, so there's that. -RAH
# 2016/10/12 7:16 PM Fixed bug (via workaround) for echo bug that throws in extra \r charactesr in some situations.