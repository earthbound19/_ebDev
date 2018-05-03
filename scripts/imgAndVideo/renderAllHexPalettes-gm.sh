# DESCRIPTION
# Calls renderHexPalette-gm.sh for every .hexplt file in the path from which this script is invoked (non-recusrive). Result: all hex palette files in the current path is rendered.

# USAGE
# thisScript.sh


# CODE
echo "finding all *.hexplt files in the current path and subpaths . . ."
gfind *.hexplt > all_hexplt.txt
dos2unix all_hexplt.txt

while read fileName
do
	echo ~~~~
	echo invoking renderHexPalette-gm.sh for $fileName . . .
	renderHexPalette-gm.sh $fileName 80 0
done < all_hexplt.txt

rm all_hexplt.txt

echo "DONE. Color palettes have been rendered from all *.hexplt files in the current path and subpaths. Palette images are named after the source *.hexplt files."