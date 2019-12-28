# DESCRIPTION
# See comments of get_CIECAM02_simplified_gamut.py . This is that but without modifying j and c -- full brightness and chroma hues.

# USAGE
# Invoke this script without any parameter:
# python /path/to/this/script/get_full_c_bright_h_jch_simplified_palette.py
# it creates output files named:
# str(h_step) + "_full_c_bright_h_jch_simplified.gamut"
# str(h_step) + "_full_c_bright_h_jch_simplified_to_RGB.hexplt"
# -- where `str(h_step)` is an interger determined by the value of the h_step variable.


# CODE
import numpy as np
from ciecam02 import jch2rgb
from colormap import rgb2hex

j = 67

c = 162

h_min = 0
h_max = 360
h_step = int(360 / 51)

simplified_jch_gamut = []
simplified_jch_gamut_as_RGB_hex = []

for h in range(h_max, h_min, -h_step):
	jch = np.array([ [j, c, h] ])
	jch_as_str = str(jch[0])
	simplified_jch_gamut.append(jch_as_str)
	rgb_array = jch2rgb(jch)
	hex_string = rgb2hex(rgb_array[0][0], rgb_array[0][1], rgb_array[0][2])
	simplified_jch_gamut_as_RGB_hex.append(hex_string)

# from more_itertools import unique_everseen
# simplified_jch_gamut = list(unique_everseen(simplified_jch_gamut))
# simplified_jch_gamut_as_RGB_hex = list(unique_everseen(simplified_jch_gamut_as_RGB_hex))

# Write .gamut file (with jch float values):
outfile_name = str(h_step) + "_full_c_bright_h_jch_simplified.gamut"
outfile = open(outfile_name, 'w')
for element in simplified_jch_gamut:
	outfile.write(element + "\n")
outfile.close()

# Write RGB .hexplt file:
outfile_name = str(h_step) + "_full_c_bright_h_jch_simplified_to_RGB.hexplt"
outfile = open(outfile_name, 'w')
for element in simplified_jch_gamut_as_RGB_hex:
	outfile.write(element + "\n")
outfile.close()