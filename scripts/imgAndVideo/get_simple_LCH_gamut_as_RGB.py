# DESCRIPTION
# Creates a list of colors expressed as RGB hexadecimal values, from a simplified LCH (a.k.a. HCL) gamut. Capture the list with the > operator via terminal (see USAGE). Can be hacked to do this with several gamuts which the supporting "spectra" python library can use. To change the step over various components in the gamut, hack the A_domain, B_domain and C_domain variables in this script.

# USAGE
# python get_simple_gamut.py > HSL_simplified_gamut.hexplt

# DEPENDENCIES
# Python 3, spectra

# Something I read and my own sample simplified gamut of lab vs. hcl convinced me to use HCL. BUT:
# NOT TO DO: use https://github.com/colour-science/colour which has _a lot_ of functionality (including Colour Difference calculation), a ton of commits, and at this writing the newest commit only 4 days ago -- or any of the packages _it_ lists? -- don't use because it doesn't support HCL. https://github.com/colour-science/colour#see-also


# CODE
import spectra
# from colormath.color_objects import LabColor
# from colormath.color_objects import LCHabColor
# from colormath.color_diff import delta_e_cie2000

# FAILED to do what I want implemented with color print; from the spectra tutorial page; but handy reference for creating gradients (scales) :
# scale = spectra.scale([ start, end ])
# scale_custom_domain = scale.domain([ 0, DOMAIN ])


# Lab max values; IF YOU USE THESE as max it gives a grayscale output:
# 99.99998453333127, -0.0004593894083471106, -0.008561457924405325
# A_max = 99.99998453333127
# B_max = -0.0004593894083471106
# C_max = -0.008561457924405325

# XYZ max values:
# (0.950467, 0.9999995999999999, 1.0889693999999999)

# HSL max values: (360, 1.0, 1.0); re http://www.workwithcolor.com/hsl-color-picker-01.htm
# -- which I had open for longer than I care to confess before it dawned on me
# _that the spectra library expects values in those ranges_.

# Lab min and max values? : L: 0 to 100; a: -110 to 110; b: -110 to 110? re: http://davidjohnstone.net/pages/lch-lab-colour-gradient-picker

# LCH (Luminance, Chroma, Hue) (also known as HCL) min and max values? : L 0 to 100, C 0 to 182 (not 100?!), H 0 to 360? (Documentation doesn't say!) re: http://www.multipole.org/discourse-server/viewtopic.php?t=24834 -- with those max ranges I get hex ff00ff, whereas with what many web sites led me to believe the ranges should be (with C max 100) I get ff95ff.
# NOTE my eyes say, assuming those values, do these step values: L_step 18, C_domain 24, H_step 7

A_min = 0
A_max = 100
A_step = int(100 / 18)

B_min = 0
B_max = 182
B_step = int(182 / 24)

C_min = 0
C_max = 360
C_step = int(360 / 7)

# Stepping (counting) down because it's difficult (or with this code depending, impossible) to hit the max ranges counting up:
simplified_gamut = []
for i in range(C_max, C_min, -C_step):
	for j in range(A_max, A_min, -A_step):
		for k in range(B_max, B_min, -B_step):
			this_color = spectra.lch(j, k, i)
			simplified_gamut.append(this_color.hexcode)

# Deduplicate list but maintain order; re: https://stackoverflow.com/a/17016257/1397555
# -- or TO DO--this without importing another library, re: https://thispointer.com/python-how-to-remove-duplicates-from-a-list/
from more_itertools import unique_everseen
simplified_gamut = list(unique_everseen(simplified_gamut))


# WIP: DELETE COLORS WHICH ARE SO SIMILAR as to be practically the same, via colormath (to reduce the list further) :
#list_len = len(simplified_gamut)
#print("list_len val:", list_len)
#for outer_idx in range(list_len -1, 0, -1):
#	outer_check_hex = simplified_gamut[outer_idx]
#	compare_color1 = spectra.html(outer_check_hex).to("lch")
#	LabColor_compare1 = LCHabColor(lch_l=compare_color1.values[0], lch_c=compare_color1.values[1], lch_h=compare_color1.values[2])
#	print("----? :")
#	print(outer_check_hex)
#	print(compare_color1.hexcode)	# DOESN'T ALWAYS MATCH outer_check_hex!
#	spectra_color_reconstructed = spectra.lab(LabColor_compare1.lch_l, LabColor_compare1.lch_c, LabColor_compare1.lch_h)
#	print(spectra_color_reconstructed.hexcode)
# TO DO: rework this script to use only colormath?! Because THE COLORS CHANGE IN A ROUNDTRIP FROM SPECTRA TO COLORMATH. Maybe that's inevitable?
# color2.lab_a, color2.lab_b, color2.lab_l
#	for inner_idx in range(outer_idx-1, 0, -1):
		# print("outer check val is:", outer_check_hex, "idx", outer_idx)
		# print("inner check val is:", inner_check_hex, "idx", inner_idx)
		# color comparison reference; re: https://python-colormath.readthedocs.io/en/latest/delta_e.html
		# (import statements moved to start of script)
		# # Reference color.
		# color1 = LabColor(lab_l=0.9, lab_a=16.3, lab_b=-2.22)
		# # Color to be compared to the reference.
		# color2 = LabColor(lab_l=0.7, lab_a=14.2, lab_b=-1.80)
		# # This is your delta E value as a float.
		# delta_e = delta_e_cie1976(color1, color2)
#		inner_check_hex = simplified_gamut[inner_idx]
#		compare_color2 = spectra.html(inner_check_hex).to("lab")
		# LabColor_compare1 = LabColor(lab_l=compare_color1.values[0], lab_a=compare_color1.values[1], lab_b=compare_color1.values[2])
		# delta_e = delta_e_cie2000(compare_color1, compare_color2)


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