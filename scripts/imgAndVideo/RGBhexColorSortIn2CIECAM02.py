# DESCRIPTION
# Takes a list of RGB colors expressed in hex (one per line) and sorts them 
# using the state of the art color appearance model for human color vision: CIECAM02.
# v1.0.1 AKTULLY works (algorithm overhaul after I realized a logic error). Also, known issue solved.

# USAGE
# With this script and a .hexplt file both in your immediate path, and
# Python in your PATH, call this script with one parameter, being a hex palette list:
# Python hex2CIECAM02colorSort2hex.py PrismacolorMarkers.hexplt
#
# It will print the sort result to stdout, so that you may for example redirect the output to a new .hexplt file, e.g.:
# Python hex2CIECAM02colorSort2hex.py PrismacolorMarkers.hexplt > PrismacolorMarkers_CIECAM02_hsJ_sort.hexplt
#
# OR, if you pass an optional 2nd argument (which may be anything), it will overwrite the source file with the sorted colors.

# DEPENDENCIES
# Python (probably Python 3.5), various python packages (see import list at start of code) which you may install with easy_install or pip.

# KNOWN ISSUES
# The same input sorted in a different order always produces the same output, but you must decide what the first color in the list is--because if you change the first color, the sorting changes.

# LICENSE
# This is my original code and I release it to the Public Domain. -RAH 2019-09-23 09:18 PM

# REFERENCE
# See URLs in comments in the below code. They all probably were developed because of this
# paper: https://www.researchgate.net/publication/227991182_CIE_Color_Appearance_Models_and_Associated_Color_Spaces



# CODE
import sys
from itertools import combinations
from colorspacious import cspace_convert, deltaE

def hex_to_CIECAM02_JCh(in_string):
    """ Takes an RGB hex value and returns:
    1. a CIECAM02 3-point value.
    2. The CIECAM02 triplet string used in the cpace_convert function call in this function.
    This is because you may want to hack this function to try different triplet strins. See comments in this function, and the cpace_convert function call in this function."""
        # hex to RGB ganked from https://stackoverflow.com/a/29643643/1397555 :
    RGB = tuple(int(in_string[i:i+2], 16) for i in (0, 2, 4))
        # REFERENCE for the third parameter of the next function call in code; re
        # re https://colorspacious.readthedocs.io/en/latest/reference.html#colorspacious.deltaE :
        # classcolorspacious.JChQMsH(J, C, h, Q, M, s, H)
        # A namedtuple with a mnemonic name: it has attributes J, C, h, Q, M, s, and H, each of which holds a scalar or NumPy array representing . . 
        # [things!] . . . [read the docs thar!] . . . and as a convenience, all strings composed of the character JChQMsH are automatically treated as specifying CIECAM02-subset spaces, so you can write:
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

# SORT HEX RGB color list to next nearest per color,
# by converting to CIECAM02, then sorting on some dimensions in that space.

# get a list of lists of all possible color two-combinations, with an deltaE (distance
# measurement between the colors) as a value in the lists; doing this
# with manual nested for loops because itertools returns tuples and other reasons that
# may not be valid:
pair_deltaEs = []
if sys.argv[2]:
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
if sys.argv[2]:
    print('Sorting deltaEs . . .')
pair_deltaEs.sort()
sorted_colors = list()

if sys.argv[2]:
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
    # then put the color pair in that subsection list in the sorted list, with the search color (the "search_color" variable here in this code) first; the search color may
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
    # remove the subsection from pair_deltaEs, to avoid future matches against current search_color after search_color changes in the next loop:
    for element_two in deltaEs_subsection:
        pair_deltaEs.remove(element_two)


# FINALE
# If a second argument (which may be anything) was passed to the script, 
# overwrite the source read file with the sorted copy of it.
# Otherwise, print the sorted list to stdout.
try:
    yorf = sys.argv[2]
    print('Writing sorted color list back over original file . . .')
    with open(inputFile, 'w') as f:
        for element in sorted_colors:
            print_element = '#' + element + '\n'
            f.write(print_element)
    f.close()
except:
    for element in sorted_colors:
        print_element = '#' + element
        print(print_element)