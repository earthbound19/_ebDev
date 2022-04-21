# DESCRIPTION
# prints a serialized (not line breaks or other interruptions) hexdump (hex character translation) of every byte of file $1.

# DEPENDENCIES
# xxd, bash

# USAGE
# Run with these parameters:
# - $1 input file name
# - $2 OPTIONAL. break input to newlines at every count of this many bytes (every N bytes). If omitted, the hex data is printed in one string with no newlines or any other interrupting data.
# Example that prints the data of file craft_paper_00006_src.png as hex characters with no newlines or anything else:
#    printHex.sh craft_paper_00006_src.png
# Example that does the same but prints a newline for every 2nd character (byte) :
#    printHex.sh craft_paper_00006_src.png 2
# NOTES
# - For very large files, splitting newlines over a small number of bytes can be very slow.
# - To create an array of bytes split on every 8 bytes of hex values from a source file, call this script like this; eightBytesArray would be the resulting array:
#    eightBytesArray=($(printHex.sh craft_paper_00006_src.png 4))
# - If you want to rejoin all data from that array (perhaps after manipulating it, for example for data bending or glitching purposes) into a string with no other data, for example as a data basis to dump back to a binary file, you can accomplish that this way, with a here-string and command substitution assigning to a variable:
#    longDataString=$(tr -d ' ' <<< ${eightBytesArray[@]})


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 (input file name) passed to script. Exit."; exit 1; else inputFileName=$1; fi

if [ "$2" ]
then
	# check if format of parameter is numeric only via grep; if it is numeric, the result of the grep command will be non-empty; if it is not numeric, the result of the grep command will be empty:
	grepResult=$(grep '^[0-9]\{1,\}$' <<< $2)
	if [ "$grepResult" != "" ]
	then
		bytesToSplitNewlinesOn=$grepResult		# rlly that's just $2 :shrug:
	else
		printf "ERROR: paramater for bytes between newline splits is not numeric. Exit."
		exit 2
	fi
fi

# if bytesToSplitNewlinesOn was not defined (is empty) in parameter checking, don't split on byte count $bytesToSplitNewlinesOn (as it effectively doesn't exist for our purposes). If it was defined, split newlines every $bytesToSplitNewlinesOn bytes:
if [ "$bytesToSplitNewlinesOn" == "" ]
then
	xxd -p $inputFileName | tr -d '\n'
else
	xxd -p $inputFileName | tr -d '\n' | fold -w$bytesToSplitNewlinesOn
fi