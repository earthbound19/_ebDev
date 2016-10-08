# DESCRIPTION
# Sets an environment path containing all used /bin etc. folders for the current shell. To do this, cd to the dir containing this script, and execute the command <source ./setTempEnv.sh>.

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

echo TEMPORARY ENVIRONMENT PATHS SET DONE.