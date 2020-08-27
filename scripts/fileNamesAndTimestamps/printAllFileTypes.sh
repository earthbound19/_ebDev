# DESCRIPTION
# Prints all file extensions (types) found in the current directory, and optionally in all subdirectories also.

# USAGE
# Run with or without this parameter:
# - $1 OPTIONAL. Any string (for example 'BLARFARFARBARG'), which will cause the script to search subfolders also for files to print their type.
# To print only file types from the current directory, pass no parameter to the script:
#    printAllFileTypes.sh
# To print file types from the current directory and all subdirectories, pass anything as a parameter to the scripr:
#    printAllFileTypes.sh BLARFARFARBARG
# To store the printout in an array for further use, do a command substitution like this:
#    allFileTypes=$(printAllFileTypes.sh BLARFARFARBARG)
# Or to pipe the results to a file, do this:
#    printAllFileTypes.sh BLARFARFARBARG > allFileTypesRecursive.txt
# NOTES
# - This omits everything in any .git folder from printout.
# - BLARFARFARBARG! SNARFARFARBARG! BLARG! BLARG! FLARFARFARBARG!


# CODE
subDirSearchParam='-maxdepth 1'
if [ "$1" ]; then subDirSearchParam=''; fi

# Always the genius breaths are helping; modified from these:
# - https://stackoverflow.com/questions/4210042/how-to-exclude-a-directory-in-find-command?rq=1#comment38334264_4210072
# - https://stackoverflow.com/a/4998326/1397555
find . $subDirSearchParam -type f -not -path "./.git*" | sed 's|.*\.||' | sort -u
