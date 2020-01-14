# DESCRIPTION
# variant of RGBhexColorSortInCIECAM02.py which uses the color-science library
# and CAM16 color model for color sorting (supposedly superior to CIECAM02).
# In my tests, RGBhexColorSortInCIECAM02.py (which uses the colorspacious library) does
# better for hue matching independent of brightness; this (which uses colour-science) does
# better for matching first brightness/saturation, then hue. Both give good results. To my eye colorspacious
# is better overall (maybe I reckon hue before brightness/saturation).
# Also, it may be a matter of here figuring the best illuminant and transform matrix paramters.
# You can also try different chromatic_adaptation_transform values from here:
# https://colour.readthedocs.io/en/develop/generated/colour.RGB_to_XYZ.html
# Also, I may not know what I'm doing here -- the illuminants and transform matrix have me scratching my head.
# A test array for this: #E33200 #FF8B94 #54F1F1 #499989 #AAEFCB #8E4C5C #F7B754 #8AC2B0 #DE9D38 #FA9394 #ADDCCA #2DD1AA #E5E4E9 #02547D #78BF82 #745D5F #414141 #958F95 #FDE182 #7699C7 #FF5933 #D9BB93 #F1E5E9 #EA5287 #E3DB9A #95B6BA #59746E #333388 #008D94 #2EC1B1 #FF534E #367793 #00A693

# NOTES: this script expects perfect data. If there's a blank line anywhere in the
# input file, or any other unexpected data, it may stop with an unhelpful error.
# ALSO, this script will eliminate duplicates in the input list.

# USAGE
# With this script and a .hexplt file both in your immediate path, and
# Python in your PATH, call this script with one parameter, being a hex palette list:
# Python hex2CIECAM02colorSort2hex.py PrismacolorMarkers.hexplt
#
# It will print the sort result to stdout, so that you may for example redirect the output to a new .hexplt file, e.g.:
# Python RGBhexColorSortInCAM16-UCS.py inputColors.hexplt
#
# OR, if you pass an optional 2nd argument (which may be anything), it will overwrite the source file with the sorted colors.

# DEPENDENCIES
# Python 3, various python packages (see import list at start of code) which you may install with
# easy_install or pip.

# KNOWN ISSUES
# The same input sorted in a different order always produces the same output, but you must
# decide what the first color in the list is--because if you change the first color, the
# sorting changes.

# LICENSE
# This is my original code and I release it to the Public Domain. -RAH 2019-09-23 09:18 PM

# REFERENCE and dev notes
# - Also, CAM16 has superceded CIECAM02: https://arxiv.org/abs/1802.06067
# CAM16 defines via tristimulus values XYZ: lightness J, brightness Q, chroma C, colorfulness M, saturation s, and hue h. re https://observablehq.com/@jrus/cam16
# - maybe yet better, as it's referenced in a paper -- https://arxiv.org/pdf/1802.06067.pdf --
# describing the very same implementation as a solution to found problems in CIECAM02;
# it is implemented in https://github.com/nschloe/colorio
# DEV NOTE: 
# "The results showed that J'a'b' gave the second best (CAM16-UCS was the best) performance
# for small color difference data sets and the best for experimental data corresponding to
# large color differences." -- https://www.osapublishing.org/DirectPDFAccess/83324CA3-D13F-9C21-A2C857331BED04A3_368272/oe-25-13-15131.pdf?da=1&id=368272&seq=0&mobile=no (from https://www.osapublishing.org/oe/abstract.cfm?uri=oe-25-13-15131) and https://www.osapublishing.org/DirectPDFAccess/72B3A417-CBFB-5C71-084E496F156FBA4E_368272/oe-25-13-15131.pdf?da=1&id=368272&seq=0&mobile=no
# in J'a'b, "J refers to lightness, a refers to redness-to-greenness, and b refers to blueness-to-yellowness." re https://github.com/connorgr/d3-cam02 (that is a javascript library I think)
# also re https://colour.readthedocs.io/en/develop/generated/colour.XYZ_to_JzAzBz.html#colour.XYZ_to_JzAzBz
# "Returns:	JzAzBz colourspace array where Jz is Lightness, Az is redness-greenness and Bz is yellowness-blueness."
# - to get all convert functions starting with a string:
# print([name for name in colour.__all__ if name.startswith('XYZ_to')])
# - to get conversion path from one color space / model to another
# (but I got errors trying) :
# colour.describe_conversion_path('sRGB', 'CAM16UCS', width=75)
# re https://colour.readthedocs.io/en/develop/generated/colour.describe_conversion_path.html#colour.describe_conversion_path
# JzAzBz is based on CAM16? re: http://files.cie.co.at/x046_2019/x046-OP71.pdf: "A new whiteness formula, named white J’a’b’ (WJ’a’b’) was derived using the datasets introduced in the last section..where J’, a’, b’ are the colour coordinates of the test stimulus in CAM16-UCS within the colour boundary."
# - yet another library: https://www.tandfonline.com/doi/full/10.1080/15502724.2018.1518717


