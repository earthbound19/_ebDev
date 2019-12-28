# DESCRIPTION
# Gets -n shades of any -c color (default white if not passed) via the CIECAM02 color space, which models human perception of color (and brightnes and other aspects of light) better than any other model at this writing.

# USAGE
# run script with --help parameter for instructions, or read the description sections in the argsparse setup below. Basic default usage for e.g. 16 shades of gray:
# getNshadesOfColorCIECAM02.py -n 16 > 18shadesOf<color>CIECAM02.hexplt
# NOTES:
# - it may produce more or less colors than specified. Welcome to inexact float math.
# - it may produce some unexpected colors. I recommend you use an editor that live previews
# hex colors (like Atom with the highlight-colors package).
# NOTE that the script adds the original color to the array at the start or end depending on
# whether you use -r | --DARK_TO_BRIGHT or not IF you also don't use -b | --BRIGHTNESS_OVERRIDE.

# DEPENDENCIES
# Python and the various import libraries declared at the start of CODE.

# DEV NOTES
# SEE COMMENTS IN get_CIECAM02_simplified_gamut.py, BUT:
# J (brightness or lightness) range is 0 to 100, h (hue) is 0 to 360, C (chroma) can be 0 to any number (I don't believe that there _is_ a max from whatever correlary/inputs produces the max), maybe max 160. For hard-coded colors, start with max 182 (this seemed a thing with L in HCL).


# CODE
import sys
import numpy as np
from colorspacious import cspace_converter, cspace_convert, deltaE
import argparse

# configure arguments / help
PARSER = argparse.ArgumentParser(description='Gets -n shades of any -c color (default color is white if not passed) via the CIECAM02 color space, which models human perception of color (and brightnes and other aspects of light) better than any other model at this writing.')
PARSER.add_argument('-c', '--COLOR', help='String. Color to get shades of, in RGB HEX format e.g. \"-c \'FF00FF\'\" (without the double quote marks, but _with_ the single quote marks) for magenta.', type=str)
PARSER.add_argument('-n', '--NUMBER_OF_SHADES', help='Number. How many shades of color to generate from brightest original color point to black., e.g. "-n 15" (without the quote marks) for 15 shades.', type=int, required=True)
PARSER.add_argument('-b', '--BRIGHTNESS_OVERRIDE', help='Optional number from 0 to 100. If provided, overrides innate brightness (according to CIECAM02 / JCh modeling of J or brightness) of -c color, resulting in colors stepping down from this override brightness. 100 is full bright (will appear white or near-white), 50 is medium bright, 0 is dark (will appear black or near-black). If not provided, generated shades will step (default down) from colors\' inherent brightness to black or near black. To step up to white, see -r option. Note that yellows may get lost as orange below about J = 80, but violets get lost as magenta above that, depending on the value of C also.', type=int)
PARSER.add_argument('-r', '--DARK_TO_BRIGHT', help='Optional switch (no value needed). If present, shades will be generated from dark to light (instead of default bright to dark).', action='store_true')
ARGS = PARSER.parse_args()

# init globals / from parsed arguments
# default color:
COLOR_HEX_RGB_GLOBAL = 'FFFFFF'
# override that default if appropriate arg. passed:
if ARGS.COLOR:
	COLOR_HEX_RGB_GLOBAL = str(ARGS.COLOR)
	COLOR_HEX_RGB_GLOBAL = COLOR_HEX_RGB_GLOBAL.rstrip()		# UN. BE. FREAKING. LEAVABLE!! Windows newlines mess with that string otherwise!!
GLOBAL_NUMBER_OF_SHADES = ARGS.NUMBER_OF_SHADES

# Global clamp function keeps values in boundaries and also converts to int
def clamp(val, minval, maxval):
    if val < minval: return minval
    if val > maxval: return maxval
    return int(val)

# delete any / all # from string if they are provided in arg. (more than one would be bad source):
COLOR_HEX_RGB_GLOBAL = COLOR_HEX_RGB_GLOBAL.replace('#', '')
# print("~\n-c color parameter is ", COLOR_HEX_RGB_GLOBAL)

RGB = tuple(int(COLOR_HEX_RGB_GLOBAL[i:i+2], 16) for i in (0, 2, 4))
JCh_result = cspace_convert(RGB, "sRGB255", "JCh")
# JCH_result[0] is J, JCH_result[1] is C, [JCH_result2] is h

J_min = 0
# set J_max depending on param.:
if ARGS.BRIGHTNESS_OVERRIDE:
	J_max = ARGS.BRIGHTNESS_OVERRIDE
else:
	J_max = int(JCh_result[0])		# J	-- loses float precision there :(
# NOTE that as this is a negative number (default) and will be used for range() step, step will be negative! :

J_step = int(J_max / GLOBAL_NUMBER_OF_SHADES) * -1

if ARGS.DARK_TO_BRIGHT:		# if told to reverse gradient (dark -> white)
	tmp = J_min; J_min = J_max; J_max = tmp
	J_step = J_step * -1
# print("J_min", J_min, " J_max", J_max, " J_step", J_step)
C = JCh_result[1]				# C
h = JCh_result[2]				# h

JCh2RGB = cspace_converter("JCh", "sRGB255")		# returns a function

colorsRGB = []
# if regular light to dark sort and no brightness override, start building array with original color:
if not ARGS.DARK_TO_BRIGHT and not ARGS.BRIGHTNESS_OVERRIDE and not ARGS.BRIGHTNESS_OVERRIDE:
	colorsRGB.append("#" + COLOR_HEX_RGB_GLOBAL)
for J in range(J_max, J_min, J_step):
	# build JCh array:
	JCh = np.array([ [J, C, h] ])
	JCh_as_str = str(JCh[0])
	# build RGB hex array:
	RGB = JCh2RGB(JCh)
	# clamp values to RGB ranges:
	R = clamp(RGB[0][0], 0, 255); G = clamp(RGB[0][1], 0, 255); B = clamp(RGB[0][2], 0, 255)
	# converts to two-digit (if needed) padded hex string: "{0:0{1}x}".format(255,2)
	R = "#" + "{0:0{1}x}".format(R,2); G = "{0:0{1}x}".format(G,2); B = "{0:0{1}x}".format(B,2);
	hex_string = R + G + B
	hex_string = hex_string.upper()
	colorsRGB.append(hex_string)
	colorsRGB.append(hex_string)
# if reverse (dark to light) sort and no brightness override, append original color to end of sort:
if ARGS.DARK_TO_BRIGHT and not ARGS.BRIGHTNESS_OVERRIDE:
	colorsRGB.append("#" + COLOR_HEX_RGB_GLOBAL)

# Deduplicate list but maintain order; re: https://stackoverflow.com/a/17016257/1397555
from more_itertools import unique_everseen
colorsRGB = list(unique_everseen(colorsRGB))

outFileName = COLOR_HEX_RGB_GLOBAL + "_" + str(len(colorsRGB)) + "shades.hexplt"

print("Writing to output file ", outFileName, " . . .")
f = open(outFileName, "w")
for element in colorsRGB:
# 	# print(element)
	f.write(element + "\n")
f.close()