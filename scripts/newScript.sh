# DESCRIPTION
# Creates a randomly named file stub for new .sh script development, commented according to my documentation conventions, and automatically opens that script (if the `start` command does anything on your system (like hopefully open the stub in a text editor). The stub file is given a .sh.txt extension, to be renamed by me to just .sh for development).

# USAGE
#  makeScriptStub.sh


# CODE
rndString=`cat /dev/urandom | tr -dc 'a-f0-9' | head -c 9`

printf "# DESCRIPTION\n# omigoshomigoshomigoshomigoshomigoshomigoshomigoshomigosh\n\n# USAGE\n#  omigoshomigoshomigosh\n\n\n# CODE\n# DELETE this line and the next if your script doesn't need them; otherwise adapt per your needs:\nif ! [ \"\$1\" ]; then printf \"\\\\nNo parameter \\\$1 (type short explanation of parameter) passed to script. Exit.\"; exit; fi\n" > "$rndString".sh.txt

start "$rndString".sh.txt