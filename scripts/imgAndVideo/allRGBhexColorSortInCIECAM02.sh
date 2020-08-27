# DESCRIPTION
# runs RGBhexColorSortInCIECAM02.py with original file overwrite parameter against all .hexplt files in the current directory (no recursion into subdirectories), comparing them by sorting nearest to black-black-black-magenta first (makes a temporary copy of every hexplt file with black as the first color, runs the comparison, then removes the added color).

# USAGE
# With more than one .hexplt file in your current directory, and RGBhexColorSortInCIECAM02.py either in your PATH or a copy of it in the current directory, and with this script also in your PATH or the current directory, run this script:
#    allRGBhexColorSortInCIECAM02.sh
# SEE ALSO `allRGBhexColorSortInCAM16-UCS.sh.`


# CODE
# TO DO
# Parameterize arbitrary sort color; default to black-black-black-magenta if not provided.
scriptLocation=`whereis RGBhexColorSortInCIECAM02.py | sed 's/.* \(.*\/RGBhexColorSortInCIECAM02.py\).*/\1/g'`

array=(`find . -maxdepth 1 -type f -iname \*.hexplt -printf '%f\n'`)
# or to find every file,`find .` . .
for element in ${array[@]}
do
	echo "Running comparisons for file $element . . ."
	python $scriptLocation $element foo '#0a000a'
done