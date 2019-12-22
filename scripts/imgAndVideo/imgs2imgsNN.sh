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

# NOTES:
# A previous verson of this script conditionally used IrfanView for ppms
# because another script I developed made ppms that only IrfanView could convert
# to pngs (I think I was making non-standard ppms). That script now makes
# proper ppms (it fills them with integer instead of hex RGB values). If you
# have ppms with hex values, hack this script to use the IrfanView option,
# though it might be better to recreate or conver the ppms to a format that
# has wider acceptance.

# TO DO
# Assign script paramaters to named variables and use the named variables.


# CODE

array=(`gfind . -maxdepth 1 -type f -iname \*.$1 -printf '%f\n'`)
for img in ${array[@]}
do
	imgFileNoExt=${img%.*}
	imgFileExt=${img##*.}
	targetFileName=$imgFileNoExt.$2
	if [ ! -f $targetFileName ]; then
			# IrfanView option:
			# i_view32.exe $img /resize_long=$3 /aspectratio /convert=$targetFileName
				# ex. GraphicsMagick command:
				# gm convert 6x5gridRND_2017_05_06__01_51_14__099842100.ppm -scale 1200 out.png
			# If params $3 or $4 were not passed to the script, the command will simply be empty where they are (on the following line of code), and it should still work:
			gm convert $img -scale $3 $4 $targetFileName
#		fi
		echo converted to $targetFileName . .
	else
		echo target file $targetFileName already exists\; skipping.
	fi
done