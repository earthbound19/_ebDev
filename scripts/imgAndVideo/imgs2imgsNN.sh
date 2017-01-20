# DESCRIPTION
# Resizes all images of type T (via parameter $1) in a path, by nearest-neighbor method, to target format F ($2), at size A x B ($3 x $4).

# USAGE
# PARAMETERS: $1 src format (without .) $2 dst format $3 scalePixX $4 scalePixY

# TO DO
		# Make it do no resizing if no params 3 and 4 given; e.g. adapt htis:
		# if [ ! -z ${5+x} ]
		# then
			# rescaleParams="-vf scale=$5:flags=neighbor"
		# fi

cygwinFind . *.$1 > all_$1.txt
sed -i 

mapfile -t all_imgs < all_$1.txt
rm all_$1.txt

for img in ${all_imgs[@]}
do
			# echo img is $img
	imgFileNoExt=`echo $img | sed 's/\(.*\)\..\{1,4\}/\1/g'`
			# echo imgFileNoExt val is\:
			# echo $imgFileNoExt
			echo running command\:
			echo nconvert -rtype quick -resize $3 $4 -out $2 -o $imgFileNoExt.$2 $img
	nconvert -rtype quick -resize $3 $4 -out $2 -o $imgFileNoExt.$2 $img
done