# CODE
import sys
import colour        # this must be the colour-science package, NOT the colour package.
from itertools import combinations
from more_itertools import unique_everseen


# split input file into list on newlines:
inputFile = sys.argv[1]
f = open(inputFile, "r")
colors_list = list(f.read().splitlines())
f.close()
# strip beginning '#' character off every string in that list:
colors_list = [element[1:] for element in colors_list]
# deduplicate the list, but maintain same order:
colors_list = list(unique_everseen(colors_list))


# GLOBALS:
pair_deltaEs = []
# going with example parameters from:
# https://colour.readthedocs.io/en/develop/generated/colour.RGB_to_XYZ.html
# A THING TO TRY for illuminants: [0.33333333, 0.33333333]
# -- which is the 1964 10-degree illuminant E values (no white tint in that like D65!) :
# TO DO? : figure out how to get illuminant values via whatever constant/variable is in the library.
illuminant_RGB = [0.33333333, 0.33333333]       # example gives [0.31270, 0.32900]
illuminant_XYZ = [0.34570, 0.35850]             # example gives [0.34570, 0.35850]
chromatic_adaptation_transform = 'Bradford'
RGB_to_XYZ_matrix = [
    [0.41240000, 0.35760000, 0.18050000],
    [0.21260000, 0.71520000, 0.07220000],
    [0.01930000, 0.11920000, 0.95050000]
]

# SORT HEX RGB color list to next nearest per color,
# by first converting hex to integers between 0 and 1 (as the colour-science library expects),
# then those RGB percetns to JzAzBz (which is based on or related to CAM16, which succeeded CIECAM02?),
# then using a color pair distance find function that uses JzAzBz with the CAM16-UCS method, whatever
# exactly that means:

# get a list of lists of all possible color two-combinations, with an deltaE (distance
# measurement between the colors) as a value in the lists; doing this
# with manual nested for loops because itertools returns tuples (and other reasons that
# may not be valid) :
if len(sys.argv) > 1:    # if a second parameter was passed to script, do these things:
    print('Input file is ', inputFile)
    print('Getting deltaE for all color combinations . . .')
