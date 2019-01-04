# DESCRIPTION
# Takes input file $1, sorts it via `sort` to a temp file, then deduplicates lines in it via `uniq` back to the original file, and deletes the temp file. WARNING: Overwrites the original file without warning. (That was your only warning--and you missed it if you didn't read this comment in the source code.)

# USAGE
# sortuniq.sh fileNameToSortAndDedup.txt


# CODE
sort $1 > _tmp_HWPqYyXjv7pGCN.txt
uniq _tmp_HWPqYyXjv7pGCN.txt > $1
rm ./_tmp_HWPqYyXjv7pGCN.txt

echo DONE. Mein Krummspugerlt ist nicht mein Krummspugelnd.