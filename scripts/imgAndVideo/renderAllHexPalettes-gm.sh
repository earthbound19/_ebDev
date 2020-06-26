# DESCRIPTION
# Calls renderHexPalette-gm.sh for every .hexplt file in the path (non-recrusive) from which this script is invoked. Result: all hex palette files in the current path are rendered.

# USAGE
# ./renderAllHexPalettes-gm.sh
# NOTE: to make this recursive (render in all sub-directories), temporily hack this by deleting the "-maxdepth 1" parameter.

# CODE
array=(`gfind . -maxdepth 1 -type f -iname \*.hexplt`)

for element in ${array[@]}
do
	echo ~~~~
	echo invoking renderHexPalette-gm.sh for $element . . .
	renderHexPalette-gm.sh $element
done

echo "DONE. Color palettes have been rendered from all *.hexplt files in the current path and subpaths for which there was not already a corresponding .png image. Palette images are named after the source *.hexplt files."