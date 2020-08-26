# DESCRIPTION
# Loads an arbitrary image file (sys.argv[1]) and gets random pixel coordinates with pixel colors, and constructs a parameter switch name and string of them (and other needed switches and their values) to pass to color_growth.py. (using --CUSTOM_COORDS_AND_COLORS) Prints this to stdout. May be captured by other scripts to be further used (e.g. to actually pass to color_growth.py).

# USAGE
# I recommend that you call this from the script `call_get_rnd_CCC_for_color_growth-py.sh` (SEE). Run this script through a Python interpreter, with these positional parameters:
# - argv[1] the path to an image to load (python sees this parameter at sys.argv[1])
# - argv[2] how many random coordinates with their colors to grab from it (sys.argv[2])
# Example run:
#    python /path/to_this_script/get_rnd_CCC_for_color_growth.py inputImageFileName.png
# Results are printed to stdout, and may be captured e.g. by bash and passed to color_growth.py this way; the following assumes that this script and getFullPathToFile.sh are both in your PATH:
#
#    pathToScript=$(getFullPathToFile.sh get_img_RND_CCC_for_color_growth.py | sed 's/get_img_RND_CCC_for_color_growth: \(.*\)/\1/g')
#
#    var_CUSTOM_COORDS_AND_COLORS=$(python $pathToScript inputImageFileName.png)


# CODE
# TO DO
# - Parameterize including N (4) in random.sample(coordinate_set, 4) . . .

# DEVELOPER NOTES
# setting environment var in calling environment is too difficult or impossible.
# re: https://stackoverflow.com/questions/49201028/set-environment-variable-of-calling-bash-script-in-python
# re: https://stackoverflow.com/a/50010276/1397555
    # TRIED and discarded: https://stackoverflow.com/a/55081908/1397555
    # (discarded because imageio's interface is simpler and also works with numpy)
import imageio
import random
import numpy as np
import sys
import re

# check for CLI parameter/argument 1 and warn and exit if nonexistent.
try:
    inputFile = str(sys.argv[1])
except:
    print('No positional parameter 1 (input image file name) passed. Exit.')
    sys.exit(1)
# ~ for argument 2.
try:
    numRNDcoordsToGet = int(sys.argv[2])
except:
    print('No positional parameter 2 (how many random coordinates/colors to get) passed. Exit.')
    sys.exit(1)

# To figure out the following additional "format=None, pilmode='RGB'" parameter changes, to prevent it from returning RGBA values (which include alpha values I don't use or expect--they caused an error) (and where mysteriously previous runs of this script with the same code had not), I dug around here: https://imageio.readthedocs.io/en/stable/userapi.html#imageio.imread, and somehow I figured out how to print help for an image format. It _seems_ that it can transform anything on the fly (on read) to RGB? Printing help like this: imageio.help(name='BMP') helped figure it out; this next line of code previously was just image = imageio.imread(inputFile) :
image = imageio.imread(inputFile, format=None, pilmode='RGB')
imageWidth = len(image[0])
imageHeight = len(image)
# create set of unique rnd coords from that area:
rnd_coordinates = set()
for i in range(0, numRNDcoordsToGet):
    # randint is inclusive (both low and high number can be), AND
    # prog expects 1-based index vals, not zero!
    xVal = random.randint(0,imageWidth -1)
    yVal = random.randint(0,imageHeight -1)
    # tuple structure needs to be the ever-throws-me y,x! :
    rnd_coordinates.add((yVal,xVal))
# format to string in form of parameter expected by color_growth.py
# --CUSTOM_COORDS_AND_COLORS, e.g. [[(50,40),[255,0,255]],[(88,84),[0,255,255]]] :
paramString=''
for element in rnd_coordinates:
    # print('x coord', element[0], 'y coord', element[1], image[ element[0] ][ element[1] ])
    # build tuple vals part of param. string, MINDING the y,x madness:
    tupleValsSTR = '(' + str(element[1]) + ',' + str(element[0]) + '),'
    # print('tupleValsSTR', tupleValsSTR)
    # build RGB vals part of param string:
    RGBvalsParamSTR = str(image[ element[0] ][ element[1] ])
    # reduce all double-spaces in string to single:
    RGBvalsParamSTR = re.sub('  *', ' ', RGBvalsParamSTR)
    # other cleanup:
    RGBvalsParamSTR = re.sub('\[ ', '[', RGBvalsParamSTR)
    RGBvalsParamSTR = re.sub(' \]', ']', RGBvalsParamSTR)
    # repl. spaces with commas:
    RGBvalsParamSTR = re.sub(' ', ',', RGBvalsParamSTR)
    # join those in str to add to larger str enclosed in list []:
    paramStringPart = '[' + tupleValsSTR + RGBvalsParamSTR + ']'
    # join that to larger paramString with ',' between list items (final ','
    # will need removal) :
    paramString += paramStringPart + ','
    # , image[ element[0] ][ element[1] ]

# remove trailing ',' from paramString:
paramString = re.sub(',$', '', paramString)
# enclose the whole thing in yet another [] (make it list of list of yada yada),
# with other switches and values that will be needed:
paramString = '--WIDTH ' + str(imageWidth) + ' --HEIGHT ' + str(imageHeight) + ' --CUSTOM_COORDS_AND_COLORS [' + paramString + ']'
print(paramString)