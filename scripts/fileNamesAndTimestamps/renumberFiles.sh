# DESCRIPTION
# Renames all files of a given extension (via parameter) in the path from which this script is called--renames them to zero-padded numbers matching the number of digit columns of the count of all said files. WARNING: use this only in directories where you actually want _all_ files of the given extension renamed by numbers.

# USAGE
# With this script in your $PATH, invoke it from a terminal, passing it one paramater, being the file extension (without a dot) that you wish for it to operate on, e.g.:
# renumberFiles.sh png

# NOTE: this will choke on file names with console-unfriendly characters e.g. spaces, parenthesis and probably others.

# TO DO? give this script a warning y/n prompt.

find *.$1 > allFiles.txt
arraySize=$(wc -l < allFiles.txt)
numDigitsOf_arraySize=${#arraySize}
mapfile -t allFilesArray < allFiles.txt
rm allFiles.txt

counter=0
for filename in ${allFilesArray[@]}
do
	# echo filename is $filename
	counter=$((counter + 1))
	countString=`printf "%0""$numDigitsOf_arraySize""d\n" $counter`
	echo Executing command\: mv $filename $countString.$1
	echo . . .
	mv $filename $countString.$1
done


# DEVELOPMENT HISTORY
# 07/17/2016 I wish it hadn't taken me a silly half hour (more?) to write this. It used to be it would take much longer, so there's that. -RAH