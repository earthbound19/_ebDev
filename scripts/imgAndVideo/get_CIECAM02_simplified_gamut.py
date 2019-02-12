# DESCRIPTION
# Creates a list of colors expressed as components OR RGB hexadecimal values, from a simplified CIECAM02 color space. Capture the list with the > operator via terminal (see USAGE).

# USAGE
# python get_CIECAM02_simplified_gamut.py > CIECAM02_simplified_gamut.gamut

# DEPENDENCIES
# ..?

# PROGRAMMER NOTES
# This page -- https://colorspacious.readthedocs.io/en/latest/tutorial.html -- describes a gamut in HCL (actually Jcl there) which is "state of the art:" CIECAM02. Supported as such by chronology in this article: https://en.wikipedia.org/wiki/Color_appearance_model#CIECAM02 Excellent article about it describing well different attributes of color and colorfulness: https://en.wikipedia.org/wiki/CIECAM02
# Packages that support it:
# - https://colorspacious.readthedocs.io/en/latest/reference.html#supported-colorspaces
# - https://colour.readthedocs.io/en/latest/colour.appearance.html#ciecam02
# - winner if it works: https://colorspacious.readthedocs.io/en/latest/reference.html#ciecam02 : "If you just want a better replacement for traditional ad hoc spaces like “Hue/Saturation/Value”, then use the string "JCh" for your colorspace (see Perceptual transformations for a tutorial) and be happy."
# - OR maybe better?! : https://pypi.org/project/ciecam02/

# cicam02 doc:
# CIECAM02 produces multiple correlates, like H, J, z, Q, t, C, M, s. Some of them represent similar concepts, such as C means chroma and M colorfulness s saturation correlate the same thing in different density. We need only 3 major property of these arguments to completely represent a color, and we can get other properties or reverse algorithms..
# Color type jch is a float list like [j, c, h], where 0.0 < j < 100.0, 0.0 < h < 360.0, and 0.0 < c. the max value of c does not limit, and may produce exceeds when transform to rgb. The effective value of max c varies. Probablly for red color h 0.0, and brightness j 50.0, c reach the valid maximum, values about 160.0.
# IN OTHER WORDS: j (brightness) range is 0 to 100, h (hue) is 0 to 360, c (chroma) can be 0 to any number (I don't beleive that there _is_ a max from whatever correlary/inputs produces the max), maybe max 160. I'll start with max 182 (this seemed a thing with L in HCL).

import numpy as np
from ciecam02 import jch2rgb

j_min = 0
j_max = 100
j_step = int(100 / 18)

h_min = 0
h_max = 182
h_step = int(182 / 24)

c_min = 0
c_max = 360
c_step = int(360 / 7)

# Stepping (counting) down because it's difficult (or with this code depending, impossible) to hit the max ranges counting up:
simplified_gamut = []
for c in range(c_max, c_min, -c_step):
	for h in range(j_max, j_min, -j_step):
		for j in range(h_max, h_min, -h_step):
			ferge = "boo"
			jch = np.array([ [c, h, j] ])
			jch_as_str = str(jch[0])
			simplified_gamut.append(jch_as_str)
			# rgb_array = jch2rgb(jch)
			# print(rgb_array[0])
			# hex_string = "#" + str(rgb_array[0][0]) + str(rgb_array[0][1]) + str(rgb_array[0][2])
			# print(hex_string) 
			# OUTPUT: array([[255,   0, 255]], dtype=uint8)

# Deduplicate list but maintain order; re: https://stackoverflow.com/a/17016257/1397555
# -- or TO DO--this without importing another library, re: https://thispointer.com/python-how-to-remove-duplicates-from-a-list/
from more_itertools import unique_everseen
simplified_gamut = list(unique_everseen(simplified_gamut))
 
for element in simplified_gamut:
	print(element)


# Write lists of all two-and-three pairs from reduced gamut:
# import string
# import itertools
# all_two_permutations = list(itertools.permutations(simplified_gamut, 2))
# outfile = open('all_gamut_two_pairs.txt', 'w')
# 
# for i in all_two_permutations:
# 	outfile.write(i[0] +"," + i[1] +'\n')
# outfile.close()

# all_three_permutations = list(itertools.permutations(simplified_gamut, 3))
# outfile = open('all_gamut_three_pairs.txt', 'w')
# 
# for i in all_three_permutations:
# 	outfile.write(i[0] +i[1] +i[2] +'\n')
# outfile.close()


# BONEYARD
# import colormath
# from colormath.color_conversions import convert_color
# from colormath.color_objects import LCHabColor, sRGBColor
# this_color = colormath.color_objects.LCHabColor(100, 50, 40)
# converted_color = convert_color(this_color, sRGBColor)
# converted_color.clamped_rgb_b
# 0.763059175368764
# converted_color.get_rgb_hex
# this_hex = converted_color.get_rgb_hex()
# this_hex
# '#153e1c3'