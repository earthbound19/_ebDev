# DESCRIPTION
# Calls dcraw2tif.sh for every .CR2 format file in the current directory (thereby making .tif format conversions of them).


# CODE
allCR2S=(*.CR2)
for element in ${allCR2S[@]}
do
	dcraw2tif.sh $element
done