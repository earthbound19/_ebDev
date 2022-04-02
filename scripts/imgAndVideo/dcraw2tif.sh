# DESCRIPTION
# Converts (almost?) any camera raw format image file into a .tif file via dcraw. See NOTES for a command to quickly extract any embedded thumbnails.

# DEPENDENCIES
#    dcraw

# USAGE
# Run this script with one parameter, which is a raw image filename in your PATH. e.g.:
#    dcraw2tif.sh rawImageFileName.cr2
# NOTES
# - See the comment about the -W option in the code.
# - To quickly rip the embedded jpegs (if there be any) out of all images, don't even use this script, run:
#    dcraw -e *.CR2
# - An interesting thing is to see raw sensor values in white scale:
#    dcraw -D -T inputFile.cr2
# - See documentation comments throughout code for details on dcraw options, etc.
# - I may have read somewhere that if you can find a camera profile for your camera and use it with dcraw, you'll get output as good as or better than manufacturer utilities. That may be something to explore.


# CODE
# I feel stupid that this far more efficient and elegant method of extracting file base names and extensions has eluded me for years, re: https://www.cyberciti.biz/faq/Unix-linux-extract-filename-and-extension-in-bash/ -- this will speed up at least a few scripts.
fileName="${1%.*}"
# fileExt=`echo "${1##*.}"`

if [ ! -f $fileName.tif ]
then
  echo Target file "$fileName".tif does not exist. Will render.
		# Something I tried and it didn't help much; maybe I know too little;
		# Re: http://www.guillermoluijk.com/tutorial/dcraw/index_en.htm 
		#
		# A previous command that produces drab, too dark results:
		# dcraw -T -w -W -o 1 +M "$1"
		# use: -6 ? [for what switch?]
  # DEV ATTEMPTED COMMAND IMPROVE; RE: https://www.dpreview.com/forums/post/54644725 and responses in the thread;
  # Also those options documented, re: http://www.guillermoluijk.com/tutorial/dcraw/index_en.htm
  # -v print conversion details
  # -w use camera white for shot if possible
  # -H 2 make blown areas neutral gray. -H 1 means don't clip, which is ok for images where there's no blowout risk. -H 0 means don't clip.
  # '-r 1 1 1 1' no custom white balance [not used here; I hope and assume it's the default
  # '-o 1' output to sRGB color space
  # '-q 3' AHD Bayer demosaicing; used here even though the dcraw author states the best is used per camera.
  # '-4' generate 16-bit file
  # -T output tiff
  # ALSO FROM DOC: https://im.snibgo.com/dcrawwb.htm :
  # -g (different gamma options) -- do I want to use this? default (2.222 4.5); from one of the linked pages though: "Visually, the best result is from -g 1 0" and "Any -g other than -g 1 0 loses data, unless the image is auto-brightened." BUT when I do that it gives way too contrasty results, NOT USING. From tests it seems indeed the default 2.222 4.5 is used and may be best. Apparently (from a discussion linked to from here) '-g 1 1' is no gamma transform. My try of that gives similarly (or identically?) undesirable results to '-g 1 0'.
  # -z Change file dates to camera timestamp
  # -p <file> Apply camera ICC profile from file or "embed" -- use this?
  # -W Don't automatically brighten the image -- NOT USING THIS; re https://im.snibgo.com/gameql.htm: "However, auto-brighten has clipped highlights in all cases, and none of the -H settings cure this." NOTE: for quickly usable images maybe remove that -W from the below command. - when I tried NOT using this, the image came out waay too dark.
  # -6 Write 16-bit instead of 8-bit -- use this?
  # -4 Linear 16-bit, same as "-6 -W -g 1 1" -- use this?
  # A new command from experimenting with the above, which produces much better results:
  # NOTE: maybe there's an "unbrightened but most useful values if you brighten them well" quality to the combination of switches '-g 1 0 -W' ?
  # ALSO SEE: https://www.cambridgeincolour.com/forums/thread47002.htm -- the "4) sRGB II" preset given there is what I settled on here, which is "..exactly the same as opening the CR2 in RawDigger and saving it as 'RGB render', with 'As Shot' white balance."
  dcraw -v -w -H 2 -q 3 -o 1 -6 -T "$1"
else
  echo Target file "$fileName".tif already exists. Will not overwrite.
fi
# -h \
# NOTE: move those additional optional switches line one up before the "$1" and uncomment them to use them.

# dcraw options, used ones indented:
# -6        Write 16-bit instead of 8-bit
# -v        Print verbose messages
# -c        Write image data to standard output
# -e        Extract embedded thumbnail image
# -i        Identify files without decoding them
# -i -v     Identify files and show metadata
# -z        Change file dates to camera timestamp
# -w        Use camera white balance, if possible
# -a        Average the whole image for white balance
# -A <x y w h> Average a grey box for white balance
# -r <r g b g> Set custom white balance
# +M		/-M     Use/don't use an embedded color matrix (might want to use +M?)
# -C <r b>  Correct chromatic aberration
# -P <file> Fix the dead pixels listed in this file
# -K <file> Subtract dark frame (16-bit raw PGM)
# -k <num>  Set the darkness level
# -S <num>  Set the saturation level
# -n <num>  Set threshold for wavelet denoising
# -H [0-9]  Highlight mode (0=clip, 1=unclip, 2=blend, 3+=rebuild)
# -t [0-7]  Flip image (0=none, 3=180, 5=90CCW, 6=90CW)
# -o [0-6]  Output colorspace (raw,sRGB,Adobe,Wide,ProPhoto,XYZ,ACES)
# -o <file> Apply output ICC profile from file
# -p <file> Apply camera ICC profile from file or "embed"
# -d        Document mode (no color, no interpolation)
# -D        Document mode without scaling (totally raw)
# -j        Don't stretch or rotate raw pixels
# -W        Don't automatically brighten the image
# -b <num>  Adjust brightness (default = 1.0)
# -g <p ts> Set custom gamma curve (default = ?)
# -q [0-3]  Set the interpolation quality	(may want to use 3: Adaptive Homogeneity-Directed (AHD) interpolation.)
# -h        Half-size color image (twice as fast as "-q 0")
# -f        Interpolate RGGB as four colors
# -m <num>  Apply a 3x3 median filter to R-G and B-G
# -s [0..N-1] Select one raw image or "all" from each file
# -4        Linear 16-bit, same as "-6 -W -g 1 1"
# -T        Write TIFF instead of PPM
