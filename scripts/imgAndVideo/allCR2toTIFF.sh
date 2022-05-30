# DESCRIPTION
# Calls dcraw2tif.sh for every .CR2 (OR .cr2 (lowercase extension) format file in the current directory, thereby making .tif format conversions of them.


# CODE
allCR2S=(*.CR2 *.cr2)
for element in ${allCR2S[@]}
do
	dcraw2tif.sh $element
done