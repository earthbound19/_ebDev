# DESCRIPTION
# Deletes all files with a given extension (e.g. .png) that have no companion file with the same base file name and a different extension (e.g. .ppm, .hexplt, anything). Useful for discarding undesired source format files whose undesirability have been ascertained by converting them to a target format and viewing, then deleting the rendered target image.

# USAGE
# ./thisScript.sh sourceFileToDeleteThatHasThisExtension ifNoMatchedFileNameWithThisExtension, e.g.:
# ./thisScript.sh hexplt png
# -- will result in the delete of every file with an extension .hexplt that has no same-named file with a .png extension. NOTE that extensions passed as parameters must not include the dot (.).
# READ ON for a detailed explanation.
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


# CODE
echo UNTIL I IMPLEMENT a check whether there are any png files at all in the current path \(and\/or a warning prompt\)\, you must manually comment out this and the next line of code in this script before running it. THIS IS TO PREVENT you from accidentally running this script against a directory of \.hexplt files you have never rendered\, thereby deleting all of them\! BE SURE to uncomment these lines again after running this script\!
# exit

find ./*.$1 > files_list.txt

while read element
do
	fileNameNoExt=${element%.*}
	searchFileName="$fileNameNoExt"."$2"
	if ! [ -f $searchFileName ]
	then
		echo File matching source file name $element but with $2 extension NOT FOUND\; will DELETE source file\!
		rm $element
	fi
done < files_list.txt

rm files_list.txt