# DESCRIPTION: Faster but more patterned variant of randomNSetChars.sh. returns N ($1) characters randomly chosen from hackable string CHARSET. If parameter 1 not provided, a default number is used. Appends to a file rndCharsSuperCollection.txt, because otherwise the terminal (it seems at least on Mac) doesn't wrap and display everything.
# Core function taken from: https://stackoverflow.com/a/26326956/1397555

# USAGE: Run this script with one parameter, being the number of times you want to generate a randomly shuffled group of characters from CHARSET (which you may alter in the code below). CHARSET may be altered to include any characters which the toolset may handle 
# (possibly Unicode). You may repeat characters in CHARSET to make it more likely that
# they will appear, for different pattern types/effects.
# ALSO NOTE that the script by default alters the CHARSET string to be a random subset
# of itself (and thereby randomly change the character of output). To use use the full
# set without alteration, find and comment out the OPTIONAL code block.
# ALSO, see DEPENDENCIES:

# DEPENDENCIES
# A 'nixy environment with seq, shuf, and printf, printf and your file system able to handle
# the block characters or whatever else you might hack into CHARSET.

# LICENSE: I wrote and deed this to the Public Domain 05/04/2016 12:22:51 PM -RAH


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

# Other potentially interesting characters to copy and paste into the CHARSET declaration;
# re https://en.wikipedia.org/wiki/Geometric_Shapes :
# ■□▢▣▤▥▦▧▨▩▪▫▬▭▮▯▰▱▲△▴▵▶▷▸▹►▻▼▽▾▿◀◁◂◃◄◅◆◇◈◉◊○◌◍◎●◐◑◒◓◔◕◖◗◘◙◚◛◜◝◞◟◠◡◢◣◤◥◦◧◨◩◪◫◬◭◮◯◰◱◲◳◴◵◶◷◸◹◺◻◼◽◾◿
CHARSET="▀▁▂▃▄▅▆▇█▉▊▋▌▍▎▏▐░▒▓▔▕▖▗▘▙▚▛▜▝▞▟■"
STR_LEN=$((${#CHARSET} - 1))
# STR_LEN has a value of CHARSET's length minus one because we will potentially randomly 
# read 1 char starting at the position of length (of the string CHARSET) minus 1. We would 
# probably try to read out of bounds of the array otherwise.

# OPTIONAL: uncomment this next code block if you want to redefine CHARSET as a randomly
# selected subset of itself:
NEW_CHARSET_LEN=`shuf -i 3-$STR_LEN -n 1`
for ELEMENT in $(seq $NEW_CHARSET_LEN)
do
  TMP_NUMBER=`shuf -i 0-$STR_LEN -n 1`
  TMP_CHAR="${CHARSET:$TMP_NUMBER:1}"
  TMP_CHARSET="$TMP_CHARSET$TMP_CHAR"
done
CHARSET=$TMP_CHARSET
STR_LEN=$((${#CHARSET} - 1))

# CORE FUNCTIONALITY:
for ELEMENT in $(seq $N_CHARS_TO_GENERATE)
do
  NUMBER=`shuf -i 0-$STR_LEN -n 1`
  scramble $CHARSET
  printf "$scramble_ret" >> rndCharsSuperCollection.txt
done