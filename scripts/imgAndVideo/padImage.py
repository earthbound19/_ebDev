# DESCRIPTION
# Takes an input image and background color and pads the image to larger dimensions x and/or y using the background color, writing to a new image. For example letterboxing or keeping all image information but making the image fit a different overall shape.

# USAGE
# Run with these parameters:
# - REQUIRED arvg[1] source image file name
# - REQUIRED arvg[2] x dimension to pad to
# - REQUIRED arvg[3] y dimension to pad to
# - REQUIRED arvg[4] color to use for padding, expressed as sRGB hex without a # sign, e.g. #01edfd (a light cyan) would be 01edfd.
# For example, to pad the source image tst1.png (which is 640 x 1136) to 910 x 1136 (to force to match target aspect 0.8), using sRGB color hex E0DBC8, run:
#    padImage.py tst1.png 910 1136 E0DBC8
# -- which will result in a padded image being written to _padded_tst1.png.

import sys
from PIL import Image

im = Image.open(sys.argv[1])

width, height = im.size
sys_argv_2_int = int(sys.argv[2])
xLeftRightPad = int((sys_argv_2_int - width) / 2)
new_width = width + xLeftRightPad + xLeftRightPad

sys_argv_3_int = int(sys.argv[3])
yTopBottomPad = int((sys_argv_3_int - height) / 2)
new_height = height + yTopBottomPad + yTopBottomPad

# hex to sRGB integer conversion thanks to a genius breath yonder: https://stackoverflow.com/a/29643643/1397555
hex = sys.argv[4]
# strip any leading '#' character off that:
hex = hex.lstrip("#")
sRGB = tuple(int(hex[i:i+2], 16) for i in (0, 2, 4))

result = Image.new(im.mode, (new_width, new_height), sRGB)

result.paste(im, (xLeftRightPad, yTopBottomPad))

outfileName = '_padded_' + sys.argv[1]

result.save(outfileName)

print("DONE. Wrote padded image to", outfileName)