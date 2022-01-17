# DESCRIPTION
# Variant of RGBhexColorSortInCIECAM02.py which uses the color-science library and CAM16 color model for color sorting. In my tests, RGBhexColorSortInCIECAM02.py (which uses the colorspacious library) does better for hue matching independent of brightness; this (which uses colour-science) does better for matching first brightness/saturation, then hue. Both give good results. To my eye colorspacious is better overall (maybe I reckon hue before brightness/saturation).

# DEPENDENCIES
# Python 3, various python packages (see import list at start of code) which you may install with easy_install or pip; NOTE that the colour import is actually from the colour-science package; you must install colour-science.

# USAGE
# Run this script through a Python interpreter, with these positional parameters:
# - sys.argv[1] A list of RGB colors as hexadecimal numbers, in .hexplt format (a simple text list, one color per line).
# - sys.argv[2] OPTIONAL. May be anything, and if present, the script will overwrite the original hex palette list with the sorted colors. To use positional parameter 3 (the next one) but not overwrite the original hex palette list, pass this as the string 'NULL' (with or without quote marks).
# - sys.argv[3] OPTIONAL. Any hex color code string in the format '#fa24cf' (RGB color expressed in hex format, surrounded by single quote marks), which the script will use as the first color to compare other colors to. The list will be sorted by next nearest color starting with this arbitrary color. If the color happens to be in the original list file (first argument), it will remain in the final list. If the color is not in the original list, it will not appear in the final sorted list.
# Example run with only a hexplt file given:
#    python /path/to_this_script/RGBhexColorSortInCAM16-UCS.py PrismacolorMarkers.hexplt
# The result will be printed to stdout, so that you may for example redirect the output to a new .hexplt file, e.g.:
#    python /path/to_this_script/RGBhexColorSortInCAM16-UCS.py inputColors.hexplt > result.hexplt
# Example run with the optional second parameter, which will cause the script to overwrite the original .hexplt file with the sorted version of it:
#    python /path/to_this_script/RGBhexColorSortInCAM16-UCS.py inputColors.hexplt foo
# Example run with the optional third parameter, an arbitrary color to start comparisons with (here, magenta):
#    python /path/to_this_script/RGBhexColorSortInCAM16-UCS.py inputColors.hexplt foo #ff00ff
# NOTES
# - It seems the library this uses for CAM16-UCS is slower than the library used in the other mentioned script (for CIECAM02).
# - This expects perfect data. If there's a blank line anywhere in the
# input file, or any other unexpected data, it may stop with an unhelpful error.
# - This will also delete duplicate colors in the list.
# - The same input always produces the same output, though if you change the order of colors in the list, the results may change. This is because the script uses the first color in the list to begin its comparisons (but you may override that with parameter 3). You therefore may wish to decide which color you want first in the list for those comparison purposes, or pass an arbitrary color via parameter 3.
# - Good comparisons with this script may be a matter of here figuring the best illuminant and transform matrix parameters, and hacking that. You can try different chromatic_adaptation_transform values from here:
# https://colour.readthedocs.io/en/develop/generated/colour.RGB_to_XYZ.html


# CODE
# See the "REFERENCE and dev notes" section at the end of this script.
# A test array: #E33200 #FF8B94 #54F1F1 #499989 #AAEFCB #8E4C5C #F7B754 #8AC2B0 #DE9D38 #FA9394 #ADDCCA #2DD1AA #E5E4E9 #02547D #78BF82 #745D5F #414141 #958F95 #FDE182 #7699C7 #FF5933 #D9BB93 #F1E5E9 #EA5287 #E3DB9A #95B6BA #59746E #333388 #008D94 #2EC1B1 #FF534E #367793 #00A693

import sys
import colour        # The colour-science package must be installed and imported under this name, NOT the colour package. It's confusing, because colour-science is imported under the name colour. But I think there is another package named just colour which imports under the same name.
from itertools import combinations
from more_itertools import unique_everseen

# GLOBALS and positional parameters check, with clear boolean/value inits to describe:
overwriteOriginalList = False
arbitraryFirstCompareColor = False
countOfArbitraryFirstColorInOriginalList = 0
if len(sys.argv) > 1:
    hexpltFileNamePassedToScript = sys.argv[1]
