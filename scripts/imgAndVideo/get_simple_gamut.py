# DESCRIPTION
# Creates a list of colors expressed as RGB hexadecimal values, from a simplified HSL gamut, in N (-n <number> switch) domains per permutation of H, S, and L in the gamut. Capture the list with the > operator via terminal (see USAGE). Can be hacked to do this with several gamuts (L*a*b of particular interest?). The script stretches the shade and hue range a bit and produces more colors than you would expect, to that end.

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

DEFUALT_NUMBER_OF_COLORS = 7

PARSER = argparse.ArgumentParser(description='Creates a list of colors expressed as RGB hexadecimal values, from a simplified HSL gamut, in N (-n <number> switch) shades of all colors in the gamut. Capture the list with the > operator via terminal e.g. "python get_simple_gamut.py -n 7 > HSL_simplified_gamut.hexplt" (without the double quote marks).')
PARSER.add_argument('-n', '--DOMAIN', type=int, help='Domains per permutation of H, S, and L in the gamut. Default ' + str(DEFUALT_NUMBER_OF_COLORS))
ARGS = PARSER.parse_args()

# If -n <a number> was passed to script, generate that many colors; otherwise generate DEFUALT_NUMBER_OF_COLORS:
if ARGS.NUMBER_OF_COLORS:
    NUMBER_OF_COLORS = ARGS.NUMBER_OF_COLORS
else:
    NUMBER_OF_COLORS = DEFUALT_NUMBER_OF_COLORS


# FAILED to do what I want implemented with color print; from the spectra tutorial page:
# scale = spectra.scale([ start, end ])
# scale_custom_domain = scale.domain([ 0, NUMBER_OF_COLORS ])


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
# The additions to all of the following compensates a bit for non-inclusive np.arange.
A_max = 360 + (360 / (NUMBER_OF_COLORS / 2) )
B_max = 1.0 + (1.0 / (NUMBER_OF_COLORS / 2) )
C_max = 1.0 + (1.0 / (NUMBER_OF_COLORS / 2) )

# creates numpy array of NUMBER_OF_COLORS (count) values over L (Lab) range; dividing final parameter further results in more colors used:
A_domain = np.arange(0.0, A_max, A_max / (NUMBER_OF_COLORS * 1.3) )	# * 1.3 moar colors
B_domain = np.arange(0.0, B_max, B_max / NUMBER_OF_COLORS)
C_domain = np.arange(0.0, C_max, C_max / (NUMBER_OF_COLORS * 1.7) )	# * 1.7 gets more L

# convert from numpy arrays to lists for combinatronics:
A_domain = list(A_domain)
B_domain = list(B_domain)
C_domain = list(C_domain)

simplified_gamut = []

# print all possible combinations from every domain:
for i in A_domain:
	for j in B_domain:
		for k in C_domain:
			this_color = spectra.hsl(i, j, k)
			# print(i, j, k)
			simplified_gamut.append(this_color.hexcode)

# Deduplicate list but maintain order; re: https://stackoverflow.com/a/17016257/1397555
# -- or TO DO--this without importing another library, re: https://thispointer.com/python-how-to-remove-duplicates-from-a-list/
from more_itertools import unique_everseen
simplified_gamut = list(unique_everseen(simplified_gamut))
# 
for element in simplified_gamut:
	print(element)


