# DESCRIPTION
# Resizes all images of type T (via parameter $1) in a path, by nearest-neighbor method, to target format F ($2), at size A x B ($3 x $4).

# USAGE
# Invoke this script with four parameters:
# $1 source format (without .)
# $2 destination format
# $3 scale by nearest neighbor method to pixels X
# $4 scale by nearest neighbor method to pixels Y
# e.g. imgs2imgsnn.sh ppm png 640 480

# TO DO
		# Make it do no resizing if no params 3 and 4 given; e.g. adapt htis:
		# if [ ! -z ${5+x} ]
		# then
			# rescaleParams="-vf scale=$5:flags=neighbor"
		# fi

	# DEPRECATED command for unexpected behavior; it may be that the following command somehow caused nconvert to iterate over every source file format by wildcard? Removing the . from the command, it iterates over the list; whereas with the . it did so twice:
	# cygwinFind . *.$1 > all_$1.txt
cygwinFind *.$1 > all_$1.txt

mapfile -t all_imgs < all_$1.txt
rm all_$1.txt

for img in ${all_imgs[@]}
do
			# echo img is $img
	imgFileNoExt=`echo $img | sed 's/\(.*\)\..\{1,4\}/\1/g'`
			# echo imgFileNoExt val is\:
			# echo $imgFileNoExt
			# echo Running command\: nconvert -rtype quick -resize $3 $4 -out $2 -o $imgFileNoExt.$2 $img
	nconvert -rtype quick -resize $3 $4 -out $2 -o $imgFileNoExt.$2 $img
done