# DESCRIPTION
# Creates a list of colors expressed as RGB hexadecimal values, from a simplified CIECAM02 color space. Names the output file partly after the number of elements in the list. Variant of script that uses one ciecam02 python library; this uses colorspacious, which at this writing I seem not to understand (or maybe it had errors) and it sometimes produces very out of place colors.

# USAGE
# python get_CIECAM02_simplified_gamut.py
# Produces a file named <n>_from_CIECAM02_simplified_as_RGB.hexplt.
# NOTES:
# - To change the number of output colors, hack the assignments in the script to the variables
# J_step, C_step and h_step.

# DEPENDENCIES
# python, with these packages: numpy, colorspacious, colormap, more_itertools


# CODE

# PROGRAMMER NOTES
# IT SEEMS that for the colorspacious library you get errors if you go beyond C = 140.
# An earlier version of this script used the ciecam02 library, but I changed to colorspacious as it is (it would seem) more accurate).
# This page -- https://colorspacious.readthedocs.io/en/latest/tutorial.html -- describes a gamut in HCL (actually Jcl there) which is "state of the art:" CIECAM02. Supported as such by chronology in this article: https://en.wikipedia.org/wiki/Color_appearance_model#CIECAM02 Excellent article about it describing well different attributes of color and colorfulness: https://en.wikipedia.org/wiki/CIECAM02
# Packages that support it:
# - https://colorspacious.readthedocs.io/en/latest/reference.html#supported-colorspaces
# - https://colour.readthedocs.io/en/latest/colour.appearance.html#ciecam02
# - winner if it works: https://colorspacious.readthedocs.io/en/latest/reference.html#ciecam02 : "If you just want a better replacement for traditional ad hoc spaces like “Hue/Saturation/Value”, then use the string "JCh" for your colorspace (see Perceptual transformations for a tutorial) and be happy."
# - Re https://pypi.org/project/ciecam02/ it is a "_simplified_ form  of CEICAM02.." (emphasis added), which I think I would not prefer.

# ciecam02 doc:
# CIECAM02 produces multiple correlates, like H, J, z, Q, t, C, M, s. Some of them represent similar concepts, such as C means chroma and M colorfulness s saturation correlate the same thing in different density. We need only 3 major property of these arguments to completely represent a color, and we can get other properties or reverse algorithms..
# Color type jch is a float list like [J, C, h], where 0.0 < J < 100.0, 0.0 < h < 360.0, and 0.0 < C. the max value of C does not limit, and may produce exceeds when transform to rgb. The effective value of max C varies. Probably for red color h 0.0, and brightness j 50.0, C reach the valid maximum, values about 160.0.
# IN OTHER WORDS: J (brightness) range is 0 to 100, h (hue) is 0 to 360, C (chroma) can be 0 to any number (I don't beleive that there _is_ a max from whatever correlary/inputs produces the max), maybe max 160. I'll start with max 182 (this seemed a thing with L in HCL).

# NOTE my eyes said, assuming those values, for HCL, do these step values: L_step 18, C_domain 24, H_step 7
# (later self: WHAT? 7 colors?! How about 12 * how many perceived steps in between all?)


import numpy as np
# DEPRECATED:
# from ciecam02 import jch2rgb
from colorspacious import cspace_convert
from colormap import rgb2hex	# which also needs easydev (pip install easydev)
import more_itertools

# Global clamp function, re: https://stackoverflow.com/a/4092565
def clamp(val, minval, maxval):
    if val < minval: return minval
    if val > maxval: return maxval
    return val

J_min = 0
J_max = 100
J_step = 100 / 13

C_min = 0
C_max = 125		# tried before and get out of bounds colors: 140
C_step = 9		#125/12.72 ~= 11

h_min = 0
h_max = 360
h_step = 360 / 60		# / 90 = 4, / 60 = 6

# Stepping (counting) down because it's difficult (or with this code depending, impossible) to hit the max ranges counting up:
simplified_JCh_gamut_as_RGB_hex = []
for h in more_itertools.numeric_range(h_max, h_min, -h_step):
	for C in more_itertools.numeric_range(C_max, C_min, -C_step):
		for J in more_itertools.numeric_range(J_max, J_min, -J_step):
			# build jch array:
			# DEPRECATED:
			# JCh = np.array([ [J, C, h] ])
			rgb_array = cspace_convert([J,C,h], "JCh", "sRGB255")
			# because that function has a bug that can produce invalid values :( correct them:
			if np.isnan(rgb_array[0]):
				rgb_array[0] = 0
			if np.isnan(rgb_array[1]):
				rgb_array[1] = 0
			if np.isnan(rgb_array[2]):
				rgb_array[2] = 0
			rgb_array_int = [
			clamp(int(rgb_array[0]), 0, 255),
			clamp(int(rgb_array[1]), 0, 255),
			clamp(int(rgb_array[2]), 0, 255)
			]
			hex_string = rgb2hex(rgb_array_int[0], rgb_array_int[1], rgb_array_int[2])
			# hex_string = rgb2hex(rgb_array[0], rgb_array[1], rgb_array[2])
			simplified_JCh_gamut_as_RGB_hex.append(hex_string)

# Deduplicate list but maintain order; re: https://stackoverflow.com/a/17016257/1397555
# -- or TO DO--this without importing another library, re: https://thispointer.com/python-how-to-remove-duplicates-from-a-list/
simplified_JCh_gamut_as_RGB_hex = list(more_itertools.unique_everseen(simplified_JCh_gamut_as_RGB_hex))
# ALTERNATE AWK method of deduping that after its piped to file from this script:
# awk -v BINMODE=rw '!($0 in a){a[$0];print}' inputFile.hexplt >> tmp.hexplt

num_list_elements = str(len(simplified_JCh_gamut_as_RGB_hex))
outFileName = num_list_elements + "_from_CIECAM02_simplified_as_RGB.hexplt"

print("Writing to output file ", outFileName, " . . .")
f = open(outFileName, "w")
for element in simplified_JCh_gamut_as_RGB_hex:
# 	# print(element)
	f.write(element + "\n")
f.close()


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