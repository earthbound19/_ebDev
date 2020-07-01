"""Renders a PNG image like bacteria that mutate color as they spread.

An earlier incarnation of this script by earthbound19 was dramatically sped up by changes
from one GitHub user "scribblemaniac" (like many orders of magnitude faster--an image
that used to take 7 minutes to render now takes 5 seconds).

Output file names are based on the date and time and random characters.
Inspired and drastically evolved from color_fibers.py, which was horked and adapted
from https://scipython.com/blog/computer-generated-contemporary-art/

USAGE
Run this script without any parameters, and it will use a default set of parameters:
python color_growth.py
To see available parameters, run this script with the --help switch:
python color_growth.py --help

DEPENDENCIES
python 3 with numpy, queue, and pyimage modules installed (and others--see the import
statements).

KNOWN ISSUES
See help for --RANDOM_SEED.
"""

# TO DO:
# - figure out whether I broke RND continuity? It would seem
# the same presets are no longer producing the same results?
# - isolate what situation didn't create a new preset / anim folder
# when I expected it to, and fix that (or document in help).
# - make naming convention of variables consistent? I think I'm
# all over the place with this . . . :p
# - possibly things in the color_growth_v1.py's TO DO list.
# - determine whether any code in the fast fork (now this script)
# is leftover from color_growth_v1.py, and delete them?
# - make it properly use negative or > 8 growth-clip values again?
# since the color_growth_fast.py fork it isn't.

# VERSION HISTORY
# v2.8.3:
# - Trivial comment/docstring tweaks for better readability.


# CODE
# START IMPORTS AND GLOBALS
ColorGrowthPyVersionString = 'v2.8.3'

import datetime
import random
import argparse
import ast
import os.path
import sys
import re
import queue
from more_itertools import unique_everseen
import platform
# I'm also using another psuedorandom number generator built into numpy as np:
import numpy as np
from PIL import Image

# Defaults which will be overriden if arguments of the same name are provided to the script:
WIDTH = 400
HEIGHT = 200
RSHIFT = 8
STOP_AT_PERCENT = 1
SAVE_EVERY_N = 0
RAMP_UP_SAVE_EVERY_N = False
START_COORDS_RANGE = (1,13)
GROWTH_CLIP = (0,5)
SAVE_PRESET = True
animationFrameCounter = 0
renderedFrameCounter = 0
saveNextFrameNumber = 0
imageFrameFileName = ''
padFileNameNumbersDigitsWidth = 0
# SOME BACKGROUND COLOR options;
# any of these (uncomment only one) are made into a list later by ast.literal_eval(BG_COLOR) :
# BG_COLOR = "[157,140,157]"        # Medium purplish gray
# BG_COLOR = "[252,251,201]"        # Buttery light yellow
BG_COLOR = "[255,63,52]"        # Scarlet-scarlet-orange
RECLAIM_ORPHANS = True
BORDER_BLEND = True
TILEABLE = False
SCRIPT_ARGS_STR = ''
# END GLOBALS


