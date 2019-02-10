# DESCRIPTION
# Creates a list of colors expressed as RGB hexadecimal values, from a simplified LCH (a.k.a. HCL) gamut. Capture the list with the > operator via terminal (see USAGE). Can be hacked to do this with several gamuts which the supporting "spectra" python library can use. To change the step over various components in the gamut, hack the A_step, B_step and C_step variables in this script.

# USAGE
# python get_simple_gamut.py -n 7 > HSL_simplified_gamut.hexplt

# DEPENDENCIES
# Python 3, spectra (python) library
# spectra library via:
# pip install spectra
# -- and documented at:
# https://github.com/jsvine/spectra/blob/master/docs/walkthrough.ipynb


# CODE
import spectra

# FAILED to do what I want implemented with color print; from the spectra tutorial page; but handy reference for creating gradients (scales) :
# scale = spectra.scale([ start, end ])
# scale_custom_domain = scale.domain([ 0, DOMAIN ])


# Lab max values; IF YOU USE THESE as max it gives a grayscale output:
# 99.99998453333127, -0.0004593894083471106, -0.008561457924405325
# L_max = 99.99998453333127
# B_max = -0.0004593894083471106
# C_max = -0.008561457924405325

# XYZ max values:
# (0.950467, 0.9999995999999999, 1.0889693999999999)

# HSL max values: (360, 1.0, 1.0); re http://www.workwithcolor.com/hsl-color-picker-01.htm
# -- which I had open for longer than I care to confess before it dawned on me
# _that the spectra library expects values in those ranges_.

# Lab min and max values? : L: 0 to 100; a: -110 to 110; b: -110 to 110? re: http://davidjohnstone.net/pages/lch-lab-colour-gradient-picker

# LCH (Luminance, Chroma, Hue) (also known as HCL) min and max values? : L 0 to 150 [but probably really to 100!], C 0 to 100, H 0 to 360? re: https://bl.ocks.org/mbostock/3e115519a1b495e0bd95 -- OR more likely L is 0 to 100, re: http://hclwizard.org/hclwizard/ -- and another color manipulation python package, "colorspace!" : https://python-colorspace.readthedocs.io/en/latest/hclcolorspace.html -- and another page supports L 0 to 100, C 0 to 100, and H 0 to 360: http://www.hclwizard.org/why-hcl/ -- AND ALSO here: https://www.colourphil.co.uk/lab_lch_colour_space.shtml

L_min = 0
L_max = 100
C_min = 0
C_max = 100
H_min = 0
H_max = 360

simplified_gamut = []

# print all possible combinations over the distribution via step_increment:
L_step = 10		# luminance step in LCH
C_step = 12		# chroma step in LCH
H_step = 7		# hue step in LCH
# The (val + val) for the maxrange is because the range function excludes the highest value (assumes zero-based counting), so that here we _do_ get the end range (it stops _past_ the range--maybe quite a bit but we dedup the results so it doesn't matter) -- although for LCH I don't worry about H; the range is broad enough without doing that:
for hue in range(H_min, (H_max + H_step), H_step):
	for chroma in range(C_min, (C_max + C_step), C_step):
		for lum in range(L_min, (L_max + L_step), L_step):
			this_color = spectra.lch(lum, chroma, hue)
			simplified_gamut.append(this_color.hexcode)

# Deduplicate list but maintain order; re: https://stackoverflow.com/a/17016257/1397555
# -- or TO DO--this without importing another library, re: https://thispointer.com/python-how-to-remove-duplicates-from-a-list/
from more_itertools import unique_everseen
simplified_gamut = list(unique_everseen(simplified_gamut))

for element in simplified_gamut:
	print(element)


# Write lists of all two-and-three pairs from reduced gamut:
import string
import itertools
all_two_permutations = list(itertools.permutations(simplified_gamut, 2))
outfile = open('all_gamut_two_pairs.txt', 'w')

for i in all_two_permutations:
	outfile.write(i[0] +"," + i[1] +'\n')
outfile.close()

# all_three_permutations = list(itertools.permutations(simplified_gamut, 3))
# outfile = open('all_gamut_three_pairs.txt', 'w')
# 
# for i in all_three_permutations:
# 	outfile.write(i[0] +i[1] +i[2] +'\n')
# outfile.close()