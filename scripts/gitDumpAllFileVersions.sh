# DESCRIPTION
# Places a copy of every revision of a given file (from a git repo) to files named originalFileName.ext__ver_"nnn".txt. Files will appear in the same path(s?) as the file for which revisions are scanned. Updates extracted file time stamps with touch and /or exiftool to match git commit time.

# USAGE
# With this script in your PATH, and from the root directory of a repo, run:
#    gitDumpAllFileVersions.sh relative/path/to/filename/filename.code
# NOTES
# - This must be done from the repository root directory and you must give the full path to the file from that root directory.
# - If you have ridiculously long history with a file, and/or the file was ever renamed, you may want to first run:
#        git config diff.renameLimit 999999
# I tried adding -S flag to the git log command and it seemed not to effect rename tracking at all. ? (re: https://stackoverflow.com/a/28064699/1397555 https://stackoverflow.com/a/5743887/1397555
# - This script was developed for the sole purpose of creating data bent animations of the progress of a file's development via mkDataBentAnim.sh.


# CODE
# ADAPTED FROM information at:
# https://stackoverflow.com/a/32849134/1397555
# https://stackoverflow.com/a/14996309/1397555

git log $* > tmp_DsunTkSwyGsM7c.txt
# Filter that result to just the hashes of commits printed from the log command:
sed -i -n 's/^commit \([0-9a-z]\{1,\}\)\(.*\)/\1/p' tmp_DsunTkSwyGsM7c.txt
# Because git lists revisions from newest to oldest, but we want oldest to newest, reverse that list of file hashes:
tac tmp_DsunTkSwyGsM7c.txt > tmp_7BTRBAqw4rMBBP.txt

while read HASH
do
	# ELEVEN-MILLIONTH TIME THAT WINDOWS @@!&@&!@*#!!! messed up newlines have screwed with script functionality and had to be chopped off via tr:
	HASH=`echo $HASH | tr -d '\15\32'`
	INDEX_OUT=$(printf %03d $INDEX)
	OUT_FILENAME="$1"__ver_"$INDEX_OUT"__"$HASH".txt
	git cat-file -p "$HASH":$* > $OUT_FILENAME
	# retrieve and apply original time stamp of file when committed;
	# re another genius breath: https://stackoverflow.com/a/30143117/1397555
	# echo updating timestamp to original commit time . . .
	TIMESTAMP=`git show -s --format=%ci $HASH`
	# working around $*()!! newline problem again with | tr -d '\15\32':
    TIME2=`echo $TIMESTAMP | sed 's/-//g;s/ //;s/://;s/:/\./;s/ .*//' | tr -d '\15\32'`
# 'nix:
    touch -a -m -t $TIME2 $OUT_FILENAME
# WINDOWS kludge: copy now accurate modify date to create date time stamp via exiftool:
	ExifTool -overwrite_original "-FileModifyDate>FileCreateDate" $OUT_FILENAME
	let INDEX=INDEX+1
done < tmp_7BTRBAqw4rMBBP.txt

rm tmp_DsunTkSwyGsM7c.txt tmp_7BTRBAqw4rMBBP.txt

printf "\nDONE.\n"