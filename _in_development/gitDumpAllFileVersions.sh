# DESCRIPTION
# Places a copy of every revision of a given file in a git repo in the repo's root path.

# GANKED FROM: https://stackoverflow.com/a/32849134/1397555

# USAGE
# thisScript.sh path/to/filename
# NOTE that you must be in the repo root for this to work.


function git_log_message_for_commit
{
  IT=$(git log -1 --pretty=format:"%an, %s, %b, %ai"  $*)
  echo $IT
}

function choose_col
{
  COL=$1
  if [ -z "$2" ]
  then
    OPTS=
  else
    OPTS="-F\\${2}"
  fi
  awk $OPTS -v col="$COL" '{print $col}' 
}

	# DEPRECATED, as it relies on a function never defined anywhere when I obtained a copy of this--it must be a function defined in some global include or summat from the original developer? :
	# FILENAME=$*
	# HASHES=$(git_log_short $FILENAME | choose_col 1)
	# INDEX=1
# REWORKING FUNCTIONAL EQUIVALENT of that with later tweak to allow that in this script:
git log $* > tmp_DsunTkSwyGsM7c.txt
# Filter that result to just the hashes of commites printed from the log command; maybe {1,} should be {40} ? :
gsed -i -n 's/^commit \([0-9a-z]\{1,\}\)\(.*\)/\1/p' tmp_DsunTkSwyGsM7c.txt

while read HASH
do
  INDEX_OUT=$(printf %03d $INDEX)
  OUT_FILENAME="$FILENAME.$INDEX_OUT.$HASH"
  OUT_LOG_FILENAME="$FILENAME.$INDEX_OUT.$HASH.logmsg"
  echo "saving version $INDEX to file $OUT_FILENAME for hash:$HASH"
  echo "*******************************************************" >>  $OUT_LOG_FILENAME
  git_log_message_for_commit $HASH >> $OUT_LOG_FILENAME
  echo "  $HASH:$FILENAME " >> $OUT_LOG_FILENAME
  echo "*******************************************************" >> $OUT_LOG_FILENAME

  git show $HASH:$FILENAME >> $OUT_FILENAME
  let INDEX=INDEX+1
done < tmp_DsunTkSwyGsM7c.txt

rm tmp_DsunTkSwyGsM7c.txt