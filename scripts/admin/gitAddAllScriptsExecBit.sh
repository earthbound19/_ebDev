# DESCRIPTION
# Searches for .sh and .py type scripts in all subdirectories and runs a git command against each of them to `git add` them with the execute bit set. Solves a problem where files created and normally added to git on Windows don't have that, and some 'Nixy environments properly refuse to execute them without that bit. (In fact, even if they are in your PATH, some or all 'nix environments behave as if they don't even exist if you try to locate them with `whereis scriptName.sh` or `whereis scriptName.sh` -- it doesn't even throw an error.)

# USAGE
# Hard-code the script types listing in the find command at the start of the script per your preferences, then run this script without any parameters:
#    gitAddAllScriptsExecBit.sh
# NOTE
# As this only runs `git add` against all the script files, you'll need to properly `git commit` and `git push` or whatever to actually get them into a remote/shared git repository.


# CODE
# create array of all source code / script file names of given types in this directory and subdirectories; -printf "%P\n" removes the ./ from the front; re: https://Unix.stackexchange.com/a/215236/110338 -- ALSO NOTE: if I use any printf command, it only lists findings for that associated -o option; so printf must be used for every -o:
scriptsArray=(`find . -type f -name '*.sh' -printf "%P\n" -o -name '*.py' -printf "%P\n"`)

for element in ${scriptsArray[@]}
do
	# Add the specific file with the execute bit set, re:
	# re: https://stackoverflow.com/a/38285462/1397555
	git update-index --add --chmod=+x $element
done

printf "\n\nDONE. So many files have been udpated in git to include the executable (chmod +x) bit. You'll probably want to now `git commit..` and `git push` to get them into a remote."