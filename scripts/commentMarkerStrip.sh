# DESCRIPTION
# Strips many kinds of source code comment markers (leaving everything on the line but the comment marker) from the start of any file, printing the result to stdout. Can optionally overwrite the original file (removing comments from the original file). Note that it removes the comment marker, but not the rest of the comment; so for example any file that has c-style comments like this in it:
#    // this be a comment yar
# -- will have that comment marker removed, but the rest of the text remains, like this:
#    this be a comment yar

# USAGE
# Run with these parameters:
# - $1 input file to strip comment markers from, printing result to stdout.
# - $2 OPTIONAL. Any string (such as the word 'CHULFOR'), which will cause this script to overwrite the original file with the comment markers removed.
# Example that would take a file named script.sh as parameter one, and remove all the # (number or hash or pound sign) comment markers from it, and print the result to stdout:
#    commentMarkerStrip.sh script.sh
# Example that would take a file named script.sh as parameter one, and remove all the # comment markers from it, and overwrite script.sh with the result:
#    commentMarkerStrip.sh script.sh CHULFOR


# CODE
if [ ! "$1" ]; then printf "\nNo parameter \$1 passed to script (input file to remove comment markers from, writing to a new file or overwriting the original if parameter \$2 is present). Exit."; exit 1; else inputFile=$1; fi

# With the following variable left at default empty (''), passing it as a switch to sed will do nothing; but if parameter 2 is passed to this script, it will be set to '-i', which when passed to sed will cause in-place overwrite of file with result of sed processing:
overwriteOriginalOrNotSwitch=''
if [ "$2" ]; then overwriteOriginalOrNotSwitch='-i'; fi

# DEVELOPER NOTES
# - to add a new comment marker to remove, copy one of the lines with a sed expression, and change the marker; for example, to use a Fortran 'C' as a comment marker, you would copy the line with a % in it to C.
# - comment marker types stripped; please add to this list if you add more: # // """ % :: [Rr][Ee][Mm] ; ;;
# breaking sed expression over multiple lines, re: https://Unix.stackexchange.com/a/146962/110338
sed $overwriteOriginalOrNotSwitch -E 's'/\
'^([[:space:]]{0,})#{1}'\
'|^([[:space:]]{0,})\/\/{1}'\
'|^([[:space:]]{0,})"""{1}'\
'|^([[:space:]]{0,})%{1}'\
'|^([[:space:]]{0,})::{1}'\
'|^([[:space:]]{0,})[Rr][Ee][Mm]{1}'\
'|^([[:space:]]{0,});{1}'\
'|^([[:space:]]{0,});;{1}'\
'/\1/g' $inputFile
