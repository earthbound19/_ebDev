# DESCRIPTION: Slices a larger image into x by x tiles.

# USAGE: Run this script with three parameters; $1 input image file name, $2 horizontal slices, and $3 vertical slices. Use this wolframalpha.com query to find a common factor (divisor) for square tiles (just a adjust the numbers) : http://www.wolframalpha.com/input/?i=common+factors+of+6400+and+3600

# TO DO: Make versions that split and/or join images (if I haven't already).

# ADAPTED FROM: http://stackoverflow.com/questions/9636350/using-imagemagick-how-can-i-slice-up-an-image-into-several-separate-images
convert $1 -crop $2x$3-0-0@ +repage +adjoin $1_Tile%d.png

# FINIS 10/29/2015 12:20:25 AM -RAH