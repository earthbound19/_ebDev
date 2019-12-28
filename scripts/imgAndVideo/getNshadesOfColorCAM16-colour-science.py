print("see description in comments. buggy script stub; forsaken.")
exit()

# DESCRIPTION
# IN PROGRESS and possibly eternal stasis. I'm in over my head with this maybe.
# At this writing turns white gradients to green, and throws out of bound errors if you
# e.g. pass -c FF00FF.
# Gets -n shades of any -c color (default white if not passed) via the CAM16 color space,
# which models human perception of color (and brightnes and other aspects of light) possibly
# better than any other model at this writing. Creates .hexplt files (flat list of RGB
# Hex colors) named after the color and number of shades of it produced. Variant of script
# getNshadesOfColorCIECAM02.py, which uses one ciecam02 python library; this uses colour-science.

# DEPENDENCIES
# various libraries you'll see in the import list, plus sub-dependency easydev

# USAGE
# run script with --help.

# CODE
import sys
import numpy as np
from colormap import rgb2hex    # which also needs easydev (pip install easydev)
import colour
import argparse
import more_itertools

# configure arguments / help
PARSER = argparse.ArgumentParser(description='Gets -n shades of any -c color (default color is white if not passed) via the CIECAM02 color space, which models human perception of color (and brightnes and other aspects of light) better than any other model at this writing.')
PARSER.add_argument('-c', '--COLOR', help='String. Color to get shades of, in RGB HEX format e.g. \"-c \'FF00FF\'\" (without the double quote marks, but _with_ the single quote marks) for magenta. May need to _not_ use single quote marks with Windows or some Python versions?', type=str)
PARSER.add_argument('-n', '--NUMBER_OF_SHADES', help='Number. How many shades of color to generate from brightest original color point to black., e.g. "-n 15" (without the quote marks) for 15 shades.', type=int, required=True)
PARSER.add_argument('-b', '--BRIGHTNESS_OVERRIDE', help='Optional number from 0 to 100. If provided, overrides innate brightness (according to CIECAM02 / JCh modeling of J or brightness) of -c color, resulting in colors stepping down from this override brightness. 100 is full bright (will appear white or near-white), 50 is medium bright, 0 is dark (will appear black or near-black). If not provided, generated shades will step (default down) from colors\' inherent brightness to black or near black. To step up to white, see -r option.', type=int)
PARSER.add_argument('-r', '--DARK_TO_BRIGHT', help='Optional switch (no value needed). If present, shades will be generated from dark to light (instead of default bright to dark).', action='store_true')

# HARD-CODED GLOBALS:
# VALUES for RGB to XYZ convertsion. Going with example parameters from:
# https://colour.readthedocs.io/en/develop/generated/colour.RGB_to_XYZ.html
# A THING TO TRY for illuminants: [0.33333333, 0.33333333]
# -- which is the 1964 10-degree illuminant E values (no white tint in that like D65!) :
# TO DO? : figure out how to get illuminant values via whatever constant/variable is in the library.
illuminant_RGB = [0.33333333, 0.33333333]       # example gives [0.31270, 0.32900]
illuminant_XYZ_for_RGB = [0.34570, 0.35850]             # example gives [0.34570, 0.35850]
RGB_to_XYZ_matrix = [
    [0.41240000, 0.35760000, 0.18050000],
    [0.21260000, 0.71520000, 0.07220000],
    [0.01930000, 0.11920000, 0.95050000]
]
chromatic_adaptation_transform = 'Bradford'
# VALUES FOR XYZ to CAM16 conversion.
# 10-degree viewer illuminant values from 1964:
# D65: [ 0.31382, 0.331 ]
# E: (equal energy): [0.33333333, 0.33333333]
# For CAM16 conversion, some of these adapted from https://colour.readthedocs.io/en/develop/generated/colour.XYZ_to_CAM16.html
XYZ_w__ILLUMINANT_E = [0.33333333, 0.33333333, 0.33333333]            # color temp. 5454 something?
L_A = XYZ_w__ILLUMINANT_E[0] + XYZ_w__ILLUMINANT_E[1] / 2 * 0.2
Y_b = 20.0
CAM16_SURROUND = colour.CAM16_VIEWING_CONDITIONS['Average']
# VALUES FOR XYZ to RGB transform:
XYZ_to_RGB_matrix = [
    [3.24062548, -1.53720797, -0.49862860],
    [-0.96893071, 1.87575606, 0.04151752],
    [0.05571012, -0.20402105, 1.05699594]
]


