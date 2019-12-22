# DESCRIPTION
# Takes a list of RGB colors expressed in hex (one per line) and sorts them 
# using an advanced color appearance model for human color vision: CIECAM02.
# If you're sorting very different colors, YOU MAY WISH to use
# RGBhexColorSortinCAM16-UCS.py instead (see). This uses the colorspacious library; that uses colour-science.
# A test array for this: #E33200 #FF8B94 #54F1F1 #499989 #AAEFCB #8E4C5C #F7B754 #8AC2B0 #DE9D38 #FA9394 #ADDCCA #2DD1AA #E5E4E9 #02547D #78BF82 #745D5F #414141 #958F95 #FDE182 #7699C7 #FF5933 #D9BB93 #F1E5E9 #EA5287 #E3DB9A #95B6BA #59746E #333388 #008D94 #2EC1B1 #FF534E #367793 #00A693

# NOTES: this script expects perfect data. If there's a blank line anywhere in the
# input file, or any other unexpected data, it may stop with an unhelpful error.
# ALSO, this script will eliminate duplicates in the input list.
#
# USAGE
# With this script and a .hexplt file both in your immediate path, and
# Python in your PATH, call this script with one parameter, being a hex palette list:
# Python RGBhexColorSortInCIECAM02.py inputColors.hexplt
#
# It will print the sort result to stdout, so that you may for example redirect the output to a new .hexplt file, e.g.:
# Python hex2CIECAM02colorSort2hex.py PrismacolorMarkers.hexplt > PrismacolorMarkers_CIECAM02_hsJ_sort.hexplt
#
# OR, if you pass an optional 2nd argument (which may be anything), it will overwrite the source file with the sorted colors.

# DEPENDENCIES
# Python (probably Python 3.5), various python packages (see import list at start of code) which you may install with
# easy_install or pip.

# TO DO
# Try the same function but with different parameters J'a'b' in the colour library? 
# re: https://colour.readthedocs.io/en/develop/generated/colour.difference.delta_E_CAM16LCD.html
# re: https://colour.readthedocs.io/en/develop/tutorial.html
# NOTE that the install package name for that is colour-science, NOT colour (which is valid but
# something else far more limited!)

# KNOWN ISSUES
# The same input sorted in a different order always produces the same output, but you must
# decide what the first color in the list is--because if you change the first color, the
# sorting changes.

# LICENSE
# This is my original code and I release it to the Public Domain. -RAH 2019-09-23 09:18 PM

# REFERENCE
# - See URLs in comments in the below code. They all probably were developed because of this
# paper: https://www.researchgate.net/publication/227991182_CIE_Color_Appearance_Models_and_Associated_Color_Spaces
# - Chart of all known color spaces / models and how to convert between them, re colour library:
# https://colour.readthedocs.io/en/develop/index.html#automatic-colour-conversion-graph-colour-graph
# - I only get the colorio library installing on python 3.8.0 on mac. possible use of cam16 color
# - another library that does other things: http://markkness.net/colorpy/ColorPy.html
# space in it: https://github.com/nschloe/colorio/blob/master/test/test_cam16.py
# - stinking awesome answer that led to some of this: https://stackoverflow.com/a/49346067/1397555


# CODE
import sys
from itertools import combinations
from colorspacious import cspace_convert, deltaE

def hex_to_CIECAM02_JCh(in_string):
    """ Takes an RGB hex value and returns:
    1. a CIECAM02 3-point value.
    2. The CIECAM02 triplet string used in the cspace_convert function call in this function.
    This is because you may want to hack this function to try different triplet strings. See comments
    in this function, and the cspace_convert function call in this function."""
        # hex to RGB ganked from https://stackoverflow.com/a/29643643/1397555 :
    RGB = tuple(int(in_string[i:i+2], 16) for i in (0, 2, 4))
        # REFERENCE for the third parameter of the next function call in code; re
        # re https://colorspacious.readthedocs.io/en/latest/reference.html#colorspacious.deltaE :
        # classcolorspacious.JChQMsH(J, C, h, Q, M, s, H)
        # A namedtuple with a mnemonic name: it has attributes J, C, h, Q, M, s, and H, each of which holds a scalar
        # or NumPy array representing . . 
        # [things!] . . . [read the docs thar!] . . . and as a convenience, all strings composed of the character
        # JChQMsH are automatically treated as specifying CIECAM02-subset spaces, so you can write:
        # 
        # "JCh"
        #
        # SO . . .
        # J = lightness
        # C = chroma
        # h = hue angle
        # Q = brightness
        # M = colorfulness
        # s = saturation
        # H = hue composition
        # 
        # . . . whatever on earth that all means.
        # 
        # The documentation (defaults to? and) recommends sort by "JCh".
        # Possible sorts are [h/H/][M/s/C][J/Q]
        #
        # permutations of 'J', 'C', 'h':
        # ('J', 'C', 'h')
        # ('J', 'h', 'C')
        # ('C', 'J', 'h')
        # ('C', 'h', 'J')
        # ('h', 'J', 'C')
        # ('h', 'C', 'J')
        #
        # I would suggest you maybe try "hQC", "hCQ", "HsQ", "ChJ", "Jhs", IF THE
        # RESULTS DIFFERED. In early development I thought they did, but that was
        # because my script's intended functionality was broken (same input didn't
        # always produce same output) :
    CIECAM02_dimSTR = "JCh"
    CIECAM02_dimResult = cspace_convert(RGB, "sRGB255", CIECAM02_dimSTR)
    return CIECAM02_dimResult, CIECAM02_dimSTR


# split input file into list on newlines:
inputFile = sys.argv[1]
f = open(inputFile, "r")
colors_list = list(f.read().splitlines())
f.close()
# strip beginning '#' character off every string in that list:
colors_list = [element[1:] for element in colors_list]
# deduplicate the list, but maintain same order:
from more_itertools import unique_everseen
colors_list = list(unique_everseen(colors_list))

# SORT HEX RGB color list to next nearest per color,
# by converting to CIECAM02, then sorting on some dimensions in that space.

# get a list of lists of all possible color two-combinations, with an deltaE (distance
# measurement between the colors) as a value in the lists; doing this
# with manual nested for loops because itertools returns tuples and other reasons that
# may not be valid:
pair_deltaEs = []

if len(sys.argv) > 1:	# if a second parameter was passed to script, do these things:
    print('Input file is ', inputFile)
    print('Getting deltaE for all color combinations . . .')
for i in range(len(colors_list)):
    for j in range(i + 1, len(colors_list)):
        # print(colors_list[i], colors_list[j])
        CIECAM02_comp_one, SPACE = hex_to_CIECAM02_JCh(colors_list[i])
        CIECAM02_comp_two, SPACE = hex_to_CIECAM02_JCh(colors_list[j])
        distance = deltaE(CIECAM02_comp_one, CIECAM02_comp_two, input_space = SPACE)
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