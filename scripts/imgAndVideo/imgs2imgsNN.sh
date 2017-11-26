# DESCRIPTION
# Resizes all images of type T (via parameter $1) in a path, by nearest-neighbor method, to target format F ($2), at size A x B ($3 x $4).

# USAGE
# Invoke this script with four parameters:
# $1 source format (without .)
# $2 destination format
# $3 scale by nearest neighbor method to pixels X
# $4 scale by nearest neighbor method to pixels Y. IF OMITTED, scales to $3 (X pix) by nearest neighbor preserving aspect ratio. Example command for that:
# imgs2imgsnn.sh ppm png 640
# OR, to force a given x by y dimension:
# imgs2imgsnn.sh ppm png 640 480


	# DEPRECATED command for unexpected behavior; it may be that the following command somehow caused nconvert to iterate over every source file format by wildcard? Removing the . from the command, it iterates over the list; whereas with the . it did so twice:
	# find . *.$1 > all_$1.txt
find *.$1 > all_$1.txt

while read img
do
			# echo img is $img
	imgFileNoExt=`echo $img | gsed 's/\(.*\)\..\{1,4\}/\1/g'`
	if [ ! -f $imgFileNoExt.$2 ]; then
		echo ~~
		echo RENDERING target file $imgFileNoExt.$2 as it does not exist . . .
			# DEPRECATED:
			# nconvert -rtype quick -resize $3 -out $2 -o $imgFileNoExt.$2 $img
			# ex. command of newly preferred tool:
			# gm convert 6x5gridRND_2017_05_06__01_51_14__099842100.ppm -scale 1200 out.png
		# If params $3 or $4 were not passed to the script, the command will simply be empty where they are (on the following line of code), and it should still work:
		gm convert $img -scale $3 $4 $imgFileNoExt.$2
		echo ~~
# exit
		else
			echo Target file $imgFileNoExt.$2 already exists\; delete the file if you wish to re-render it\; SKIPPING RENDER . . .
	fi
done < all_$1.txt

rm all_$1.txt