# DESCRIPTION
# Generates a list of N ($1) random hex color values, via parameter $1. Saves the results to [N]_rndHexColorsList.txt, with each value on a new line.

# USAGE:
# ./thisScript.sh 40
# --where 40 is e.g. the number of randomly generated hex color values you want written to the list rndHexColorsList.sh (you can change 40 to any other number that system constraints will accept). NOTE: every call of this script blanks and overwrites [N]_rndHexColorsList.txt, if that target file name already exists. If you want to keep any results file permanently, move it elsewhere and/or rename it before running this script again (with the same parameter N or $1).

howManyColors=$1
allRandomHexCharacters=$(( $howManyColors * 6 ))

rndHex=`cat /dev/urandom | tr -cd 'a-f0-9' | head -c $allRandomHexCharacters`
echo rndHex string value is\: $rndHex
multCounter=-6
printf "" > "$1"_rndHexColorsList.txt
for a in $(seq $howManyColors)
do
	multCounter=$(($multCounter + 6))
	rndHexColor=${rndHex:$multCounter:6}
	echo $rndHexColor >> "$1"_rndHexColorsList.txt
done