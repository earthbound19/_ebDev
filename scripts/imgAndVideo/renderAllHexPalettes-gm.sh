# DESCRIPTION
# Calls renderHexPalette-gm.sh for every .hexplt file in the path from which this script is invoked (non-recusrive). Result: all hex palette files in the current path is rendered.

# USAGE
# thisScript.sh


# CODE
# UNCOMMENT the next two lines and comment out the third line from here to work on all subdirs also:
# echo "finding all *.hexplt files in the current path and subpaths . . ."
# array=(`gfind *.hexplt`)
array=(`gfind . -maxdepth 1 -type f -iname \*.hexplt -printf '%f\n'`)

for element in ${array[@]}
do
	echo ~~~~
	echo invoking renderHexPalette-gm.sh for $element . . .
	renderHexPalette-gm.sh $element 80 0
done

echo "DONE. Color palettes have been rendered from all *.hexplt files in the current path and subpaths. Palette images are named after the source *.hexplt files."