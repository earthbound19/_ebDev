# DESCRIPTION
# Converts (almost?) any camera raw format image file into a .tif file via dcraw.

# DEPENDENCIES
# dcraw

# USAGE
# Invoke this script with one parameter, being a raw image filename in your PATH. e.g.:
#  dcraw2tif.sh rawImageFileName.cr2
# NOTE: to quickly rip the embedded jpegs (if there be any) out of all images, don't
# even use this script, just do:
# dcraw -e *.CR2
# An interesting thing is to see raw sensor values in white scale:
# dcraw -D -T *.CR2


# CODE
# I feel stupid that this far more efficient and elegant method of extracting file base names and extensions has eluded me for years, re: https://www.cyberciti.biz/faq/unix-linux-extract-filename-and-extension-in-bash/ -- this will speed up at least a few scripts.
fileName="${1%.*}"
# fileExt=`echo "${1##*.}"`

# - SCRATCHED -D switch; it makes the image very white. ? AND -W makes it very black. Together, they make it gray. (I assume that with good paramters they can adjust the white and black points.)
if [ ! -e $fileName.tif ]
then
  echo Target file "$fileName".tif does not exist. Will render.
    # Something I tried and it didn't help much; maybe I know too little;
    # Re: http://www.guillermoluijk.com/tutorial/dcraw/index_en.htm 
    # echo Performing sat. anaylsys pass . . .
    # dcraw -v -w -H 6 -f -T "$fileName"
  # dcraw -v -w +M -o 1 -j -W -q 3 -T -H 1 -p embed -h -4 \
  # "$1"
  dcraw -T -h -o 1 -g 1 1 -w -H 1 -S 15360 \
  "$1"
  # +M -w -6 -W  -q 3 -h \
  # -S 1 -H 1 -p embed -h \
else
  echo Target file "$fileName".tif already exists. Will not overwrite.
fi
# -h \
# NOTE: move those additional optional switches line one up before the "$1" and uncomment them to use them.

# dcraw options, used ones indented:
# 	-6        Write 16-bit instead of 8-bit
# 	-v        Print verbose messages
# -c        Write image data to standard output
# -e        Extract embedded thumbnail image
# -i        Identify files without decoding them
# -i -v     Identify files and show metadata
# 	-z        Change file dates to camera timestamp
#		-w        Use camera white balance, if possible
# -a        Average the whole image for white balance
# -A <x y w h> Average a grey box for white balance
# -r <r g b g> Set custom white balance
# 	+M		/-M     Use/don't use an embedded color matrix (using +M)
# -C <r b>  Correct chromatic aberration
# -P <file> Fix the dead pixels listed in this file
# -K <file> Subtract dark frame (16-bit raw PGM)
# -k <num>  Set the darkness level
# -S <num>  Set the saturation level
# -n <num>  Set threshold for wavelet denoising
# -H [0-9]  Highlight mode (0=clip, 1=unclip, 2=blend, 3+=rebuild)
# -t [0-7]  Flip image (0=none, 3=180, 5=90CCW, 6=90CW)
# 	-o [0-6]  Output colorspace (raw,sRGB,Adobe,Wide,ProPhoto,XYZ,ACES) (using 1)
# -o <file> Apply output ICC profile from file
# -p <file> Apply camera ICC profile from file or "embed"
# -d        Document mode (no color, no interpolation)
# -D        Document mode without scaling (totally raw)
# -j        Don't stretch or rotate raw pixels
# 	-W        Don't automatically brighten the image
# -b <num>  Adjust brightness (default = 1.0)
# -g <p ts> Set custom gamma curve (default = 2.222 4.5)
# 	-q [0-3]  Set the interpolation quality	(using 3 re: Use Adaptive Homogeneity-Directed (AHD) interpolation.)
# -h        Half-size color image (twice as fast as "-q 0")
# -f        Interpolate RGGB as four colors
# 	-m <num>  Apply a 3x3 median filter to R-G and B-G (using 2)
# -s [0..N-1] Select one raw image or "all" from each file
# -4        Linear 16-bit, same as "-6 -W -g 1 1"
# 	-T        Write TIFF instead of PPM
