# DESCRIPTION
# Runs dos2unix on all files found in either the current directory, or optionally the current directory and all subdirectories as well. See USAGE.

# DEPENDENCIES
# The dos2unix utility in your PATH.

# USAGE
# To run dos2unix on all files in the current directory, but not on files in subdirectories, run without any parameter:
#    allDOS2unix.sh
# To run dos2unix on all files in the current directory and all subdirectories, run with anything (for example the nonense word 'WABYEG') as a parameter:
#    allDOS2unix.sh WABYEG


# CODE
# depthParameter defaults to only the current directory:
depthParameter='-maxdepth 1'
# But if any parameter is passed to this script, it is set to nothing, which will cause "find" to search all subdirectories also:
if [ "$1" ]; then depthParameter=''; fi

find . $depthParameter -type f -exec dos2unix {} \;