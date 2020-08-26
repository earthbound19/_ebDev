# DESCRIPTION
# Converts a fountain format plain text file screenplay into a fountain file with semantic linefeeds (AKA ventilated prose or sense lines) joined. Result is printed to `<inputFileBasename>_unventilated.fountain`. Adapted from:
#    fountain2pdf.sh

# USAGE
# Run with one parameter, which is the input fountain file:
#    fountain2fountain.sh input-file.fountain


# CODE
if [ ! -e $1 ]; then echo proposed input file $1 not found. Terminating script.; fi

fileNameNoExt=${1%.*}
# Kludgy and arbitrarily inflexible (instead of pattern matching any title page elements
# and temporarily cutting them out), but:
# - to avoid the sed command mangling title page info, cut everything before and after
# the initial > FADE IN: (which is now an exact match requirement--MUST be present in the
# fountain script!--) into two separate files, work on the second, then rejoin them:
#  - get line number (of match) to split on:
tail_from=`awk '/> FADE IN:/{print NR;exit}' $1`
let head_to=tail_from-1
head -n $head_to $1 > tmp_head_wYSNpHgq.fountain
gtail -n +$tail_from $1 > tmp_tail_wYSNpHgq.fountain
dos2unix tmp_head_wYSNpHgq.fountain tmp_tail_wYSNpHgq.fountain
#  - join semantic linefeeds into that tail file, in-place:
# Adapted from: https://backreference.org/2009/12/23/how-to-match-newlines-in-sed/
# sed ':begin;$!N;s/FOO\nBAR/FOOBAR/;tbegin;P;D'   # if a line ends in FOO and the next
# starts with BAR, join them
#   - Also don't match [ .@~] characters at start of line (don't join if those fountain syntax
# marks are present:
sed -i ':begin;$!N;s/\(^[^ .\(~@\n].*[a-z].*\)\n\(^[^ .\(~@\n].*[a-z].*\)/\1 \2/;tbegin;P;D' tmp_tail_wYSNpHgq.fountain
cat tmp_head_wYSNpHgq.fountain tmp_tail_wYSNpHgq.fountain > "$fileNameNoExt"_unventilated.fountain 
rm ./tmp_head_wYSNpHgq.fountain ./tmp_tail_wYSNpHgq.fountain
