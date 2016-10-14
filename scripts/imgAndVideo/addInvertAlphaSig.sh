# DESCRIPTION
# Adds a signature or watermark image to an image in an inverse cut-out style (see USAGE).

# USAGE
# Invoke with two parameters, being
# $1 the image on which to overlay a signature with an invert background, with a transparent "cut-out" signature within
# $2 the image to use for the transparent signature cut-out, with the cut-out area being white in the image, and the area for inverted colors being fully transparent.
# EXAMPLE INVOCATION:
# addInvertAlphaSig.sh in.png signature_alpha.png

nconvert -negate -canvas 7%%%% 7%%%% bottom-right -bgcolor 255 255 255 -o pic_invert_corner_for_sig_alpha.png $1

magick pic_invert_corner_for_sig_alpha.png -alpha set -gravity center -extent 89x50 $2 -compose DstIn -composite pic_invert_corner_with_sig_alpha.png

# TO DO before the following: make it not crop off the part of the source image that doesn't fit, OR expand the canvas of pic_invert~ to the original image size, without any background; re: http://stackoverflow.com/a/12186759
magick pic_invert_corner_with_sig_alpha.png -background none -gravity SouthEast -extent `identify -ping -format "%wx%h\!" $1` temp.png
		# re: http://www.imagemagick.org/Usage/thumbnails/#glass_bubble
		# and http://www.imagemagick.org/script/command-line-options.php#gravity
		# template command: magick border_overlay.png srcImg.png -gravity center -compose DstOver -composite result.png
magick temp.png $1 -gravity SouthEast -compose DstOver -composite __img_with_sig.png

rm pic_invert_corner_for_sig_alpha.png temp.png pic_invert_corner_with_sig_alpha.png