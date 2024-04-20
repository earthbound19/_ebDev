# DESCRIPTION
# Interpolates in -n steps between a start -s color and end -e
# color in color space -c (default HCT as \'hct\'). Prints the original and
# the in-between (augmented) color results to stdout as sRGB hex color codes
# like #ff0596.

# DEPENDENCIES
# Python (probably Python 3), with the coloraide library installed:
# https://facelessuser.github.io/coloraide/

# USAGE
# See help information with this command:
#    interpolateTwoSRGBColors_coloraide.py --help


# CODE
# START IMPORTS AND GLOBALS
ThisScriptVersionString = '1.0.0'
import argparse, sys
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
PARSER.add_argument('-s', '--START', metavar='\b', required=True, type=str, help=
'Color to (s)tart interpolation (gradient) from. Must be six sRGB hex digits, \
for example \'ff0596\' (your terminal may need to surround the parameter with \
quote marks).'
)
PARSER.add_argument('-e', '--END', metavar='\b', required=True, type=str, help=
'Color to (e)nd interpolation (gradient) with. Must be six sRGB hex digits, \
for example \'01edfd\' (your terminal may need to surround the parameter with \
quote marks).'
)
PARSER.add_argument('-n', '--NUMBER', metavar='\b', required=True, type=int, help=
'[Natural number > 2] the (n)umber of colors to create by interpolation. Note \
that this includes the first and last color. Asking for 5 colors will give \
you the start color, three colors between it and the end color, and the end \
color: start + 3 + end = 5. NOTE: if you ask for more colors than it\'s \
possible to get -n discrete colors for, you\'ll end up with duplicate colors. \
See -d DEDUPLICATE to fix that.'
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
any duplicate colors before print. See NOTE of -n --NUMBER. Also NOTE: \
# this may result in fewer colors than you asked for with -n --NUMBER.')

# ARGUMENT PARSING
ARGS = PARSER.parse_args()

# INIT VALUES FROM ARGS
INTERPOLATION_COLORSPACE = ARGS.COLORSPACE
# create sRGB color objects from hex codes
# This is dumb but could be necessary. If the user passes parameters with leading # symbols, remove them with lstrip . . . and add them back (so there's only 1, not 2 or more # characters):
START_COLOR = "#" + ARGS.START.strip().lstrip("#")
START_COLOR = Color(START_COLOR)
END_COLOR = "#" + ARGS.END.strip().lstrip("#")
END_COLOR = Color(END_COLOR)
INTERPOLATION_STEPS = int(ARGS.NUMBER)
# declare and init this global with default 0; override with argumetn if it is passed:
N_END_COLORS_REMOVE = 0
if ARGS.LASTCOLORSREMOVE:
    N_END_COLORS_REMOVE = int(ARGS.LASTCOLORSREMOVE)
    if N_END_COLORS_REMOVE <= 0:
        print('ERROR: parameter -l LASTCOLORSREMOVE <= 0. Must be a positive integer. Exit 1.')
        sys.exit(1)

# REFERENCE:
# sRGB color convert from/to hex: https://facelessuser.github.io/coloraide/colors/srgb/
# interpolate through any supported space: https://facelessuser.github.io/coloraide/interpolation/
# setup for any convert space, or convert through any space: https://github.com/facelessuser/coloraide-extras

#UNUSED REFERENCE: use of hct for direct value create:
# thing = Color('hct', [27.41, 113.36, 53.237], 1)
# print(thing)
#PRIOR, DEPRECATED, nearly equivalently functional method (produced *very slighlty different colors* sometimes;
#here only for reference, skip on ahead to the AKTUL METHOD comment:
#interpolate them through HCT space, OR okHSV, or ANY supported space; just change the value assigned to space='<color space name>':
#i = Color.interpolate([startColor, endColor], space=\"$colorspaceKey\")
# NOTE that we do ($nColors - 1) here because the interpolation starts with the start color but does not end with the end color; if we want the end color..
#lerp = [i(x / nColors).to_string() for x in range($nColors - 1)]
#for element in lerp:
#    sRGBcolor = Color(element).convert('srgb').to_string(hex=True)
#    print(sRGBcolor)
# .. manually print the end color we want:
#print(\"$endColor\")

# Re: https://facelessuser.github.io/coloraide/interpolation/
colors = Color.steps(
	[START_COLOR, END_COLOR],
	steps=INTERPOLATION_STEPS,
	space=INTERPOLATION_COLORSPACE,
	out_space="srgb"
)

hexColors = []
for color in colors:
	hexColors.append(color.to_string(hex=True))

# If asked to an argument to remove duplicate colors (but maintain order), do so:
if ARGS.DEDUPLICATE:
    hexColors = list(unique_everseen(hexColors))

# If asked via an argument to remove N colors from the end, do so:
if N_END_COLORS_REMOVE > 0:
    del hexColors[- N_END_COLORS_REMOVE:]

# Print result, one per line:
for hexColor in hexColors:
	print(hexColor)
