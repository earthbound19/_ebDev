# DESCRIPTION: returns N ($1) characters randomly chosen from hackable string CHARSET. If parameter 1 not provided, a default number is used.

# USAGE: Run this script with one parameter, being the number of characters desired,
# and pipe the output to a text file, like this:
# ./randomBlockCharsString.sh 48 > block_chars_art.txt
# NOTE that you may alter the declaration of CHARSET to include any characters which
# the toolset may handle (possibly Unicode), including repeating characters in CHARSET
# to make it more likely that they will appear, for different pattern types/effects.
# ALSO NOTE that the script by default alters the CHARSET string to be a random subset
# of itself (and thereby randomly change the character of output). To use use the full
# set without alteration, find and comment out the OPTIONAL code block.
# ALSO, see DEPENDENCIES:

# DEPENDENCIES
# A 'nixy environment with seq, shuf, and printf, printf and your file system able to handle
# the block characters or whatever else you might hack into CHARSET.

# LICENSE: I wrote and deed this to the Public Domain 05/04/2016 12:22:51 PM -RAH


# CODE

# Init N_CHARS_TO_GENERATE from $1 or set defaullt if $1 is not provided:
if [ "$1" ]; then N_CHARS_TO_GENERATE=$1; else N_CHARS_TO_GENERATE=1024; fi

# Other potentially interesting characters to copy and paste into the CHARSET declaration;
# re https://en.wikipedia.org/wiki/Geometric_Shapes :
# ■□▢▣▤▥▦▧▨▩▪▫▬▭▮▯▰▱▲△▴▵▶▷▸▹►▻▼▽▾▿◀◁◂◃◄◅◆◇◈◉◊○◌◍◎●◐◑◒◓◔◕◖◗◘◙◚◛◜◝◞◟◠◡◢◣◤◥◦◧◨◩◪◫◬◭◮◯◰◱◲◳◴◵◶◷◸◹◺◻◼◽◾◿
CHARSET="▀▁▂▃▄▅▆▇█▉▊▋▌▍▎▏▐░▒▓▔▕▖▗▘▙▚▛▜▝▞▟■"
STR_LEN=$((${#CHARSET} - 1))
# STR_LEN has a value of CHARSET's length minus one because we will potentially randomly read 1
# char starting at the position of length (of the string CHARSET) minus 1. We would probably
# try to read out of bounds of the array otherwise.

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
  # for a curious slow terminal effect, pause between character renders:
  # sleep 0.2
  printf "${CHARSET:$NUMBER:1}"
  # printf "${CHARSET:$NUMBER:1}" >> rndCharsSuperCollection.txt
done


# DEV HISTORY:
# - 05/04/2016 12:37:50 PM -RAH Created after seeing these interesting characters in an .nfo;
# coincidentally, just such blocky "noise" suited for what I had wanted at that moment to make!
# - 10/04/good buddy/2016 12:15 PM on lunch at work -RAH updated to find the path of this dir,
# store it in THIS_SCRIPTS_PATH, and invoke it locally to actually make use of blockstring.txt
# - 2019-12-13 09:31 PM Friday completely refactored to use a hard-coded, in-script character
# string which can be hacked for any purpose (to use different characters). Also included
# possible other character references (ha ha) in comment, and an optional code block that alters
# the character set to a random subset of itself (code block commited as used; can be commented out).