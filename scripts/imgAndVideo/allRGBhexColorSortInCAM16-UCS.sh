# DESCRIPTION
# runs RGBhexColorSortInCAM16-UCS.py with original file overwrite parameter against all .hexplt files in the current directory (no recursion into subdirectories), comparing them by sorting nearest to $1 first (makes a temporary copy of every hexplt file with black as the first color, runs the comparison, then removes the added color).

# DEPENDENCIES
# `getFullPathToFile.sh`, `RGBhexColorSortInCAM16-UCS.py`

# USAGE
# With more than one .hexplt file in your current directory, and RGBhexColorSortInCAM16-UCS.py in your PATH, run this script with these parameters:
# - $1 OPTIONAL. Arbitrary color in sRGB hex to begin sorting on. If omitted, the script this script calls will default to the first color in the palette.
# For example, to run with default parameter, don't pass any parameter:
#    allRGBhexColorSortInCAM16-UCS.sh
# Or to run sorting on a black-black-black-magenta, run:
#    allRGBhexColorSortInCAM16-UCS.sh '#0a000a'
# NOTES
# - See also `allRGBhexColorSortInOkLab.sh' and `allRGBhexColorSortInCIECAM02.sh'.
# - You can also pass the color parameter in the form '0a000a' or just 0a000a (with no quote marks).


# CODE
# TO DO
# Parameterize arbitrary sort color; default to black-black-black-magenta if not provided.
scriptLocation=$(getFullPathToFile.sh RGBhexColorSortInCAM16-UCS.py)

# defaultSortColor variable is undefined and effectively empty if attempted to use; otherwise if value for it provided, define variable with that value:
if [ "$1" ]; then defaultSortColor=$1; fi

array=($(find . -maxdepth 1 -type f -iname \*.hexplt -printf '%f\n'))
# or to find every file,`find .` . .
for element in ${array[@]}
do
	echo "Running comparisons for file $element . . ."
	python $scriptLocation $element foo $defaultSortColor
	echo ""
done