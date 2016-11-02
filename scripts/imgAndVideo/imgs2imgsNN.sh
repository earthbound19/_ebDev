# USAGE
# PARAMETERS: $1 src format (without .) $2 dst format $3 scalePixX $4 scalePixY

cygwinFind . *.$1 > all_$1.txt

mapfile -t all_imgs < all_$1.txt

for img in ${all_imgs[@]}
do
			# echo img is $img
	imgFileNoExt=`echo $img | sed 's/\(.*\)\..\{1,4\}/\1/g'`
			# echo imgFileNoExt val is\:
			# echo $imgFileNoExt
	nconvert -rtype quick -resize $3 $4 -out $2 -o $imgFileNoExt.$2 $img
done