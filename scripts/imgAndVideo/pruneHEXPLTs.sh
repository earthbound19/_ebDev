# DESCRIPTION
# Deletes ~.hexplt files for which there is no corresponding png palette render. Intended to run after NrandomHexColorSchemes.sh and renderAllHexPalettes-gm.sh (which invokes renderHexPalette-gm.sh repeatedly for every .hexplt file in a directory).

# USAGE
# Run the scripts under DESCRIPTION first. Delete any rendered palette (png) images for which you have distaste. Then run this script--it will delete all corresponding .hexplt files:
# ./thisScript.sh

gfind *.hexplt > all_hexplt.txt
dos2unix all_hexplt.txt

while read element
do
	searchImageFileName="$element"".png"
			# echo searchImageFileName is\: $searchImageFileName
	if [ ! -e $searchImageFileName ]
	then
		echo Corresponding image NOT FOUND\; will DELETE palette file $element !
		rm $element
	fi
done < all_hexplt.txt

rm all_hexplt.txt