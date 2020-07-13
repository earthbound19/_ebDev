# DESCRIPTION
# Compares two palettes (.hexplt format) $1 and $2 and prints a similarity ranking float between 0 and 1 (zero and one hundred percent). See USAGE for how it works.

# NOTES
# - You may want to use allRGBhexColorSortIn2CIECAM02.sh to sort all colors in all palettes in the directory you work in (with any .hexplt format color palettes) before running this script. The similarity ranking produced by this script will probably be meaningless without that.
# - Also, it may be meaningless unless the palettes compared have the same number of colors.
#
# USAGE
# Invoke with these parameters:
# - arvg[1] palette one file name, e.g. FD613A_F9C956_BAB25B_3D9676_1F463E.hexplt
# - arvg[2] palette two file name, e.g. FE6737_F8D845_9DC17E_489B73_375557.hexplt
# Example that will result in a print of a similarity ranking percent (a float between 0 and 1) for two palettes:
#  paletteCompareCIECAM02.py FD613A_F9C956_BAB25B_3D9676_1F463E.hexplt FE6737_F8D845_9DC17E_489B73_375557.hexplt
#
# HOW IT WORKS
# The script compares


# CODE
import sys
from itertools import combinations
from colorspacious import cspace_convert, deltaE

# GLOBALS and positional parameters check, with clear boolean/value inits to describe:
if len(sys.argv) > 1:
    hexpltFileNameOnePassedToScript = sys.argv[1]
else:
    print('\nNo parameter 1 (source .hexplt palette file one) passed to script. Exit.')
    sys.exit()
if len(sys.argv) > 2:
    hexpltFileNameTwoPassedToScript = sys.argv[2]
else:
    print('\nNo parameter 2 (source .hexplt palette file two) passed to script. Exit.')
    sys.exit()

# See RGBhexColorSortInCIECAM02.py for comments/function documentation.
def hex_to_CIECAM02_JCh(in_string):
    RGB = tuple(int(in_string[i:i+2], 16) for i in (0, 2, 4))
    CIECAM02_dimSTR = "JCh"
    CIECAM02_dimResult = cspace_convert(RGB, "sRGB255", CIECAM02_dimSTR)
    return CIECAM02_dimResult, CIECAM02_dimSTR

# CREATE FORMATTED LISTS (for comparisons) from input files:
from more_itertools import unique_everseen
# split input file one into list on newlines:
f = open(hexpltFileNameOnePassedToScript, "r")
colors_list_one = list(f.read().splitlines())
f.close()
# strip beginning '#' character off every string in that list:
colors_list_one = [element[1:] for element in colors_list_one]
# deduplicate the list, but maintain same order:
colors_list_one = list(unique_everseen(colors_list_one))

# Do the same things for input file two:
f = open(hexpltFileNameTwoPassedToScript, "r")
colors_list_two = list(f.read().splitlines())
f.close()
colors_list_two = [element[1:] for element in colors_list_two]
colors_list_two = list(unique_everseen(colors_list_two))

if (len(colors_list_one) != len(colors_list_two)):
    print('\nProblem: palette one and two are of different lenghts (they have different numbers of colors). They must have the same number of colors for this to work. (This can also happen if there are duplicate elements in a list but it has the same number of elements as the other list to begin with, because this script eliminates duplicate colors before comparison.) Exiting script.')
    sys.exit()

DeltaEs = []
for IDX, element in enumerate(colors_list_one):
    CIECAM02_comp_one, SPACE = hex_to_CIECAM02_JCh(colors_list_one[IDX])
    CIECAM02_comp_two, SPACE = hex_to_CIECAM02_JCh(colors_list_two[IDX])
    distance = deltaE(CIECAM02_comp_one, CIECAM02_comp_two, input_space = SPACE)
    # DeltaEs.append([distance, colors_list_one[IDX], colors_list_two[IDX]])
    DeltaEs.append(distance)

# To understand the following math, know this: a _lower_ delta value (toward zero) indicates that the colors are perceptually nearer together. A _higher_ delta value (toward 100) indicates that the colors are perceputally further apart.
sumOfDeltaEs = 0
for deltaE in DeltaEs:
    # sumOfDeltaEs += deltaE[0]
    sumOfDeltaEs += deltaE

# paletteDeltaE = sumOfDeltaEs / len(colors_list_one)
paletteDeltaE = (sumOfDeltaEs / len(colors_list_one)) / 100

print(paletteDeltaE)