find . -iname \*.tif -o -iname \*.tiff -o -iname \*.png -o -iname \*.psd -o -iname \*.ora -o -iname \*.rif -o -iname \*.riff -o -iname \*.jpg -o -iname \*.jpeg -o -iname \*.gif -o -iname \*.bmp -o -iname \*.cr2 -o -iname \*.raw  -o -iname \*.crw -o -iname \*.pdf > imageFilesList.txt

mapfile -t imageFilesArray < ./imageFilesList.txt

for element in ${imageFilesArray[@]}
{
	imagePath=`expr match "$element" '\(.*\/\).*'`
	exiftool "$element" > "$element"_simpleEXIFinfo.txt
}