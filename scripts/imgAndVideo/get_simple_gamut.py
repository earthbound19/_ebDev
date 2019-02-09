# DESCRIPTION
# Creates a list of colors expressed as RGB hexadecimal values, from a simplified L*a*b gamut, in D (-d <number> switch) domains per permutation of L, a, and b in the gamut. Capture the list with the > operator via terminal (see USAGE). Can be hacked to do this with several gamuts (L*a*b of particular interest?). The script stretches the shade and hue range a bit and produces more colors than you would expect, to that end. Also writes new files (or clobbers them if they already exist) all_gamut_two_pairs.txt, which is a list of all possible combinations of two colors in the simplified gamut (without repetition of any color--every combination will be two different colors).

# USAGE
# python get_simple_gamut.py -n 7
# -- where -n is the number of shades to include for every hue in the gamut (default 7).
# capture the output to a file with the > operator, e.g.
# python get_simple_gamut.py -n 7 > HSL_simplified_gamut.hexplt

# DEPENDENCIES
# Python 3, spectra, argparse, numpy
# spectra library via:
# pip install spectra
# -- and documented at:
# https://github.com/jsvine/spectra/blob/master/docs/walkthrough.ipynb


# CODE
import spectra
import argparse
import numpy as np

DEFAULT_DOMAIN = 5.5

PARSER = argparse.ArgumentParser(description='Creates a list of colors expressed as RGB hexadecimal values, from a simplified HSL gamut, in D (-d <number> switch) domains per permutation of L, a, and b in the gamut. Capture the list with the > operator via terminal e.g. "python get_simple_gamut.py -d 5.5 > Lab_simplified_gamut.hexplt" (without the double quote marks). Note that -d is a float.')
PARSER.add_argument('-d', '--DOMAIN', type=float, help='Domains per permutation of L, a, and b in the L*a*b gamut. Default ' + str(DEFAULT_DOMAIN))
ARGS = PARSER.parse_args()

# If -n <a number> was passed to script, generate that many colors; otherwise generate DEFAULT_DOMAIN:
if ARGS.DOMAIN:
    DOMAIN = ARGS.DOMAIN
else:
    DOMAIN = DEFAULT_DOMAIN


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

# The clipping of the low L*a*b range compensates for the fact that few actually decipher color that dark.
# The additions to the max range compensate for the non-inclusive upper np.arange.
A_min = 2
A_max = 100 + (100 / DOMAIN * 1.8)
B_min = -100
B_max = 110 + (110 / DOMAIN)
C_min = -100
C_max = 110 + (110 / DOMAIN)

# creates numpy array of NUMBER_OF_COLORS (count) values over L (Lab) range; dividing final parameter further results in more colors used:
A_domain = np.arange(A_min, A_max, A_max / DOMAIN)
B_domain = np.arange(B_min, B_max, B_max / DOMAIN)
C_domain = np.arange(C_min, C_max, C_max / DOMAIN)

# convert from numpy arrays to lists for combinatronics:
A_domain = list(A_domain)
B_domain = list(B_domain)
C_domain = list(C_domain)

simplified_gamut = []

# print all possible combinations from every domain:
for i in A_domain:
	for j in B_domain:
		for k in C_domain:
			this_color = spectra.lab(i, j, k)
			# print(i, j, k)
			simplified_gamut.append(this_color.hexcode)


# Deduplicate list but maintain order; re: https://stackoverflow.com/a/17016257/1397555
# -- or TO DO--this without importing another library, re: https://thispointer.com/python-how-to-remove-duplicates-from-a-list/
from more_itertools import unique_everseen
simplified_gamut = list(unique_everseen(simplified_gamut))
# 
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