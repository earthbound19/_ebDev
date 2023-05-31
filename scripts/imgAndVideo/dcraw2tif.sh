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
# TO DO:
# - use libraw instead; in tests with the same parameters there is much less hue distortion: https://www.libraw.org/ https://github.com/LibRaw/LibRaw
# I feel stupid that this far more efficient and elegant method of extracting file base names and extensions has eluded me for years, re: https://www.cyberciti.biz/faq/Unix-linux-extract-filename-and-extension-in-bash/ -- this will speed up at least a few scripts.
fileNameNoExt="${1%.*}"
targetFileName=$fileNameNoExt.tiff

# OPTION: adjust brightness (default 1.0); uncomment if you wish to use this:
# brightnessParameter="-b 3"

if [ ! -f $targetFileName ]
then
  echo Target file $targetFileName does not exist. Will render.
  # REFERENCE:
  # http://www.guillermoluijk.com/tutorial/dcraw/index_en.htm 
  # https://www.dpreview.com/forums/post/54644725 and responses in the thread;
  # http://www.guillermoluijk.com/tutorial/dcraw/index_en.htm
  # https://im.snibgo.com/dcrawwb.htm :
  # https://im.snibgo.com/gameql.htm
  # https://www.cambridgeincolour.com/forums/thread47002.htm
  # good but extreme brights turn violet:
  # dcraw -v -w -H 0 -o 1 -W -q 0 -T "$1"
  # NOTE: for blown out scenes, anything other than -H 0 may cause severe luminance and hue distortion.
  dcraw $brightnessParameter -w +M -H 0 -o 0 -q 3 -6 -T "$1"
else
  echo Target file $targetFileName already exists. Will not overwrite.
fi