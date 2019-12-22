# DESCRIPTION
# Places a copy of every revision of a given file (from a git repo) to files named originalFileName.ext__ver_<nnn>.txt. Files will appear in the same path(s?) as the file for which revisions are scanned. For 

# USAGE
# with this script in your PATH, and from the root directory of a repo, run:
# gitDumpAllFileVersions.sh relative/path/to/filename/filename.code
# NOTE That this must be done from the repository root directory and you must give the full path to the file from that root directory.

# NOTES
# If you have ridiculously long history with a file, and/or the file was ever renamed,
# you may want to first run:
# git config diff.renameLimit 999999
# -- I tried adding -S flag to the git log command and it seemed not to effect
# rename tracking at all. ?
# (re: https://stackoverflow.com/a/28064699/1397555 https://stackoverflow.com/a/5743887/1397555


# CODE
# ADAPTED FROM information at:
# https://stackoverflow.com/a/32849134/1397555
# https://stackoverflow.com/a/14996309/1397555

git log $* > tmp_DsunTkSwyGsM7c.txt
# Filter that result to just the hashes of commits printed from the log command; maybe {1,} should be {40} ? :
gsed -i -n 's/^commit \([0-9a-z]\{1,\}\)\(.*\)/\1/p' tmp_DsunTkSwyGsM7c.txt
# Because git (apparently) counts revisions ascending from newest to oldest, but we want ascending from oldest to newest, reverse that resultant list of file hashes:
tac tmp_DsunTkSwyGsM7c.txt > tmp_7BTRBAqw4rMBBP.txt
# REVERT to that previous line if the following doesn't work:
# tail -r tmp_DsunTkSwyGsM7c.txt > tmp_7BTRBAqw4rMBBP.txt

while read HASH
do
	# ELEVEN-MILLIONTH TIME THAT WINDOWS @@!&@&!@*#!!! messed up newlines have screwed with script functionality and had to be chopped off via tr:
	HASH=`echo $HASH | tr -d '\15\32'`
	INDEX_OUT=$(printf %03d $INDEX)
	OUT_FILENAME="$FILENAME.$INDEX_OUT.$HASH"
	# echo will write to file "$1"__ver_"$INDEX_OUT".txt . . .
	git cat-file -p "$HASH":$* > "$1"__ver_"$INDEX_OUT".txt
	# retrieve and apply original time stamp of file when commited;
	# re another genius breath: https://stackoverflow.com/a/30143117/1397555
	# echo updating timestamp to original commit time . . .
	TIMESTAMP=`git show -s --format=%ci $HASH`
	# working around $*()!! newline problem again with | tr -d '\15\32':
    TIME2=`echo $TIMESTAMP | gsed 's/-//g;s/ //;s/://;s/:/\./;s/ .*//' | tr -d '\15\32'`
# 'nix:
    touch -a -m -t $TIME2 "$1"__ver_"$INDEX_OUT".txt
# WINDOWS kludge: copy now accurate modify date to create date time stamp via exiftool:
	ExifTool -overwrite_original "-FileModifyDate>FileCreateDate" "$1"__ver_"$INDEX_OUT".txt
	let INDEX=INDEX+1
done < tmp_7BTRBAqw4rMBBP.txt

rm tmp_DsunTkSwyGsM7c.txt tmp_7BTRBAqw4rMBBP.txt