# DESCRIPTION
# Compares two palettes (.hexplt format) and prints a dissimilarity ranking float between 0 and 1, where 0 means perceptually nearest or identical, and 1 means most different. 1 means 100 percent (and at best it will be expressed as something like 1.00041..). You can test this by comparing a palette of only white with only black, which is how I got that example value. SEE ALSO paletteCompareCIECAM02.py, though the default HCT space this script uses may be preferred.

# USAGE
# Run this script through a Python interpreter, with these parameters:
# - -s | --firstpalette REQUIRED. Path / filename of palette one, to (s)tart comparison.
# - -e | --secondpalette REQUIRED. Path / filename of palette two, to (e)nd comparison.
# - -c | --colorspace OPTIONAL. The (c)olorspace in which to compare palettes (or the colors within them). Default 'hct' if omitted. Any colorpsace supported by the coloraide library may be given. Notable options include 'oklch' and 'oklab'. See https://facelessuser.github.io/coloraide/colors
# Example that will result in a print of a dissimilarity ranking (a float of 0 or higher) for two palettes:
#    python /path/to_this_script/paletteCompareColoraide.py --firstpalette 4_ySswfpA7.hexplt --secondpalette 6_XSj3UPW8.hexplt
# NOTES
# - Again as in the DESCRIPTION, the printed number is a dissimilarity ranking, so a lower float means the palettes are more similar. Zero means they are identical and one or higher means they are very dissimilar.
# - You may want to use sortAllHexPalettesColoraide.sh to sort all colors in all palettes in the directory you work in (with any .hexplt format color palettes) _in the same way_ (for example starting sort on the same arbitrary color, for example black) before running this script. The similarity ranking produced by this script will probably be meaningless without that.
# - The similarity ranking between two palettes is obtained by comparison of color 1 in palette one to color 1 in palette 2, then color 2 in palette 1 to color 2 in palette 2, and so on. The sum of these rankings is then divided by the number of colors in each palette, and that's divided by 100 to be expressed as a float percent.
# - This script was adapted from paletteCompareCIECAM02.py.
# KNOWN WEIRDNESS
# Probably not an issue, as the differences still have a scale, it's just the scale may not be known: different color spaces can produce radically different maximum ranges. In the case of HCT for example it seems to work out that the max range of color comparisons is numeric 100 (with trailing decimals) for 100 percent. But for example okHSL seems to give a float between 0 and 1 to express percent. Both cases are probably valid for showing amount of difference, again, just at difference scales.


# CODE
# START IMPORTS
import sys, argparse, re
from itertools import combinations
# With coloraide, we can import things so that it's specifically set up to convert in a given space:
#    from coloraide import Color as Base
#    from coloraide.spaces.hct import HCT
#    class Color(Base): ...
#    Color.register(HCT())
# OR, strongly preferred for flexibility, and here required because we'll accept any supported parameter for this: set it up to convert in ANY supported space:
from coloraide_extras.everything import ColorAll as Color
# END IMPORTS

# START OPTIONS (which affect globals)
PARSER = argparse.ArgumentParser(description=
'Compares two palettes (.hexplt format) and prints a dissimilarity ranking \
float between 0 and 1, where 0 means perceptually nearest or identical, and \
1 means most different. 1 means 100 percent (and at best it will be expressed \
as something like 1.00041..). You can test this by comparing a palette of only \
white with only black, which is how I got that example value.')
# suppress annoying redundant metavar print on help with metavar='' -- but MAYBE ONLY FOR REQUIRED ARGUMENTS? re: https://stackoverflow.com/a/62350140
PARSER.add_argument('-s', '--firstpalette', metavar='\b', required=True, type=str, help=
'Path / filename of palette one, to (s)tart comparison.'
)
PARSER.add_argument('-e', '--secondpalette', metavar='\b', required=True, type=str, help=
'Path / filename of palette two, to (e)nd comparison.'
)
PARSER.add_argument('-c', '--colorspace', metavar='\b', default='hct', type=str, help=
'The (c)olorspace in which to compare palettes (or the colors within them). \
Default \'hct\' if omitted. Any colorpsace supported by the coloraide library \
may be given. Notable options include \'oklch\' and \
\'oklab\'. See https://facelessuser.github.io/coloraide/colors/'
)
# ARGUMENT PARSING
ARGS = PARSER.parse_args()

# INIT VALUES FROM ARGS
hexpltFileNameOnePassedToScript = ARGS.firstpalette
hexpltFileNameTwoPassedToScript = ARGS.secondpalette
comparisonColorSpace = ARGS.colorspace
# END OPTIONS

def extract_hex_colors_from_file(file_path):
    # Define the regular expression pattern to capture hex color codes
    # this regex could be: pattern = r'#?([a-fA-F0-9]{6})' -- but it doesn't need an optional # to work:
    pattern = r'([a-fA-F0-9]{6})'

    # Open and read the file content
    with open(file_path, 'r') as file:
        file_content = file.read()
    file.close()
    
    # Find all matches in the file content
    matches = re.findall(pattern, file_content)
    
    # Transform all color codes to lowercase and add the '#' prefix
    lowercase_hex_colors_with_prefix = [f'#{color.lower()}' for color in matches]
    
    # Return the array of lowercase hex color codes
    return lowercase_hex_colors_with_prefix

colors_list_one = extract_hex_colors_from_file(hexpltFileNameOnePassedToScript)
colors_list_two = extract_hex_colors_from_file(hexpltFileNameTwoPassedToScript)

# dev debug print only -- comment out in production:
# print("--colors_list_one contents:")
# for color in colors_list_one:
    # print('color is', color)
# print("--colors_list_two contents:")
# for color in colors_list_two:
    # print('color is', color)

if (len(colors_list_one) != len(colors_list_two)):
    print('\nProblem: palette one and two are of different lengths (they have different numbers of colors). They must have the same number of colors for this to work. (This can also happen if there are duplicate elements in a list but it has the same number of elements as the other list to begin with, because this script eliminates duplicate colors before comparison.) Exiting script.')
    sys.exit(3)

DeltaEs = []
for IDX, element in enumerate(colors_list_one):
    comparison_color_one = colors_list_one[IDX]
    comparison_color_two = colors_list_two[IDX]
    distance = Color(comparison_color_one).distance(comparison_color_two, space=comparisonColorSpace)
    # dev debug print only -- comment out in production:
    # print('dist of ', comparison_color_one, ' and ', comparison_color_two, 'in ', comparisonColorSpace, 'color space:', str(distance))
    DeltaEs.append(distance)

# To understand the following math, know this: a _lower_ delta value (toward zero) indicates that the colors are perceptually nearer together. A _higher_ delta value (toward 100) indicates that the colors are perceputally further apart.
sumOfDeltaEs = 0
for deltaE in DeltaEs:
    sumOfDeltaEs += deltaE
# print('\n sumOfDeltaEs: ', sumOfDeltaEs)

paletteDeltaE = (sumOfDeltaEs / len(colors_list_one)) / 100
# print('\n paletteDeltaE: ', paletteDeltaE)

print(paletteDeltaE)