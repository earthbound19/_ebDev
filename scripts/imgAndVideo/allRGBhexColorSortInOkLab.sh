# DESCRIPTION
# runs `rgbHexColorSortInOkLab.js` against all .hexplt files in the current directory (and optionally all subdirectories), overwriting the original files with the result.

# DEPENDENCIES
# `getFullPathToFile.sh`, `rgbHexColorSortInOkLab.js`.

# USAGE
# With more than one .hexplt file in your current directory, and `rgbHexColorSortInOkLab.js` in your PATH, run with these parameters:
# - $1 OPTIONAL. Arbitrary first color (in sRGB hex format, e.g. f800fc) to compare all other colors in the list to (for each file that this script calls `rgbHexColorSortInOkLab.js` to sort perceptually by next nearest color to this color). If provided, it must not have the '#' symbol at the start of the sRGB color (for example, to use a magenta color, just pass f800fc, not #f800fc). If not provided, no arbitrary first color parameter will be passed to `rgbHexColorSortInOkLab.js`.
# - $2 OPTIONAL. Anything, such as the word FROGBALF, which will cause the script to also search for `.hexplt` files in all subdirectories under the current directory, and call `rgbHexColorSortInOkLab.js` for all such found `.hexplt` files (in subdirectories) also. If omitted, only `.hexplt` files in the current directory will be found and passed to `rgbHexColorSortInOkLab.js`. To use this paramter but not $1, pass the word NULL for $1.
# Example that will call `rgbHexColorSortInOkLab.js` repeatedly for every `.hexplt` format file in the current directory, with no additional parameter:
#    allRGBhexColorSortInOkLab.sh
# Example that will call `rgbHexColorSortInOkLab.js` repeatedly for every `.hexplt` format file in the current directory, with a parameter telling it to set #0a000a (a magenta black) as the arbitrary first color to start comparisons with for every `.hexplt` file:
#    allRGBhexColorSortInOkLab.sh 0a000a
# Example that will call `rgbHexColorSortInOkLab.js` for every `.hexplt` file found in all subdirectories also, but not specify any arbitrary first comparison color:
#    allRGBhexColorSortInOkLab.sh NULL FROGBALF
# Example that will specify an arbitrary first comparison color and operate on all `.hexplt` files in all subdirectories also:
#    allRGBhexColorSortInOkLab.sh f800fc FROGBALF
# SEE ALSO `allRGBhexColorSortInCAM16-UCS.sh` and `allRGBhexColorSortInCIECAM02.sh`.


# CODE
if [ "$1" ] && [ "$1" != "NULL" ]
then
	arbitraryColorParam="-f $1"
fi

# set default maxdepth parameter 1 (current directory only):
maxdepthParameter='-maxdepth 1'
# --but override to no maxdepth (all subdirectories) if parameter $2 passed to script:
if [ "$2" ]; then maxdepthParameter=''; fi

scriptLocation=$(getFullPathToFile.sh rgbHexColorSortInOkLab.js)

array=( $(find . $maxdepthParameter -type f -iname \*.hexplt) )
# or to find every file,`find .` . .
for element in ${array[@]}
do
	echo "Running comparisons for file $element . . ."
	results=( $(node $scriptLocation -i $element $arbitraryColorParam) )
	# print array re: https://stackoverflow.com/a/15692004/1397555
	printf '%s\n' "${results[@]}" | tr -d '\15\32' > $element
	echo "DONE and result written back over file $element."
	echo ""
done