# DESCRIPTION
# clears adjacent duplicates in shell history via uniq and stuff. Assumes .bash_history is at /home/$username/.

# USAGE
# With this here in your path, type:
# swoosh.sh <enter>

# FAILED attempt:
# username=`whoami`
# uniq /home/$username/.bash_history > temp.txt
# cat temp.txt > /home/$username/.bash_history
# rm temp.txt

# NO, also FAIL:
# RE: http://stackoverflow.com/a/7449399/1397555
# remove duplicates while preserving input order
# function dedup {
   # awk '! x[$0]++' $@
# }

# removes $HISTIGNORE commands from input
# function remove_histignore {
   # if [ -n "$HISTIGNORE" ]; then
      # replace : with |, then * with .*
      # local IGNORE_PAT=`echo "$HISTIGNORE" | gsed s/\:/\|/g | gsed s/\*/\.\*/g`
      # negated grep removes matches
      # grep -vx "$IGNORE_PAT" $@
   # else
      # cat $@
   # fi
# }

# clean up the history file by remove duplicates and commands matching
# $HISTIGNORE entries
# function history_cleanup {
   # local HISTFILE_SRC=~/.bash_history
   # local HISTFILE_DST=/tmp/.$USER.bash_history.clean
   # if [ -f $HISTFILE_SRC ]; then
      # \cp $HISTFILE_SRC $HISTFILE_SRC.backup
      # dedup $HISTFILE_SRC | remove_histignore >| $HISTFILE_DST
      # \mv $HISTFILE_DST $HISTFILE_SRC
      # chmod go-r $HISTFILE_SRC
      # history -c
      # history -r
   # fi
# }