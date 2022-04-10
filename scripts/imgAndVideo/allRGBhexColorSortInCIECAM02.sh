# DESCRIPTION
# runs RGBhexColorSortInCIECAM02.py with original file overwrite parameter against all .hexplt files in the current directory (no recursion into subdirectories), comparing them by sorting nearest to black-black-black-magenta first (makes a temporary copy of every hexplt file with black as the first color, runs the comparison, then removes the added color).

# DEPENDENCIES
# `getFullPathToFile.sh`, `RGBhexColorSortInCIECAM02.py`

# USAGE
# With more than one .hexplt file in your current directory, and RGBhexColorSortInCIECAM02.py in your PATH, run this script with these parameters:
# - $1 OPTIONAL. Arbitrary first color (in sRGB hex format, e.g. 0a000a) to compare all other colors in the list to (for each file that this script calls `RGBhexColorSortInCIECAM02.py` to sort perceptually by next nearest color to this color). If provided, it must not have the '#' symbol at the start of the sRGB color (for example, to use a magenta color, just pass f800fc, not #f800fc). If not provided, no arbitrary first color parameter will be passed to `RGBhexColorSortInCIECAM02.py`.
# Example that will sort the colors in all .hexplt files in this directory by next nearest color starting with the first color in each .hexplt file:
#    allRGBhexColorSortInCIECAM02.sh
# Example that will sort the colors in all .hexplt files in this directory by next nearest color starting with the arbitary sRGB color #0a000a, a magenta black:
#    allRGBhexColorSortInCIECAM02.sh 0a000a
# NOTE
# See also `allRGBhexColorSortInOkLab.sh` and `allRGBhexColorSortInCAM16-UCS.sh`.


# CODE
# set the value to pass for an arbitrary color to nothing (empty), and override it with $1 if $1 is passed:
arbitraryFirstSortColor=
if [ "$1" ]; then arbitraryFirstSortColor=$1; fi

scriptLocation=$(getFullPathToFile.sh RGBhexColorSortInCIECAM02.py)

array=($(find . -maxdepth 1 -type f -iname \*.hexplt -printf '%f\n'))
for element in ${array[@]}
do
	echo "Running comparisons for file $element . . ."
	python $scriptLocation $element foo $arbitraryFirstSortColor
	echo ""
done