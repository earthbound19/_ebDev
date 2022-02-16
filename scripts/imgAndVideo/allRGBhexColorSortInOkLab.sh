# DESCRIPTION
# runs `rgbHexColorSortInOkLab.js` against all .hexplt files in the current directory (no recursion into subdirectories), overwrtiting the original files with the result.

# DEPENDENCIES
# `getFullPathToFile.sh`, `rgbHexColorSortInOkLab.js`.

# USAGE
# With more than one .hexplt file in your current directory, and `rgbHexColorSortInOkLab.js` in your PATH, run this script:
#    allRGBhexColorSortInOkLab.sh
# SEE ALSO `allRGBhexColorSortInCAM16-UCS.sh` and `allRGBhexColorSortInCIECAM02.sh`.


# CODE
# TO DO
# After arbitrary sort on first color is added to the script this calls, add it as an optional parameter (and use it) for this.
scriptLocation=$(getFullPathToFile.sh rgbHexColorSortInOkLab.js)

array=( $(find . -maxdepth 1 -type f -iname \*.hexplt -printf '%f\n') )
# or to find every file,`find .` . .
for element in ${array[@]}
do
	echo "Running comparisons for file $element . . ."
	results=( $(node $scriptLocation -i $element) )
	# print array re: https://stackoverflow.com/a/15692004/1397555
	printf '%s\n' "${results[@]}" > $element
	echo "DONE and result written back over file $element."
	echo ""
done