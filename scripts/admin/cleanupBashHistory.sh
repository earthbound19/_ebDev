# DESCRIPTION
# Deduplicates listings in bash history.

# USAGE
# Run without any parameters:
#    cleanupBashHistory.sh
# NOTES
# - This script expects a file `~/.bash_history` to exist and contain bash history.
# - re: https://stackoverflow.com/a/7449399/1397555
# - SEE ALSO (to do--? implement?) : https://jorge.fbarr.net/2011/03/24/making-your-bash-history-more-efficient/


# CODE
# remove duplicates while preserving input order
function dedup {
   awk '! x[$0]++' $@
}

# removes $HISTIGNORE commands from input
function remove_histignore {
   if [ -n "$HISTIGNORE" ]; then
      # replace : with |, then * with .*
      local IGNORE_PAT=`echo "$HISTIGNORE" | sed s/\:/\|/g | sed s/\*/\.\*/g`
      # negated grep removes matches
      grep -vx "$IGNORE_PAT" $@
   else
      cat $@
   fi
}

# clean up the history file by remove duplicates and commands matching
# $HISTIGNORE entries
function history_cleanup {
   local HISTFILE_SRC=~/.bash_history
   local HISTFILE_DST=/tmp/.$USER.bash_history.clean
   if [ -f $HISTFILE_SRC ]; then
      \cp $HISTFILE_SRC $HISTFILE_SRC.backup
      dedup $HISTFILE_SRC | remove_histignore >| $HISTFILE_DST
      \mv $HISTFILE_DST $HISTFILE_SRC
      chmod go-r $HISTFILE_SRC
      history -c
      history -r
   fi
}

# Run that function which runs other functions :) and it seems like this doesn't work as hoped unless I call that repeatedly? Why?
history_cleanup
history_cleanup
history_cleanup
history_cleanup
history_cleanup

echo \.bash_history cleanup done.