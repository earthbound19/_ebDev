# DESCRIPTION
# Takes a list of RGB colors expressed in hex (one per line) and sorts them 
# using an advanced color appearance model for human color vision: CIECAM02, sorting into
# lists of darks and lights (nearest to black and nearest to white), via the colorspacious library.
# Adapted from RGBhexColorSortIn2CIECAM02.py.
# A test array for this: #E33200 #FF8B94 #54F1F1 #499989 #AAEFCB #8E4C5C #F7B754 #8AC2B0 #DE9D38 #FA9394 #ADDCCA #2DD1AA #E5E4E9 #02547D #78BF82 #745D5F #414141 #958F95 #FDE182 #7699C7 #FF5933 #D9BB93 #F1E5E9 #EA5287 #E3DB9A #95B6BA #59746E #333388 #008D94 #2EC1B1 #FF534E #367793 #00A693

# NOTES: this script expects perfect data. If there's a blank line anywhere in the
# input file, or any other unexpected data, it may stop with an unhelpful error.
# ALSO, this script will eliminate duplicates in the input list.
#
# USAGE
# With this script and a .hexplt file both in your immediate path, and
# Python in your PATH, call this script with one parameter, being a hex palette list:
# Python RGBhexColorSortToDarksAndLightsIn2CIECAM02.py inputColors.hexplt
# --
# It will print the results to new files named darks.hexplt and lights.hexplt
# you may sort those results by next nearest color via e.g. RGBhexColorSortIn2CIECAM02.py.

# LICENSE
# This is my original code and I release it to the Public Domain. -RAH 2019-12-03 03:17 AM



# CODE
import sys
from itertools import combinations
from more_itertools import unique_everseen
from colorspacious import cspace_convert, deltaE

def hex_to_CIECAM02_JCh(in_string):
    """ Takes an RGB hex value and returns:
    1. a CIECAM02 3-point value.
    2. The CIECAM02 triplet string used in the cspace_convert function call in this function.
    This is because you may want to hack this function to try different triplet strings. See comments
    in this function, and the cspace_convert function call in this function."""
    RGB = tuple(int(in_string[i:i+2], 16) for i in (0, 2, 4))
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
colors_list = list(unique_everseen(colors_list))

# SORT HEX RGB color list to next nearest per color,
# by converting to CIECAM02, then sorting on some dimensions in that space.

# get a list of lists of all possible color two-combinations, with an deltaE (distance
# measurement between the colors) as a value in the lists; doing this
# with manual nested for loops because itertools returns tuples and other reasons that
# may not be valid:
pair_deltaEs_darks = []
pair_deltaEs_lights = []

white_comp, DISCARD = hex_to_CIECAM02_JCh('FFFFFF')
black_comp, DISCARD = hex_to_CIECAM02_JCh('000000')

if len(sys.argv) > 1:	# if a second parameter was passed to script, do these things:
    print('Input file is ', inputFile)
    print('Getting deltaE for all colors vs. black and white . . .')
for i in range(len(colors_list)):
    # print(colors_list[i], colors_list[j])
    CIECAM02_comp, SPACE = hex_to_CIECAM02_JCh(colors_list[i])
    distance_white_comp = deltaE(CIECAM02_comp, white_comp, input_space = SPACE)
    distance_black_comp = deltaE(CIECAM02_comp, black_comp, input_space = SPACE)
    if distance_white_comp < distance_black_comp:       # lower delta means _closer_
        pair_deltaEs_lights.append(colors_list[i])
    else:
        pair_deltaEs_darks.append(colors_list[i])
    if distance_white_comp == distance_black_comp:      # if the distances are equal, default to lights list:
        pair_deltaEs_lights.append(colors_list[i])


# dump to lists and report dump
print('Writing to darks list . . .')
with open('darks.hexplt', 'w') as f:
    for element in pair_deltaEs_darks:
        print_element = '#' + element + '\n'
        f.write(print_element)
f.close()

print('Writing to lights list . . .')
with open('lights.hexplt', 'w') as f:
    for element in pair_deltaEs_lights:
        print_element = '#' + element + '\n'
        f.write(print_element)
f.close()