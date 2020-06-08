"""Renders a PNG image like bacteria that mutate color as they spread.

An earlier incarnation of this script by earthbound19 was dramatically sped up by changes
from one GitHub user "scribblemaniac" (like many orders of magnitude faster--an image
that used to take 7 minutes to render now takes 5 seconds). I may paste the code from this
script on to that one after testing.

Output file names are based on the date and time and random characters.
Inspired and drastically evolved from color_fibers.py, which was horked and adapted
from https://scipython.com/blog/computer-generated-contemporary-art/

# USAGE
Run this script without any parameters, and it will use a default set of parameters:
python thisScript.py
To see available parameters, run this script with the -h switch:
python thisScript.py -h

# DEPENDENCIES
python 3 with numpy, queue, and pyimage modules installed (and maybe others--see the
import statements).

# KNOWN ISSUES
See help for --RANDOM_SEED.

# TO DO
See comments under documentation heading in this module.

"""

# TO DO:
# - make naming convention of variables consistent? I think I'm
# all over the place with this . . . :p
# - possibly things in the color_growth_v1.py's TO DO list.
# - determine whether any code in the fast fork (now this script)
# are leftover from color_growth_v1.py, and delete them (EXCEPT
# what is commented as VESTIGAL) from this?
# - make it properly use negative or > 8 growth-clip values again?
# since the color_growth_fast.py fork it isn't.

# VERSION HISTORY
# v2.5.8:
# Bug fix: it didn't stop rendering at --STOP_AT_PERCENT if
# --STOP_AT_PERCENT < 1 e.g. 0.59.
# - Continued work (commented out) on new feature to make animation
# growth visually more linear over space (sped up/more painted
# coordinates between saves, so animation doesn't seem to slow
# down toward middle and end)


# CODE
import datetime
import random
import argparse
import ast
import os.path
import sys
import re
import subprocess
import shlex
import queue
# I'm also using another psuedorandom number generator built into numpy as np:
import numpy as np
from PIL import Image