# START OPTIONS (which affect globals)
# allows me to have a version string parser option that prints
# and exits; re: https://stackoverflow.com/a/41575802/1397555
class versionStringPrintAction(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        print('color_growth.py', ColorGrowthPyVersionString)
        parser.exit()

PARSER = argparse.ArgumentParser(description=
'Renders a PNG image like bacteria that produce random color mutations \
as they grow over a surface. Output file names are named after the date \
and time. Inspired by and drastically evolved from colorFibers.py, which \
was horked and adapted from \
https://scipython.com/blog/computer-generated-contemporary-art/ \
NOTE: CLI options have had breaking changes over time. If reusing settings \
from a previous version, check those settings first if you get errors. \
NOTE: by default the --RAMP_UP_SAVE_EVERY_N switch has a False value, but \
you probably want it True if you save animation frames (--SAVE_EVERY_N).'
)
PARSER.register('action', 'versionStringPrint', versionStringPrintAction)
PARSER.add_argument('-v', '--VERSION', nargs=0, action='versionStringPrint', help='Print version number and exit.')
PARSER.add_argument('--WIDTH', type=int, help=
'WIDTH of output image(s). Default ' + str(WIDTH) + '.')
PARSER.add_argument('--HEIGHT', type=int, help=
'HEIGHT of output image(s). Default ' + str(HEIGHT) + '.')
PARSER.add_argument('-r', '--RSHIFT', type=int, help=
'Vary R, G and B channel values randomly in the range negative this \
value or positive this value. Note that this means the range is RSHIFT \
times two. Defaut ' + str(RSHIFT) + '.'
)
PARSER.add_argument('-b', '--BG_COLOR', type=str, help=
'Canvas color. Expressed as a python list or single number that will be \
assigned to every value in an RGB triplet. If a list, give the RGB \
values in the format \'[255,70,70]\' (if you add spaces after the \
commas, you must surround the parameter in single or double quotes). \
This example would produce a deep red, as Red = 255, Green = 70, Blue = \
70). A single number example like just 150 will result in a medium-light \
gray of [150,150,150] (Red = 150, Green = 150, Blue = 150). All values \
must be between 0 and 255. Default ' + str(BG_COLOR) + '.'
)
PARSER.add_argument('-c', '--COLOR_MUTATION_BASE', type=str, help=
'Base initialization color for pixels, which randomly mutates as \
painting proceeds. If omitted, defaults to whatever BG_COLOR is. If \
included, may differ from BG_COLOR. This option must be given in the \
same format as BG_COLOR. You may make the base initialization color of \
each origin random by specifying "--COLOR_MUTATION_BASE random".'
)
PARSER.add_argument('--BORDER_BLEND', type=str, help=
'If this is enabled, the hard edges between different colonies will be \
blended together. Enabled by default. To disable pass \
--BORDER_BLEND False or --BORDER_BLEND 0.'
)
PARSER.add_argument('--TILEABLE', type=str, help=
'Make the generated image seamlessly tile. Colonies will wrap around \
the edge when they encounter it. Disabled by default. Enable with \
--TILEABLE True or --TILEABLE 1.'
)
PARSER.add_argument('--STOP_AT_PERCENT', type=float, help=
'What percent canvas fill to stop painting at. To paint until the canvas \
is filled (which can take extremely long for higher resolutions), pass 1 \
(for 100 percent). If not 1, value should be a percent expressed as a \
decimal (float) between 0 and 1 (e.g 0.4 for 40 percent. Default ' + \
str(STOP_AT_PERCENT) + '. For high --failedMutationsThreshold or random \
walk (neither of which is implemented at this writing), 0.475 (around 48 \
percent) is recommended. Stop percent is adhered to approximately (it \
could be much less efficient to make it exact).'
)
PARSER.add_argument('-a', '--SAVE_EVERY_N', type=int, help=
'Every N successful coordinate and color mutations, save an animation \
frame into a subfolder named after the intended final art file. To save \
every frame, set this to 1, or to save every 3rd frame set it to 3, etc. \
Saves zero-padded numbered frames to a subfolder which may be strung \
together into an animation of the entire painting process (for example \
via ffmpegAnim.sh). May substantially slow down render, and can also \
create many, many gigabytes of data, depending. ' + str(SAVE_EVERY_N) + \
' by default. To disable, set it to 0 with: -a 0 OR: --SAVE_EVERY_N 0. \
NOTE: If this is nonzero and you do not set --RAMP_UP_SAVE_EVERY_N to \
either True or False (see), the default --RAMP_UP_SAVE_EVERY_N False \
will override to True, as it is strongly suggested you want that if \
you render an animation. If that is not what you want, manually set \
--RAMP_UP_SAVE_EVERY_N False.'
)
PARSER.add_argument('--RAMP_UP_SAVE_EVERY_N', type=str, help=
'Increase the value of --SAVE_EVERY_N over time. Without this, the \
animation may seem to slow toward the middle and end, because the \
interval --SAVE_EVERY_N is constant; the same number of new mutated \
coordinates is spread over a wider area every save frame. \
--RAMP_UP_SAVE_EVERY_N causes the value of --SAVE_EVERY_N to increase \
over time, like dragging the corner of a selection rectangle to increase \
rendered area over the whole canvas. The result is an apparently \
more visually linear growth (in all growth vectors) and a faster \
animation (and faster animation render, as less time is made saving \
fewer frames), but technically the growth rate (vs. saved animation frames) \
actually increases over time. Default ' + str(RAMP_UP_SAVE_EVERY_N) + '. \
NOTES: 1) Relies on --SAVE_EVERY_N being nonzero. Script will warn and exit \
if --RAMP_UP_SAVE_EVERY_N is True and --SAVE_EVERY_N is 0 (zero). \
2) Save frame intervals near start of animation may be similar to \
--SAVE_EVERY_N value, but as noted increase (and can increase a lot) \
over time. 3) To re-render animations created prior to v2.6.6 the same \
as at their creation --RAMP_UP_SAVE_EVERY_N must be False (as this feature \
was introduced in v2.6.6). 4) See related NOTE for --SAVE_EVERY_N.'
)
PARSER.add_argument('-s', '--RANDOM_SEED', type=int, help=
'Seed for random number generators (random and numpy.random are used). \
Default generated by random library itself and added to render file name \
for reference. Can be any integer in the range 0 to 4294967296 (2^32). \
If not provided, it will be randomly chosen from that range (meta!). If \
--SAVE_PRESET is used, the chosen seed will be saved with the preset \
.cgp file. KNOWN ISSUE: functional differences between random generators \
of different versions of Python and/or Python, maybe on different platforms, \
produce different output from the same random seed. ALSO, some versions of \
this script had code that accidentally altered the pseudorandom number \
sequence via something outside the intended color growth algorithm. The \
result was different output from the same --RANDOM_SEED. If you get \
different output than before from the same --RANDOM_SEED, search for and \
examine the VESTIGAL CODE comment(s!), and try uncommenting the line of code \
they detail.'
)
PARSER.add_argument('-q', '--START_COORDS_N', type=int, help=
'How many origin coordinates to begin coordinate and color mutation \
from. Default randomly chosen from range in --START_COORDS_RANGE (see). \
Random selection from that range is performed *after* random seeding by \
--RANDOM_SEED, so that the same random seed will always produce the same \
number of start coordinates. I haven\'t tested whether this will work if \
the number exceeds the number of coordinates possible in the image. \
Maybe it would just overlap itself until they\'re all used?'
)
PARSER.add_argument('--START_COORDS_RANGE', help=
'Random integer range to select a random number of --START_COORDS_N if \
--START_COORDS_N is not provided. Default (' + \
str(START_COORDS_RANGE[0]) + ',' + str(START_COORDS_RANGE[1]) + '). Must \
be provided in that form (a string surrounded by double quote marks (for \
Windows) which can be evaluated to a python tuple), and in the range 0 \
to 4294967296 (2^32), but I bet that sometimes nothing will render if \
you choose a max range number orders of magnitude higher than the number \
of pixels available in the image. I probably would never make the max \
range higher than (number of pixesl in image) / 62500 (which is 250 \
squared). Will not be used if [-q | START_COORDS_N] is provided.'
)
PARSER.add_argument('--CUSTOM_COORDS_AND_COLORS', type=str, help=
'Custom coordinate locations and colors list to initialized coordinate \
mutation queue with. In complex nested lists of tuples _and lists_ \
formt (I know, it\'s crazy), surrounded by single or double quote marks, \
OR passed without any space characters in the parameter, like: \
\'[[(coordinate),[color]], [(coordinate),[color]], [(coordinate),[color]]]\', \
or more accurately like: \
[[(50,40),[255,0,255]],[(88,84),[0,255,255]]]. NOTES: \
1) Because this overrides --START_COORDS_N, --START_COORDS_RANGE, and \
--COLOR_MUTATION_BASE, if you want random numbers of coordinates and \
coordinate positions with this, contrive them via another custom script \
or program, and pass them to this. 2) Internally in code the coordinates \
are zero-index-based, which means 0 is 1, 1 is 2, 4 is 5, etc.; BUT \
that\'s not human-friendly, so use the actual values (1 is 1!) \
and the program will just subtract 1 for the zero-based indexing. 3) \
Although internally in code, coordinates are represented as (y,x) tuples \
(or (down,accross), that confuses me and isn\'t standard or expected for \
humans, so in this parameter coordinate are represented as (x,y) (or \
(accross,down), and the code swaps them before assignment to real, \
internal tuples. You\'re welcome.'
)
PARSER.add_argument('--GROWTH_CLIP', type=str, help=
'Affects seeming "thickness" (or viscosity) of growth. A Python tuple \
expressed as a string (must be surrounded by double quote marks for \
Windows). Default ' + str(GROWTH_CLIP) + '. In growth into adjacent \
coordinates, the maximum number of possible neighbor coordinates to grow \
into is 8 (which may only ever happen with a start coordinate: in \
practical terms, the most coordinates that may usually be expanded into \
is 7). The first number in the tuple is the minimum number of \
coordinates to randomly select, and the second number is the maximum. \
The second must be greater than the first. The first may be lower than 0 \
and will be clipped to 1, making selection of only 1 neighbor coordinate \
more common. The second number may be higher than 8 (or the number of \
available coordinates as the case may be), and will be clipped to the \
maximum number of available coordinates, making selection of all \
available coordinates more common. If the first number is a positive \
integer <= 7, at least that many coordinates will always be selected \
when possible. If the second number is a positive integer >= 1, at most \
that many coordinates will ever be selected. A negative first number or \
low first number clip will tend toward a more evenly spreading liquid \
appearance, and a lower second number clip will cause a more \
stringy/meandering/splatty path or form (as it spreads less uniformly). \
With an effectively more viscous clip like "(2,4)", smaller \
streamy/flood things may traverse a distance faster. Some tuples make \
--RECLAIM_ORPHANS quickly fail, some make it virtually never fail.'
)
PARSER.add_argument('--RECLAIM_ORPHANS', type=str, help=
'Coordinates can end up never mutating color, and remain the same color \
as --BG_COLOR (which may result in the appearance of pixels that seem \
like flecks or discontiguous color). This may be more likely with a \
--GROWTH_CLIP range nearer zero (higher viscosity). This option coralls \
these orphan coordinates and revives them so that their color will \
mutate. Default ' + str(RECLAIM_ORPHANS) + '. To disable pass \
--RECLAIM_ORPHANS False or --RECLAIM_ORPHANS 0.'
)
PARSER.add_argument('--SAVE_PRESET', type=str, help=
'Save all parameters (which are passed to this script) to a .cgp (color \
growth preset) file. If provided, --SAVE_PRESET must be a string \
representing a boolean state (True or False or 1 or 0). Default '+ \
str(SAVE_PRESET) +'. The .cgp file can later be loaded with the \
--LOAD_PRESET switch to create either new or identical work from the \
same parameters (whether it is new or identical depends on the switches, \
--RANDOM_SEED being the most consequential). This with [-a | \
--SAVE_EVERY_N] can recreate gigabytes of exactly the same animation \
frames using just a preset. NOTES: 1) --START_COORDS_RANGE and its \
accompanying value are not saved to config files, and the resultantly \
generated [-q | --START_COORDS_N] is saved instead. 2) You may add \
arbitrary text (such as notes) to the second and subsequent lines of a \
saved preset, as only the first line is used.'
)
PARSER.add_argument('--LOAD_PRESET', type=str, help=
'A preset file (as first created by --SAVE_PRESET) to use. Empty (none \
used) by default. Not saved to any preset. At this writing only a single \
file name is handled, not a path, and it is assumed the file is in the \
current directory. A .cgp preset file is a plain text file on one line, \
which is a collection of SWITCHES to be passed to this script, written \
literally the way you would pass them to this script. NOTE: you may load \
a preset and override any switches in the preset by using the override \
after --LOAD_PRESET. For example, if a preset contains --RANDOM SEED \
98765 but you want to override it with 12345, pass --LOAD_PRESET \
<preset_filename.cgp> --RANDOM_SEED 12345 to this script.'
)


# START ARGUMENT PARSING
# DEVELOPER NOTE: Throughout the below argument checks, wherever a user does not specify
# an argument and I use a default (as defaults are defined near the start of working code
# in this script), add that default switch and switch value pair argsparse, for use by
# the --SAVE_PRESET feature (which saves everything except for the script path ([0]) to
# a preset). I take this approach because I can't check if a default value was supplied
# if I do that in the PARSER.add_argument function --
# http://python.6.x6.nabble.com/argparse-tell-if-arg-was-defaulted-td1528162.html -- so what
# I do is check for None (and then supply a default and add to argsparse if None is found).
# The check for None isn't literal: it's in the else: clause after an if (value) check
# (if the if check fails, that means the value is None, and else: is invoked) :
print('')
print('Processing any arguments to script . . .')

# allows me to override parser arguments declared in this namespace:
class ARGUMENTS_NAMESPACE:
    pass

argumentsNamespace = ARGUMENTS_NAMESPACE()

    # Weirdly, for the behavior I want, I must call parse_args a few times:
    # - first to get the --LOAD_PRESET CLI argument if there is any
    # - then potentially many times to iterate over arguments got from the
    # .cgp config file specified
    # - then again to override any of those with options passed via CLI
    # which I want to override those.
# DEPRECATED: call parse_args with default no parameters (except it is done before the above of necessity):
# ARGS = PARSER.parse_args()
# NOW, create a namespace that allows loaded .cgp file parameters to overwrite values in:
# re: https://docs.python.org/3/library/argparse.html#argparse.Namespace
# re: https://docs.python.org/3/library/argparse.html#argparse.ArgumentParser.parse_args
ARGS = PARSER.parse_args(args=sys.argv[1:], namespace=argumentsNamespace)
# Build dictionary from ARGS and use it to build global SCRIPT_ARGS_STR;
# clean it up later (we don't want elements in it with value "None":
argsDict = vars(ARGS)
# modify like this:
# argsDict['COLOR_MUTATION_BASE'] = '[0,0,0]'

# IF A PRESET file is given, load its contents and make its parameters override anything else that was just parsed through the argument parser:
if ARGS.LOAD_PRESET:
    LOAD_PRESET = ARGS.LOAD_PRESET
    with open(LOAD_PRESET) as f:
        SWITCHES = f.readline()
    # Remove spaces from parameters in tuples like (1, 13), because it
    # mucks up this parsing:
    SWITCHES = re.sub('(\([0-9]*),\s*([0-9]*\))', r'\1,\2', SWITCHES)
    # removes any start and end whitespace that can throw off
    # the following parsing:
    SWITCHES = SWITCHES.strip()
    SWITCHES = SWITCHES.split(' ')
    for i in range(0, len(SWITCHES), 2):
        ARGS = PARSER.parse_args(args=[SWITCHES[i], SWITCHES[i+1]], namespace=argumentsNamespace)

# Doing this again here so that anything in the command line overrides:
ARGS = PARSER.parse_args(args=sys.argv[1:], namespace=argumentsNamespace)      # When this 

# If a user supplied an argument (so that WIDTH has a value (is not None), use that:
if ARGS.WIDTH:
    # It is in argsparse already, so it will be used by --WIDTH:
    WIDTH = ARGS.WIDTH
else:
    # If not, leave the default as it was defined globally, and add to argsDict
    # so it can be saved in a .cfg preset:
    argsDict['WIDTH'] = WIDTH

if ARGS.HEIGHT:
    HEIGHT = ARGS.HEIGHT
else:
    argsDict['HEIGHT'] = HEIGHT

if ARGS.RSHIFT:
    RSHIFT = ARGS.RSHIFT
else:
    argsDict['RSHIFT'] = RSHIFT

if ARGS.BG_COLOR:
    # For preset saving, remove spaces and write back to argsparse,
    # OR ADD IT (if it was gotten through argparse), so a preset saved by
    # --SAVE_PRESET won't cause errors:
    BG_COLOR = ARGS.BG_COLOR
    BG_COLOR = re.sub(' ', '', BG_COLOR)
    argsDict['BG_COLOR'] = BG_COLOR
else:
    argsDict['BG_COLOR'] = BG_COLOR

# Convert BG_COLOR (as set from ARGS.BG_COLOR or default) string to python list for use
# by this script, re: https://stackoverflow.com/a/1894296/1397555
BG_COLOR = ast.literal_eval(BG_COLOR)

# See comments in ARGS.BG_COLOR handling; handled the same:
if not ARGS.CUSTOM_COORDS_AND_COLORS:
    if ARGS.COLOR_MUTATION_BASE:
        COLOR_MUTATION_BASE = ARGS.COLOR_MUTATION_BASE
        COLOR_MUTATION_BASE = re.sub(' ', '', COLOR_MUTATION_BASE)
        argsDict['COLOR_MUTATION_BASE'] = COLOR_MUTATION_BASE
        if ARGS.COLOR_MUTATION_BASE.lower() == 'random':
            COLOR_MUTATION_BASE = 'random'
        else:
            COLOR_MUTATION_BASE = ast.literal_eval(COLOR_MUTATION_BASE)
    else:       # Write same string as BG_COLOR, after the same silly string manipulation as
                # for COLOR_MUTATION_BASE, but more ridiculously now _back_ from that to
                # a string again:
        BG_COLOR_TMP_STR = str(BG_COLOR)
        BG_COLOR_TMP_STR = re.sub(' ', '', BG_COLOR_TMP_STR)
        argsDict['COLOR_MUTATION_BASE'] = BG_COLOR_TMP_STR
        # In this case we're using a list as already assigned to BG_COLOR:
        COLOR_MUTATION_BASE = list(BG_COLOR)
        # If I hadn't used list(), COLOR_MUTATION_BASE would be a reference to BG_COLOR (which
        # is default Python list handling behavior with the = operator), and when I changed either,
        # "both" would change (but they would really just be different names for the same list).
        # I want them to be different.

# purple = [255, 0, 255]    # Purple. In prior commits of this script, this has been defined
# and unused, just like in real life. Now, it is commented out or not even defined, just
# like it is in real life.

if ARGS.RECLAIM_ORPHANS:
    RECLAIM_ORPHANS = ast.literal_eval(ARGS.RECLAIM_ORPHANS)
else:
    argsDict['RECLAIM_ORPHANS'] = RECLAIM_ORPHANS

if ARGS.BORDER_BLEND:
    BORDER_BLEND = ast.literal_eval(ARGS.BORDER_BLEND)
else:
    argsDict['BORDER_BLEND'] = BORDER_BLEND

if ARGS.TILEABLE:
    TILEABLE = ast.literal_eval(ARGS.TILEABLE)
else:
    argsDict['TILEABLE'] = TILEABLE

if ARGS.STOP_AT_PERCENT:
    STOP_AT_PERCENT = ARGS.STOP_AT_PERCENT
else:
    argsDict['STOP_AT_PERCENT'] = STOP_AT_PERCENT

if ARGS.SAVE_EVERY_N:
    SAVE_EVERY_N = ARGS.SAVE_EVERY_N
else:
    argsDict['SAVE_EVERY_N'] = SAVE_EVERY_N

# Conditional override:
if ARGS.SAVE_EVERY_N and not ARGS.RAMP_UP_SAVE_EVERY_N:
    RAMP_UP_SAVE_EVERY_N = True
    argsDict['RAMP_UP_SAVE_EVERY_N'] = 'True'

if ARGS.RAMP_UP_SAVE_EVERY_N:
    RAMP_UP_SAVE_EVERY_N = ast.literal_eval(ARGS.RAMP_UP_SAVE_EVERY_N)
    if SAVE_EVERY_N == 0 and RAMP_UP_SAVE_EVERY_N == True:
        print('--RAMP_UP_SAVE_EVERY_N is True, but --SAVE_EVERY_N is 0. --SAVE_EVERY_N must be nonzero if --RAMP_UP_SAVE_EVERY_N is True. Either set --SAVE_EVERY_N to something other than 0, or set RAMP_UP_SAVE_EVERY_N to False. Exiting script.')
        sys.exit(2)
else:
    argsDict['RAMP_UP_SAVE_EVERY_N'] = RAMP_UP_SAVE_EVERY_N

if ARGS.RANDOM_SEED:
    RANDOM_SEED = ARGS.RANDOM_SEED
else:
    RANDOM_SEED = random.randint(0, 4294967296)
    argsDict['RANDOM_SEED'] = RANDOM_SEED

# Use that seed straightway:
random.seed(RANDOM_SEED)
np.random.seed(RANDOM_SEED)

    # BEGIN STATE MACHINE "Megergeberg 5,000."
    # DOCUMENTATION.
    # Possible combinations of these variables to handle; "coords" means START_COORDS_N,
    # RNDcoords means START_COORDS_RANGE:
    # --
    # ('coords', 'RNDcoords') : use coords, delete any RNDcoords
    # ('coords', 'noRNDcoords') : use coords, no need to delete any RNDcoords. These two:
    # if coords if RNDcoords.
    # ('noCoords', 'RNDcoords') : assign user-provided RNDcoords for use (overwrite defaults).
    # ('noCoords', 'noRNDcoords') : continue with RNDcoords defaults (don't overwrite defaults).
    # These two: else if RNDcoords else. Also these two: generate coords independent of
    # (outside) that last if else (by using whatever RNDcoords ends up being (user-provided
    # or default).
    # --
    # I COULD just have four different, independent "if" checks explicitly for those four
    # pairs and work from that, but this is more compact logic (fewer checks).
# If --START_COORDS_N is provided by the user, use it, unless there is overriding
# CUSTOM_COORDS_AND_COLORS:
if not ARGS.CUSTOM_COORDS_AND_COLORS:
    if ARGS.START_COORDS_N:
        START_COORDS_N = ARGS.START_COORDS_N
        print('Will use the provided --START_COORDS_N, ', START_COORDS_N)
        if ARGS.START_COORDS_RANGE:
            # .. and delete any --START_COORDS_RANGE and its value from argsparse (as it will
            # not be used and would best not be stored in the .cgp config file via --SAVE_PRESET:
            argsDict.pop('START_COORDS_RANGE', None)
            print(
    '** NOTE: ** You provided both [-q | --START_COORDS_N] and --START_COORDS_RANGE, \
    but the former overrides the latter (the latter will not be used). This program \
    disregards the latter from the parameters list.'
    )
    else:        # If --START_COORDS_N is _not_ provided by the user..
        if ARGS.START_COORDS_RANGE:
            # .. but if --START_COORDS_RANGE _is_ provided, assign from that:
            START_COORDS_RANGE = ast.literal_eval(ARGS.START_COORDS_RANGE)
            STR_PART = 'from user-supplied range ' + str(START_COORDS_RANGE)
        else:        # .. otherwise use the default START_COORDS_RANGE:
            STR_PART = 'from default range ' + str(START_COORDS_RANGE)
        START_COORDS_N = random.randint(START_COORDS_RANGE[0], START_COORDS_RANGE[1])
        argsDict['START_COORDS_N'] = START_COORDS_N
        print('Using', START_COORDS_N, 'start coordinates, by random selection ' + STR_PART)
        # END STATE MACHINE "Megergeberg 5,000."

if ARGS.CUSTOM_COORDS_AND_COLORS:
    CUSTOM_COORDS_AND_COLORS = ARGS.CUSTOM_COORDS_AND_COLORS
    CUSTOM_COORDS_AND_COLORS = re.sub(' ', '', CUSTOM_COORDS_AND_COLORS)
    argsDict['CUSTOM_COORDS_AND_COLORS'] = CUSTOM_COORDS_AND_COLORS
    CUSTOM_COORDS_AND_COLORS = ast.literal_eval(ARGS.CUSTOM_COORDS_AND_COLORS)

if ARGS.GROWTH_CLIP:        # See comments in ARGS.BG_COLOR handling. Handled the same.
    GROWTH_CLIP = ARGS.GROWTH_CLIP
    GROWTH_CLIP = re.sub(' ', '', GROWTH_CLIP)
    argsDict['GROWTH_CLIP'] = GROWTH_CLIP
    GROWTH_CLIP = ast.literal_eval(GROWTH_CLIP)
# NOTE: VESTIGAL CODE HERE that will alter pseudorandom determinism if commented vs.
# not commented out; if render from a preset doesn't produce the same result as it
# once did, try uncommenting the next line! :
    # zax_blor = ('%03x' % random.randrange(16**6))
else:
    temp_str = str(GROWTH_CLIP)
    temp_str = re.sub(' ', '', temp_str)
    argsDict['GROWTH_CLIP'] = GROWTH_CLIP

if ARGS.SAVE_PRESET:
    SAVE_PRESET = ast.literal_eval(ARGS.SAVE_PRESET)
else:
    argsDict['SAVE_PRESET'] = SAVE_PRESET
# END ARGUMENT PARSING

# Remove arguments from argsDict whose values are 'None' from that
# (they cause problems when doing things with the arguments list
# via CLI, as intended) :
for key in argsDict:
    # if the key value is 'None', don't bother saving it; otherwise save it:
    if argsDict[key] != None:
        keyValStr = '--' + key + ' ' + str(argsDict[key])
        SCRIPT_ARGS_STR += keyValStr + ' '
# removes whitespace from start and end that would mess
# up parse code earlier in the script (if I didn't do this
# there also) :
SCRIPT_ARGS_STR = SCRIPT_ARGS_STR.strip()

# ADDITIONAL GLOBALS defined here:
allPixelsN = WIDTH * HEIGHT
stopRenderAtPixelsN = int(allPixelsN * STOP_AT_PERCENT)
# If RAMP_UP_SAVE_EVERY_N is True, create list saveFramesAtCoordsPaintedArray
# with increasing values for when to save N evolved coordinates to animation frames:
saveFramesAtCoordsPaintedArray = []
if SAVE_EVERY_N != 0 and RAMP_UP_SAVE_EVERY_N == True:
    allPixelsNdividedBy_SAVE_EVERY_N = allPixelsN / SAVE_EVERY_N
    divisor = 1 / allPixelsNdividedBy_SAVE_EVERY_N
    saveFramesAtCoordsPaintedMultipliers = [x * divisor for x in range(0, int(allPixelsNdividedBy_SAVE_EVERY_N)+1)]
    for multiplier in saveFramesAtCoordsPaintedMultipliers:
        mod_w = WIDTH * multiplier
        mod_h = HEIGHT * multiplier
        mod_area = mod_w * mod_h
        saveFramesAtCoordsPaintedArray.append(int(mod_area))
    # Deduplicate elements in the list but maintain order:
    saveFramesAtCoordsPaintedArray = list(unique_everseen(saveFramesAtCoordsPaintedArray))
    # Because that resulting list doesn't include the ending number, add it:
    saveFramesAtCoordsPaintedArray.append(stopRenderAtPixelsN)
# If RAMP_UP_SAVE_EVERY_N is False, create list saveFramesAtCoordsPaintedArray with
# values at constant intervals for when to save animation frames:
if SAVE_EVERY_N != 0 and RAMP_UP_SAVE_EVERY_N == False:
    saveFramesAtCoordsPaintedArray = [x * SAVE_EVERY_N for x in range(0, int(stopRenderAtPixelsN/SAVE_EVERY_N)+1 )]
    # Because that range doesn't include the end of the range:
    saveFramesAtCoordsPaintedArray.append(stopRenderAtPixelsN)
    # Because that resulting list doesn't include the ending number, add it:
    saveFramesAtCoordsPaintedArray.append(stopRenderAtPixelsN)
# Values of these used elsewhere:
saveFramesAtCoordsPaintedArrayIDX = 0
saveFramesAtCoordsPaintedArrayMaxIDX = (len(saveFramesAtCoordsPaintedArray) - 1)

def is_coord_in_bounds(y, x):
    return y >= 0 and y < HEIGHT and x >= 0 and x < WIDTH

def is_color_valid(y, x, canvas):
    return canvas[y][x][0] >= 0 # Negative number used for invalid color

def get_rnd_unallocd_neighbors(y, x, canvas):
    """Returns both a set() of randomly selected empty neighbor coordinates to use
    immediately, and a set() of neighbors to use later."""
    # init an empty set we'll populate with neighbors (int tuples) and return:
    rnd_neighbors_to_ret = []
    unallocd_neighbors = set()
    for i in range(-1, 2):
        for j in range(-1, 2):
            if TILEABLE:
                if not (i == 0 and j == 0) and not is_color_valid((y+i) % HEIGHT, (x+j) % WIDTH, canvas):
                    unallocd_neighbors.add(((y+i) % HEIGHT, (x+j) % WIDTH))
            else:
                if not (i == 0 and j == 0) and is_coord_in_bounds(y+i, x+j) and not is_color_valid(y+i, x+j, canvas):
                    unallocd_neighbors.add((y+i, x+j))
    if unallocd_neighbors:        # If there is anything left in unallocd_neighbors:
        # START GROWTH_CLIP (VISCOSITY) CONTROL.
        # Decide how many to pick:
        n_neighbors_to_ret = np.clip(np.random.randint(GROWTH_CLIP[0], GROWTH_CLIP[1] + 1), 0, len(unallocd_neighbors))
        # END GROWTH_CLIP (VISCOSITY) CONTROL.
        rnd_neighbors_to_ret = random.sample(unallocd_neighbors, n_neighbors_to_ret)
        for neighbor in rnd_neighbors_to_ret:
            unallocd_neighbors.remove(neighbor)
    return rnd_neighbors_to_ret, unallocd_neighbors

def find_adjacent_color(y, x, canvas):
    allocd_neighbors = []
    for i in range(-1, 2):
        for j in range(-1, 2):
            if TILEABLE:
                if not (i == 0 and j == 0) and is_color_valid((y+i) % HEIGHT, (x+j) % WIDTH, canvas):
                        allocd_neighbors.append(((y+i) % HEIGHT, (x+j) % WIDTH))
            else:
                if not (i == 0 and j == 0) and is_coord_in_bounds(y+i, x+j) and is_color_valid(y+i, x+j, canvas):
                    allocd_neighbors.append((y+i, x+j))
    if not allocd_neighbors:
        return None
    else:
        y, x = random.choice(allocd_neighbors)
        return canvas[y][x]

def coords_set_to_image(canvas, render_target_file_name):
    """Creates and saves image from dict of Coordinate objects, HEIGHT and WIDTH definitions,
    and a filename string."""
    tmp_array = [[BG_COLOR if x[0] < 0 else x for x in row] for row in canvas]
    tmp_array = np.asarray(tmp_array)
    image_to_save = Image.fromarray(tmp_array.astype(np.uint8)).convert('RGB')
    image_to_save.save(render_target_file_name)

def print_progress(newly_painted_coords):
    """Prints coordinate plotting statistics (progress report)."""
    print('newly painted : total painted : target : canvas size : reclaimed orphans') 
    print(newly_painted_coords, ':', painted_coordinates, ':', \
    stopRenderAtPixelsN, ':', allPixelsN, ':', orphans_to_reclaim_n)

def set_img_frame_file_name():
    global padFileNameNumbersDigitsWidth
    global renderedFrameCounter
    global imageFrameFileName
    renderedFrameCounter += 1
    frameNumberStr = str(renderedFrameCounter)
    imageFrameFileName = anim_frames_folder_name + '/' + frameNumberStr.zfill(padFileNameNumbersDigitsWidth) + '.png'

def save_animation_frame():
    # Tells the function we are using global variables:
    global animationFrameCounter
    global saveNextFrameNumber
    global saveFramesAtCoordsPaintedArrayIDX
    global saveFramesAtCoordsPaintedArrayMaxIDX
#    print('animationFrameCounter', animationFrameCounter, 'saveNextFrameNumber', saveNextFrameNumber)
    if SAVE_EVERY_N != 0:
        if (animationFrameCounter == saveNextFrameNumber):
            # only increment the ~IDX if it will be in array bounds:
            if (saveFramesAtCoordsPaintedArrayIDX + 1) < saveFramesAtCoordsPaintedArrayMaxIDX:
                saveFramesAtCoordsPaintedArrayIDX += 1
                saveNextFrameNumber = saveFramesAtCoordsPaintedArray[saveFramesAtCoordsPaintedArrayIDX]
            set_img_frame_file_name()
            # Only write frame if it does not already exist
            # (allows resume of suspended / crashed renders) :
            if os.path.exists(imageFrameFileName) == False:
                # print("Animation render frame file does not exist; writing frame.")
                coords_set_to_image(canvas, imageFrameFileName)
        animationFrameCounter += 1
# END GLOBAL FUNCTIONS
# END OPTIONS AND GLOBALS


"""START MAIN FUNCTIONALITY."""
print('Initializing render script..')

# A dict of Coordinate objects which is used with tracking sets to fill a "canvas:"
canvas = []
# A set of coordinates (tuples, not Coordinate objects) which are free for the taking:
unallocd_coords = set()
# A set of coordinates (again tuples) which are set aside (allocated) for use:
allocd_coords = set()
# A set of coordinates (again tuples) which have been color mutated and may no longer
# coordinate mutate:
filled_coords = set()

coord_queue = []

# Initialize canvas dict and unallocd_coords set (canvas being a dict of Coordinates with
# tuple coordinates as keys:
for y in range(0, HEIGHT):        # for columns (x) in row)
    canvas.append([])
    for x in range(0, WIDTH):        # over the columns, prep and add:
        unallocd_coords.add((y, x))
        canvas[y].append([-1,-1,-1])

# If ARGS.CUSTOM_COORDS_AND_COLORS was not passed to script, initialize
# allocd_coords set by random selection from unallocd_coords (and remove
# from unallocd_coords); structure of coords is (y,x)
if not ARGS.CUSTOM_COORDS_AND_COLORS:
    print('no --CUSTOM_COORDS_AND_COLORS argument passed to script, so initializing coordinate locations randomly . . .')
    RNDcoord = random.sample(unallocd_coords, START_COORDS_N)
    for coord in RNDcoord:
        coord_queue.append(coord)
        if COLOR_MUTATION_BASE == "random":
            canvas[coord[0]][coord[1]] = np.random.randint(0, 255, 3)
        else:
            canvas[coord[0]][coord[1]] = COLOR_MUTATION_BASE
# If ARGS.CUSTOM_COORDS_AND_COLORS was passed to script, init coords and their colors from it: 
else:
    print('--CUSTOM_COORDS_AND_COLORS argument passed to script, so initializing coords and colors from that. NOTE that this overrides --START_COORDS_N, --START_COORDS_RANGE, and --COLOR_MUTATION_BASE if those were provided.')
    print('\n')
    for element in CUSTOM_COORDS_AND_COLORS:
        # SWAPPING those (on CLI they are x,y; here it wants y,x) ;
        # ALSO, this program kindly allows hoomans to not bother with zero-based
        # indexing, which means 1 for hoomans is 0 for program, so substracting 1
        # from both values:
        coord = (element[0][1], element[0][0])
        # print('without mod:', coord)
        coord = (element[0][1]-1, element[0][0]-1)
        # print('with mod:', coord)
        coord_queue.append(coord)
        color_values = np.asarray(element[1])       # np.asarray() gets it into same object type as elsewhere done and expected.
        # print('adding color to canvas:', color_values)
        # MINDING the x,y swap AND to modify the hooman 1-based index here, too! :
        canvas[ element[0][1]-1 ][ element[0][0]-1 ] = color_values     # LORF! 

report_stats_every_n = 5000
report_stats_nth_counter = 0

# Render target file name generation; differs in different scenarios:
# If a preset was loaded, base the render target file name on it.
if ARGS.LOAD_PRESET:
    # take trailing .cgp off it:
    render_target_file_base_name = LOAD_PRESET.rstrip('.cgp')
else:
# Otherwise, create render target file name based on time painting began.
    now = datetime.datetime.now()
    time_stamp = now.strftime('%Y_%m_%d__%H_%M_%S__')
    # VESTIGAL CODE; most versions of this script here altered the
    # pseudorandom sequence of --RANDOM_SEED with the following line
    # of code (that makes an rndStr); this had been commented out around
    # v2.3.6 - v2.5.5 (maybe?), which broke with psuedorandom continuity as
    # originally developed in the script. For continuity (and because output
    # seemed randomly better _with_ this code), it is left here; ALSO NOTE:
    # in trying to track down this issue some versions of the script had the
    # following line of code before the above if ARGS.LOAD_PRESET; but now I
    # think it _would_ have been here (also git history isn't complete on
    # versions, I think, so I'm speculating); if you can't duplicate the rnd
    # state of a render, you may want to try copying it up there.
    rndStr = ('%03x' % random.randrange(16**6))
    render_target_file_base_name = time_stamp + '__' + rndStr + '_colorGrowthPy'
# Check if render target file with same name (but .png) extension exists.
# This logic is very slightly risky: if render_target_file_base_name does
# not exist, I will assume that state image file name and anim frames
# folder names also do not exist; if I am wrong, those may get overwritten
# (by other logic in this script).
target_render_file_exists = os.path.exists(render_target_file_base_name + '.png')
# If it does not exist, set render target file name to that ( + '.png').
# In that case, the following following "while" block will never
# execute. BUT if it does exist, the following "while" block _will_
# execute, and do this: rename the render target file name by appending six
# rnd hex chars to it plus 'var', e.g. 'var_32ef5f' to file base name,
# and keep checking and doing that over again until there's no target name
# conflict:
cgp_rename_count = 1
while target_render_file_exists == True:
    # Returns six random lowercase hex characters:
    cgp_rename_count += 1; variantNameStr = str(cgp_rename_count)
    variantNameStr = variantNameStr.zfill(4)
    tst_str = render_target_file_base_name + '__variant_' + variantNameStr
    target_render_file_exists = os.path.exists(tst_str + '.png')
    if cgp_rename_count > 10000:
        print(
"Encountered 10,000 naming collisions making new render target file \
names. Please make a copy of and rename the source .cgp file before \
continuning, Sparkles McSparkly. Exiting."
        )
        sys.exit(1)
    if target_render_file_exists == False:
        render_target_file_base_name = tst_str
render_target_file_name = render_target_file_base_name + '.png'
anim_frames_folder_name = render_target_file_base_name + '_frames'
print('\nrender_target_file_name: ', render_target_file_name)
print('anim_frames_folder_name: ', anim_frames_folder_name)


# If SAVE_EVERY_N has a value greater than zero, create a subfolder to write frames to;
# Also, initialize a variable which is how many zeros to pad animation save frame file
# (numbers) to, based on how many frames will be rendered:
if SAVE_EVERY_N > 0:
    padFileNameNumbersDigitsWidth = len(str(stopRenderAtPixelsN))
    # Only create the anim frames folder if it does not exist:
    if os.path.exists(anim_frames_folder_name) == False:
        os.mkdir(anim_frames_folder_name)

# If bool set saying so, save arguments to this script to a .cgp file with the target
# render base file name:
if SAVE_PRESET:
    # strip the --LOAD_PRESET parameter and value from SCRIPT_ARGS_STR
    # before writing it to preset file (and save it in a new variable),
    # as it would be redundant (and, if the parameters are based on
    # loading another preset and overriding some parameters, it would
    # moreover be wrong) :
    SCRIPT_ARGS_WRITE_STR = re.sub('--LOAD_PRESET [^ ]*', r'', SCRIPT_ARGS_STR)
    file = open(render_target_file_base_name + '.cgp', "w")
    file.write(SCRIPT_ARGS_WRITE_STR + '\n\n')
    if ARGS.LOAD_PRESET:
        file.write('# Derived of preset: ' + LOAD_PRESET + '\n')
    file.write('# Created with color_growth.py ' + ColorGrowthPyVersionString + '\n')
    file.write('# Python version: ' + sys.version + '\n')
    file.write('# Platform: ' + platform.platform() + '\n')
    file.close()

# ----
# START IMAGE MAPPING
painted_coordinates = 0
# With higher VISCOSITY some coordinates can be painted around (by other coordinates on
# all sides) but coordinate mutation never actually moves into that coordinate. The
# result is that some coordinates may never be "born." this set and associated code
# revives orphan coordinates:
potential_orphan_coords_two = set()
# used to reclaim orphan coordinates every N iterations through the
# `while allocd_coords` loop:
base_orphan_reclaim_multiplier = 0.015
orphans_to_reclaim_n = 0
coords_painted_since_reclaim = 0
# These next two variables are used to ramp up orphan coordinate reclamation rate
# as the render proceeds:
print('Generating image . . . ')
newly_painted_coords = 0        # This is reset at every call of print_progress()

continue_painting = True

while coord_queue:
    if continue_painting == False:
        break
    while coord_queue:
        index = np.random.randint(0, len(coord_queue))
        y, x = coord_queue[index]
        if index == len(coord_queue) - 1:
            coord_queue.pop()
        else:
            coord_queue[index] = coord_queue.pop()

        # Mutate color--! and assign it to the color variable (list) in the Coordinate object:
        canvas[y][x] = canvas[y][x] + np.random.randint(-RSHIFT, RSHIFT + 1, size=3) / 2
        # print('Colored coordinate (y, x)', coord)
        new_allocd_coords_color = canvas[y][x] = np.clip(canvas[y][x], 0, 255)
        painted_coordinates += 1
        newly_painted_coords += 1
        coords_painted_since_reclaim += 1
        # The first returned set is used straightway, the second optionally shuffles
        # into the first after the first is depleted:
        rnd_new_coords_set, potential_orphan_coords_one = get_rnd_unallocd_neighbors(y, x, canvas)
        for new_y, new_x in rnd_new_coords_set:
            coord_queue.append((new_y, new_x))
            if BORDER_BLEND and is_coord_in_bounds(2*new_y-y, 2*new_x-x) and is_color_valid(2*new_y-y, 2*new_x-x, canvas):
                canvas[new_y][new_x] = (np.array(new_allocd_coords_color) + np.array(canvas[2*new_y-y][2*new_x-x])) / 2
            else:
                canvas[new_y][new_x] = new_allocd_coords_color
        # Save an animation frame (function only does if SAVE_EVERY_N True):
        save_animation_frame()
        
        # Print progress:
        if report_stats_nth_counter == 0 or report_stats_nth_counter == report_stats_every_n:
            print_progress(newly_painted_coords)
            newly_painted_coords = 0
            report_stats_nth_counter = 0
        report_stats_nth_counter += 1
        
        # Terminate all coordinate and color mutation at an
        # arbitary number of mutations:
        if painted_coordinates > stopRenderAtPixelsN:
            print('Painted coordinate termination count', painted_coordinates, 'exceeded. Ending paint algorithm.')
            continue_painting = False
            break
        
    if RECLAIM_ORPHANS:
        for y in range(0, HEIGHT):
            for x in range(0, WIDTH):
                if not is_color_valid(y, x, canvas):
                    adj_color = find_adjacent_color(y, x, canvas)
                    if adj_color is not None:
                        coord_queue.append((y, x))
                        canvas[y][x] = adj_color + np.random.randint(-RSHIFT, RSHIFT + 1, size=3) / 2
                        canvas[y][x] = np.clip(canvas[y][x], 0, 255)
                        orphans_to_reclaim_n += 1
# END IMAGE MAPPING
# ----

# Works around problem that this setup can (always does?) save
# everything _except_ for a last frame with every coordinate painted
# if painted_coordinates >= stopRenderAtPixelsN and
# STOP_AT_PERCENT == 1; is there a better-engineered way to fix this
# problem? But this works:
if SAVE_EVERY_N != 0:
    set_img_frame_file_name()
    coords_set_to_image(canvas, imageFrameFileName)

# Save final image file:
print('Saving image ', render_target_file_name, ' . . .')
coords_set_to_image(canvas, render_target_file_name)
print('Render complete and image saved.')
# END MAIN FUNCTIONALITY.