# DESCRIPTION
# Takes input file $1, sorts it, reduces it to unique entries, and writes that back to $1.

# WARNING
# This overwrites the original file without warning. That was your only warning--and you missed it if you didn't read this comment in the source code.

# USAGE
# Run with one parameter, which is a file name to operate on:
#    sortuniq.sh fileNameToSortAndDedup.txt


# CODE
	# DEPRECATED prior command:
	# sort $1 | uniq > _tmp_HWPqYyXjv7pGCN.txt
# MORE EFFICIENT new command:
sort $1 -u > _tmp_HWPqYyXjv7pGCN.txt

mv -f _tmp_HWPqYyXjv7pGCN.txt $1

echo ""
echo "DONE. Mein Krummspugerlt ist nicht mein Krummspugelnd."

