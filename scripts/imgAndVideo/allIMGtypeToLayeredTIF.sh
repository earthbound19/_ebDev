# Template command:
# gm convert 1.tif 2.tif 3.tif 4.tif out.tif

gfind *.$1 > all_$1.txt

while read element
do
	echo $element
done < all_$1.txt