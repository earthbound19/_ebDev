# DESCRIPTION
# Prints high brightness hues from the CIECAM02 color model in N (parameter -n) steps from 0 to 360 degrees of hue. Colors are printed as RGB colors in hex format.

# USAGE
# Run this script through a Python interpreter, and pass the script a numeric value for the switch '-n', which is the number of full chroma hues you wish to print. For example, to print 18 hues, run:
#    python /path/to/this/script/printNhuesCIECAM02.py -n 18
# To write the colors to a .hexplt file for permanent palette storage (recommended), use the > operator:
#    python /path/to/this/script/printNhuesCIECAM02.py -n 18 > 18_max_chroma_hues_from_CIECAM02.hexplt
# NOTES
# - If you have this script create many colors, it may produce fewer colors because it eliminates duplicate colors. Because colors are created outside the RGB color space, and then clamped to it, duplicate colors are more likely from more values outside the RGB range clamped to it when you create hundreds of colors or more. This behavior seems to alter when you alter J and C.
# - You probably want to tweak the J, C etc. variables with hard-coded alternatives for your run of the script for different color type scenarios.
# - The CIECAM02 color space is not perceptually linear along hues, and yellow changes to orange at lower lightness, and other funky things happen. While this script can get some good palette suggestions, ultimately I made palettes that I want by hand.


# CODE
# DEVELOPER NOTES
# The Wikipedia article on CIECAM02 has pretty clear descriptions (at this writing) of what the different color components in the model are: https://en.wikipedia.org/wiki/CIECAM02
# - J (lightness) range is 0 to 100, h (hue) is 0 to 360, C (chroma) can be 0 to any number (I don't believe that there _is_ a max from whatever corollary/inputs produces the max), maybe max 160.
# - Yellow only shows up at higher J (80 to 100) and /or very high C (C = 140 to 160, I think!) At J = 50, it's a brownish dimmer orange. Apparently this is what hoomans think yellow is at less intensity. OR it's a problem of converting from CIECAM02 to sRGB.
# - My experiments find a compromise between this problem and not-quite-so-pastel results for other colors at J = 85 to 93, C = 160 - 165. At C = 135, violet is lost as a pastel magenta.
# - is a colorfulness (M) conversion to RGB available in the libraries I use?

import sys
import numpy as np
import colorspacious
from colormap import rgb2hex
import argparse

# configure arguments / help
PARSER = argparse.ArgumentParser(description='Writes -n full chroma hues from the CIECAM02 color model by division returns from 0 to 360 in -n steps, to a file named <n>_MaxChroma_hues_fromCIECAM02.hexplt. May produce less colors than asked for, because it eliminates duplicate colors.')
PARSER.add_argument('-c', '--COLOR', help='String. Color to get shades of, in RGB HEX format e.g. \"-c \'FF00FF\'\" (without the double quote marks, but _with_ the single quote marks) for magenta.', type=str)
PARSER.add_argument('-n', '--NUMBER_OF_HUES', help='Number. How many hues to return by dividing the 0 to 360 degree hue range by that number and returning a hue from each interval dividend, uh, index, thingie.', type=int, required=True)
ARGS = PARSER.parse_args()

GLOBAL_NUMBER_OF_HUES = ARGS.NUMBER_OF_HUES + 1     # +1 because we'll get that many values but remove the last one. Removing the last one because it will be identical or very nearly identical to the first (hue wrapped around to start).

# Global clamp function keeps values in boundaries and also converts to int
def clamp(val, minval, maxval):
    if val < minval: return int(minval)
    if val > maxval: return int(maxval)
    return int(val)

# SEE DEVELOPER NOTES at start of script re these variables:
J = 89                  # HARD-CODED default: 89. Good mid-range power value?: 50? 74.5?
C = 162                  # " 162. Good mid-high range chroma value? : Between 120 to 125. Highest 182?
h_min = 0               # " 0, and you probably don't want to change that
h_max = 360             # " 360 "
    # DEPRECATED METHOD of getting a divisor/incrementor used to get a series of h values:
    # h_step = int(h_max / GLOBAL_NUMBER_OF_HUES)
h_values = np.linspace(h_min, h_max, num=GLOBAL_NUMBER_OF_HUES)
# remove last element of array because it will be hue wrapped around to end; virtually if not actually identical to first element the way this script will use it:
h_values = h_values[:-1]

# "If you are doing a large number of conversions between the same pair of spaces, then calling this function once and then using the returned function repeatedly will be slightly more efficient than calling cspace_convert() repeatedly." ; uncomment one only of the following OPTIONS:
# OPTION:
ciecam2RGB = colorspacious.cspace_converter("JCh", "sRGB255")		# returns a function converting from CIECAM02 lightness (J), chroma (C), and hue (h)
# OPTION:
# ciecam2RGB = colorspacious.cspace_converter("JMh", "sRGB255")      # " lightness (J), colorfulness (M), hue (h)
# How I figured out that resulting funtion expects one parameter:
# import inspect
# florf = inspect.signature(JCh2RGB)
# print(florf)

colorsRGB = []
    # DEPRECATED METHOD:
    # for h in range(h_min, h_max, h_step):
for h in h_values:
#	print("h is ", h)
	JCh = np.array([ [J, C, h] ])
	RGB = ciecam2RGB(JCh)
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

for element in colorsRGB:
 	print(element)