# START GLOBALS
# Defaults which will be overriden if arguments of the same name are provided to the script:
ColorGrowthPyVersionString = 'v2.5.8'
WIDTH = 400
HEIGHT = 200
RSHIFT = 8
STOP_AT_PERCENT = 1
SAVE_EVERY_N = 0
saveNextFrameNumber = 1
START_COORDS_RANGE = (1,13)
GROWTH_CLIP = (0,5)
SAVE_PRESET = True
animationFrameCounter = 0
renderedFrameCounter = 0
imageFrameFileName = ''
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
as they grow over a surface. Output file names are after the date plus \
random characters. Inspired by and drastically evolved from \
colorFibers.py, which was horked and adapted from \
https://scipython.com/blog/computer-generated-contemporary-art/'
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
PARSER.add_argument('--RECLAIM_ORPHANS', type=str, help=
'With higher --VISCOSITY, coordinates can be painted around (by \
coordinate and color mutation of surrounding coordinates) but never \
themselves painted. This option coralls these orphan coordinates and, \
after all other living coordinates evolve (die), revives these orphans. \
If there are orphans after that, it repeats, and so on, until every \
coordinate is painted. Default on. To disable pass --RECLAIM_ORPHANS \
False or --RECLAIM_ORPHANS 0.'
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
' by default. To disable, set it to 0 with: -a 0 OR: --SAVE_EVERY_N 0'
)
PARSER.add_argument('-s', '--RANDOM_SEED', type=int, help=
'Seed for random number generators (random and numpy.random are used). \
Default generated by random library itself and added to render file name \
for reference. Can be any integer in the range 0 to 4294967296 (2^32). \
If not provided, it will be randomly chosen from that range (meta!). If \
--SAVE_PRESET is used, the chosen seed will be saved with the preset \
.cgp file. KNOWN ISSUE at this writing: evidently functional differences \
between random generators of different versions of Python and/or Python \
on different platforms produce different output from the same random \
seed. ALSO, before v2.5.5, this script had code that accidentally \
altered the pseudorandom number sequence for something other than the \
color growth algorithm. If you get different output than before from the \
same --RANDOM_SEED, search for and examine the VESTIGAL CODE comment, \
and try uncommenting the line of code it details.'
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
PARSER.add_argument('--GROWTH_CLIP', type=str, help=
'Affects seeming "thickness" (or viscosity) of the liquid. A Python \
tuple expressed as a string (must be surrounded by double quote marks \
for Windows). Default ' + str(GROWTH_CLIP) + '. In growth into adjacent \
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
stringy/meandering/splatty path or form\ (as it spreads less uniformly). \
With an effectively more viscous clip like "(2,4)", smaller \
streamy/flood things may traverse a distance faster. Some tuples make \
--RECLAIM_ORPHANS quickly fail, some make it virtually never fail.'
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
frames using just a preset. NOTES: --START_COORDS_RANGE and its \
accompanying value are not saved to config files, and the resultantly \
generated [-q | --START_COORDS_N] is saved instead. Note: you may add \
arbitrary text (such as notes) to the second and subsequent lines of a \
saved preset, as only the first line is used.'
)
PARSER.add_argument('--LOAD_PRESET', type=str, help=
'A preset file (as first created by --SAVE_PRESET) to use. Empty (none \
used) by default. Not saved to any preset. At this writing only a single \
file name is handled, not a path, and it is assumed the file is in the \
current directory. NOTE: use of this switch discards all other \
parameters and loads all parameters from the preset. A .cgp preset file \
is a plain text file on one line, which is a collection of SWITCHES to \
be passed to this script, written literally the way you would pass them \
to this script.'
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
print('~-')
print('~- Processing any arguments to script . . .')

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
    # DEPRECATED: invoke a new call of this script with those .cgp parameters:
    # subprocess.call(shlex.split('python ' + repr(sys.argv[0]) + ' ' + SWITCHES))
    # sys.argv[0] is the path to this script.
    # repr() found at: http://code.activestate.com/recipes/65211-convert-a-string-into-a-raw-string/#c5
    # repr() fixes some problem with shlex.split string handling of Windows paths.
    # print('Subprocess hopefully completed successfully. Will now exit script.')
    # sys.exit()
    # INSTEAD, AS CODED BEFORE THAT DEPRECATION NOTICE:
    # those parameters add anything not passed via CLI, but also, CLI overrides
    # anything from .cgp.

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

if ARGS.COLOR_MUTATION_BASE:        # See comments in ARGS.BG_COLOR handling. Handled the same.
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
if ARGS.START_COORDS_N:        # If --START_COORDS_N is provided by the user, use it..
    START_COORDS_N = ARGS.START_COORDS_N
    print('Will use the provided --START_COORDS_N, ', START_COORDS_N)
    if ARGS.START_COORDS_RANGE:
        # .. and delete any --START_COORDS_RANGE and its value from argsparse (as it will
        # not be used and would best not be stored in the .cgp config file via --SAVE_PRESET:
        argsDict.pop('START_COORDS_RANGE', None)
        print(
'** NOTE: ** You provided both [-q | --START_COORDS_N] and --START_COORDS_RANGE, \
but the former overrides the latter (the latter will not be used). This program \
disregards  the latter from the parameters list.'
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

if ARGS.GROWTH_CLIP:        # See comments in ARGS.BG_COLOR handling. Handled the same.
    GROWTH_CLIP = ARGS.GROWTH_CLIP
    GROWTH_CLIP = re.sub(' ', '', GROWTH_CLIP)
    argsDict['GROWTH_CLIP'] = GROWTH_CLIP
    GROWTH_CLIP = ast.literal_eval(GROWTH_CLIP)
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
# CONTINUE CODING HERE for feature I'm adding . . .
#allPixelsNdividedBy_SAVE_EVERY_N = allPixelsN / SAVE_EVERY_N
#divisor = 1 / allPixelsNdividedBy_SAVE_EVERY_N
#saveFramesAtCoordsPaintedMultipliersTuple = tuple(np.arange(0, 1, divisor))
#saveFramesAtCoordsPaintedArray = []
#for multiplier in saveFramesAtCoordsPaintedMultipliersTuple:
#    mod_w = WIDTH * multiplier
#    mod_h = HEIGHT * multiplier
#    mod_area = mod_w * mod_h
#    saveFramesAtCoordsPaintedArray.append(int(mod_area))
# deduplicate elements in the list but maintain order:
#from more_itertools import unique_everseen
#saveFramesAtCoordsPaintedArray = list(unique_everseen(saveFramesAtCoordsPaintedArray))
# else the list starts with 0, which will lead to no frames ever rendering:
#saveFramesAtCoordsPaintedArray.remove(0)
# Because the range doesn't include the stop render count:
#saveFramesAtCoordsPaintedArray.append(stopRenderAtPixelsN)
#lengthOfList = len(saveFramesAtCoordsPaintedArray)
#print(allPixelsN, ' >? ', stopRenderAtPixelsN, ' >? ', saveFramesAtCoordsPaintedArray[lengthOfList-1])

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
        # START VISCOSITY CONTROL.
        # Decide how many to pick:
        n_neighbors_to_ret = np.clip(np.random.randint(GROWTH_CLIP[0], GROWTH_CLIP[1] + 1), 0, len(unallocd_neighbors))
        # END VISCOSITY CONTROL.
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
    global renderedFrameCounter
    global imageFrameFileName
    renderedFrameCounter += 1
    frameNumberStr = str(renderedFrameCounter)
    imageFrameFileName = anim_frames_folder_name + '/' + frameNumberStr.zfill(pad_file_name_numbers_n) + '.png'

def save_animation_frame():
    # Tells the function we are using global variables:
    global animationFrameCounter
    global saveNextFrameNumber
    animationFrameCounter += 1
    if SAVE_EVERY_N:
        # DEPRECATED conditional, as I assume division is slower, and modulo even slower:
        # if (animationFrameCounter % SAVE_EVERY_N) == 0:
        if (animationFrameCounter == saveNextFrameNumber):
            saveNextFrameNumber = animationFrameCounter + SAVE_EVERY_N
            set_img_frame_file_name()
            # Only write frame if it does not already exist
            # (allows resume of suspended / crashed renders) :
            if os.path.exists(imageFrameFileName) == False:
                # print("Animation render frame file does not exist; writing frame.")
                coords_set_to_image(canvas, imageFrameFileName)
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

# Initialize allocd_coords set by random selection from unallocd_coords (and remove
# from unallocd_coords):
# for i in range(0, START_COORDS_N):
# TO DO: check if things here and here would be faster for getting a random sample:
# https://medium.freecodecamp.org/how-to-get-embarrassingly-fast-random-subset-sampling-with-python-da9b27d494d9
# https://stackoverflow.com/a/15993515/1397555
RNDcoord = random.sample(unallocd_coords, START_COORDS_N)
for coord in RNDcoord:
    coord_queue.append(coord)
    if COLOR_MUTATION_BASE == "random":
        canvas[coord[0]][coord[1]] = np.random.randint(0, 255, 3)
    else:
        canvas[coord[0]][coord[1]] = COLOR_MUTATION_BASE

report_stats_every_n = 5000
report_stats_nth_counter = 0

# VESTIGAL CODE; all versions of this script before v2.5.5 here
# altered the pseudorandom sequence of --RANDOM_SEED with the 
# following line of code; this has been left here uncommented  
# since (and a bit before?) v2.3.6, preferring psuedorandom
# continuity with how the script had already made art, even
# though technically this altered "pure" psuedorandom intent:
rndStr = ('%03x' % random.randrange(16**6))
#
# Render target file name generation; differs in different scenarios:
# If a preset was loaded, base the render target file name on it.
if ARGS.LOAD_PRESET:
    # take trailing .cgp off it:
    render_target_file_base_name = LOAD_PRESET.rstrip('.cgp')
else:
# Otherwise, create render target file name based on time painting began.
    now = datetime.datetime.now()
    time_stamp = now.strftime('%Y_%m_%d__%H_%M_%S__')
    render_target_file_base_name = time_stamp + '_colorGrowthPy'
# Check if render target file with same name (but .png) extension exists.
    # This logic is very slightly risky: if
    # render_target_file_base_name does not exist, I will
    # assume that state image file name and anim frames folder names
    # also do not exist; if I am wrong, those may get overwritten (by
    # other logic in this script).
target_render_file_exists = os.path.exists(render_target_file_base_name + '.png')
print('\nState of target_render_file_exists: ', target_render_file_exists, '\nIf you see that as True a lot, something may be wrong.')
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
        sys.exit()
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
    pad_file_name_numbers_n = len(str(stopRenderAtPixelsN))
    # Only create the anim frames folder if it does not exist:
    if os.path.exists(anim_frames_folder_name) == False:
        os.mkdir(anim_frames_folder_name)

# If bool set saying so, save arguments to this script to a .cgp file with the target
# render base file name:
import platform
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
# if painted_coordinates >= stopRenderAtPixelsN &&
# STOP_AT_PERCENT == 1; is there a better-engineered way to fix this
# problem? But this works:
set_img_frame_file_name()
coords_set_to_image(canvas, imageFrameFileName)
# Save final image file and delete progress (state, temp) image file:
print('Saving image ', render_target_file_name, ' . . .')
coords_set_to_image(canvas, render_target_file_name)
print('Render complete and image saved.')
# END MAIN FUNCTIONALITY.