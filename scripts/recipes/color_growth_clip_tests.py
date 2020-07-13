# DESCRIPTION
# Tests all possible --GROWTH_CLIP rates of color_growth.py, by invoking it repeatedly, saving .cgp presets for each of the same.

# USAGE
#  python /path/to/this/script/color_growth_clip_tests.py
# NOTE
# - This assumes that color_growth.py is in your PATH, and searches for it (which can cause a delay at the start). If you're in a hurry, hard-code the pathToColorGrowthPy variable to the correct path, and comment out the path search code.


# CODE
import itertools
import subprocess
import shlex
import numpy as np
import re
import datetime

# WOA WUT??!
# FIND color_growth.py, assuming it is anywhere in the system or user PATH:
print ('Searching for color_growth.py in PATH . . .')
import os
import sys
# FOR A HORROR SHOW:
# print(os.environ)
# OR:
# for item, value in os.environ.items():
    # print('{}: {}'.format(item, value))
pathToColorGrowthPy=''
pathList = os.environ['PATH'].split(';')
for element in pathList:
    # print('searching ', element)
    # re https://stackoverflow.com/questions/1724693/find-a-file-in-python
    for root, dirs, files in os.walk(element):
        # print(files)
        if 'color_growth.py' in files:
            pathToColorGrowthPy = os.path.join(root, 'color_growth.py')

if pathToColorGrowthPy != '':
    print('FOUND at ', pathToColorGrowthPy)
else:
    print('I cannae find it! Exit.')
    sys.exit()
# END WOA WUT??!

# build set of tuples we want to pass to the --GROWTH_CLIP switch of color_growth.py; ALAS that at this writing it no longer accepts negative values, so a prior used set is commented out on the next line, and the actual usable one is uncommented:
# original_set = {-11,-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10,11}
original_set = {0,1,2,3,4,5,6,7,8,9,10,11}
original_tuples = itertools.permutations(original_set, 2)
clip_tuples = set()
for element in original_tuples:
    if element[0] < element[1] and element[1] > 0:
        clip_tuples.add(element)

# Invoke color_growth.py so many times with those tuples, and random colors, saving datetime and tuple-named .cgp presets and loading for each invocation:
for element in clip_tuples:
    rgb_color_triplet = np.random.randint(0, 255 + 1, size=3)
    foreground_color = list(rgb_color_triplet)
    # Inverts the color;
    #  subtracts all the elements of the numpy array from 255,
    #  returns that as a numpy array and converts it to a list:
    background_color = list(255 - rgb_color_triplet)
    background_color = re.sub(' ', '', str(background_color))
    foreground_color = re.sub(' ', '', str(foreground_color))
    now = datetime.datetime.now()
    time_stamp = now.strftime('%Y_%m_%d__%H_%M_%S__')
    growth_clip_file_name_str = time_stamp + 'growth_clip_' + str(element[0]) + '_' + str(element[1]) + '.cgp'
    preset_string = '--WIDTH 520 --HEIGHT 240 -q 1 -a 1 -b ' + background_color + ' -c ' + foreground_color + ' --RSHIFT 12 --SAVE_EVERY_N 0 --GROWTH_CLIP ' + str(element)
    file = open(growth_clip_file_name_str, "w")
    file.write(preset_string + '\n\n')
    file.close()
    command_string = 'python "' + pathToColorGrowthPy + '" --LOAD_PRESET ' + growth_clip_file_name_str
    print('Invoking command via subprocess: ', command_string)
    subprocess.call(shlex.split(command_string))
    print('Subprocess completed.')