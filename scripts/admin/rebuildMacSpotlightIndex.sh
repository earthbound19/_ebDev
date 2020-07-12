# DESCRIPTION
# Force rebuilds the MacOS Spotlight index.

# USAGE
#  rebuildMacSpotlightIndex.sh

# CODE
# re mdutil help (when run without any switch) :
sudo mdutil -Esa -i on;

# Without the semicolon (";") at the end of this command, it doesn't return to the terminal again (and allow you to enter another command) until re-indexing completes. But with the & echo, it forces the command to effectively run in the background, by "finishing" the command and moving to the "next" command, which is nothing.