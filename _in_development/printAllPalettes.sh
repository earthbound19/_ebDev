if [ -e ~/palettesRootDir.txt ]
then
	palettesRootDir=$(< ~/palettesRootDir.txt)
	echo feijfi $palettesRootDir
	# find $palettesRootDir -iname '*.hexplt' > XPaugYhv6XYXsV5QcDFU_paletteFilesListTMP.txt
	find $palettesRootDir -iname '*.hexplt' > XPaugYhv6XYXsV5QcDFU_paletteFilesListTMP.txt
fi

# TO DO: wasn't there some advantage to using a read loop like the following line that I read about? Discover if so, and if so, adapt all scripts using a read loop to work like so:
while IFS= read -r line || [ -n "$line" ]
do
	baseFileName=`basename "$line"`
	renderHexPalette-gm.sh "$baseFileName"
done < XPaugYhv6XYXsV5QcDFU_paletteFilesListTMP.txt