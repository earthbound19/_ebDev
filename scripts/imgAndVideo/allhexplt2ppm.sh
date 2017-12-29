# DESCRIPTION
# Invokes hexplt2ppm.sh for every .hexplt file in the path from which this script is invoked (non-recusrive). Thereafter invokes imgs2imgsNN.sh for every resultant ppm file (to blow up the teensy ppm files to useable reference pallete png files. Result: all hex palette files in the current path are rendered to more accessible visual reference images.

# USAGE
# Invoke this script with one parameter, being the pixels across of the intended result png files, e.g.:
# thisScript.sh 640
# If you provide no parameter $1, it wil default to 640.


# CODE
if [ -z ${1+x} ]		# Checks for NON-value, ergo non-value returns true. Superfluous? Would checking for value without that -z *always* return false if no parameter $1 is passed to a script?
then
	blowUpToXpixPNG=640
else
	blowUpToXpixPNG=$1
fi

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

# OPTIONAL, on by default:
imgs2imgsNN.sh ppm png $blowUpToXpixPNG

echo "DONE. Color palettes have been rendered from all *.hexplt files in the current path and subpaths. Palette images are named after the source *.hexplt files."