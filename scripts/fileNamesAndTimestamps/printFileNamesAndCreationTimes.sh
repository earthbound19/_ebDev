# DESCRIPTION
# Prints file names and creation dates for every file in the current directory, one file per line, with the file name and date separated by a bar |. If an optional parameter is passed, does this for all files in all subdirectories also.

# USAGE
# Run without any parameter:
#    printFileNamesAndCreationTimes.sh
# Run with one optional parameter, which may be anything (for example the word 'FLURFBLORG'), to print information for all files in all subdirectories as well:
#    printFileNamesAndCreationTimes.sh FLURFBLORG


# CODE
maxdepthParameter='-maxdepth 1'
if [ "$1" ]; then maxdepthParameter=''; fi

# Thanks to help from a genius breath yonder: https://unix.stackexchange.com/a/22221/110338
find . $maxdepthParameter -printf '%P %CY-%Cm-%Cd__%CH-%CM-%CS\n'