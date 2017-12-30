# DESCRIPTION
# Invokes hexplt2ppm.sh for every .hexplt file in the path from which this script is invoked (non-recusrive). Thereafter invokes imgs2imgsNN.sh for every resultant ppm file (to blow up the teensy ppm files to useable reference pallete png files. Result: all hex palette files in the current path are rendered to more accessible visual reference images.

# USAGE
# Invoke this script with one parameter, being the pixels across of the intended result png files, e.g.:
# thisScript.sh 640
# If you provide no parameter $1, it wil default to 640.


echo "finding all *.hexplt files in the current path and subpaths . . ."
gfind *.hexplt > all_hexplt.txt
dos2unix all_hexplt.txt

while read fileName
do
	echo ~~~~
	echo invoking hexplt2ppm.sh for $fileName . . .
	hexplt2ppm.sh $fileName $1 0
done < all_hexplt.txt

rm all_hexplt.txt

echo "DONE. Color palettes have been rendered from all *.hexplt files in the current path and subpaths. Palette images are named after the source *.hexplt files."