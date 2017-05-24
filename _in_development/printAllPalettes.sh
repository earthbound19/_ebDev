if [ -e ~/palettesRootDir.txt ]
then
	palettesRootDir=$(< ~/palettesRootDir.txt)
	echo feijfi $palettesRootDir
	# find $palettesRootDir -iname '*.hexplt' > XPaugYhv6XYXsV5QcDFU_paletteFilesListTMP.txt
	find $palettesRootDir -iname '*.hexplt' > XPaugYhv6XYXsV5QcDFU_paletteFilesListTMP.txt
fi

while IFS= read -r line || [ -n "$line" ]
do
	baseFileName=`basename "$line"`
	colorsGridFromHexScheme-gm.sh "$baseFileName"
done < XPaugYhv6XYXsV5QcDFU_paletteFilesListTMP.txt