# DESCRIPTION
# Faster but more patterned variant of randomNSetChars.sh. Prints N ($1) groups of characters randomly chosen from hackable string CHARSET. If parameter 1 not provided, a default number is used. Optionally dynamically makes CHARSET a random subset of itself. Core function taken from: https://stackoverflow.com/a/26326956/1397555

# DEPENDENCIES
# A 'Nixy environment with seq, shuf, and printf, printf and your file system able to handle the block characters or whatever else you might hack into CHARSET.

# KNOWN ISSUES
# On MacOS it may not properly display and wrap printed characters.

# USAGE
# Run with one these parameters:
# - $1 OPTIONAL. The number of groups of characters you want to generate and print from CHARSET (which you may alter in the code). If omitted, a default is used.
# - $2 OPTIONAL. anything, for example the word CHALPUR, which will cause the script to redefine CHARSET (see the declaration and initialization of that variable in the code) as a randomly selected subset of itself.
# - $3 OPTIONAL. A number of seconds (may be decimal) for the system to sleep (wait) between printing groups of characters. Desirable if you want to slow printout down to visually process it and create a scrolling random character noise effect. If you pass anything other than a number for this, you will see errors from the sleep command not knowing what to do with it.
# Examples:
# To generate and print 12 groups of characters randomly chosen from CHARSET, run:
#    randomNsetCharsAlt.sh 12
# To generate and print 100 groups of characters using a random subset of CHARSET, run:
#    randomNsetCharsAlt.sh 100 CHORFL
# To generate and print 15000 groups of characters using a random subset of CHARSET, and wait 0.2 seconds between every print of characters, run:
#    randomNsetCharsAlt.sh 100 CHORFL 0.7
# NOTES
# - CHARSET may be altered in the source code to be any characters which the toolset may handle (which could mean any Unicode characters, depending). See comments in `randomNsetChars.sh` for some ideas.
# - You may repeat characters in CHARSET to make it more likely that they will appear, for different pattern types/effects.
# See the OPTIONAL comment to possibly cause the script to sleep for a set amount of time between prints of character groups.


# CODE
scramble() {
    # $1: string to scramble
    # return in variable scramble_ret
    local a=$1 i
    scramble_ret=
    while((${#a})); do
        ((i=RANDOM%${#a}))
        scramble_ret+=${a:i:1}
        a=${a::i}${a:i+1}
    done
}

# Init N_CHARS_TO_GENERATE from $1 or set defaullt if $1 is not provided:
if [ "$1" ]; then N_CHARS_TO_GENERATE=$1; else N_CHARS_TO_GENERATE=1024; fi

# FOR OTHER POSSIBLE characters to use in superset, see: http://s.earthbound.io/RNDblockChars
CHARSET="▀▁▃▅▇█▋▌▎▏▐░▒▓▔▕▖▗▘▙▚▛▜▝▞▟"
STR_LEN=$((${#CHARSET} - 1))
# STR_LEN has a value of CHARSET's length minus one because we will potentially randomly 
# read 1 char starting at the position of length (of the string CHARSET) minus 1. We would 
# probably try to read out of bounds of the array otherwise.

# if parameter 2 was passed to the script, reassign CHARSET with a random subset of itself:
if [ "$2" ]
then
	NEW_CHARSET_LEN=$(shuf -i 3-$STR_LEN -n 1)
	for ELEMENT in $(seq $NEW_CHARSET_LEN)
	do
	  TMP_NUMBER=$(shuf -i 0-$STR_LEN -n 1)
	  TMP_CHAR="${CHARSET:$TMP_NUMBER:1}"
	  TMP_CHARSET="$TMP_CHARSET$TMP_CHAR"
	done
	CHARSET=$TMP_CHARSET
	STR_LEN=$((${#CHARSET} - 1))
fi

# CORE FUNCTIONALITY:
for ELEMENT in $(seq $N_CHARS_TO_GENERATE)
do
  scramble $CHARSET
  printf $scramble_ret
  # OPTIONAL if $3 passed to script: cause the system to sleep $3 seconds between prints of character groups:
  if [ "$3" ]; then sleep $3; fi
done