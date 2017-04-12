# DESCRIPTION
# Sets an environment path containing all used /bin etc. folders for the current shell.

# USAGE
# CD to the dir containing this script, and execute the command <source ./setTempEnv.sh>. To conveniently invoke this script from the home dir of your terminal, copy e.g. this code to a file callGetDevEnv.sh in your home dir:
# cd "$USERPROFILE\Documents\scrap\_devtools-master"
# source ./getDevEnv.sh
# -- and then when you open your terminal (at the home dir), type:
# source ./gde.sh
# -- and you will now have a prompt with all paths in BINPATHSrelativeBash.txt.

while read -r element
do
	_pwd_=$(pwd)
	addPathToDir="$_pwd_"/"$element"
	export PATH="$PATH":"$addPathToDir"
done < ./BINPATHSrelativeBash.txt

echo ----------------
echo TEMPORARY ENVIRONMENT PATHS SET DONE.

# HISTORY
# BEFORE NOW
# Things.
# 2017 apr 12 refactored for better cross-platform compatibility.