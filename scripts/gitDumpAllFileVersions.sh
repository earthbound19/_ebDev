# DESCRIPTION
# Places a copy of every revision of a given file (from a git repo) to files named originalFileName.ext__ver_<nnn>.txt. Files will appear in the same path(s?) as the file for which revisions are scanned.

# USAGE
# thisScript.sh path/to/filename
# NOTE That this must be done from the repository root directory and you must give the full path to the file from that root directory.


# CODE
# ADAPTED FROM information at:
# https://stackoverflow.com/a/32849134/1397555
# https://stackoverflow.com/a/14996309/1397555

git log $* > tmp_DsunTkSwyGsM7c.txt
# Filter that result to just the hashes of commits printed from the log command; maybe {1,} should be {40} ? :
sed -i -n 's/^commit \([0-9a-z]\{1,\}\)\(.*\)/\1/p' tmp_DsunTkSwyGsM7c.txt
# Because git (apparently) counts revisions ascending from newest to oldest, but we want ascending from oldest to newest, reverse that resultant list of file hashes:
# tac tmp_DsunTkSwyGsM7c.txt > tmp_7BTRBAqw4rMBBP.txt
# REVERT to that previous line if the following doesn't work:
tail -r tmp_DsunTkSwyGsM7c.txt > tmp_7BTRBAqw4rMBBP.txt

while read HASH
do
	INDEX_OUT=$(printf %03d $INDEX)
	OUT_FILENAME="$FILENAME.$INDEX_OUT.$HASH"
	git cat-file -p "$HASH":$* > "$1"__ver_"$INDEX_OUT".txt
	let INDEX=INDEX+1
done < tmp_7BTRBAqw4rMBBP.txt

rm tmp_DsunTkSwyGsM7c.txt tmp_7BTRBAqw4rMBBP.txt