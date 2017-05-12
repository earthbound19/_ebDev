# DESCRIPTION
# Resizes all images of type T (via parameter $1) in a path, by nearest-neighbor method, to target format F ($2), at size A x B ($3 x $4).

# USAGE
# Invoke this script with four parameters:
# $1 source format (without .)
# $2 destination format
# $3 scale by nearest neighbor method to pixels X
# $4 scale by nearest neighbor method to pixels Y. IF OMITTED, scales to $3 (X pix) by nearest neighbor preserving aspect ratio, e.g.:
# imgs2imgsnn.sh ppm png 640 480
# OR:
# imgs2imgsnn.sh ppm png 640


	# DEPRECATED command for unexpected behavior; it may be that the following command somehow caused nconvert to iterate over every source file format by wildcard? Removing the . from the command, it iterates over the list; whereas with the . it did so twice:
	# find . *.$1 > all_$1.txt
find *.$1 > all_$1.txt

mapfile -t all_imgs < all_$1.txt
# rm all_$1.txt

for img in ${all_imgs[@]}
do

			# IN WHICH THE BLOCK BELOW THIS FURTHER INDENTED is absurd because what I really want is a command like this:
			# gm convert 6x5gridRND_2017_05_06__01_51_14__099842100.ppm -scale 1200 out.png
			
				# IN PROGRESS: auto-upscale to pix Y given target X by figuring from pics' aspect.
				# thing $4 not $5 dev. commands:
				# if [ -z ${4+x} ]
				# then
				# derp=`gm identify $img`
				# pixX=`echo $derp | sed 's/.* \([0-9]\{1,\}\)x[0-9]\{1,\}+[0-9]\{1,\}+[0-9]\{1,\} .*/\1/g'`
				# pixY=`echo $derp | sed 's/.* [0-9]\{1,\}x\([0-9]\{1,\}\)+[0-9]\{1,\}+[0-9]\{1,\} .*/\1/g'`
				# echo pixX val is $pixX
				# echo pixY val is $pixY
				# echo pixY val is $pixY
				# 5x6 img upscaled to 850px X maintaining aspect = 850 x 1020
				# fi
				# exit

			# echo img is $img
	imgFileNoExt=`echo $img | sed 's/\(.*\)\..\{1,4\}/\1/g'`
			# echo imgFileNoExt val is\:
			# echo $imgFileNoExt
			# echo Running command\: nconvert -rtype quick -resize $3 $4 -out $2 -o $imgFileNoExt.$2 $img
	if [ ! -f $imgFileNoExt.$2 ]; then
		echo ~~
		echo RENDERING target file $imgFileNoExt.$2 as it does not exist . . .
		nconvert -rtype quick -resize $3 -out $2 -o $imgFileNoExt.$2 $img
		echo ~~
		else
			echo Target file $imgFileNoExt.$2 already exists\; delete the file if you wish to re-render it\; SKIPPING RENDER . . .
	fi
done