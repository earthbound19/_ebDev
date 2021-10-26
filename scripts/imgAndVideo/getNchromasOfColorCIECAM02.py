# DESCRIPTION
# Gets -n chromatic intensities (different states of saturation) for any -c color via the CIECAM02 color space, which models human perception of color (and brightness and other aspects of light) better than any other model at this writing. Writes results to a new .hexplt file named after the color.

# DEPENDENCIES
# Python and the various import libraries declared at the start of CODE.

# USAGE
# Run this script through a Python interpeter with the --help parameter for instructions, or read the description sections in the argsparse setup below.
# EXAMPLE RUN that produces 16 chromacities of medium blue, which the script will write to the file named 0041ff_6_chromas.hexplt:
#    python /path/to_this_script/getNchromasOfColorCIECAM02.py -n 7 --COLOR 0041ff
# NOTES
# - It may produce some unexpected colors. I recommend you use an editor that live previews hex colors (like Atom with the highlight-colors package). You may be able to avoid unexpected colors by overriding start chromacity of color (see -o parameter).
# - It writes results to a file named after the color, e.g. `fff585_15shades.hexplt`.


# CODE
# DEV NOTES
# SEE COMMENTS IN get_CIECAM02_simplified_gamut.py, BUT:
# J (brightness or lightness) range is 0 to 100, h (hue) is 0 to 360, C (chroma) can be 0 to any number (I don't believe that there _is_ a max from whatever corollary/inputs produces the max), maybe max 160. For hard-coded colors, start with max 182 (this seemed a thing with L in HCL).

import sys
import numpy as np
from colorspacious import cspace_converter, cspace_convert
import argparse

# configure arguments / help
PARSER = argparse.ArgumentParser(description='Gets -n chromas (different chromatic intensities or saturations) of any -c color via the CIECAM02 color space, which models human perception of color (and brightness and other aspects of light) better than any other model at this writing.')
PARSER.add_argument('-c', '--COLOR', help='String. Color to get chromas of, in RGB HEX format e.g. \"-c \'f800fc\'\" (without the double quote marks, but _with_ the single quote marks) for magenta. Default magenta if not provided.', type=str)
PARSER.add_argument('-n', '--NUMBER_OF_CHROMAS', help='Number. How many chromas of color to generate from original color saturation point to gray (no chroma)., e.g. "-n 7" (without the quote marks) for 7 chromas.', type=int, required=True)
PARSER.add_argument('-o', '--CHROMA_OVERRIDE', help='Optional number from 0 to unknown (maybe 160 to 180). If provided, overrides innate chroma (according to CIECAM02 / JCh modeling of C or chroma) of -c color, resulting in colors stepping down from this override chroma. You may need to experiment to find the chroma that works best for the color you give this script, as chroma is a freaky animal in this color model (or maybe just the implementation of it in the library this script uses?), which has a varying maximum range depending on whether Grogu is happy. If not provided, generated chromas will step (default down) from colors\' chroma as calculated by this script to the nearest n-divided step from gray. Not providing this parameter, and using the calculated C from a full chromacity provided color -c is recommended', type=int)
PARSER.add_argument('-r', '--GRAY_TO_CHROMA', help='Optional switch (no value needed). If present, chromas will be generated from gray to saturated (instead of default saturated to gray).', action='store_true')
ARGS = PARSER.parse_args()

# init globals / from parsed arguments
# default color:
COLOR_HEX_RGB_GLOBAL = 'f800fc'
# override that default if appropriate arg. passed:
if ARGS.COLOR:
	COLOR_HEX_RGB_GLOBAL = str(ARGS.COLOR)
	COLOR_HEX_RGB_GLOBAL = COLOR_HEX_RGB_GLOBAL.rstrip()		# Windows newlines mess with that string otherwise!
GLOBAL_NUMBER_OF_CHROMAS = ARGS.NUMBER_OF_CHROMAS

# Global clamp function keeps values in boundaries and also converts to int
def clamp(val, minval, maxval):
    if val < minval: return int(minval)
    if val > maxval: return int(maxval)
    return int(val)

# delete any / all # from string if they are provided in arg. (more than one would be bad source):
COLOR_HEX_RGB_GLOBAL = COLOR_HEX_RGB_GLOBAL.replace('#', '')
# print("~\n-c color parameter is ", COLOR_HEX_RGB_GLOBAL)

RGB = tuple(int(COLOR_HEX_RGB_GLOBAL[i:i+2], 16) for i in (0, 2, 4))
JCh_result = cspace_convert(RGB, "sRGB255", "JCh")
# JCH_result[0] is J, JCH_result[1] is C, [JCH_result2] is h

C_min = 0.0000000000000001      # Practically zero and avoids divide by zero warning
C_max = JCh_result[1]
# alter C_max if param. says so:
if ARGS.CHROMA_OVERRIDE:
	C_max = ARGS.CHROMA_OVERRIDE

# It turns out that the way I've coded this, the math works out how I want if I reverse things here. If GRAY_TO_CHROMA has been set, it will be used to reverse the order of colors later. Meanwhile, here:
tmp = C_min; C_min = C_max; C_max = tmp

J = JCh_result[0]				# J
h = JCh_result[2]				# h

JCh2RGB = cspace_converter("JCh", "sRGB255")		# returns a function

colorsRGB = []
# Thanks to help here: https://stackoverflow.com/a/7267806/1397555
AKTUL_MATH_NUMBER_OF_CHROMAS = GLOBAL_NUMBER_OF_CHROMAS + 1       # This is because the way the math is done here, the first shade will be black, and my intend is to have shades exluding black and white (which are the perfect shade and tint of every color). The math doesn't work out here to include white.
descending_c_values = np.linspace(C_max, C_min, num=AKTUL_MATH_NUMBER_OF_CHROMAS)
for C in descending_c_values:
	# build JCh array:
	JCh = np.array([ [J, C, h] ])
	# build RGB hex array:
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
colorsRGB.pop(0)     # removes the first color, which is black. White isn't in the list via the math; see an earlier comment.
if not ARGS.GRAY_TO_CHROMA:		# if told to reverse gradient (dark -> white), reverse that list; but (re earlier comment), as the math works best dark to light, that's actually how it's done internally anyway, so only reverse it here (light to dark) if _not_ told it is dark to light:
    colorsRGB.reverse()

outFileName = COLOR_HEX_RGB_GLOBAL + "_" + str(len(colorsRGB)) + "_chromas.hexplt"

print("Writing to output file ", outFileName, " . . .")
f = open(outFileName, "w")
for element in colorsRGB:
# 	# print(element)
	f.write(element + "\n")
f.close()