# DESCRIPTION
# Checks for unusual characters in the path (pwd), or a very long path name, and exits assigning an errorlevel in either case.

# USAGE
# Run without any parameters:
#    checkForTerminalProblematicPath.sh
# Then check errorlevel:
#    echo $?
# If there were unusual characters in the path, that will return 1. If the path is very long, errorlevel will be 2. If there are no such errors, it will return 0.


# CODE
# The &>/dev/null redirects the command output to nowhere:
pathString=$(pwd)
pwd | grep "[@=\`~\!#$%^&+(){}; ,]" &>/dev/null
# Because that command will _succeed_ if those characters are found, it will set errorlevel to 0 (no error). We therefore want to exit with 1 (set errorlevel to 1) :
if (( $? == 0 )); then echo "$0: Potentially terminal-unfriendly character in path $pathString. Exit 1."; exit 1; fi

pathCharacterCount=$(pwd | wc -c)
if (( $pathCharacterCount > 512 )); then echo "$0: path $pathString longer than 512 characters at $pathCharacterCount. Exit 2"; exit 2; fi

# to cover other cases, do essentially nothing, which has the effect of setting errorlevel to 0 ?:
echo Gluorf &>/dev/null