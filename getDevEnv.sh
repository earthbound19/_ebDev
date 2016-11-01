# DESCRIPTION
# Sets an environment path containing all used /bin etc. folders for the current shell. To do this, cd to the dir containing this script, and execute the command <source ./setTempEnv.sh>.

# USAGE
# To conveniently invoke this script from the home dir of your terminal, copy e.g. this code to a file callGetDevEnv.sh in your home dir:
# cd "$USERPROFILE\Documents\scrap\_devtools-master"
# source ./getDevEnv.sh
# -- and then when you open your terminal (at the home dir), type:
# source ./gde.sh
# -- and you will now have a prompt with all paths in BINPATHSrelativeBash.txt.

mapfile -t paths < BINPATHSrelativeBash.txt

for element in ${paths[@]}
do
		# echo $element
	_cygDir_=`cygpath -u $element`
		# echo _cygDir_ val is\:
		# echo $_cygDir_
	_pwd_=$(pwd)
		# echo ~~~~~
		# echo val of _pwd_ is\:
		# echo $_pwd_
	_cygDir_="$_pwd_"/"$_cygDir_"
		# echo appended to pwd is\:
		# echo $_cygDir_
	export PATH="$PATH":"$_cygDir_"
done

echo ----------------
echo TEMPORARY ENVIRONMENT PATHS SET DONE.