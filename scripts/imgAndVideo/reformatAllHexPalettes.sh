# DESCRIPTION
# runs `reformatHexPalette.sh` with the same parameters for every `.hexplt` file in the current directory. Uses same parameters as that script (SEE) but shifted. See USAGE.

# DEPENDENCIES
# `reformatHexPalette.sh` in your PATH.

# USAGE
# Call this script with these parameters:
# - $1 OPTIONAL. Number of columns. If omitted, defaults to 1.
# - $2 OPTIONAL. Number of rows. If omitted, the script this calls (`reformatHexPalette.sh) will use its defaults for its parameter $3 (see USAGE details for $3 for that script), with handling to fit rows/columns as also described in that script.
# Example that passes 16 for the columns parameter:
#    reformatAllHexPalettes.sh 16
# Example that passes 16 for the columns parameter and 8 for the rows parameter:
#    reformatAllHexPalettes.sh 16 8
# NOTES
# This script provides $1 as a different file name (pulling from every `.hexplt` format file in the current directory), for every call it makes to `reformatHexPalette.sh`. What is provided as $1 for this script is passed as $2 for that script, and $2 is passed for $3.


# CODE
if [ "$1" ]; then cols=$1; fi
if [ "$2" ]; then rows=$2; fi

allHexpltFileNames=( $(find . -type f -iname "*.hexplt" -printf "%P\n") )

for hexpltFileName in ${allHexpltFileNames[@]}
do
	reformatHexPalette.sh $hexpltFileName $cols $rows
done

printf "DONE reformatting all .hexplt format files in the current directory.\n"