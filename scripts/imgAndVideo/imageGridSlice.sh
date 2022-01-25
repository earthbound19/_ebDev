# DESCRIPTION
# Slices a larger image into X by Y tiles on math of WxH of each slice, via GraphicsMagick convert.

# DEPENDENCIES
# A 'Nixy environment, GraphicsMagick.

# USAGE
# Run with these parameters:
# - $1 input image file name
# - $2 width of cut tiles
# - $3 height of cut tiles
# - Use this wolframalpha.com query to find a common factor (divisor) for square tiles (adjust the numbers) : http://www.wolframalpha.com/input/?i=common+factors+of+6400+and+3600
# Example that cuts input.png to 640x480 slices:
#    IMgridSlice.sh input.png 640 480


# CODE
# ADAPTED FROM: http://stackoverflow.com/questions/9636350/using-ImageMagick-how-can-i-slice-up-an-image-into-several-separate-images -- where I think with ImageMagick a -0-0@ appended to $2x$3 meant zero padding, it seems GraphicsMagick only does that if you omit those parts of the argument altogether:
# TO DO: Make another script that joins slices, if I haven't already. Also one that shuffles and joins them for interesting image rearrangement?
gm convert $1 -crop $2x$3 +repage +adjoin $1_tile_%05d.png

# FINIS 10/29/2015 12:20:25 AM -RAH