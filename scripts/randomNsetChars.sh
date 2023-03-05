# DESCRIPTION
# Returns approximately N ($1) characters randomly chosen from hackable string CHARSET. If parameter 1 not provided, a default number is used. DEPRECATED; use randomNsetChars.py instead: it is far faster, and can write to files.

# DEPENDENCIES
# A 'Nixy environment with seq, shuf, and printf, printf and your file system able to handle the block characters or whatever else you might hack into CHARSET.

# USAGE
# Run this script with one parameter, which is the number of characters desired, and pipe the output to a text file, like this:
#    randomBlockCharsString.sh 800 > block_chars_art.txt
# The script by default prints hard newlines after 72 characters per line. To override that e.g. with 60 characters, provide that as a second parameter:
#    randomBlockCharsString.sh 800 60 > block_chars_art.txt
# NOTES
# - You may alter the declaration of CHARSET to include any characters which the toolset may handle (possibly Unicode), including repeating characters in CHARSET to make it more likely that they will appear, for different pattern types/effects.
# - The script by default alters the CHARSET string to be a random subset of itself (and thereby randomly change the character of output). To use use the full set without alteration, find and comment out the OPTIONAL code block.


# CODE
# Init N_CHARS_TO_GENERATE from $1 or set defaullt if $1 is not provided:
if [ "$1" ]; then N_CHARS_TO_GENERATE=$1; else N_CHARS_TO_GENERATE=1024; fi
if [ "$2" ]; then HARD_NEWLINE_AT_CHARACTER=$2; else HARD_NEWLINE_AT_CHARACTER=72; fi

# COULD USE: BOX DRAWING Unicode block set, re: https://en.wikipedia.org/wiki/Box_Drawing_(Unicode_block)
# ─━│┃┄┅┆┇┈┉┊┋┌┍┎┏┐┑┒┓└┕┖┗┘┙┚┛├┝┞┟┠┡┢┣┤┥┦┧┨┩┪┫┬┭┮┯┰┱┲┳┴┵┶┷┸┹┺┻┼┽┾┿╀╁╂╃╄╅╆╇╈╉╊╋╌╍╎╏═║╒╓╔╕╖╗╘╙╚╛╜╝╞╟╠╡╢╣╤╥╦╧╨╩╪╫╬╭╮╯╰╱╲╳╴╵╶╷╸╹╺╻╼╽╾╿
# A SUBSET OF THAT WHICH I MAY LIKE: ┈┉┊┋┌└├┤┬┴┼╌╍╎╭╮╯╰╱╲╳╴╵╶╷
#
# OR: GEOMETRIC SHAPES Unicode block:
# ■□▢▣▤▥▦▧▨▩▪▫▬▭▮▯▰▱▲△▴▵▶▷▸▹►▻▼▽▾▿◀◁◂◃◄◅◆◇◈◉◊○◌◍◎●◐◑◒◓◔◕◖◗◘◙◚◛◜◝◞◟◠◡◢◣◤◥◦◧◨◩◪◫◬◭◮◯◰◱◲◳◴◵◶◷◸◹◺◻◼◽◾◿
# A SUBSET OF THAT WHICH I MAY LIKE: ▲△◆◇○◌◍◎●◜◝◞◟◠◡◢◣◤◥◸◹◺◿◻◼
#
# OR: MATH OPERATORS block:
# ∀∁∂∃∄∅∆∇∈∉∊∋∌∍∎∏∐∑−∓∔∕∖∗∘∙√∛∜∝∞∟∠∡∢∣∤∥∦∧∨∩∪∫∬∭∮∯∰∱∲∳∴∵∶∷∸∹∺∻∼∽∾∿≀≁≂≃≄≅≆≇≈≉≊≋≌≍≎≏≐≑≒≓≔≕≖≗≘≙≚≛≜≝≞≟≠≡≢≣≤≥≦≧≨≩≪≫≬≭≮≯≰≱≲≳≴≵≶≷≸≹≺≻≼≽≾≿⊀⊁⊂⊃⊄⊅⊆⊇⊈⊉⊊⊋⊌⊍⊎⊏⊐⊑⊒⊓⊔⊕⊖⊗⊘⊙⊚⊛⊜⊝⊞⊟⊠⊡⊢⊣⊤⊥⊦⊧⊨⊩⊪⊫⊬⊭⊮⊯⊰⊱⊲⊳⊴⊵⊶⊷⊸⊹⊺⊻⊼⊽⊾⊿⋀⋁⋂⋃⋄⋅⋆⋇⋈⋉⋊⋋⋌⋍⋎⋏⋐⋑⋒⋓⋔⋕⋖⋗⋘⋙⋚⋛⋜⋝⋞⋟⋠⋡⋢⋣⋤⋥⋦⋧⋨⋩⋪⋫⋬⋭⋮⋯⋰⋱⋲⋳⋴⋵⋶⋷⋸⋹⋺⋻⋼⋽⋾⋿
# A SUBSET OF THAT WHICH I MAY LIKE: ∧∨∩∪∴∵∶∷∸∹∺⊂⊃⊏⊐⊓⊔⊢⊣⋮⋯⋰⋱
# There's also a Commodore 64 character set, PETSCII, an Atari one, etc..
# Or + Apple-supported emoji:
# 🔴🟠🟡🟢🔵🟣🟤⚫️⚪️🔸🔷🔸🔹◆◇♦️💠♢❖♦⃟⋄◈⟐⟡⧰⟢⟣⤝⤞⤟⤠⧪⧰⧱⬖⬗⬘⬙⬥⬦⬩⛋▬▭▮✷✸⋉⋊▯⤳⬿⳻⳺⨲⋋⋌⌧🔺🔻⏃⏄⏅▲△▴▵▷▸▹▼▽▾▿◁▶◀ːˑ∺≋≎≑≣⊪⊹⊿┄┆┅┇◂◃◢◣◤◥◬◭☱☰◿◺◹◸◮☲☳☴☵☶☷🌀▰▱⎖፨჻܀⏢
# A SUBSET OF THAT WHICH I MAY LIKE: ◈⟐ːˑ∺≋≎≑≣⊪⊹☱☰☲☳☴☵☶☷፨჻܀
#
# OR: BLOCK ELEMENTS; re: https://en.wikipedia.org/wiki/Block_Elements
# original more detailed set that I simplified from: ▀▁▂▃▄▅▆▇█▉▊▋▌▍▎▏▐░▒▓▔▕▖▗▘▙▚▛▜▝▞▟
#
# OR: what is this? Are there other things like it in any code page? ¦ (spotted first by me at: https://en.wikipedia.org/wiki/Alexandrine) Or this? : ‖

