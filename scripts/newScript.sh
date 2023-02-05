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

printf "# DESCRIPTION\n# omigoshomigoshomigoshomigoshomigoshomigoshomigoshomigosh\n\n# USAGE\n# Run with these parameters:\n# - \$1 (describe parameter)\n# For example:\n#    scriptFileName.sh parameterOne\n\n\n# CODE\n# NOTES: if you want to get all command line parameters to a script as a single string;\n# how to get command line arguments . . . collection? Array? Re: https://stackoverflow.com/a/12711837/1397555\n# -- and print array re: https://stackoverflow.com/a/15692004/1397555\n# -- you can put those together to get the following:\n# scriptArgumentsAsString=$(printf '%s ' "$@")\n\nif [ \"\$1\" ]; then param1=\$1; else printf \"\\\\nNo parameter \\\$1 (type short explanation of parameter) passed to script. Exit.\"; exit 1; fi" > "$rndString".sh.txt

start "$rndString".sh.txt