else:
    print('\nNo parameter 1 (source .hexplt file) passed to script. Exit.')
    sys.exit(1)
if len(sys.argv) > 2:
    if sys.argv[2] != 'NULL':   # Only set the following to true if user did not pass the string NULL (allows using positional parameter 2 without "using" it, and also using positional parameter 3:
        overwriteOriginalList = True
if len(sys.argv) > 3:
    arbitraryFirstCompareColor = sys.argv[3]
    # add a # to start of that parameter if it is six characters but missing that:
    if (len(arbitraryFirstCompareColor) == 6) and (arbitraryFirstCompareColor[0] != '#'):
        arbitraryFirstCompareColor = '#' + arbitraryFirstCompareColor
# END GLOBALS and positional parameters check

# split input file into list on newlines:
f = open(hexpltFileNamePassedToScript, "r")
colors_list = list(f.read().splitlines())
f.close()

if arbitraryFirstCompareColor != False:     # if a parameter was passed to script (arbitrary color in format '#ffffff' to start comparisons with), dynamically alter the list to insert that color at the start. BUT FIRST, track (with the following variable, countOfArbitraryFirstColorInOriginalList) the count of that color in the list before we add it to the list, because if that count is zero before adding, we will want to remove it from the list after comparisons and sorting (we don't want to permanently add it to the list; we only want to add it temporarily). (Because we don't want to add colors permanently to the list that were never there; we want to leave the list as it was found.) But if it _was_ originally in the list, we want to keep it there after adding, because the list will be deduplicated. Because the list will be deduplicated, the color we add to the list (even if it was in the list already before we added it) it would end up appearing only once in the list, and removing it after that would remove it entirely. That is a lot of explanation for the following two lines of code :)
    countOfArbitraryFirstColorInOriginalList = colors_list.count(arbitraryFirstCompareColor)
    colors_list.insert(0, arbitraryFirstCompareColor)
# strip beginning '#' character off every string in that list:
colors_list = [element[1:] for element in colors_list]
# deduplicate the list, but maintain same order:
colors_list = list(unique_everseen(colors_list))

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
# may not be valid) ;
# Conditional print: only print this information if we're overwriting original palette file (because if we aren't overwriting it, the user may be piping output to a new palette file that they wouldn't want cluttered with other information that breaks the file format:
if overwriteOriginalList == True:
    print('Input file is ', hexpltFileNamePassedToScript)
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
# Again, conditional print:
if overwriteOriginalList == True:
    print('Sorting deltaEs . . .')
pair_deltaEs.sort()
sorted_colors = list()

# Again, conditional print:
if overwriteOriginalList == True:
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
    # other color:
    if search_color == deltaEs_subsection[0][1]:
        matched_color = deltaEs_subsection[0][2]
        sorted_colors.append(matched_color)
    else:
        matched_color = deltaEs_subsection[0][1]
        sorted_colors.append(matched_color)
#   print('added ', matched_color, 'for', search_color)
    search_color = matched_color
    # remove the subsection from pair_deltaEs, to avoid future matches against current search_color
    # after search_color changes in the next loop:
    for element_two in deltaEs_subsection:
        pair_deltaEs.remove(element_two)


# FINALE
# add '#' back to the start of every element in the sorted color list before print:
for IDX, color in enumerate(sorted_colors):
    fixedTehColorFormat = '#' + color
    sorted_colors[IDX] = fixedTehColorFormat

# If we inserted an arbitrary color at start of list (to make first comprarison from), but it wasn't in the original list, remove it from the new sorted colors list; otherwise leave it there; also with double-checking it is there else not do this:
if countOfArbitraryFirstColorInOriginalList == 0 and arbitraryFirstCompareColor != False and (arbitraryFirstCompareColor in sorted_colors):
    sorted_colors.remove(arbitraryFirstCompareColor)

# Again, conditional print if we're overwriting original list, and if we are overwriting original list, this is where in code we do that:
if overwriteOriginalList == True:
    print('Writing sorted color list back over original file . . .')
    with open(hexpltFileNamePassedToScript, 'w') as f:
        for element in sorted_colors:
            f.write(element + "\n")
    f.close()
else:
    for element in sorted_colors:
        print(element)
