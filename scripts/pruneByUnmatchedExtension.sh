# DESCRIPTION
# Deletes all files in the current folder (non-recursive) with a given extension (e.g. .png) that have no companion file with the same base file name and a different extension (e.g. .ppm, .hexplt, anything). Useful for discarding e.g. undesired source format files whose undesirability have been ascertained by converting them to a target format and viewing, then deleting the rendered target image.

# WARNING
# If you use this on files with unintented dissimilar base file names such as thisFractalRenderFlame.flame.png, you will lose work!

# USAGE
# ./thisScript.sh extensionOfSourceFilesToDelete ifNoMatchedFileNameWithThisExtension, e.g.:
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
find ./*.$1 > files_list.txt

echo "# PROPOSED DELETES" >> tmp_Dn6M_proposed_deletes.sh.txt
echo "# THE FOLLOWING COMMANDS will delete the given files. If you approve of this, rename this script from tmp_Dn6M_proposed_deletes.sh.txt to iKnowThisIsWhatIwantToDo.sh, chmod +x it, and execute it." >> tmp_Dn6M_proposed_deletes.sh.txt

while read element
do
	fileNameNoExt=${element%.*}
	searchFileName="$fileNameNoExt"."$2"
	if ! [ -f $searchFileName ]
	then
		echo File matching source file name $element but with $2 extension NOT FOUND\; will PROPOSE TO DELETE source file\!
		echo "rm $element" >> tmp_Dn6M_proposed_deletes.sh.txt
	fi
done < files_list.txt

rm files_list.txt

echo DONE. Open the file tmp_Dn6M_proposed_deletes.sh.txt and follow the instructions therein.