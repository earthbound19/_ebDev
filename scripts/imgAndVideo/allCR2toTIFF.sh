allCR2S=(*.CR2)
for element in ${allCR2S[@]}
do
	dcraw2tif.sh $element
done