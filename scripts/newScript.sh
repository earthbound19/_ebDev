# DESCRIPTION
# Creates a randomly named file stub for new .sh script development, commented according to my documentation conventions, and automatically opens that script (if the `start` command does anything on your system (like hopefully open the stub in a text editor). The stub file is given a .sh.txt extension, to be renamed by me to just .sh for development).

# USAGE
#  makeScriptStub.sh


# CODE
rndString=`cat /dev/urandom | tr -dc 'a-f0-9' | head -c 9`

printf "# DESCRIPTION\n# omigoshomigoshomigoshomigoshomigoshomigoshomigoshomigosh\n\nUSAGE\n#  omigoshomigoshomigosh\n\n\n# CODE\n" > "$rndString".sh.txt

start "$rndString".sh.txt