for i in range(len(colors_list)):
    for j in range(i + 1, len(colors_list)):
        i_RGB = tuple(int(colors_list[i][x:x+2], 16) for x in (0, 2, 4))
        j_RGB = tuple(int(colors_list[j][x:x+2], 16) for x in (0, 2, 4))
        # convert those to percent (0 to 1) per colour-science expectation:
        percent_i_RGB = [(i_RGB[0] / 255), (i_RGB[1] / 255), (i_RGB[2] / 255)]
        percent_j_RGB = [(j_RGB[0] / 255), (j_RGB[1] / 255), (j_RGB[2] / 255)]
        # RGB to XYZ:
        RGB_i_as_XYZ = colour.RGB_to_XYZ(percent_i_RGB, illuminant_RGB, illuminant_XYZ, RGB_to_XYZ_matrix, chromatic_adaptation_transform)
        RGB_j_as_XYZ = colour.RGB_to_XYZ(percent_j_RGB, illuminant_RGB, illuminant_XYZ, RGB_to_XYZ_matrix, chromatic_adaptation_transform)
        # color comparison from XYZ through a delta function in another color space:
        # CAM16 boneyard:
            # RGB_i_as_CAM16 = colour.XYZ_to_CAM16(RGB_i_as_XYZ, XYZ_w, L_A, Y_b, CAM16_SURROUND, 0)
            # RGB_i_as_CAM16 = colour.XYZ_to_CAM16(RGB_j_as_XYZ, XYZ_w, L_A, Y_b, CAM16_SURROUND, 0)
                # CAM16_Specification(J=14.25387410524929, C=26.098284643489645, h=32.022241090829169, s=148.81680522210502, Q=8.1330918133918981, M=18.011904219372205, H=15.205855285709777, HC=None)
                # re: https://colour.readthedocs.io/en/develop/generated/colour.difference.delta_E_CAM16UCS.html
                # distance = colour.difference.delta_E_CAM16UCS(RGB_i_as_Jab, RGB_i_as_CAM16)
                # colour.delta_E(RGB_i_as_Jab, RGB_i_as_CAM16, method='CAM16-UCS')
                # NOPE -- that ran into a brickwall when I searched for a delta_E function that would take that result. 
                # IS NONE FOUND. And no compare functions I find will use Jch from that.
        # INSTEAD; going with defaults because I don't understand the second constants param given here:
        # https://colour.readthedocs.io/en/develop/generated/colour.XYZ_to_JzAzBz.html
        RGB_i_as_JzAzBz = colour.XYZ_to_JzAzBz(RGB_i_as_XYZ)
        RGB_j_as_JzAzBz = colour.XYZ_to_JzAzBz(RGB_j_as_XYZ)
            # deprecated, though it seems to produce the same result? :
            # distance = colour.delta_E(RGB_i_as_JzAzBz, RGB_j_as_JzAzBz, method='CAM16-UCS')
        # re: https://colour.readthedocs.io/en/develop/generated/colour.difference.delta_E_CAM16UCS.html#colour.difference.delta_E_CAM16UCS
        distance = colour.difference.delta_E_CAM16UCS(RGB_i_as_JzAzBz, RGB_j_as_JzAzBz)
        pair_deltaEs.append([distance, colors_list[i], colors_list[j]])

# results in lowest deltaE values first; may cause searches to run faster (I don't know):
if len(sys.argv) > 1:
    print('Sorting deltaEs . . .')
pair_deltaEs.sort()
sorted_colors = list()

if len(sys.argv) > 1:
    print('Sorting colors by nearest deltaE . . .')
search_color = colors_list[0]
sorted_colors.append(search_color)  # starts list
while len(sorted_colors) < len(colors_list):
    # get subsection of deltaE list in which color appears:
    deltaEs_subsection = list()
    for idx, element in enumerate(pair_deltaEs):
        if search_color in element:
            deltaEs_subsection.append(element)
    # sort that subsection, which places the lowest deltaE in the first list in it.
    deltaEs_subsection.sort()
    # then put the color pair in that subsection list in the sorted list, with the search color (the
    # "search_color" variable here in this code) first; the search color may
    # be at either [0][1] or [0][2], so figure out which. Then add color and the
    # other color: if len(deltaEs_subsection) > 1:
    if search_color == deltaEs_subsection[0][1]:
        matched_color = deltaEs_subsection[0][2]
        sorted_colors.append(matched_color)
#        print('added ', matched_color, 'for', search_color)
        search_color = matched_color
    else:
        matched_color = deltaEs_subsection[0][1]
        sorted_colors.append(matched_color)
#        print('added ', matched_color, 'for', search_color)
        search_color = matched_color
    # remove the subsection from pair_deltaEs, to avoid future matches against current search_color
    # after search_color changes in the next loop:
    for element_two in deltaEs_subsection:
        pair_deltaEs.remove(element_two)


# FINALE
# If a second argument (which may be anything) was passed to the script, 
# overwrite the source read file with the sorted copy of it.
# Otherwise, print the sorted list to stdout.
if len(sys.argv) > 2:
    print('Writing sorted color list back over original file . . .')
    with open(inputFile, 'w') as f:
        for element in sorted_colors:
            print_element = '#' + element + '\n'
            f.write(print_element)
    f.close()
else:
    for element in sorted_colors:
        print_element = '#' + element
        print(print_element)