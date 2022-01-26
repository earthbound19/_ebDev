# DESCRIPTION
# runs RGBhexColorSortInCIECAM02.py with original file overwrite parameter against all .hexplt files in the current directory (no recursion into subdirectories), comparing them by sorting nearest to black-black-black-magenta first (makes a temporary copy of every hexplt file with black as the first color, runs the comparison, then removes the added color).

# DEPENDENCIES
# `getFullPathToFile.sh`, `RGBhexColorSortInCIECAM02.py`

# USAGE
# With more than one .hexplt file in your current directory, and RGBhexColorSortInCIECAM02.py in your PATH, run this script:
#    allRGBhexColorSortInCIECAM02.sh
# NOTE
# See also `allRGBhexColorSortInOkLab.sh` and `allRGBhexColorSortInCAM16-UCS.sh`.


# CODE
# TO DO
# Parameterize arbitrary sort color; default to black-black-black-magenta if not provided.
scriptLocation=$(getFullPathToFile.sh RGBhexColorSortInCIECAM02.py)

array=($(find . -maxdepth 1 -type f -iname \*.hexplt -printf '%f\n'))
for element in ${array[@]}
do
	echo "Running comparisons for file $element . . ."
	python $scriptLocation $element foo '#0a000a'
	echo ""
done