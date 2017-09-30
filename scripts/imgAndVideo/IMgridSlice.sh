# DESCRIPTION: Slices a larger image into x by x tiles.

# USAGE: Run this script with three parameters; $1 input image file name, $2 width of cut tiles, and $3 height of cut tiles. Use this wolframalpha.com query to find a common factor (divisor) for square tiles (just a adjust the numbers) : http://www.wolframalpha.com/input/?i=common+factors+of+6400+and+3600

# TO DO: Make versions that split and/or join images (if I haven't already).

# ADAPTED FROM: http://stackoverflow.com/questions/9636350/using-imagemagick-how-can-i-slice-up-an-image-into-several-separate-images -- where I think with imagemagick a -0-0@ appended to $2x$3 meant zero padding, it seems graphicsmagick only does that if you omit those parts of the argument altogether:
gm convert $1 -crop $2x$3 +repage +adjoin $1_tile_%05d.png

# FINIS 10/29/2015 12:20:25 AM -RAH



# 72 total