# DESCRIPTION
# Interpolates in -n steps between a start -s color and end -e
# color in color space -c (default HCT as 'hct'). Prints the original and
# the in-between (augmented) color results to stdout as sRGB hex color codes
# like #ff0596.

# DEPENDENCIES
# Python (probably Python 3), with the coloraide library installed:
# https://facelessuser.github.io/coloraide/

# USAGE
# See help information with this command:
#    interpolateSRGBColorsArray_coloraide.py --help


# CODE
# START IMPORTS AND GLOBALS
ThisScriptVersionString = '2.0.0'
import argparse, sys, re
from more_itertools import unique_everseen
# With coloraide, we can import things so that it's specifically set up to convert in a given space:
#    from coloraide import Color as Base
#    from coloraide.spaces.hct import HCT
#    class Color(Base): ...
#    Color.register(HCT())
# OR, strongly preferred for flexibility, and here required because we'll accept any supported parameter for this: set it up to convert in ANY supported space:
from coloraide_extras.everything import ColorAll as Color

# START OPTIONS (which affect globals)
# allows me to have a version string parser option that prints
# and exits; re: https://stackoverflow.com/a/41575802/1397555
class versionStringPrintAction(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        print('interpolateTwoSRGBColors_coloraide.py', ThisScriptVersionString)
        parser.exit()

PARSER = argparse.ArgumentParser(description=
'Interpolates in -n steps between a start -s color and end -e \
color in color space -c (default HCT as \'hct\'). Prints the original and \
the in-between (augmented) color results to stdout as sRGB hex color codes \
like #ff0596.'
)
PARSER.register('action', 'versionStringPrint', versionStringPrintAction)
PARSER.add_argument('-v', '--VERSION', nargs=0, action='versionStringPrint', help='Print version number and exit.')
# suppress annoying redundant metavar print on help with metavar='' -- but MAYBE ONLY FOR REQUIRED ARGUMENTS? re: https://stackoverflow.com/a/62350140
PARSER.add_argument('-a', '--ARRAY', metavar='\b', required=True, type=str, help=
'Array of colors to interpolate between. Must be a list of sRGB hex colors, \
for example \'[#151B2E, 0E183E, 0A287A, #004FC6, 006FC3, 4DA6E7, #66BEFF]\' \
(your terminal may need to surround the parameter with quote marks). Array \
must have at least 2 colors. The script will create sub-gradients between \
each consecutive pair.'
)
PARSER.add_argument('-n', '--NUMBER', metavar='\b', required=True, type=int, help=
'[Natural number > 2] the (n)umber of colors to create in the final composite \
gradient. Note that this includes the first and last color. The total number \
of colors will be divided among the sub-gradients between each pair of colors \
in the array. The minimum value is (number of colors in array × 2).'
)
PARSER.add_argument('-c', '--COLORSPACE', metavar='\b', default='hct', type=str, help=
'The (c)olorspace through which to interpolate colors. Default \'hct\' if \
omitted. Any colorpsace supported by the coloraide library\'s steps \
(interpolation) function may be given. Notable options include \'oklab\' and \
\'oklch\'. See https://facelessuser.github.io/coloraide/colors/'
)
PARSER.add_argument('-l', '--LASTCOLORSREMOVE', metavar='\b', type=int, help=
'[Natural number > 0] remove the N (l)ast colors from generated interpolation \
before print.\n'
)
PARSER.add_argument('-d', '--DEDUPLICATE', action='store_true', help='Remove \
any duplicate colors within each sub-gradient before combining. See NOTE of \
-n --NUMBER. Also NOTE: # this may result in fewer colors than you asked for \
with -n --NUMBER.')

# ARGUMENT PARSING
ARGS = PARSER.parse_args()

# INIT VALUES FROM ARGS
INTERPOLATION_COLORSPACE = ARGS.COLORSPACE
INTERPOLATION_STEPS = int(ARGS.NUMBER)
# declare and init this global with default 0; override with argumetn if it is passed:
N_END_COLORS_REMOVE = 0
if ARGS.LASTCOLORSREMOVE:
    N_END_COLORS_REMOVE = int(ARGS.LASTCOLORSREMOVE)
    if N_END_COLORS_REMOVE <= 0:
        print('ERROR: parameter -l LASTCOLORSREMOVE <= 0. Must be a positive integer. Exit 1.')
        sys.exit(1)

# Parse and normalize the array of colors
def parse_color_array(array_str):
    """Parse a string representation of a color array into a list of normalized hex colors.
    Handles irregular spacing, missing # prefixes, and extracts 6-digit hex codes."""
    # Remove brackets and split by commas
    cleaned = array_str.strip()
    # Remove outer brackets if present
    if cleaned.startswith('[') and cleaned.endswith(']'):
        cleaned = cleaned[1:-1]
    
    # Split by commas and clean each part
    raw_colors = [item.strip() for item in cleaned.split(',') if item.strip()]
    
    normalized_colors = []
    for raw in raw_colors:
        # Remove any # prefix and whitespace
        clean = raw.strip().lstrip('#')
        # Validate it's exactly 6 hex digits
        if not re.match(r'^[0-9a-fA-F]{6}$', clean):
            print(f'ERROR: Invalid color format: "{raw}". Must be 6 hex digits (with or without # prefix). Exit 1.')
            sys.exit(1)
        normalized_colors.append(clean)
    
    return normalized_colors

# Parse the color array
try:
    color_hex_list = parse_color_array(ARGS.ARRAY)
except Exception as e:
    print(f'ERROR: Failed to parse color array: {e}. Exit 1.')
    sys.exit(1)

# Validate array has at least 2 colors
if len(color_hex_list) < 2:
    print('ERROR: Array must contain at least 2 colors. Exit 1.')
    sys.exit(1)

# Validate -n is at least (number_of_colors * 2)
min_steps = len(color_hex_list) * 2
if INTERPOLATION_STEPS < min_steps:
    print(f'ERROR: -n NUMBER ({INTERPOLATION_STEPS}) must be at least {min_steps} (2 × number of colors in array). Exit 1.')
    sys.exit(1)

# Calculate colors per sub-gradient
num_segments = len(color_hex_list) - 1
colors_per_segment = INTERPOLATION_STEPS // num_segments
remainder = INTERPOLATION_STEPS % num_segments

# Create Color objects for each hex color
color_objects = []
for hex_color in color_hex_list:
    # Add # prefix for Color object creation
    color_objects.append(Color("#" + hex_color))

# REFERENCE:
# sRGB color convert from/to hex: https://facelessuser.github.io/coloraide/colors/srgb/
# interpolate through any supported space: https://facelessuser.github.io/coloraide/interpolation/
# setup for any convert space, or convert through any space: https://github.com/facelessuser/coloraide-extras

# Generate sub-gradients between each consecutive pair
all_hex_colors = []
for i in range(num_segments):
    start_color = color_objects[i]
    end_color = color_objects[i + 1]
    
    # Calculate steps for this segment
    steps_for_segment = colors_per_segment
    # Add remainder to the final segment
    if i == num_segments - 1:
        steps_for_segment += remainder
    
    # Generate gradient for this segment
    # Re: https://facelessuser.github.io/coloraide/interpolation/
    colors = Color.steps(
        [start_color, end_color],
        steps=steps_for_segment,
        space=INTERPOLATION_COLORSPACE,
        out_space="srgb"
    )
    
    # Convert to hex strings
    hex_colors = []
    for color in colors:
        hex_colors.append(color.to_string(hex=True))
    
    # If asked to remove duplicate colors within this segment (but maintain order), do so:
    if ARGS.DEDUPLICATE:
        hex_colors = list(unique_everseen(hex_colors))
    
    # Strip the last color from all segments except the final one
    # This prevents duplicate colors at the join points
    if i < num_segments - 1:
        hex_colors = hex_colors[:-1]
    
    # Add this segment's colors to the overall list
    all_hex_colors.extend(hex_colors)

# If asked via an argument to remove N colors from the end, do so:
if N_END_COLORS_REMOVE > 0:
    del all_hex_colors[-N_END_COLORS_REMOVE:]

# Print result, one per line:
for hexColor in all_hex_colors:
    print(hexColor)