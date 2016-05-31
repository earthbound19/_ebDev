find . -iname \*.bmp > bmp_imgs.txt
mapfile -t imgs < bmp_imgs.txt
i=0
for element in "${imgs[@]}"
do
	imgFileNoExt=`echo $element | sed 's/\(.*\)\..\{1,4\}/\1/g'`
	if [ -a $imgFileNoExt.svg ]
	then
		der=duh
	else
	echo tracing $element . . .
	potrace -n -s --group -r 24 -C \#000000 --fillcolor \#ffffff $element
	i=$[ $i+1 ]
	fi
# ! --------
# OPTIONAL--COMMENT OUT IF YOU DON'T WANT THE ORIGINAL IMAGE DELETED! :
rm $element
# ! --------
done

echo Traced $i bitmaps. Done.

rm bmp_imgs.txt