# DESCRIPTION
# Deletes all files with a given extension (e.g. .png) that have no companion file with the same base file name and a different extension (e.g. .ppm, .hexplt, anything). Useful for discarding undesired source format files whose undesirability have been ascertained by converting them to a target format

# USAGE
# Suppose you have so many .ppm files which you have converted to .png:
# ~
# img_01.ppm
# img_01.png
# img_02.ppm
# img_02.png
# img_03.ppm
# img_03.png
# img_04.ppm
# img_04.png
# ~
# -- and you decide you want to delete some of the source .ppm files because you don't like the pngs they render to. First delete the rendered pngs you don't like:
# ~
# img_01.ppm
# img_02.ppm
# img_02.png
# img_03.ppm
# img_03.png
# img_04.ppm
# ~
# -- and then run this script with parameters that tell this script $1 the source file extension to search for matching file names with extension $2, where $1 will be deleted if no file with extension $2 is found. Example:
# ./thisScript.sh ppm png
# After the script run, ppm files the had no png with the same base file name will be deleted:
# img_02.ppm
# img_02.png
# img_03.ppm
# img_03.png

# NOTES
# This script intended to run e.g. after NrandomHexColorSchemes.sh and renderAllHexPalettes-gm.sh (which invokes renderHexPalette-gm.sh repeatedly for every .hexplt file in a directory), or after autobrood fractorium renders to prune undesired fractal flame genomes.


echo REWORKING from another script. IN DEVELOPMENT.
exit
# CODE
echo UNTIL I IMPLEMENT a check whether there are any png files at all in the current path \(and\/or a warning prompt\)\, you must manually comment out this and the next line of code in this script before running it. THIS IS TO PREVENT you from accidentally running this script against a directory of \.hexplt files you have never rendered\, thereby deleting all of them\! BE SURE to uncomment these lines again after running this script\!
exit

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