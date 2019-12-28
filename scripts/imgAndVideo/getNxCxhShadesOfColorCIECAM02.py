IN DEVELOPMENT. I think.
exit()

# DESCRIPTION
# Variant of getNshadesOfColorCIECAM02.py which gives C and h degrees up and down chroma and hue shift in addition to -n shades of color.

# USAGE
# run script with --help parameter for instructions, or read the description sections in the argsparse setup below. Basic default usage for e.g. 16 shades of gray:
# getCIECAM02ShadesOfColor.py -n 16 -C 20 - h 12 -d 4 > 18shadesOf<color>CIECAM02.hexplt
# NOTES:
# See NOTES comments in script referenced in DESCRIPTION.

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
PARSER.add_argument('-C', '--CHROMA_SHIFT', help='How many degrees C chroma (intensity) to vary positive and negative', type=int, required=True)
PARSER.add_argument('-h', '--HUE_SHIFT', help='How many degrees h to vary hue (color) to vary positive and negative', type=int, required=True)
PARSER.add_argument('-s', '--C_AND_H_STEPS', help='How many steps over degrees C and h to make.', type=int, required=True)
ARGS = PARSER.parse_args()

COLOR_HEX_RGB_GLOBAL = 'FFFFFF'
if ARGS.COLOR:
	COLOR_HEX_RGB_GLOBAL = str(ARGS.COLOR)
	COLOR_HEX_RGB_GLOBAL = COLOR_HEX_RGB_GLOBAL.rstrip()		# UN. BE. FREAKING. LEAVABLE!! Windows newlines mess with that string otherwise!!
GLOBAL_NUMBER_OF_SHADES = ARGS.NUMBER_OF_SHADES

def clamp(val, minval, maxval):
    if val < minval: return minval
    if val > maxval: return maxval
    return int(val)

COLOR_HEX_RGB_GLOBAL = COLOR_HEX_RGB_GLOBAL.replace('#', '')

RGB = tuple(int(COLOR_HEX_RGB_GLOBAL[i:i+2], 16) for i in (0, 2, 4))
JCh_result = cspace_convert(RGB, "sRGB255", "JCh")

J_min = 0
if ARGS.BRIGHTNESS_OVERRIDE:
	J_max = ARGS.BRIGHTNESS_OVERRIDE
else:
	J_max = int(JCh_result[0])

CHROMA_SHIFT = ARGS.CHROMA_SHIFT
HUE_SHIFT = ARGS.HUE_SHIFT
J_step = int(J_max / GLOBAL_NUMBER_OF_SHADES) * -1
C_h_steps=ARGS.C_AND_H_STEPS
# TO DO: add C and h step vals here, use them in triple-nested (!) loop that goes neg C/2 to pos C/2, neg h/2 to pos. h/2.
print("Work in progress. Exiting script. See TO DO.")
exit()

if ARGS.DARK_TO_BRIGHT:
	tmp = J_min; J_min = J_max; J_max = tmp
	J_step = J_step * -1
C = JCh_result[1]
h = JCh_result[2]

JCh2RGB = cspace_converter("JCh", "sRGB255")		# returns a function

colorsRGB = []
if not ARGS.DARK_TO_BRIGHT and not ARGS.BRIGHTNESS_OVERRIDE and not ARGS.BRIGHTNESS_OVERRIDE:
	colorsRGB.append("#" + COLOR_HEX_RGB_GLOBAL)
for J in range(J_max, J_min, J_step):
	JCh = np.array([ [J, C, h] ])
	JCh_as_str = str(JCh[0])
	RGB = JCh2RGB(JCh)
	R = clamp(RGB[0][0], 0, 255); G = clamp(RGB[0][1], 0, 255); B = clamp(RGB[0][2], 0, 255)
	R = "#" + "{0:0{1}x}".format(R,2); G = "{0:0{1}x}".format(G,2); B = "{0:0{1}x}".format(B,2);
	hex_string = R + G + B
	hex_string = hex_string.upper()
	colorsRGB.append(hex_string)
	colorsRGB.append(hex_string)
if ARGS.DARK_TO_BRIGHT and not ARGS.BRIGHTNESS_OVERRIDE:
	colorsRGB.append("#" + COLOR_HEX_RGB_GLOBAL)

from more_itertools import unique_everseen
colorsRGB = list(unique_everseen(colorsRGB))

outFileName = COLOR_HEX_RGB_GLOBAL + "_" + str(len(colorsRGB)) + "shades.hexplt"

print("Writing to output file ", outFileName, " . . .")
f = open(outFileName, "w")
for element in colorsRGB:
	f.write(element + "\n")
f.close()