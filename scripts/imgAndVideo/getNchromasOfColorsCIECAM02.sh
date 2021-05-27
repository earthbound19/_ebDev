# DESCRIPTION
# Repeatedly runs getNchromasOfColorCIECAM02.py for every color in a .hexplt file $1, with optional $2 colors (default hard-coded number may be overridden with optional 2nd parameter).

# DEPENDENCIES
# Bash, and all the dependencies of the python script this calls.

# USAGE
# With this and the python script it runs, and the .hexplt file you'll work against all in your PATH, run this script with these parameters:
# - $1 The source .hexplt file
# - $2 OPTIONAL. The number of shades to create. If not present, a default is used.
# Example that will produce 7 shades from every color in inputPalette.hexplt:
#    getNchromasOfColorsCIECAM02.sh inputPalette.hexplt 7
# NOTE
# To hack other parameters modify the command=".." assignment in the script directly, for example to `-b 100`, referring to the Python script.


# CODE
if [ "$1" ]; then
  INFILE=$1
else
  echo "no parameter 1 (input file) passed. Exit."
  exit 1
fi

if [ "$2" ]; then
  N=$2
else
  N=13
  echo "no parameter 2 for N passed, defaulting to $N."
fi

whereScriptIs=$(getFullPathToFile.sh getNchromasOfColorCIECAM02.py)

arr=($(<$INFILE))
for element in ${arr[@]}
do
  # an optional possible switch to pass (I avoid using it and just use the C detected from the color -c :
  # -o 115"
  command="python $whereScriptIs -c $element -n $N"
  $command
done