# GLOBAL FUNCTION
# Global clamp function, re: https://stackoverflow.com/a/4092565
def clamp(val, minval, maxval):
    if val < minval: return minval
    if val > maxval: return maxval
    return val

# default color:
COLOR_HEX_RGB_GLOBAL = 'FFFFFF'

# init globals / from parsed arguments
ARGS = PARSER.parse_args()

# override default color if appropriate arg. passed:
if ARGS.COLOR:
    COLOR_HEX_RGB_GLOBAL = str(ARGS.COLOR)
GLOBAL_NUMBER_OF_SHADES = ARGS.NUMBER_OF_SHADES

# delete any / all # from string if they are provided in arg. (more than one would be bad source):
COLOR_HEX_RGB_GLOBAL = COLOR_HEX_RGB_GLOBAL.replace('#', '')
# print("~\n-c color parameter is ", COLOR_HEX_RGB_GLOBAL)

    # previous code with different color library:
    # JCh_result = cspace_convert(RGB, "sRGB255", "JCh")
    # JCH_result[0] is J, JCH_result[1] is C, [JCH_result2] is h
RGB = tuple(int(COLOR_HEX_RGB_GLOBAL[i:i+2], 16) for i in (0, 2, 4))
RGBs_as_percent = [(RGB[0] / 255), (RGB[1] / 255), (RGB[2] / 255)]
RGBs_as_XYZ = colour.RGB_to_XYZ(RGB, illuminant_RGB, illuminant_XYZ_for_RGB, RGB_to_XYZ_matrix, chromatic_adaptation_transform)
# Values at this point seem orders of magnitute out of whack
# unless I scale them after xyz conversion, but this might be expected,
# re: https://colour.readthedocs.io/en/develop/basics.html#domain-range-scales
RGBs_as_XYZ *= 0.001        # needs to be scaled that much maybe?!
JCh = colour.XYZ_to_CAM16(RGBs_as_XYZ, XYZ_w__ILLUMINANT_E, L_A, Y_b)
JCh_result = [clamp(JCh.J, 0, 100), clamp(JCh.C, 0, 100), clamp(JCh.h, 0, 360)]

J_min = 0
# set J_max depending on param.:
if ARGS.BRIGHTNESS_OVERRIDE:
    J_max = ARGS.BRIGHTNESS_OVERRIDE
else:
    J_max = JCh_result[0]        # J

# NOTE that as this is a negative number (default) and will be used for range() step, step will be negative! :
J_step = J_max / GLOBAL_NUMBER_OF_SHADES * -1
if J_step == 0:
    print("Zero resulting additional colors. Will produce no file and exit script.")
    exit()

# J_max -= (J_step * 2)
if ARGS.DARK_TO_BRIGHT:        # if told to reverse gradient (dark -> white)
    tmp = J_min; J_min = J_max; J_max = tmp
    J_step = J_step * -1
# print("J_min", J_min, " J_max", J_max, " J_step", J_step)
C = JCh_result[1]                # C
h = JCh_result[2]                # h

colorsRGB = []
# could alternately use numpy.arange() here? :
for J in more_itertools.numeric_range(J_max, J_min, J_step):
    # build JCh array:
    JCh = [J, C, h]
    # needs CAM16_specification from a function returning JCh values, OR just straight up making up those values:
    XYZ_result = colour.CAM16_to_XYZ(JCh, XYZ_w__ILLUMINANT_E, L_A, Y_b)
    RGB_result = colour.XYZ_to_RGB(XYZ_result, illuminant_XYZ_for_RGB, illuminant_RGB, XYZ_to_RGB_matrix, chromatic_adaptation_transform)
    RGB_result = RGB_result * 1000        # scaling back up per https://colour.readthedocs.io/en/develop/basics.html#domain-range-scales
    # turn back to straight int values:
    RGB_result = [int(RGB_result[0]), int(RGB_result[1]), int(RGB_result[2])]
    # print(RGB_result)
    hex_string = rgb2hex(RGB_result[0], RGB_result[1], RGB_result[2])
    # print("J ", J, "C ", C, "h", h, "; hex ", hex_string)
    colorsRGB.append(hex_string)
exit()
# Deduplicate list but maintain order; re: https://stackoverflow.com/a/17016257/1397555
colorsRGB = list(more_itertools.unique_everseen(colorsRGB))

outFileName = str(COLOR_HEX_RGB_GLOBAL) + "_" + str(len(colorsRGB)) + "shades.hexplt"

print("Writing to output file ", outFileName, " . . .")
f = open(outFileName, "w")
for element in colorsRGB:
#     # print(element)
    f.write(element + "\n")
f.close()