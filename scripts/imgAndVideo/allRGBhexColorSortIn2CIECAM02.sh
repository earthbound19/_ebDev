# DESCRIPTION
# runs RGBhexColorSortInCIECAM02.py with original file overwrite parameter against all .hexplt files in the current directory (no recursion into subdirectories).

# USAGE
# With more than one .hexplt file in your current directory, and RGBhexColorSortInCIECAM02.py either in your PATH or a copy of it in the current directory, and with this script also in your PATH or the current directory, invoke this script:
# ./CIECAM02_sort_all_palettes.sh


# CODE
array=(`gfind . -maxdepth 1 -type f -iname \*.hexplt -printf '%f\n'`)
# or to find every file,`gfind .` . .
for element in ${array[@]}
do
	Python RGBhexColorSortInCIECAM02.py $element foo
done