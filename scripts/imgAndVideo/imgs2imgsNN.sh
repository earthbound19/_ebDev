# DESCRIPTION
# Resizes all images of type T (via parameter $1) in a path, by nearest-neighbor method, to target format F ($2), at size A x B ($3 x $4). Uses GraphicsMagick, unless the file is ppm format, and in that case it uses IrfanView.

# USAGE
# Invoke this script with the following parameters
# $1 source format (without .)
# $2 destination format
# $3 scale by nearest neighbor method to pixels X
# $4 scale by nearest neighbor method to pixels Y. IF OMITTED, scales to $3 (X pix) by nearest neighbor preserving aspect ratio. NOT ENABLED for ppm (IrfanView) conversion; for that use only $3. See irfanView2imgNN.sh comments for options you may manually use to specify non-ratio sizes.
# Example command:
# imgs2imgsnn.sh ppm png 640
# OR, to force a given x by y dimension:
# imgs2imgsNN.sh ppm png 640 480

# DEPENDENCIES
# GraphicsMagick, possibly IrfanView, both in your $PATH.

# TO DO
# Make irfanvew call alter if $4 parameter present.
# Assign script paramaters to named variables and use the named variables.


# CODE
	# DEPRECATED command for unexpected behavior; it may be that the following command somehow caused nconvert to iterate over every source file format by wildcard? Removing the . from the command, it iterates over the list; whereas with the . it did so twice:
	# find . *.$1 > all_$1.txt
find *.$1 > all_$1.txt

while read img
do
	imgFileNoExt=${img%.*}
	imgFileExt=${img##*.}
	targetFileName=$imgFileNoExt.$2
	if [ ! -f $targetFileName ]; then
		echo RENDERING target file $targetFileName as it does not exist . . .
		# If the source file format is ppm, use Irfanview to do the conversion (at this writing, I find that only IrfanView reads ppm format). Otherwise, use GraphicsMagick.
		if [ $imgFileExt == "ppm" ]; then
			# option that forces a given size:
			i_view32.exe $img /resize=\($3,$4\) /convert=$targetFileName
			# option that preserves aspect setting dimension for longest side:
			# i_view32.exe $img /resize_long=$3 /aspectratio /convert=$targetFileName
		else
				# ex. GraphicsMagick command:
				# gm convert 6x5gridRND_2017_05_06__01_51_14__099842100.ppm -scale 1200 out.png
			# If params $3 or $4 were not passed to the script, the command will simply be empty where they are (on the following line of code), and it should still work:
			gm convert $img -scale $3 $4 $targetFileName
		fi
		echo ~~
	fi
done < all_$1.txt

rm all_$1.txt