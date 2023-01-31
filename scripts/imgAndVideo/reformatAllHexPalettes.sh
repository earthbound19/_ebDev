# DESCRIPTION
# runs `reformatHexPalette.sh` repeatedly with every .hexplt file in the current directory as -i, and optionally different paramters that script can use via #1. See USAGE.

# DEPENDENCIES
# `reformatHexPalette.sh` in your PATH.

# USAGE
# Call this script with these parameters:
# - $1 OPTIONAL. Any string of parameters/switches usable by `reformatHexPalette.sh` which you wish to pass to it; see documentation for that script. NOTE that if you use more than one paramters, you must surround them all with quotes. If omitted, the defaults of the called script will be used.
# Example that passes 16 for the columns parameter:
#    reformatAllHexPalettes.sh -c16
# Example that passes 5 for the columns parameter, with the -n switch to print no columns and rows layout comment:
#    reformatAllHexPalettes.sh '-c16 -n'
# Example that uses the -a switch to make as many columns as colors:
#    reformatAllHexPalettes.sh 16 '-a'
# NOTES
# This script provides a different file name (pulling from every `.hexplt` format file in the current directory) for every call it makes to `reformatHexPalette.sh`. For each call it provides a new file name for -i, as if it were many calls like this:
#    reformatHexPalette.sh -i <palette1.hexplt> <any parameters from $1>
#    reformatHexPalette.sh -i <palette2.hexplt> <any parameters from $1>
#    reformatHexPalette.sh -i <palette3.hexplt> <any parameters from $1>
#    ..


# CODE
if [ "$1" ]; then extraParameters=$1; fi

allHexpltFileNames=( $(find . -maxdepth 1 -type f -iname "*.hexplt" -printf "%P\n") )

for hexpltFileName in ${allHexpltFileNames[@]}
do
	reformatHexPalette.sh -i $hexpltFileName $extraParameters
done

printf "DONE reformatting all .hexplt format files in the current directory.\n"