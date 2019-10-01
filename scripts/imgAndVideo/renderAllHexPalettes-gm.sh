# DESCRIPTION
# Calls renderHexPalette-gm.sh for every .hexplt file in the path from which this script is invoked (recusrive). Result: all hex palette files in the current path are rendered.

# USAGE
# ./renderAllHexPalettes-gm.sh


# CODE
array=(`gfind . -type f -iname \*.hexplt`)

for element in ${array[@]}
do
	echo ~~~~
	echo invoking renderHexPalette-gm.sh for $element . . .
	renderHexPalette-gm.sh $element 80 0
done

echo "DONE. Color palettes have been rendered from all *.hexplt files in the current path and subpaths for which there was not already a corresponding .png image. Palette images are named after the source *.hexplt files."