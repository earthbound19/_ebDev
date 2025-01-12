# DESCRIPTION
# runs `sortSRGBhexColorsColoraide.py` against all .hexplt files in the current directory (and optionally all subdirectories), overwriting the original files with the result.
# SEE ALSO `allRGBhexColorSortInOkLab.sh`, `allRGBhexColorSortInCAM16-UCS.sh`, and `allRGBhexColorSortInCIECAM02.sh`.

# DEPENDENCIES
# `sortSRGBhexColorsColoraide.py` and dependencies, getFullPathToFile.sh (to locate the full path to that python script)

# USAGE
# With more than one .hexplt file in your current directory, and `sortSRGBhexColorsColoraide.py` in your PATH, run with these parameters:
# - $1 OPTIONAL. Surrounded by quote marks, the same parameters as you would pass to `sortSRGBhexColorsColoraide.py` (see), but without any input file parameter. You don't want to specify any input file because this script repeatedly calls `sortSRGBhexColorsColoraide.py` with your parameters but a different source file paramater for each call. (At this writing the input file parameter is -i; don't use -i.) To clarify this, read on to examples.
# - $2 OPTIONAL. Anything, such as the word FROGBALF, which will cause the script to also search for `.hexplt` files in all subdirectories under the current directory, and call `sortSRGBhexColorsColoraide.py` for all such found `.hexplt` files (in subdirectories) also. If omitted, only `.hexplt` files in the current directory will be found and passed to `sortSRGBhexColorsColoraide.py`. To use this parameter but not $1, pass an empty string '' (two single or double quote marks in a row) for $1, thereby effectively passing nothing for $1 (which will cause the called script to use any default options).
# EXAMPLES
# At this writing, the following examples are current; if you find they don't work, refer to the documentation in `sortSRGBhexColorsColoraide.py`:
# Example that will use all defaults of this script and the script this calls; call it without any parameters and it will operate on all .hexplt palettes in this directory, using the first color in each as the first sort color:
#    allRGBhexColorSortInOkLab.sh
# Example that will specify an arbitrary first comparison color of f800fc and operate on all palettes in this directrory only (no recursion):
#    allRGBhexColorSortInOkLab.sh '-s f800fc'
# Example that will specify an arbitrary first comparison color for every palette in the current directory, and operate on all `.hexplt` files in all subdirectories also; note that the part which is a parameter to `sortSRGBhexColorsColoraide.py` is surrounded by single quote marks:
#    allRGBhexColorSortInOkLab.sh '-s f800fc' FROGBALF
# Example that will specify an arbitrary first comparison color for every palette in the current directory, and keep any duplicate colors (instead of the default behavior of removing duplicates) :
#    allRGBhexColorSortInOkLab.sh '-s f800fc -k'
# Example that will do the same but recurse into subdirectories, the last (really second) parameter, FROGBALF, being to this script:
#    allRGBhexColorSortInOkLab.sh '-s f800fc -k' FROGBALF
# NOTES
# - it would be redundant to pass the -w switch in $1; this script does that to fulfill the requirement of overwriting the original files.
# - this script previously called sortSRGBhexColorsColoraide.sh, which was functionally identical but more cumbersome to manage (as it used inline python code with a -c "run this python code" setup), so it was deprecated -- deleted -- and replaced with sortSRGBhexColorsColoraide.py.


# CODE
if [ "$1" ]
then
	additionalParametersToScript="$1"
fi

# if no $2 parameter passed to script, set maxdepth parameter 1 (current directory only); otherwise maxdepthParameter will be undefined, which will result in find's default search behavior to search subdirs:
if [ ! "$2" ]; then maxdepthParameter='-maxdepth 1'; fi

array=( $(find . $maxdepthParameter -type f -iname \*.hexplt -printf '%P\n') )

fullPathToPythonScript=$(getFullPathToFile.sh sortSRGBhexColorsColoraide.py)
if [ "$fullPathToPythonScript" == "" ]; then echo "ERROR: dependency script sortSRGBhexColorsColoraide.py not found in your PATH. Exit."; fi

for element in ${array[@]}
do
	echo "Running comparisons for file $element . . ."
	echo python $fullPathToPythonScript -i $element $additionalParametersToScript -w
	python $fullPathToPythonScript -i $element $additionalParametersToScript -w
	# print array re: https://stackoverflow.com/a/15692004/1397555
	# DEPRECATED -- redundant, as we're using the -w switch to overwrite the original file:
	# printf '%s\n' "${results[@]}" | tr -d '\15\32' > $element
	echo "DONE and result written back over file $element."
	echo ""
done