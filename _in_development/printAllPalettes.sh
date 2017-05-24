# DESCRIPTION
# Invokes colorsGridFromHexScheme-gm.sh over all color schemes in ~/palettesRootDir.txt, writing resultant images into the current directory.

# TO DO? : parameterize this and pass on parameters to colorsGridFromHexScheme-gm.sh

if [ -e ~/palettesRootDir.txt ]
then
	palettesRootDir=$(< ~/palettesRootDir.txt)
	echo searching path $palettesRootDir . . .
	# find $palettesRootDir -iname '*.hexplt' > XPaugYhv6XYXsV5QcDFU_paletteFilesListTMP.txt
	find $palettesRootDir -iname '*.hexplt' > XPaugYhv6XYXsV5QcDFU_paletteFilesListTMP.txt
fi

while IFS= read -r line || [ -n "$line" ]
do
	baseFileName=`basename "$line"`
		# PARAMETERS TO SCRIPT BEING CALLED:
		# $1 hex color palette flat file list (input file).
		# $2 edge length of each square tile to be composited into final image.
		# $3 number of tiles accross of tiles-assembled image (columns)
		# $4 number of tiles down of tiles-assembled image (rows)
		# $5 Any value--if set, it will randomly shuffle the hex color files before compositing them to one image
	colorsGridFromHexScheme-gm.sh "$baseFileName" 200 9 800 foo
done < XPaugYhv6XYXsV5QcDFU_paletteFilesListTMP.txt

rm ./XPaugYhv6XYXsV5QcDFU_paletteFilesListTMP.txt