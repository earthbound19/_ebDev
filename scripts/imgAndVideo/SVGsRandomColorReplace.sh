# DESCRIPTION
# calls SVGrandomColorReplace.sh for every .svg file in the current directory, doing random fills from .hexplt file $1, replacing color $2 with random colors from $1. (Uses a new svg file for $1 for that script, passing $1 from this as $2 and $2 from this as $3.) Note that script is named SVGrandom~ where this script is SVGsRandom~.

# USAGE
# Run with these parameters:
# - $1 REQUIRED. A flat text file list of hexadecimal RGB color codes, one per line, from which to choose random colors for this fill. NOTE: each hex color in the file must be preceded by #. Note that this is $2 in the called script.
# - $2 OPTIONAL. RGB hex color code in format f800fc (six hex digits, no starting # symbol) to search and replace with random colors from $2. If omitted, the called script uses a default (at this writing ffffff). Note that this is $3 in the called script.
# For example:
# scriptFileName.sh parameterOne


# CODE
if [ "$1" ]; then paletteFile=$1; else printf "\nNo parameter \$1 (source .hexplt file name) passed to script. Exit."; exit 1; fi

if [ "$2" ]; then replaceThisHexColor=$2; fi

SVGfilesList=( $(find . $subDirSearchParam -type f -iname "*.svg" -printf "%P\n" ) )
for SVGfile in ${SVGfilesList[@]}
do
	echo "calling command:"
	echo "SVGrandomColorReplace.sh $SVGfile $paletteFile $replaceThisHexColor"
	SVGrandomColorReplace.sh $SVGfile $paletteFile $replaceThisHexColor
done