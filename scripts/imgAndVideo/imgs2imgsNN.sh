# DESCRIPTION
# Resizes all images of type T (via parameter $1) in a path, by
# nearest-neighbor method, to target format F ($2), at size A x B ($3 x $4).
# (Nearest neighbor method will keep hard egdes, or look "pixelated.")
# Uses GraphicsMagick, unless the file is ppm format, and in that case it
# uses IrfanView.

# USAGE
# NOTE that as this auto-switches to IrfanView as needed, it supercedes
# the now deleted irfanView2imgNN.sh and allIrfanView2imgNN.sh scripts.
# To use:
# Invoke this script with the following parameters
# $1 source file format (or extension, without .)
# $2 destination format
# $3 scale by nearest neighbor method to pixels X
# $4 Optional. Force this Y-dimension, regardless of aspect. Scales by
#  nearest neighbor method to pixels Y. ONLY USED for ppms. Ignored for
#  all other types (aspect kept). SEE COMMENTS in i_view32.exe code
#  lines area for options to maintain aspect and/or rotate image (wanted
#  for my purposes at times).
# Example command:
# imgs2imgsnn.sh ppm png 640
# OR, to force a given x by y dimension for a ppm:
# imgs2imgsNN.sh ppm png 640 480

# DEPENDENCIES
# GraphicsMagick and/or IrfanView, both in your $PATH.

# CODE
array=(`gfind . -maxdepth 1 -type f -iname \*.$1 -printf '%f\n'`)
for img in ${array[@]}
do
	imgFileNoExt=${img%.*}
	imgFileExt=${img##*.}
	targetFileName=$imgFileNoExt.$2
	if [ ! -f $targetFileName ]; then
		# if source file is ppm, use IrfanView or graphicsmagic
		# (uncomment your preference) to convert.
		if [ $imgFileExt == ppm ]; then
			echo converting ppm file via i_view32 . . .
			# re: http://www.etcwiki.org/wiki/IrfanView_Command_Line_Options
			# ROTATE 90 DEGREES OPTION; uncomment next line (used with other options) :
			# extraIrfanViewParam1="/rotate_r"
				# FORCE ARBITRARY DIMENSIONS (aspect) OPTION:
			i_view32.exe $img /resize_long=$3 /resize_short=$4 $extraIrfanViewParam1 /convert=$targetFileName
				# MAINTAIN ASPECT OPTION:
			# i_view32.exe $img /resize_long=$3 /aspectratio $extraIrfanViewParam1 $extraIrfanViewParam2 /convert=$targetFileName
		# otherwise use graphicsmagic:
		else
			echo converting image via graphicsmagick . . .
			# If params $3 or $4 were not passed to the script, the command will simply be empty where they are (on the following line of code), and it should still work:
			gm convert $img -scale $3 $targetFileName
		fi
		echo converted to $targetFileName . .
	else
		echo target file $targetFileName already exists\; skipping.
	fi
done