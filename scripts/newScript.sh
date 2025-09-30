# DESCRIPTION
# Creates a randomly named file stub for new .sh script development, like this:
# - Commented according to my documentation conventions
# - With a parameter parse case stub for easy tweak for scripting purposes
# - The text file automatically opened in the default text editor (if the `start` command does anything on your system (like hopefully open the stub in a text editor).
# - The stub file is given a .sh.txt extension, to be renamed by me to just .sh for development).

# USAGE
# Run without any parameter:
#    newScript.sh


# CODE
rndString=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c 9)
newScriptFileName="$rndString".sh

printf '# DESCRIPTION\n# omigoshomigoshomigoshomigoshomigoshomigoshomigoshomigosh\n\n# USAGE\n# Run with these parameters:\n# - $1 (describe parameter)\n# For example:\n#    scriptFileName.sh parameterOne\n\n\n# CODE\n# NOTES: if you want to get all command line parameters to a script as a single string, re: https://stackoverflow.com/a/12711837/1397555\n#    scriptArgumentsAsString=$@\n# -- although probably you can just use $@ directly without assigning it to any other variable.\n\nif [ \"$1\" ]; then param1=$1; else printf \"\\nNo parameter \$1 (type short explanation of parameter) passed to script. Exit.\"; exit 1; fi\n\n# template code that sets the find commands maxdepth switch to only one level deep if no parameter or NULL is passed for $2, and defaults to nothing (which searches all subdirectories) if a parameter other than NULL is passed for $2; adapt this to search for any given file type, or -d for directories, etc.:\nif [ ! "$2" ] || [ "$2" == "NULL" ]; then subDirSearchParam="-maxdepth 1"; fi\nfilesList=( $(find . $subDirSearchParam -type f -printf "%%P\\n" ) )\n\n# template code that iterates over the resulting array, printing each item:\nfor file in ${filesList[@]}\ndo\n\techo $file\ndone' > $newScriptFileName

start $newScriptFileName
printf "\nNew script template file name:\n$newScriptFileName\n"