CHARSET="▀▁▃▅▇█▋▌▎▏▐░▒▓▔▕▖▗▘▙▚▛▜▝▞▟"
STR_LEN=$((${#CHARSET} - 1))
# STR_LEN has a value of CHARSET's length minus one because we will potentially randomly read 1
# char starting at the position of length (of the string CHARSET) minus 1. We would probably
# try to read out of bounds of the array otherwise.

# OPTIONAL: uncomment this next code block if you want to redefine CHARSET as a randomly
# selected subset of itself:
NEW_CHARSET_LEN=$(shuf -i 2-$STR_LEN -n 1)
for ELEMENT in $(seq $NEW_CHARSET_LEN)
do
  TMP_NUMBER=$(shuf -i 0-$STR_LEN -n 1)
  TMP_CHAR="${CHARSET:$TMP_NUMBER:1}"
  TMP_CHARSET="$TMP_CHARSET$TMP_CHAR"
done
CHARSET=$TMP_CHARSET
STR_LEN=$((${#CHARSET} - 1))

# CORE FUNCTIONALITY:

# HOW IS THIS THE FIRST I've learned of this simpler expression form for native bash arithmetic?!
# Re: https://ryanstutorials.net/bash-scripting-tutorial/bash-arithmetic.php
let "HARD_NEWLINES = $N_CHARS_TO_GENERATE / $HARD_NEWLINE_AT_CHARACTER"
# echo $HARD_NEWLINES
# exit
for NEWLINE in $(seq $HARD_NEWLINES)
do
  for ELEMENT in $(seq $HARD_NEWLINE_AT_CHARACTER)
  do
    NUMBER=$(shuf -i 0-$STR_LEN -n 1)
    # echo $NEWLINE $ELEMENT
    # for a curious slow terminal effect, pause between character renders:
    # sleep 0.2
    printf "${CHARSET:$NUMBER:1}"
  done
  printf "\n"
done


# DEV HISTORY
# - 2016-05-04 Created after seeing these interesting characters in an .nfo; coincidentally, just such blocky "noise" suited for what I had wanted at that moment to make!
# - 2016-10-04 Good buddy on lunch at work updated to find the path of this dir,
# store it in THIS_SCRIPTS_PATH, and run it locally to actually make use of blockstring.txt
# - 2019-12-13 Completely refactored to use a hard-coded, in-script character string which can be hacked for any purpose (to use different characters). Also included possible other character references (ha ha) in comment, and an optional code block that alters the character set to a random subset of itself (code block committed as used; can be commented out).