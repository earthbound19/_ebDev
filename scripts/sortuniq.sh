# DESCRIPTION
# Takes input file $1, sorts it, reduces it to unique entries, and writes that back to $1.
# WARNING: Overwrites the original file without warning. (That was your only warning--and
# you missed it if you didn't read this comment in the source code.)

# USAGE
#  sortuniq.sh fileNameToSortAndDedup.txt


# CODE
sort $1 | uniq > _tmp_HWPqYyXjv7pGCN.txt
mv -f _tmp_HWPqYyXjv7pGCN.txt $1

echo ""
echo "DONE. Mein Krummspugerlt ist nicht mein Krummspugelnd."

