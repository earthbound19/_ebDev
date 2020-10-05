# DESCRIPTION
# Prints N shades of gray (parameter 2) via the CIECAM02 color space, which models human perception of color (and brightness and other aspects of light) better than any other model at this writing. Colors are given as an RGB color in hex format.

# USAGE
# Run this script through a Python interpeter with one parameter, which is the number of shades of gray you want to print in hex-encoded RGB values. For example, this will print 16 shades of gray:
#    python /path/to_this_script/getNshadesOfGrayCIECAM02.py 16
# To write the printout to a file, use the > operator, like this:
#    python /path/to_this_script/getNshadesOfGrayCIECAM02.py 16 > 18shadesOfGrayCIECAM02.hexplt
# NOTE
# Because of inexact float math, this script may produce more or less colors than requested.


# CODE
# - See comments in get_CIECAM02_simplified_gamut.py, BUT: j (brightness) range is 0 to 100, h (hue) is 0 to 360, c (chroma) can be 0 to any number (I don't beleive that there _is_ a max from whatever corollary/inputs produces the max), maybe max 160. I'll start with max 182 (this seemed a thing with L in HCL).
import sys
import numpy as np
from ciecam02 import jch2rgb
from colormap import rgb2hex	# which also needs easydev (pip install easydev)
import ast

j_min = 0
j_max = 100
steps = ast.literal_eval(sys.argv[1])	# EXPECTS numeric parameter as only parameter to script!
j_step = int(100 / steps)
c = 0
h = 0

graysJCH = []
graysRGB = []
for j in range(j_max, j_min, -j_step):
	# build jch array:
	jch = np.array([ [j, c, h] ])
	jch_as_str = str(jch[0])
	graysJCH.append(jch_as_str)
	# build RGB hex array:
	rgb_array = jch2rgb(jch)
	# re: https://stackoverflow.com/a/27144564/1397555
	hex_string = rgb2hex(rgb_array[0][0], rgb_array[0][1], rgb_array[0][2])
	graysRGB.append(hex_string)

# Deduplicate list but maintain order; re: https://stackoverflow.com/a/17016257/1397555
from more_itertools import unique_everseen
graysRGB = list(unique_everseen(graysRGB))

for element in graysRGB:
	print(element)