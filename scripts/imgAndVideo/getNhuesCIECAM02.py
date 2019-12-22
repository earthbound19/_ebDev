# DESCRIPTION
# Writes -n full chromacity hues from the CIECAM02 color model by division returns from 0 to 360 in -n steps, to a file named <n>_MaxChroma_hues_fromCIECAM02.hexplt. May produce less colors than asked for, because it eliminates duplicate colors.

# DEV NOTES
# J (brightness or lightness) range is 0 to 100, h (hue) is 0 to 360, C (chroma) can be 0 to any number (I don't believe that there _is_ a max from whatever correlary/inputs produces the max), maybe max 160. For hard-coded colors, start with max 182 (this seemed a thing with L in HCL).

# CODE
import sys
import numpy as np
import colorspacious
from colormap import rgb2hex
import argparse

# configure arguments / help
PARSER = argparse.ArgumentParser(description='Writes -n full chromacity hues from the CIECAM02 color model by division returns from 0 to 360 in -n steps, to a file named <n>_MaxChroma_hues_fromCIECAM02.hexplt. May produce less colors than asked for, because it eliminates duplicate colors.')
PARSER.add_argument('-c', '--COLOR', help='String. Color to get shades of, in RGB HEX format e.g. \"-c \'FF00FF\'\" (without the double quote marks, but _with_ the single quote marks) for magenta.', type=str)
PARSER.add_argument('-n', '--NUMBER_OF_HUES', help='Number. How many hues to return by dividing the 0 to 360 degree hue range by that number and returning a hue from each interval dividend, uh, index, thingie.', type=int, required=True)
ARGS = PARSER.parse_args()

GLOBAL_NUMBER_OF_HUES = ARGS.NUMBER_OF_HUES

# Global clamp function keeps values in boundaries and also converts to int
def clamp(val, minval, maxval):
    if val < minval: return minval
    if val > maxval: return maxval
    return int(val)

# Observations: yellow only shows up at higher J (80 to 100) and /or very high C (C = 140 to 160, I think!) At J = 50, it's a brownish dimmer orange. Apparently this is what hoomans think yellow is at less intensity. OR it's a problem of converting from CIECAM02 to sRGB.
# My experiments find a compromise between this problem and not-quite-so-pastel results for other colors at J = 85 to 93, C = 160 - 165. At C = 135, violet is lost as a pastel magenta.
J = 89
C = 162
h_min = 0
h_max = 360
h_step = int(h_max / GLOBAL_NUMBER_OF_HUES)

# "If you are doing a large number of conversions between the same pair of spaces, then calling this function once and then using the returned function repeatedly will be slightly more efficient than calling cspace_convert() repeatedly." :
JCh2RGB = colorspacious.cspace_converter("JCh", "sRGB255")		# returns a function
# How I figured out that resulting funtion expects one parameter:
# import inspect
# florf = inspect.signature(JCh2RGB)
# print(florf)

colorsRGB = []
for h in range(h_min, h_max, h_step):
	# print("h is ", h)
	JCh = np.array([ [J, C, h] ])
	RGB = JCh2RGB(JCh)
	# clamp values to RGB ranges:
	R = clamp(RGB[0][0], 0, 255); G = clamp(RGB[0][1], 0, 255); B = clamp(RGB[0][2], 0, 255)
	# converts to two-digit (if needed) padded hex string: "{0:0{1}x}".format(255,2)
	R = "#" + "{0:0{1}x}".format(R,2); G = "{0:0{1}x}".format(G,2); B = "{0:0{1}x}".format(B,2);
	hex_string = R + G + B
	hex_string = hex_string.upper()
	colorsRGB.append(hex_string)

# Deduplicate list but maintain order; re: https://stackoverflow.com/a/17016257/1397555
from more_itertools import unique_everseen
colorsRGB = list(unique_everseen(colorsRGB))

outFileName = str(len(colorsRGB)) + "_MaxChroma_hues_fromCIECAM02.hexplt"

print("Writing to output file ", outFileName, " . . .")
f = open(outFileName, "w")
for element in colorsRGB:
# 	# print(element)
	f.write(element + "\n")
f.close()