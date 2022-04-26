# DESCRIPTION
# Prints the binary values of the data in file $1, with no spaces or newlines or any other information other than the binary digits. Optionally breaks into newlines on every Nth ($2) binary digit.

# DEPENDENCIES
#    xxd

# USAGE
# Run with these parameters:
# - $1 input file name
# - $2 OPTIONAL. break input to newlines at every count of this many bits (every N bits). If omitted, the binary data is printed in one string with no newlines or any other interrupting data.
# Example that prints the data of file inputFile.dat as binary digits with no newlines or anything else:
#    printBinary.sh inputFile.dat
# Example that does the same but prints a newline for every 8th bit (or in other words it splits into newlines on every byte) :
#    printBinary.sh inputFile.dat 8
# NOTES
# - Like many things in bash/Unix, you can pipe the result to a file:
#    printBinary.sh inputFile.dat 8 > inputFileBinaryValues.txt
# - For very large files, splitting newlines over a small number of bits can be very slow.
# - To create an array of bits split on every 8 bytes of binary values from a source file, call this script like this; bytesArray would be the resulting array:
#    bytesArray=($(printBinary.sh inputFile.dat 8))
# - If you want to rejoin all data from that array (perhaps after manipulating it) into a string with no other data, you can accomplish that this way, with a here-string and command substitution assigning to a variable:
#    longDataString=$(tr -d ' ' <<< ${bytesArray[@]})


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (input file name) passed to script. Exit."; exit 1; else inputFileName=$1; fi

if [ "$2" ]
then
	# check if format of parameter 2 is numeric only via grep; if it is numeric, the result of the grep command will be non-empty; if it is not numeric, the result of the grep command will be empty:
	grepResult=$(grep '^[0-9]\{1,\}$' <<< $2)
	if [ "$grepResult" != "" ]
	then
		bitsToSplitNewlinesOn=$grepResult		# rlly that's just $2 :shrug:
	else
		printf "ERROR: paramater for bits between newline splits is not numeric. Exit."
		exit 2
	fi
fi

binaryValues=$(xxd -b $inputFileName | sed 's/[^:]*: \(.*\)  .*/\1/g' | tr -d '[[:space:]]')

# if bitsToSplitNewlinesOn was not defined (is empty) in parameter checking, don't split on byte count $bitsToSplitNewlinesOn (as it effectively doesn't exist for our purposes). If it was defined, split newlines every $bitsToSplitNewlinesOn bytes:
if [ "$bitsToSplitNewlinesOn" == "" ]
then
	printf $binaryValues
else
	fold -w$bitsToSplitNewlinesOn <<< $binaryValues
fi