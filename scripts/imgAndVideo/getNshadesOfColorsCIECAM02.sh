# DESCRIPTION
# Repeatedly invokes getNshadesOfColorCIECAM02.py for every color in a .hexplt file $1,
# with optional $2 colors (default 13 may be overriden with optional 2nd parameter).

# USAGE
# With this and thy python script it invokes, and the .hexplt file you'll work against all in
# your PATH, invoke this script with minimum one argument (the .hexplt file to work with)
# and optional second argument, being the number of shades to create:
#
# getNshadesOfColors.sh inputPalette.hexplt [number_of_shades]
#
# To hack other parameters modify the command=".." assignment directly (e.g. with -b 100),
# referring to the python script.

# DEPENDENCIES
# Bash, and all the dependencies of the python script this calls.


whereScriptIs=`which getNshadesOfColorCIECAM02.py`
# if operating system is windows, assume we're using cygin (I dunna use any other 'nixy thing on windows, but ubuntu might be poss.? -- anyhoo --
# and adapt that var per:
if [ "$OS" == "Windows_NT" ]
then
	whereScriptIs=`cygpath -w $whereScriptIs`
fi

if [ "$1" ]; then
  INFILE=$1
else
  echo "no parameter 1 (input file) passed. Exiting."
  exit 1
fi

if [ "$2" ]; then
  N=$2
else
  N=13
  echo "no parameter 2 for N passed, defaulting to $N."
fi

arr=$(<$INFILE)
for element in ${arr[@]}
do
  command="python $whereScriptIs -c $element -n $N -b 100"
  $command
  # echo \'$element\'
done